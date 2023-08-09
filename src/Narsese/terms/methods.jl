#=
集中存储有关词项的各类方法
=#
#= 📝Julia: 关于「包含结构体的集合」判等不稳定的问题
    1. 符号「==」和函数「isequal」相似而不相同
        - 并且，这两者对结构体都可能隐含着「hash(a) == hash(b)」即哈希相等
        - 「issetequal」对此也无济于事
    2. 哈希路径：Julia中Set的背后是KeySet，而KeySet背后是Dict
        - Dict的「无序性」是使用哈希存储的
        - 📌【20230803 17:35:29】目前还没有一个方便的「将数组内所有元素都hash到一块」的方法
    3. 兜底路径 强制apply「==」判断「集合是否相等」的方法：对两个集合S1、S2，有
        1. 个数相等：length(S1) == length(S2)
        2. 任意配对：∀x∈S1，∃y∈S2，使得x=y
=#

# 长度
begin "长度：用于「判断所直接含有的原子数量」"
    
    "原子の长度=1"
    Base.length(a::Atom)::Integer = 1

    "复合词项の长度=其元素的数量(像占位符不含在内)"
    Base.length(c::Compound)::Integer = length(c.terms)

end

# # 散列/哈希 # 弃用：见上文笔记
# begin "散列/哈希: 应用于集合操作中，使得集合用于判断相等"
    
#     # "原子の哈希=其名"
#     # Base.hash(a::Atom, h) = Base.hash(Base.hash(a.name, h), Base.hash(:NarseseAtom, h))
    
#     # "复合词项の哈希"
#     # Base.hash(c::Compound, h) = 

# end

# 判断相等 #
begin "判断相等"

    "核心判等逻辑：使用多分派特性统一判断复合词项中的成分"
    _collection_equal(v1::Vector, v2::Vector)::Bool = (v1 .== v2) |> all
    _collection_equal(v1::Tuple, v2::Tuple)::Bool = (v1 .== v2) |> all
    _collection_equal(::Vector, ::Set)::Bool = false
    _collection_equal(::Set, ::Vector)::Bool = false
    _collection_equal(::Vector, ::Tuple)::Bool = false
    _collection_equal(::Set, ::Tuple)::Bool = false
    """
    ✨对两个集合的判等逻辑
    - 📌对「嵌套集合」的判等很显吃力
        - 【20230803 16:43:32】在元素为非基础类型时，可能会因「隐含顺序」误判不等
        - 【20230803 17:41:31】现使用「∀x∈S1，∃y∈S2，使得x=y」的方式兜底
    - 参考资料
        - https://discourse.julialang.org/t/struct-equality-seems-weird-inside-sets/51283
        - https://discourse.julialang.org/t/why-isnt-isequal-x-y-hash-x-hash-y/8300
    """
    function _collection_equal(s1::Set, s2::Set)::Bool
        return s1 == s2 || issetequal(s1, s2) || ( # 若自带方法无法处理，则使用数理逻辑方法
            length(s1) == length(s2) && # 长度相等
            all(
                any(t1 == t2 for t2 in s2) # 递归判断所有元素(还有「排除法」的优化空间)
                for t1 in s1
            )
        )
    end

    "兜底判等逻辑"
    Base.isequal(t1::Term, t2::Term) = (
        typeof(t1) == typeof(t2) && ( # 同类型
            isequal(getproperty(t1, propertyname), getproperty(t2, propertyname)) # 所有属性相等
            for propertyname in t1 |> propertynames # 使用t1的，在同类型的前提下
        ) |> all
    )
    "重定向「==」符号"
    Base.:(==)(t1::Term, t2::Term) = Base.isequal(t1, t2)

    "原子词项相等"
    Base.isequal(t1::AbstractAtom, t2::AbstractAtom)::Bool = (
        typeof(t1) == typeof(t2) && # 类型相等
        t1.name == t2.name # 名称相等
    )

    """
    抽象词项集相等 = 类型&各组分 相等
    - 词项集
    - 词项逻辑集
    - 乘积
    """
    function Base.isequal(t1::AbstractTermSet, t2::AbstractTermSet)::Bool
        # @show typeof(t1) typeof(t2)
        # @show (t1.terms .== t2.terms)
        typeof(t1) == typeof(t2) && # 类型相等
        _collection_equal(t1.terms, t2.terms) # 自行判断相等
    end

    """
    特殊重载：像相等
    - 类型相等
    - 占位符位置相等
    - 所有元素相等
    """
    function Base.isequal(t1::TermImage{EIT1}, t2::TermImage{EIT2})::Bool where {EIT1, EIT2}
        EIT1 == EIT2 && # 类型相等（外延像/内涵像）
        t1.relation_index == t2.relation_index &&  # 占位符位置相等
        _collection_equal(t1.terms, t2.terms) # 所有元素相等
    end

    "陈述相等"
    function Base.isequal(s1::Statement{T1}, s2::Statement{T2})::Bool where {T1, T2}
        T1 == T2 && # 类型相等
        s1.ϕ1 == s2.ϕ1 &&
        s1.ϕ2 == s2.ϕ2
    end

    """
    抽象陈述集相等：类型&各陈述 相等
    """
    function Base.isequal(s1::AStatementSet, s2::AStatementSet)::Bool
        typeof(s1) == typeof(s2) && # 类型相等
        _collection_equal(s1.terms, s2.terms) # 比对词项集合
    end
end

# 收集(`Base.collect`): 收集其中包含的所有（原子）词项 #
begin "收集其中包含的所有（原子）词项，并返回向量"

    "原子词项のcollect：只有它自己"
    Base.collect(aa::AbstractAtom) = Term[aa]

    """
    抽象词项集/抽象陈述集のcollect：获取terms参数
    - 词项集
    - 词项逻辑集
    - 像
    - 乘积
    - 陈述逻辑集
    - 陈述时序集
    
    ⚠不会拷贝
    """
    Base.collect(s::Union{TermSet,AbstractStatementSet}) = [
        (
            (s.terms .|> collect)...
        )... # 📌二次展开：📌二次展开：第一次展开成「向量の向量」，第二次展开成「词项の向量」
    ]

    """
    陈述のcollect：获取两项中的所有词项
    - 不会拷贝
    """
    Base.collect(s::Statement) = Term[
        collect(s.ϕ1)..., 
        collect(s.ϕ2)...,
    ]

end

# 时态
begin "时态：用于获取「时序蕴含/等价」中的「时态信息」"
    
    """
    获取「时序蕴含/等价」陈述中的时态
    - 格式：`get(陈述, Tense)`
    - 默认值：对其它语句返回「Eternal」
    - ⚠和语句的时态可能不一致「参见OpenNARS」
    """
    function Base.get(::Statement{ST}, ::Type{Tense}) where {ST <: AbstractStatementType}
        if ST <: TemporalStatementTypes # 若其为「有时态系词」
            return ST.parameters[1] # 获取ST{T <: Tense}的第一个类型参数，直接作为返回值
        end
        return Eternal
    end
end

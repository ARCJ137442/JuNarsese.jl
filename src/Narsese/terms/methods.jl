#=
集中存储有关词项的各类方法
=#

# 判断相等 #
begin "判断相等"

    "兜底判等逻辑"
    Base.:(==)(t1::AbstractTerm, t2::AbstractTerm) = (
        typeof(t1) == typeof(t2) && ( # 同类型
            getproperty(t1, propertyname) == getproperty(t2, propertyname) # 所有属性相等
            for propertyname in t1 |> propertynames # 使用t1的，在同类型的前提下
        ) |> all
    )

    "原子词项相等"
    Base.:(==)(t1::AbstractAtom, t2::AbstractAtom)::Bool = (
        typeof(t1) == typeof(t2) && # 类型相等
        t1.name == t2.name # 名称相等
    )

    """
    抽象词项集相等 = 类型&各组分 相等
    - 词项集
    - 词项逻辑集
    - 乘积
    """
    function Base.:(==)(t1::AbstractTermSet, t2::AbstractTermSet)::Bool
        # @show typeof(t1) typeof(t2)
        # @show (t1.terms .== t2.terms)
        typeof(t1) == typeof(t2) && # 类型相等
        t1.terms == t2.terms # 自行判断相等
    end

    """
    特殊重载：像相等
    - 类型相等
    - 占位符位置相等
    - 所有元素相等
    """
    function Base.:(==)(t1::TermImage{EIT1}, t2::TermImage{EIT2})::Bool where {EIT1, EIT2}
        EIT1 == EIT2 && # 类型相等（外延像/内涵像）
        t1.relation_index == t2.relation_index &&  # 占位符位置相等
        (t1.terms .== t2.terms) |> all # 所有元素相等
    end

    "陈述相等"
    function Base.:(==)(s1::Statement{T1}, s2::Statement{T2})::Bool where {T1, T2}
        T1 == T2 && # 类型相等
        s1.ϕ1 == s2.ϕ1 &&
        s1.ϕ2 == s2.ϕ2
    end

    """
    抽象陈述集相等：类型&各陈述 相等
    """
    function Base.:(==)(s1::AbstractStatementSet, s2::AbstractStatementSet)::Bool
        typeof(s1) == typeof(s2) && # 类型相等
        s1.terms == s2.terms # 集合相等⇒所有对象值相等（不存在「引用问题」「顺序问题」）
    end

    "特殊重载：陈述逻辑集相等（参数类型&词项集 相等）"
    function Base.:(==)(s1::StatementLogicalSet{O1}, s2::StatementLogicalSet{O2})::Bool where {O1, O2}
        O1 == O2 && # 参数类型相等
        s1.terms == s2.terms # 对集合无需比较「逐一相等」，无需「.==」强制按顺序判断
    end
end

# 收集(`Base.collect`): 收集其中包含的所有（原子）词项 #
begin "收集其中包含的所有（原子）词项，并返回向量"

    "原子词项のcollect：只有它自己"
    Base.collect(aa::AbstractAtom) = AbstractTerm[aa]

    """
    抽象词项集/抽象陈述集のcollect：获取terms参数
    - 词项集
    - 词项逻辑集
    - 像
    - 乘积
    
    ⚠不会拷贝
    """
    Base.collect(s::Union{AbstractTermSet,AbstractStatementSet}) = [
        (
            (s.terms .|> collect)...
        )... # 📌二次展开：📌二次展开：第一次展开成「向量の向量」，第二次展开成「词项の向量」
    ]

    """
    陈述のcollect：获取两项中的所有词项
    - 不会拷贝
    """
    Base.collect(s::Statement) = AbstractTerm[
        collect(s.ϕ1)..., 
        collect(s.ϕ2)...,
    ]

end

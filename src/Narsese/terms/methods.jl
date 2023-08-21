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

#= 📝Julia: 性能提升方面`@inline``@code_XXXX`宏的使用
    1. 在Julia中，@inline宏用于提示编译器将函数内联展开。内联展开可以提高函数的执行效率，尤其是对于短小的函数
        1. 通过在函数前添加@inline宏，编译器会尝试将该函数的调用点替换为函数的实际代码，从而避免了函数调用的开销
        2. 请注意，@inline宏只是给编译器一个提示，指示它应该进行内联，但最终是否内联还取决于编译器的决策
        3. 通常，只有简短的、被频繁调用的函数才适合内联展开。这是因为内联会增加编译时间和可执行文件的大小，因此不适合用于复杂且少调用的函数
    2. 可以使用`@code_XXXX`系列宏，直观看到Julia代码编译成下层语言的逻辑代码
        1. 并进一步预测代码的可能效率
=#

# # 散列/哈希 # 弃用：见上文笔记
# begin "散列/哈希: 应用于集合操作中，使得集合用于判断相等"
    
#     # "原子の哈希=其名"
#     # Base.hash(a::Atom, h) = Base.hash(Base.hash(a.name, h), Base.hash(:NarseseAtom, h))
    
#     # "复合词项の哈希"
#     # Base.hash(c::Compound, h) = 

# end

# NAL信息支持
begin "NAL信息支持"
    
    export get_syntactic_complexity, get_syntactic_simplicity
    export is_commutative, is_repeatable

    """
    [NAL-3]获取词项的「语法复杂度」
    - 用于获取词项在语法上的复杂程度
        - 一般包含「所引用（实体原子）的多少」
    
    参考：《NAL》定义7.2
    > Each term in NAL has a syntactic complexity. 
    > The syntactic complexity of an atomic term (i.e., word) is 1. 
    > The syntactic complexity of a compound term is 1 plus the sum of the syntactic complexity of its components.
    
    机翻：
    > NAL中的每个词项都有一个语法复杂度。
    > 原子词项(例如「词语」)的语法复杂度为1。
    > 复合词项的句法复杂度等于1加上其组成部分的句法复杂度之和。

    ↓默认：未定义→报错
    - 等价于：虚方法/抽象方法
    - 需要被子类实现
    """
    @inline get_syntactic_complexity(::Term) = error("未定义的计算！")

    """
    （默认）原子の复杂度 = 1

    参见 `get_syntactic_complexity(::Term)`的引用
    > 原子词项(例如「词语」)的语法复杂度为1。

    """
    @inline get_syntactic_complexity(::Atom) = 1
    
    """
    变量の复杂度 = 0

    来源：OpenNARS `Variable.java`
    > The syntactic complexity of a variable is 0, because it does not refer to any concept.
    
    机翻：
    > 变量的语法复杂度为0，因为它不引用任何概念。
    """
    @inline get_syntactic_complexity(::Variable) = 0

    """
    复合词项の复杂度 = 1 + ∑组分の复杂度

    参见 `get_syntactic_complexity(::Term)`的引用
    > 复合词项的句法复杂度等于1加上其组成部分的句法复杂度之和。

    协议：所有复合词项都支持`terms`属性
    """
    get_syntactic_complexity(c::ACompound) = 1 + sum(
        get_syntactic_complexity, # 每一个的复杂度
        c.terms # 遍历每一个组分
    )

    """
    陈述の复杂度 = 1 + 主词复杂度 + 谓词复杂度
    - 特立于复合词项

    因：陈述无`terms`属性，不满足复合词项的协议

    协议：所有「陈述」都有`ϕ1`与`ϕ2`属性
    """
    get_syntactic_complexity(s::AStatement) = 1 + get_syntactic_complexity(s.ϕ1) + get_syntactic_complexity(s.ϕ2)

    """
    [NAL-3]获取词项的「语法简易度」
    
    参考：《NAL》定义7.11
    > If the syntactic complexity of a term is n, then its syntactic simplicity is s = 1/nʳ, where r > 0 is a system parameter.
    > Since n ≥ 1, s is in (0, 1]. 
    > Atomic terms have the highest simplicity, 1.0.
    
    机翻：
    > 如果某一词项的语法复杂度为n，则其语法简易度为s = 1/nʳ，其中r > 0为系统参数。
    > 由于n≥1，s在(0,1]中。【译者注：n ≥ 1 ⇒ 0 < s ≤ 1】
    > 原子词项的简易度最高，为1.0。

    【20230811 12:10:34】留存r以开放给后续调用
    """
    @inline get_syntactic_simplicity(t::Term, r::Number) = 1 / get_syntactic_complexity(t)^r

    """
    「是否可交换」亦即「无序组分」
    
    方法范围：
    - 词项类型
    - 陈述类型
    - 词项→词项类型
    - 陈述→陈述类型

    应用于：
    - 词项判等 `isequal`

    📌返回值一般是不会变的常量，适合内联

    默认：有序
    - 返回`false`

    【20230815 15:59:50】参考自OpenNARS Equivalence.java
    """
    @inline is_commutative(::Type{<:Term})::Bool = false
    "所有陈述类型 默认 = false"
    @inline is_commutative(::Type{<:AStatementType}) = false
    "各个「复合词项类型」的可交换性：默认 = false"
    @inline is_commutative(::Type{<:ACompoundType})::Bool = false

    "词项→重定向到其Type类型" # 使用参数类型取代typeof
    @inline (is_commutative(::T)::Bool) where {T <: Term} = is_commutative(T)
    "Type@陈述→重定向到其陈述类型" # 使用参数类型取代typeof
    @inline (is_commutative(::Type{<:Statement{T}})::Bool) where {T <: AStatementType} = is_commutative(T)
    "Type@复合词项→重定向到「符合词项类型」"
    @inline (is_commutative(::Type{<:ACompound{T}})::Bool) where {T <: ACompoundType} = is_commutative(T)

    "相似&等价 = true"
    @inline is_commutative(::Type{STSimilarity})::Bool = true
    @inline is_commutative(::Type{<:StatementTypeEquivalence})::Bool = true # 注意时态

    "外延集&内涵集 = true"
    @inline is_commutative(::Type{<:CTTermSet})::Bool = true
    "外延交&内涵交/外延并&内涵并 = true" # 解决方案：括弧。issue链接：https://github.com/JuliaLang/julia/issues/21847
    @inline (is_commutative(::Type{<:CTTermLogicalSet{EI, LO}})::Bool) where {EI <: AbstractEI, LO <: Union{And, Or}} = true
    "陈述逻辑集 = true" # 对只有一个组分的「否定」而言，使用「一元元组」更有利于性能
    @inline is_commutative(::Type{<:CTStatementLogicalSet})::Bool = true
    "序列合取 = false"
    @inline is_commutative(::Type{<:CTStatementTemporalSet{Sequential}})::Bool = false
    "平行合取 = true"
    @inline is_commutative(::Type{<:CTStatementTemporalSet{Parallel}})::Bool = true

    """
    「是否可重复」
    - 是否允许复合词项的组分中有重复（在`Base.isequal`意义下）的词项
    
    方法范围：
    - 词项类型
    - 词项→词项类型

    应用于：
    - 词项构建（在构造方法中自动删除重复的元素）
    - （TODO）合法性检查

    📌一般是不会变的常量，适合内联

    默认：可重复
    - 返回`true`

    【20230819 15:33:28】一般情况下，「可交换」通常意味着「不可重复」，反之亦然
    """
    @inline is_repeatable(::Type{<:Term})::Bool = true
    "各个「复合词项类型」的可重复性：默认为true"
    @inline is_repeatable(::Type{<:ACompoundType})::Bool = true

    "词项→重定向到其类型" # 使用参数类型取代typeof
    @inline (is_repeatable(::T)::Bool) where {T <: Term} = is_repeatable(T)
    "Type@复合词项→重定向到「符合词项类型」"
    @inline (is_repeatable(::Type{<:CommonCompound{T}})::Bool) where {T <: ACompoundType} = is_repeatable(T)

    "外延集&内涵集 = false"
    @inline is_repeatable(::Type{<:CTTermSet})::Bool = false
    "词项逻辑集 = false" # 解决方案：括弧。issue链接：https://github.com/JuliaLang/julia/issues/21847
    @inline is_repeatable(::Type{<:CTTermLogicalSet})::Bool = false
    "陈述逻辑集 = false" # 对只有一个组分的「否定」而言，使用「一元元组」更有利于性能
    @inline is_repeatable(::Type{<:CTStatementLogicalSet})::Bool = false
    "序列合取 = true"
    @inline is_repeatable(::Type{<:CTStatementTemporalSet{Sequential}})::Bool = true
    "平行合取 = false"
    @inline is_repeatable(::Type{<:CTStatementTemporalSet{Parallel}})::Bool = false
    
end

begin "检查合法性（API接口，用于后续NAL识别）"

    export check_valid, check_valid_external, check_valid_explainable, check_valid_external_explainable

    """
    词项合法性检查
    - 🎯为后续「检查合法性」的功能提供API接口，例如：
        - 陈述@识别重言式「Tautology」
        - 继承&相似：识别「一等公民词项」
        - 蕴含&等价：识别「非语句词项」
    - 🎯用于在逻辑（而非数据结构）层面对代码进行检查
    - 实际实现留给后续NAL，而不体现在词项本身的构造上
        - 即便用户构造了「NAL不合法的词项」，也可以通过此间「检查合法性」否决创建
            - 例如，可用于NARS系统的「合法性检验」中，如「创建一个词项就检验一次」
    
    依「调用时机」分两种类型
    - 「内联合法性检查」
        - 在各个类「内部构造函数被调用」时被调用
        - 🎯用于筛选「不想被用户构建的词项」
    - 「外部合法性检查」
        - 默认收束至「内联合法性检查」
            - 类似「==」收束至「===」一般
        - 🎯主要提供「构造后被修改时的合法性检查」
        - ⚠逻辑上尽可能与「内联版本」保持一致
    
    依「内容是否可解释」分两种类型
    - 「非解释合法性检查」
        - 🎯用于「只需要检测是否合法」而无需其他信息
        - 只会返回true/false
    - 「可解释合法性检查」
        - 🎯用于「不仅需要检测『是否合法』，而且需要返回『非法缘由』」的场景
            - 类似Julia自身的「类型断言」机制，亦可称其为「合法性断言」
        - 词项合法时返回本身
        - 词项非法时抛出异常
            - 【20230812 22:14:38】牺牲「后续不catch直接处理异常」的自由度
        - ⚠逻辑上尽可能与「非解释版本」保持一致
    
    整体类型依赖逻辑：
        内联非解释（最快） ⇐　内联可解释
        　　⇑　　　　　　　　　　　⇑
        外部非解释　　　　 ⇐　外部可解释（最慢）
    
    【20230814 13:08:45】📝代码量少、调用频繁⇒适合@inline内联
    【20230819 14:57:58】TODO：利用「返回nothing/返回报错信息（字符串）」减少重复工作量
    """
    @inline check_valid(::Term)::Bool = true # 默认为真（最基础地只需修改这个）
    @inline check_valid_external(t::Term)::Bool = check_valid(t) # 默认重定向
    @inline check_valid_explainable(t::Term)::Term = check_valid(t) ? t : error("非法词项！") # 默认重构「非解释合法性检查」逻辑
    @inline check_valid_external_explainable(t::Term)::Term = check_valid_explainable(t) # 默认重定向
    
    begin "示例集"

        "原子：识别词项名是否为纯文字(Word)：不能有其它特殊符号出现"
        @inline check_valid(a::Atom) = isnothing(
            findfirst(r"[^\w]", string(a.name)) # 【20230814 13:07:16】根据`@code_native`的输出行数，比occursin高效
        )

        "可解释"
        @inline check_valid_explainable(a::Atom)::Term = check_valid(a) ? 
            a : 
            error("非法词项名「$(a.name)」！")
        
    end
end

# 对接容器
begin "容器对接：对复合词项的操作⇔对其容器的操作"
    
    "原子の长度=1"
    Base.length(a::Atom)::Integer = 1

    "原子の索引[] = 其名"
    Base.getindex(c::Atom) = c.name
    
    

    "复合词项の长度=其元素的数量(像占位符不含在内)"
    Base.length(c::ACompound)::Integer = length(c.terms)

    "复合词项の索引[i] = 内容の索引"
    Base.getindex(c::ACompound, i) = getindex(c.terms, i)

    "复合词项の枚举 = 内容の枚举"
    Base.iterate(c::ACompound, i=1) = iterate(c.terms, i)

    "复合词项のmap = 内容のmap(变成Vector)再构造"
    Base.map(f, c::ACompound) = typeof(c)(map(f, c.terms))

    "复合词项の随机 = 内容の随机"
    Base.rand(c::ACompound, args...; kw...) = rand(c, args...; kw...)

    "复合词项のall&any = 内容のall&any"
    Base.all(f, c::ACompound) = all(f, c.terms)
    Base.any(f, c::ACompound) = any(f, c.terms)

    "复合词项の倒转 = 内容倒转"
    Base.reverse(c::ACompound) = typeof(c)(reverse(c.terms))


    "陈述の长度=2" # 主词+谓词
    Base.length(c::AStatement)::Integer = 2

    "陈述の索引[i] = 对Pair的索引"
    Base.getindex(s::AStatement, i) = getindex(Pair(s), i)

    "陈述の枚举 = 对Pair的枚举"
    Base.iterate(s::AStatement, i=1) = iterate(Pair(s), i)

    "陈述のmap = 对Pair的map(变成Vector)再构造"
    Base.map(f, s::AStatement) = typeof(s)(map(f, Pair(s)))

    "陈述の随机 = 对元组的随机"
    Base.rand(s::AStatement, args...; kw...) = rand((s.ϕ1, s.ϕ2), args...; kw...)

    "陈述のall&any = 对Pair的all&any"
    Base.all(f, s::AStatement) = all(f, Pair(s))
    Base.any(f, s::AStatement) = any(f, Pair(s))

    "陈述の倒转 = 对Pair的倒转"
    Base.reverse(s::AStatement) = typeof(s)(reverse(Pair(s)))
    
end

# 排序
begin "排序: 用于判断「词项的先后」"

    """
    对类名的排序
    - ⚠注意：可能在不同调用点有不同的类名
        - 不过类名「JuNarsese.XXX」的前缀还是相等的
    """
    @inline _isless_type(t1::Type, t2::Type) = isless(
        string(t1),
        string(t2),
    )
    "自动变为Type类型"
    @inline _isless_type(t1::Any, t2::Any) = _isless_type(
        typeof(t1),
        typeof(t2),
    )

    "兜底排序=类名"
    Base.isless(t1::Term, t2::Term) = _isless_type(
        typeof(t1),
        typeof(t2),
    )
    
    """
    原子の排序=其名|类名
    - 🎯用于`sort`方法，进一步用于无序复合词项的「唯一序列」存储
        - 例如外延集`{A,B,C}` == `{B,A,C}` == `{B,C,A}` ==> `(A,B,C)`
    - 优先比名称，其次比类型
        - 比较逻辑源自Julia`tuple.jl`库
        - 📌模型：「第一个小于」⇒「第一个不大于」且「剩下的小于」
        - 逻辑：
            1. `1.1<2.1`？
            2. 若否(1.1≥2.1)，判断2.1≥1.1 && 第二项...
                - 合取等价于`1.1==2.1`
                - 若此项为false，等价于`1.1>2.1`，自然返回false「不小于」
    - ⚠与「字符串形式」的比较可能不同
        - 例如：`w"W" > o"W"`，但`"W" < "^W"`
        - 🎯减少耦合与提升效率
    """
    Base.isless(a1::Atom, a2::Atom) = (
        isless(a1.name, a2.name) || (!isless(a2.name, a1.name) &&
        _isless_type(a1, a2)
        )
    )
    
    """
    复合词项の排序 = 元素|类名
    - 优先比元素，其次比类名
        - ⚡通常类名比元素的字串更长，复合词项一般只有1~10个组分
        - 对组分数不多的复合词项更快
    """
    Base.isless(c1::ACompound, c2::ACompound) = (
        isless(c1.terms, c2.terms) || (!isless(c2.terms, c1.terms) &&
        _isless_type(c1, c2)
        )
    )
    
    """
    像の排序：像占位符位置|元素|类名
    """
    Base.isless(i1::TermImage, i2::TermImage) = (
        isless(i1.relation_index, i2.relation_index) || (i2.relation_index == i1.relation_index &&
        isless(i1.terms, i2.terms) || (!isless(i2.terms, i1.terms) &&
        _isless_type(i1, i2)
        ))
    )

    """
    陈述の排序 = 其主谓项|类名
    - 主谓项通过ϕ1、ϕ2两个属性分别实现
        - 先比较第一项
        - 再比较第二项
        - 最后比较类型
    - 不同于「复合词项の排序」：直接「主项⇒谓项⇒类名」逐个比对
    """
    function Base.isless(s1::AStatement, s2::AStatement)
        isless(s1.ϕ1, s2.ϕ1) || (isequal(s1.ϕ1, s2.ϕ1) && # 后面断言第一项相等(注：似乎用isless会出现「既大于又小于」的情况)
        isless(s1.ϕ2, s2.ϕ2) || (isequal(s1.ϕ2, s2.ϕ2) && # 后面断言第二项相等
        _isless_type(s1, s2)
        ))
    end
end

# 判断相等 #
begin "判断相等(Base.isequal)：基于值而非基于引用"

    "统一的类型相等逻辑"
    _isequal_type(t1::Type, t2::Type) = t1 == t2

    "兜底判等逻辑" # 没有不行：类型不同的词项无法进行比较
    @inline function Base.isequal(t1::Term, t2::Term)
        typeof(t1) == typeof(t2) && all( # 同类型
            isequal(getproperty(t1, propertyname), getproperty(t2, propertyname)) # 所有属性相等
            for propertyname in t1 |> propertynames # 使用t1的，在同类型的前提下
        )
    end

    "原子词项相等：其名&类型"
    @inline Base.isequal(t1::Atom, t2::Atom)::Bool = (
        t1.name == t2.name && # 名称相等
        _isequal_type(typeof(t1), typeof(t2)) # 类型相等
    )
    
    "（特殊）间隔相等：仅需其名"
    @inline Base.isequal(i1::Interval, i2::Interval)::Bool = (
        i1.interval == i2.interval
    )

    """
    通用复合词项`CommonCompound`相等：元素&类型
    - 逻辑同`isless`方法，但前者要被调用两次

    【20230820 12:20:32】基于「构造时排序」的预处理，现可直接比对其中的组分
    """
    function Base.isequal(t1::CommonCompound{T1}, t2::CommonCompound{T2})::Bool where {T1, T2}
        t1.terms == t2.terms && # 先元素
        _isequal_type(typeof(t1), typeof(t2)) # 再类型
    end

    """
    特殊重载「像相等」：元素&类型
    - 类型相等
    - 占位符位置相等
    - 所有元素相等

    【20230820 12:20:32】基于「构造时排序」的预处理，作为「有序可重复」的默认定义，现可直接比对其中的组分
    """
    function Base.isequal(t1::TermImage{EIT1}, t2::TermImage{EIT2})::Bool where {EIT1, EIT2}
        EIT1 == EIT2 && # 类型相等（外延像/内涵像）
        t1.relation_index == t2.relation_index &&  # 占位符位置相等
        t1.terms == t2.terms # 组分相等
    end

    """
    陈述相等：元素&类型

    【20230820 12:20:32】基于「构造时排序」的预处理，现可直接比对其中的组分
    """
    function Base.isequal(s1::Statement{P1}, s2::Statement{P2})::Bool where {P1, P2}
        P1 == P2 && # 类型相等
        s1.ϕ1 == s2.ϕ1 && # 主词相等
        s1.ϕ2 == s2.ϕ2 # 谓词相等
    end
    
    "重定向「==」符号"
    Base.:(==)(t1::Term, t2::Term) = Base.isequal(t1, t2)

end

# 收集(`Base.collect`): 收集其中包含的所有（原子）词项 #
begin "收集(Base.collect)其中包含的所有（原子）词项，并返回向量"

    "原子词项のcollect：只有它自己"
    Base.collect(aa::Atom) = Term[aa]

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
    Base.collect(s::ACompound) = [
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

# 运算重载
begin "运算重载：四则运算等"
    
    "同类原子词项拼接 = 文字拼接（使用Juliaの加号，因与「乘积」快捷构造冲突）（间隔除外）"
    (Base.:(+)(a1::T, a2::T)::T) where {T <: Atom} = T(string(a1.name) * string(a2.name))

    "间隔の加法（参照自PyNARS Interval.py/__add__）"
    Base.:(+)(i1::Interval, i2::Interval)::Interval = Interval(i1.interval + i2.interval)

end

# 时态
begin "时态：用于获取(Base.collect)「时序蕴含/等价」中的「时态信息」"

    export get_tense
    
    """
    获取「时序蕴含/等价」陈述中的时态
    - 格式：`get(陈述, Tense)`
    - 默认值：对其它语句返回「Eternal」
    - ⚠和语句的时态可能不一致「参见OpenNARS」
    """
    @inline function get_tense(::Statement{ST})::TTense where {ST <: AStatementType}
        if ST <: TemporalStatementTypes # 若其为「有时态系词」
            return ST.parameters[1] # 获取ST{::TTense}的第一个类型参数，直接作为返回值
        end
        return Eternal
    end
end

# 对象互转
begin "增加一些Narsese对象与Julia常用原生对象的互转方式"
    
    # 陈述 ↔ Pair
    "Pair接受陈述"
    Base.Pair(s::Statement)::Base.Pair = Base.Pair(s.ϕ1, s.ϕ2)
    "【20230812 22:21:48】现恢复与Pair的相互转换"
    ((::Type{s})(p::Base.Pair)::s) where {s <: Statement} = s(p.first, p.second)
    
    "间隔→无符号整数"
    Base.UInt(i::Interval)::UInt = i.interval

end

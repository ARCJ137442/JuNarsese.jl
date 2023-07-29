#= 提供基本的词项定义

架构总览
- 词项（抽象）
    - 原子（抽象）
        - 词语
        - 变量{类型}
        - 操作符
    - 复合（抽象）
        - 词项集（抽象）
            - 词项集
            - 词项逻辑集
            - 像
            - 乘积
        - 语句（抽象）
            - 语句{类型}
            - 语句集（抽象）
                - 语句逻辑集

具体在Narsese的文本表示，参见string.jl

参考：
- OpenJunars 詞項層級結構

情况：
- 📌现在不使用「deepcopy」对词项进行深拷贝：将「拷贝与否」交给调用者
=#

#= 📝NAL: 关于「为何没有『外延并/内涵并』的问题」：

    - 核心：**外延交=内涵并，外延并=内涵交**
    - 源：《NAL》2012版，定理 7.4

    原文：

    > The above definition and theorem show that the duality of extension
    > and intension in NAL corresponds to the duality of intersection and union
    > in set theory — intensional intersection corresponds to extensional union,
    > and extensional intersection corresponds to intensional union. Since set
    > theory is purely extensional, the ‘∪’ is associated to union only. To stress
    > the symmetry between extension and intense in NAL, here it is called “intensional intersection”, rather than “extensional union”, though the latter
    > is also correct, and sounds more natural to people familiar with set theory.

    机翻：

    > 上述定义和定理证明了NAL中的外延与内涵的对偶性，对应于集合论中的交与并的对偶性——内涵交对应于外延并，而外延交对应于内涵并。
    > 因为集合论是纯外延的，所以'∪'只与并集有关。
    > 为了强调NAL中扩展与强烈的对称性，这里称之为“内涵交”，而不是“外延并”，尽管后者也是正确的，对熟悉集合论的人来说听起来更自然。

=#

#= 📝Julia: 泛型类的「类型参数」可以「挂羊头卖狗肉」：s{Int}(a) = s{Float64}(1.0)
    此即：在调用类构造方法时，返回的「类型参数」与调用时的「类型参数」**可以不一致**
    通过使用参数化类型和条件约束，Julia可以根据不同的类型参数生成不同的实例，并在必要时进行类型转换。这使得代码更加灵活且具有通用性，能够处理多种类型的数据。
=#

#= 📝Julia: 面向「唯一标识符」时，使用Symbol替代String

    📌核心：Symbol使用「字符串内联」机制，把每个字符串作为唯一索引，且比对时无需逐个字符比对
    - 因此：Symbol在用作「唯一标识符」时，比String更有效率

    英文维基的「字符串内联」资料：
    > String interning speeds up string comparisons, 
    > which are sometimes a performance bottleneck in applications 
    > (such as compilers and dynamic programming language runtimes) 
    > that rely heavily on associative arrays with string keys to look up the attributes and methods of an object. 
    > Without interning, comparing two distinct strings may involve examining every character of both.

    GPTの答：
    在 Julia 中，Symbol 类型通常比 String 类型更具有运行时效率。
    这是因为 Symbol 是不可变的类型，而 String 是可变的。
    - 每当你使用字符串字面量来创建一个新的字符串时，它都会生成一个新的字符串对象，可能会占用更多的内存并导致额外的性能开销。
    - 而 Symbol 只会创建一个唯一的符号，并且在运行时重复使用相同的符号。这使得 Symbol 比较速度更快，因为可以直接对其进行引用比较。

    另外，当你需要在代码中频繁地进行字符串操作时，使用 Symbol 也可以提高性能。
    字符串操作通常涉及到分割、拼接、查找等操作，而这些操作在 Symbol 上是更高效的，因为它们不涉及复制和重新分配内存空间的开销。

    但需要注意的是，Symbol 和 String 是不同的数据类型，它们的适用场景也不同。Symbol 主要用于表示标识符、键和常量等不可变概念，而 String 则用于处理文本和字符串操作。
    因此，在选择使用 Symbol 还是 String 时，需要根据具体的应用场景和需求来决定。

    另可参考如下代码：
    ```julia
    a = "string_symbol"
    @time [
        "string_symbol" == a
        for _ in 1:0xfffff
        ]
    # 0.057884 seconds (31.06 k allocations: 3.075 MiB, 67.64% compilation time)
    a = :string_symbol
    @time [
        :string_symbol == a
        for _ in 1:0xfffff
        ]
    # 0.053276 seconds (38.77 k allocations: 3.656 MiB, 98.21% compilation time)
    ```
=#

#= 📝Julia: 嵌套数组的二次展开，直接使用「[(arr...)...]」
    例：对「嵌套数组对象」`a = [(1,2),[3,4,5]]`
    - 有`[(a...)...] == [1,2,3,4,5]`
=#

# 导出

export AbstractVariableType, VariableTypeIndependent, VariableTypeDependent, VariableTypeQuery
export AbstractStatementType, StatementTypeInheriance, StatementTypeSimilarity, StatementTypeImplication, StatementTypeEquivalance
export AbstractLogicOperation, And, Or, Not
export AbstractEI, Extension, Intension

export AbstractTerm, AbstractAtom, AbstractCompound, AbstractStatement
export AbstractTermSet, AbstractStatementSet

export Word, Variable, Operator, TermSet, TermLogicalSet, TermImage, TermProduct
export Statement, StatementLogicalSet



# 作为「类型标记」的类型参数 #

"变量类型" # 【20230724 11:38:25】💭不知道OpenJunars中为何要让「AbstractVariableType」继承AbstractTerm
abstract type AbstractVariableType end
abstract type VariableTypeIndependent <: AbstractVariableType end # 独立变量 & 对于
abstract type VariableTypeDependent <: AbstractVariableType end # 非独变量 # 存在
abstract type VariableTypeQuery <: AbstractVariableType end # 查询变量 ? 疑问

"语句类型：继承&相似、蕴含&等价"
abstract type AbstractStatementType end
abstract type StatementTypeInheriance <: AbstractStatementType end
abstract type StatementTypeSimilarity <: AbstractStatementType end
abstract type StatementTypeImplication <: AbstractStatementType end
abstract type StatementTypeEquivalance <: AbstractStatementType end

"集合论/一阶逻辑操作：与或非" # 原创
abstract type AbstractLogicOperation end
abstract type And <: AbstractLogicOperation end # 词项→交，语句→与
abstract type Or <: AbstractLogicOperation end # 词项→并，语句→或
abstract type Not <: AbstractLogicOperation end # 词项→非，语句→非

"区分「外延」与「内涵」" # TODO：抽象类型如何命名更恰当？
abstract type AbstractEI end
abstract type Extension <: AbstractEI end
abstract type Intension <: AbstractEI end



# 正式对象 #

"一切词项的总基础" # OpenJunars所谓「FOTerm」实际上就是此处的「AbstractTerm」，只因OpenJunars把「变量类型」也定义成了词项
abstract type AbstractTerm end


"所有的原子词项"
abstract type AbstractAtom <: AbstractTerm end

"复合词项の基石"
abstract type AbstractCompound <: AbstractTerm end

"词项の复合：集合操作⇒复合集"
abstract type AbstractTermSet <: AbstractCompound end

"语句as词项"
abstract type AbstractStatement <: AbstractCompound end

"语句の复合：集合操作⇒复合集"
abstract type AbstractStatementSet <: AbstractStatement end




# 具体结构定义

begin "单体词项"

    "最简单的「词语」词项"
    struct Word <: AbstractAtom
        name::Symbol # 为何不用String？见上文笔记
    end
    """
    支持从String构造
    - 目的：处理从（AST）解析中返回的字符串参数
    """
    Word(name::String) = name |> Symbol |> Word

    "变量词项（用类型参数包括三种类型）"
    struct Variable{Type <: AbstractVariableType} <: AbstractAtom
        name::Symbol
    end
    "支持从String构造"
    Variable{T}(name::String) where {T<:AbstractVariableType} = name |> Symbol |> Variable{T}

    "操作词项(Action)"
    struct Operator <: AbstractAtom
        name::Symbol
    end
    "支持从String构造"
    Operator(name::String) = name |> Symbol |> Operator

    "复合集 {} []"
    struct TermSet{EIType <: AbstractEI} <: AbstractTermSet
        terms::Set{AbstractTerm}
    end

    "任意长参数"
    function TermSet{EIType}(terms::Vararg{AbstractTerm}) where EIType
        TermSet{EIType}(terms |> Set{AbstractTerm})
    end

    """
    词项逻辑集{外延/内涵, 交/并/差}
    - And: 交集 ∩& ∩|
    - Or : 并集 ∪& ∪|
        - 注意：此处不会使用，会自动转换（见📝「为何不使用外延/内涵 并？」）
    - Not: 差集 - ~
        - 有序(其余皆无序)
    """
    # 此处「&」「|」是对应的「外延交&」「外延并|」
    struct TermLogicalSet{EIType <: AbstractEI, LogicOperation <: AbstractLogicOperation} <: AbstractTermSet
        terms::Union{Vector{AbstractTerm}, Set{AbstractTerm}}

        "(无序)交集 Intersection{外延/内涵} ∩& ∩|"
        function TermLogicalSet{EIType, And}(terms::Vararg{AbstractTerm}) where EIType # 此EIType构造时还会被检查类型
            new{EIType, And}( # 把元组转换成对应数据结构
                terms |> Set{AbstractTerm}
            )
        end

        "(无序，重定向)并集 Union{外延/内涵} ∪& ∪|" # 【20230724 14:12:33】暂且自动转换成交集（返回值类型参数转换不影响）（参考《NAL》定理7.4）
        TermLogicalSet{Extension, Or}(terms...) = TermLogicalSet{Intension, And}(terms...) # 外延并=内涵交
        TermLogicalSet{Intension, Or}(terms...) = TermLogicalSet{Extension, And}(terms...) # 内涵并=外延交

        "(有序)差集 Difference{外延/内涵} - ~" # 注意：这是二元的 参数命名参考自OpenJunars
        function TermLogicalSet{EIType, Not}(ϕ₁::AbstractTerm, ϕ₂::AbstractTerm) where EIType # 此EIType构造时还会被检查类型
            new{EIType, Not}( # 把元组转换成对应数据结构，再深拷贝
                AbstractTerm[ϕ₁, ϕ₂]
            )
        end

    end

    """
    像{外延/内涵} (/, a, b, _, c) (\\\\, a, b, _, c)
    - 有序
    - 【20230724 22:06:36】注意：词项在terms中的索引，不代表其在实际情况下的索引

    例：`TermImage{Extension}([a,b,c], 3)` = (/, a, b, _, c)
    """
    struct TermImage{EIType <: AbstractEI} <: AbstractTermSet
        terms::Tuple{Vararg{AbstractTerm}}
        relation_index::Unsigned # 「_」的位置(一个占位符，保证词项中只有一个「_」)

        "限制占位符位置（0除外）"
        function TermImage{EIType}(terms::Tuple{Vararg{T}}, relation_index::Integer) where {EIType, T <: AbstractTerm}
            # 检查
            relation_index == 0 || @assert relation_index ≤ length(terms) + 1
            # 构造
            new{EIType}(terms, unsigned(relation_index))
        end
    end

    "多参数构造(倒过来，占位符位置放在最前面)"
    function TermImage{EIType}(relation_index::Integer, terms::Vararg{AbstractTerm}) where EIType
        TermImage{EIType}(terms, relation_index |> unsigned)
    end

    """
    乘积 (*, ...)
    - 有序
    - 无内涵外延之分
    - 用于关系词项「(*, 水, 盐) --> 前者可被后者溶解」
    """
    struct TermProduct <: AbstractTermSet
        terms::Vector{AbstractTerm}
    end

    "多参数构造"
    function TermProduct(terms::Vararg{AbstractTerm})
        TermProduct(terms |> collect)
    end

end

begin "语句词项"

    """
    语句{继承/相似/蕴含/等价} --> <-> ==> <=>
    - 现只支持「二元」语句，只表达两个词项之间的关系
    """
    struct Statement{Type <: AbstractStatementType} <: AbstractStatement
        ϕ1::AbstractTerm
        ϕ2::AbstractTerm
    end

    """
    语句逻辑集：{与/或/非}
    - And: 语句与 ∧ && Conjunction
    - Or : 语句或 ∨ || Disjunction
    - Not: 语句非 ¬ --

    注意：都是「对称」的⇒集合
    """ # 与「TermSet」不同的是：只使用最多两个词项（语句）
    struct StatementLogicalSet{LogicOperation <: AbstractLogicOperation} <: AbstractStatementSet

        terms::Set{AbstractStatement}

        "语句与 Conjunction / 语句或 Disjunction"
        function StatementLogicalSet{T}(
            terms::Vararg{AbstractStatement}, # 实质上是个元组
        ) where {T <: Union{And, Or}} # 与或都行
            new{T}(terms |> Set) # 收集元组成集合
        end

        "语句非 Negation"
        function StatementLogicalSet{Not}(ϕ::AbstractStatement)
            new{Not}(AbstractStatement[ϕ] |> Set{AbstractStatement}) # 只有一个
        end

    end
    
end

# 别名
include("terms/aliases.jl")

# 方法
include("terms/methods.jl")

# 快捷构造方式
include("terms/constructor_shotcuts.jl")
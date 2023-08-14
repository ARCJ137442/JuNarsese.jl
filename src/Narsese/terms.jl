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

    中译：

    > 上述定义和定理证明了NAL中的外延与内涵的对偶性，对应于集合论中的交与并的对偶性——内涵交对应于外延并，而外延交对应于内涵并。
    > 因为集合论是纯外延的，所以'∪'只与并集有关。
    > 为了强调NAL中外延与内涵的对称性，这里称之为“内涵交”，而不是“外延并”，尽管后者也是正确的，对熟悉集合论的人来说听起来更自然。

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

"""
提供基本的词项定义

架构总览
- 词项（抽象）
    - 原子（抽象）
        - 词语
        - 变量{类型}
        - 操作符
    - 复合（抽象）
        - 词项集（抽象）
            - 词项集
            - 词项逻辑集{逻辑操作}
            - 像
            - 乘积
        - 陈述（抽象）
            - 陈述{类型}
            - 陈述集（抽象）
                - 陈述逻辑集{逻辑操作}（抽象）
                    - 陈述逻辑集{逻辑操作}
                    - 陈述时序集{时序关系}

具体在Narsese的文本表示，参见string.jl

参考：
- OpenJunars 词项层级结构

情况：
- 📌现在不使用「deepcopy」对词项进行深拷贝：将「拷贝与否」交给调用者
- 【20230803 11:31:40】暂不将整个文件拆分为「Narsese1-8」的形式，而是以[NAL-X]的格式标注其来源
"""
module Terms

# 导入:前置 #

# 时态 【20230804 14:20:50】因为「时序蕴含/等价」的存在，需要引入「时间参数」（参考自OpenNARS）
include("Terms/tense.jl")

# 导出 #

export AbstractVariableType, VariableTypeIndependent, VariableTypeDependent, VariableTypeQuery
export AbstractStatementType, StatementTypeInheriance, StatementTypeSimilarity, StatementTypeImplication, StatementTypeEquivalence
export AbstractLogicOperation, And, Or, Not
export AbstractEI, Extension, Intension
export AbstractTemporalRelation, Sequential, Parallel

export AbstractTerm, AbstractAtom, AbstractCompound, AbstractStatement
export AbstractTermSet, AbstractStatementSet

export Word, Variable, Operator, TermSet, TermLogicalSet, TermImage, TermProduct
export Statement, AbstractStatementLogicalSet, StatementLogicalSet, StatementTemporalSet



# 作为「类型标记」的类型参数 #

"[NAL-1|NAL-2|NAL-5]陈述类型：继承&相似、蕴含&等价"
abstract type AbstractStatementType end
abstract type StatementTypeInheriance <: AbstractStatementType end # NAL-1
abstract type StatementTypeSimilarity <: AbstractStatementType end # NAL-2
abstract type StatementTypeImplication{T <: Tense} <: AbstractStatementType end # NAL-5|NAL-7
abstract type StatementTypeEquivalence{T <: Tense} <: AbstractStatementType end # NAL-5|NAL-7

"[NAL-2]区分「外延」与「内涵」"
abstract type AbstractEI end # NAL-2
abstract type Extension <: AbstractEI end
abstract type Intension <: AbstractEI end

"[NAL-3|NAL-5]集合论/一阶逻辑操作：与或非" # 原创
abstract type AbstractLogicOperation end
abstract type And <: AbstractLogicOperation end # 词项→交，陈述→与
abstract type Or <: AbstractLogicOperation end # 词项→并，陈述→或
abstract type Not <: AbstractLogicOperation end # 词项→非，陈述→非

"[NAL-6]变量类型" # 【20230724 11:38:25】💭不知道OpenJunars中为何要让「AbstractVariableType」继承AbstractTerm
abstract type AbstractVariableType end # NAL-6
abstract type VariableTypeIndependent <: AbstractVariableType end # 独立变量 & 对于
abstract type VariableTypeDependent <: AbstractVariableType end # 非独变量 # 存在
abstract type VariableTypeQuery <: AbstractVariableType end # 查询变量 ? 疑问

"[NAL-7]时序合取：区分「序列」与「平行」"
abstract type AbstractTemporalRelation end
abstract type Sequential <: AbstractTemporalRelation end
abstract type Parallel <: AbstractTemporalRelation end

# 正式对象 #

"一切词项的总基础" # OpenJunars所谓「FOTerm」实际上就是此处的「AbstractTerm」，只因OpenJunars把「变量类型」也定义成了词项
abstract type AbstractTerm end


"[NAL-1]所有的原子词项"
abstract type AbstractAtom <: AbstractTerm end

"[NAL-2]复合词项の基石"
abstract type AbstractCompound <: AbstractTerm end

"[NAL-2]词项の复合：集合操作⇒复合集"
abstract type AbstractTermSet <: AbstractCompound end

"[NAL-5]抽象陈述：陈述→词项"
abstract type AbstractStatement <: AbstractCompound end

"[NAL-5]复合陈述"
abstract type AbstractStatementSet <: AbstractStatement end

"[NAL-5]抽象陈述逻辑集: {与/或/非}"
abstract type AbstractStatementLogicalSet{LogicOperation <: AbstractLogicOperation} <: AbstractStatementSet end



# 具体结构定义

begin "单体词项"

    """
    [NAL-1]最简单的「词语」词项

    参考：《NAL》定义2.1
    > The basic form of a term is a word, that is, a string of characters from a finite alphabet.
    > There is no additional requirement on the alphabet.
    > In this document the alphabet includes English letters, digits 0 to 9, and a few special signs, such as hyphen (‘-’).
    > In the examples in this book, we often use common English nouns for terms, such as bird and animal, just to make the examples easy to understand.
    > There is no problem to do the same in a different natural language, such as Chinese.On the other hand, it is also fine to use terms that are meaningless to human beings, such as drib and aminal.

    中译：
    > 一个词项的基本形式是一个「词语」，即来自有限字母表的一串字符。
    > 除此之外对字母表没有要求。
    > 本书中字母表包括英文字母、数字0 ~ 9和一些特殊符号，如“-”，并常用常见的英语名词来表示术语，例如bird和animal，只是为了使示例易于理解。
    > 用一种不同的自然语言(如中文)做同样的事情是没有问题的。另一方面，也可以使用对人类没有意义的术语，如drib和aminal。

    """
    struct Word <: AbstractAtom
        name::Symbol # 为何不用String？见上文笔记

        "加入合法性检查"
        Word(name::Symbol) = check_valid_explainable(
            new(name)
        ) # 增加合法性检查_explainable
    end
    """
    支持从String构造
    - 目的：处理从（AST）解析中返回的字符串参数
    """
    Word(name::String) = name |> Symbol |> Word

    """
    [NAL-6]变量词项（用类型参数包括三种类型）

    参考：《NAL》定义10.1~2
    > A query variable is a variable term in a question that represents a constant term to be found to answer the question,
    > and it is named by ‘?’,
    > optionally followed by a word or a number.

    > An independent variable represents any unspecified term under a given restriction,
    > and it is named by a word (or a number) preceded by ‘#’.
    > A dependent variable represents a certain unspecified term under a given restriction,
    > and it is named as an independent variable with a dependency list consisting of independent variables it depends on,
    > which can be empty.

    中译：
    > 查询变量是问题中的一个变量项，
    > 它表示要找到的用于回答问题的常量项，
    > 它被命名为'?'，
    > 可选后跟一个单词或数字。

    > 独立变量表示给定限制下的任何未指定项，
    > 并以“#”前面的单词(或数字)命名。
    > 非独变量表示给定限制下的某个未指定项，
    > 它被命名为具有由它所依赖的独立变量组成的依赖列表的独立变量，
    > 该列表可以为空。
    """
    struct Variable{T <: AbstractVariableType} <: AbstractAtom
        name::Symbol

        "加入合法性检查"
        Variable{T}(name::Symbol) where {T <: AbstractVariableType} = check_valid_explainable(
            new(name)
        ) # 增加合法性检查
    end
    "支持从String构造"
    Variable{T}(name::String) where {T<:AbstractVariableType} = name |> Symbol |> Variable{T}

    """
    [NAL-8]操作词项(Action)

    参考：《NAL》定义12.2

    > An atomic operation is represented as an operator (a special term whose name starts with ‘⇑’)
    > followed by an argument list (a sequence of terms, though can be empty).
    > Within the system, operation “(⇑op a₁ ··· aₙ)” is treated as statement “(× self a₁ ··· aₙ) → op”,
    > where op belongs to a special type of term that has a procedural interpretation,
    > and self is a special term referring to the system itself.

    中译：
    > 一个原子操作表示为一个操作符(一个特殊的词项，其名以“⇑”开头)跟一个参数列表(一个词项序列，但可为空)。
    > 在系统内，操作“(⇑op a₁ ··· aₙ)”被视为语句“(× self a₁ ··· aₙ) → op”，
    >   其中op属于具有程序解释的特殊类型词项，【译者注：此「程序解释的特殊类型」即此处定义的类】
    >   而self是指系统本身的特殊词项。【译者注：此即NAL代码中经常出现的`{SELF}`】
    """
    struct Operator <: AbstractAtom
        name::Symbol

        "加入合法性检查"
        Operator(name::Symbol) = check_valid_explainable(
            new(name)
        ) # 增加合法性检查
    end
    "支持从String构造"
    Operator(name::String) = name |> Symbol |> Operator

    """
    [NAL-2]词项集 {} []

    参考：《NAL》定义6.3、6.5
    > If T is a term, the extensional set with T as the only component, {T}, is defined by (∀x)((x → {T}) ⟺ (x ↔ {T})).
    > If T is a term, the intensional set with T as the only component, [T], is defined by (∀x)(([T] → x) ⟺ ([T] ↔ x)).

    中译：
    > 如果T是一个词项，则以T为唯一组分的外延集 {T} 定义为 (∀x)((x → {T}) ⟺ (x ↔ {T}))。
    > 如果T是一个词项，则以T为唯一组分的内涵集 [T] 定义为 (∀x)(([T] → x) ⟺ ([T] ↔ x))。
    """
    struct TermSet{EIType <: AbstractEI} <: AbstractTermSet
        terms::Set{<:AbstractTerm}

        "加入合法性检查"
        TermSet{EIType}(terms::Set{T}) where {
            T <: AbstractTerm, EIType <: AbstractEI
        } = check_valid_explainable(
            new{EIType}(terms)
        ) # 增加合法性检查
    end

    "任意长参数"
    function TermSet{EIType}(terms::Vararg{AbstractTerm}) where {EIType <: AbstractEI}
        TermSet{EIType}(terms |> Set{AbstractTerm})
    end

    """
    [NAL-3]词项逻辑集 {外延/内涵, 交/并/差}
    - And: 交集 ∩& ∩|
    - Or : 并集 ∪& ∪|
        - 注意：此处不会使用，会自动转换（见📝「为何不使用外延/内涵 并？」）
    - Not: 差集 - ~
        - 有序(其余皆无序)

    参考：《NAL》定义7.6~9
    > Given terms T1 and T2, their extensional intersection (T1 ∩ T2)
    >   is a compound term defined by (∀x)((x → (T1 ∩ T2)) ⟺ ((x → T1) ∧ (x → T2))).
    > Given terms T1 and T2, their intensional intersection (T1∪T2)
    >   is a compound term defined by (∀x)(((T1 ∪ T2) → x) ⟺ ((T1 → x) ∧ (T2 → x))).
    > If T1 and T2 are different terms, their extensional difference (T1 - T2)
    >   is a compound term defined by (∀x)((x → (T1 - T2)) ⟺((x → T1) ∧ ¬(x → T2))).
    > If T1 and T2 are different terms, their intensional difference (T1⊖T2)
    >   is a compound term defined by (∀x)(((T1⊖T2) → x) ⟺ ((T1 → x) ∧ ¬(T2 → x))).


    中译：
    > 给定词项T1与T2，它们的外延交(T1∩T2)是一个复合词项，定义为 (∀x)((x → (T1 ∩ T2)) ⟺ ((x → T1) ∧ (x → T2)))。
    > 给定词项T1与T2，它们的内涵交(T1∪T2)是一个复合词项，定义为 (∀x)(((T1 ∪ T2) → x) ⟺ ((T1 → x) ∧ (T2 → x)))。
    > 如果T1和T2是不同的词项，它们的外延差(T1-T2)是一个复合词项，定义为 (∀x)((x → (T1 - T2)) ⟺((x → T1) ∧ ¬(x → T2)))。
    > 如果T1和T2是不同的词项，它们的内涵差(T1 * T2)是一个复合词项，定义为 (∀x)(((T1⊖T2) → x) ⟺ ((T1 → x) ∧ ¬(T2 → x)))。
    """ # 此处「&」「|」是对应的「外延交&」「外延并|」
    struct TermLogicalSet{EIType <: AbstractEI, LogicOperation <: AbstractLogicOperation} <: AbstractTermSet
        terms::Union{Tuple{Vararg{AbstractTerm}}, Set{AbstractTerm}}

        "(无序)交集 Intersection{外延/内涵} ∩& ∩|"
        function TermLogicalSet{EIType, And}(terms::Vararg{AbstractTerm}) where EIType # 此EIType构造时还会被检查类型
            check_valid_explainable(
                new{EIType, And}( # 把元组转换成对应数据结构
                    terms |> Set{AbstractTerm}
                )
            ) # 增加合法性检查
        end

        "(无序，重定向)并集 Union{外延/内涵} ∪& ∪|" # 【20230724 14:12:33】暂且自动转换成交集（返回值类型参数转换不影响）（参考《NAL》定理7.4）
        TermLogicalSet{Extension, Or}(terms...) = TermLogicalSet{Intension, And}(terms...) # 外延并=内涵交
        TermLogicalSet{Intension, Or}(terms...) = TermLogicalSet{Extension, And}(terms...) # 内涵并=外延交

        "(有序)差集 Difference{外延/内涵} - ~" # 注意：这是二元的 参数命名参考自OpenJunars
        function TermLogicalSet{EIType, Not}(ϕ₁::AbstractTerm, ϕ₂::AbstractTerm) where EIType # 此EIType构造时还会被检查类型
            check_valid_explainable(
                new{EIType, Not}(
                    (ϕ₁, ϕ₂) # 【20230814 13:21:55】直接构造元组
                )
            ) # 增加合法性检查
        end

    end

    """
    [NAL-4]乘积 (*, ...)
    - 有序
    - 无内涵外延之分
    - 用于关系词项「(*, 水, 盐) --> 前者可被后者溶解」

    参考：《NAL》定义8.1
    > The product connector ‘×’ takes two or more terms as components,
    >   and forms a compound term that satisfies ((× S₁ ··· Sₙ) → (× P₁ ··· Pₙ)) ⟺ ((S₁ → P₁) ∧ ··· ∧ (Sₙ → Pₙ)).

    中译：
    > 乘积连接符“×”采用两个或多个词项作为组分，形成一个复合词项，
    >   满足 ((× S₁ ··· Sₙ) → (× P₁ ··· Pₙ)) ⟺ ((S₁ → P₁) ∧ ··· ∧ (Sₙ → Pₙ))。
    """
    struct TermProduct <: AbstractTermSet
        terms::Tuple{Vararg{AbstractTerm}}

        "多参数构造：直接使用元组"
        TermProduct(terms::Tuple{Vararg{AbstractTerm}}) = check_valid_explainable(
            new(terms)
        ) # 增加合法性检查
    end

    "多参数构造：Vararg⇒元组"
    TermProduct(terms::Vararg{<:AbstractTerm}) = TermProduct(terms)

    "多参数构造：直接使用向量"
    TermProduct(terms::Vector{<:AbstractTerm}) = TermProduct(
        terms |> Tuple
    )
        
    raw"""
    [NAL-4]像{外延/内涵} (/, a, b, _, c) (\, a, b, _, c)
    - 有序
    - 【20230724 22:06:36】注意：词项在terms中的索引，不代表其在实际情况下的索引

    例：`TermImage{Extension}([a,b,c], 3)` = (/, a, b, _, c)

    参考：《NAL》定义8.4
    > For a relation R and a product (× T1 T2),
    >   the extensional image connector, ‘/’, and intensional image connector, ‘\’,
    >   of the relation on the product are defined as the following, respectively:
    >     ((× T1 T2) → R) ⟺ (T1 → (/ R ⋄ T2)) ⟺ (T2 → (/ R T1 ⋄))
    >     (R → (× T1 T2)) ⟺ ((\ R ⋄ T2) → T1) ⟺ ((\ R T1 ⋄) → T2)

    中译：
    > 对于关系R和乘积(× T1 T2)，乘积上关系的外延像连接符“/”和内延像连接符“\”分别定义为：
    >     ((× T1 T2) → R) ⟺ (T1 → (/ R ⋄ T2)) ⟺ (T2 → (/ R T1 ⋄))
    >     (R → (× T1 T2)) ⟺ ((\ R ⋄ T2) → T1) ⟺ ((\ R T1 ⋄) → T2)

    """
    struct TermImage{EIType <: AbstractEI} <: AbstractTermSet
        terms::Tuple{Vararg{AbstractTerm}}
        relation_index::Unsigned # 「_」的位置(一个占位符，保证词项中只有一个「_」)

        """
        限制占位符位置（0除外）

        📌莫使用`Tuple{Vararg{T}} where T <: AbstractTerm`
        - 理：Julia参数类型的「不变性」，参数类型的子类关系不会反映到整体上
            - 例: `Tuple{Int} <: Tuple{Integer} == false`
        - 因：此用法会限制Tuple中「只能由一种类型」
            - 因而产生「无方法错误」（其中有「!Matched::Tuple{Vararg{T}}」）
        - 解：直接使用`Tuple{AbstractTerm}`
            - 其可以包含任意词项，而不会被限制到某个具体类型中
            - 例如：只用`Tuple{Integer}`而不用`Tuple{Int}`
        """
        function TermImage{EIType}(terms::Tuple{Vararg{AbstractTerm}}, relation_index::Unsigned) where {EIType}
            relation_index == 0 || @assert relation_index ≤ length(terms) + 1 "索引`$relation_index`越界！"
            check_valid_explainable(
                new{EIType}(terms, relation_index) # 加入合法性检查
            ) # 增加合法性检查
        end
    end

    "类型适配：对有符号整数的映射"
    function TermImage{EIType}(terms::Tuple{Vararg{AbstractTerm}}, relation_index::Integer) where {EIType}
        TermImage{EIType}(terms, unsigned(relation_index))
    end

    "转换兼容支持：多参数构造(倒过来，占位符位置放在最前面)"
    function TermImage{EIType}(relation_index::Integer, terms::Vararg{AbstractTerm}) where EIType
        TermImage{EIType}(terms, relation_index |> unsigned)
    end

    "转换兼容支持：多参数构造(兼容「词项序列」，以Nothing替代词项)"
    function TermImage{EIType}(uni_terms::Vararg{Union{AbstractTerm, Nothing}}) where EIType
        TermImage{EIType}(
            filter(term -> !isnothing(term), uni_terms), # 过滤出所有非空词项
            findfirst(isnothing, uni_terms) |> unsigned, # 使用「匹配函数」找到首个「占位符」位置
        )
    end

end

begin "陈述词项"

    """
    [NAL=1|NAL-5]陈述Statement{继承/相似/蕴含/等价} --> <-> ==> <=>
    - 现只支持「二元」陈述，只表达两个词项之间的关系
    - ❎【20230804 14:17:30】现增加「时序」参数，以便在词项层面解析「时序关系」
    - 【20230804 14:44:13】现把「时序系词」作为「主系词」（参考自OpenNARS）
    - 【20230812 22:19:20】加入「合法性检查」机制

    参考：《NAL》定义2.2、9.1
    > The basic form of a statement is an inheritance statement,
    >   “S → P”, where S is the subject term, P is the predicate term, and ‘→’ is the inheritance copula,
    >   defined as being a reflexive and transitive relation from one term to another term.
    > If S1 and S2 are statements, “S1 ⇒ S2” is true if and only if in IL S2 can be derived from S1 in a finite number of inference steps.
    >   Here ‘⇒’ is the implication copula. Formally, it means (S1 ⇒ S2) ⟺ {S1} ⊢ S2.

    中译：
    > 语句的基本形式是继承语句“S→P”，
    >   其中S为主词项，P为谓词项，“→”为继承系词，
    >   定义为从一个词项到另一个词项的自反传递关系。
    > 如果S1和S2是陈述，“S1⇒S2”当且仅当在IL中S2可以在有限的推理步骤中由S1导出时为真。
    >   这里的“⇒”是隐含的联结词。形式上，它表示 (S1 ⇒ S2) ⟺ {S1} ⊢ S2。【译者注 LaTeX代码：`⟺iff`,`⊢vdash`】
    """
    struct Statement{type <: AbstractStatementType} <: AbstractStatement
        ϕ1::AbstractTerm # subject 主词
        ϕ2::AbstractTerm # predicate 谓词

        """
        内部构造方法
        - 【20230812 22:20:01】现调用外部定义的「内联可解释合法性检查」函数
        """
        function Statement{type}(
            ϕ1::AbstractTerm, ϕ2::AbstractTerm,
            ) where {type <: AbstractStatementType}
            check_valid_explainable(
                new{type}(ϕ1, ϕ2)
            ) # 增加合法性检查
        end
    end

    """
    [NAL-5]陈述逻辑集：{与/或/非}
    - And: 陈述与 ∧ && Conjunction
    - Or : 陈述或 ∨ || Disjunction
    - Not: 陈述非 ¬ --

    注意：都是「对称」的⇒集合(无序)

    参考：《NAL》定义9.6

    > When S1 and S2 are different statements,
    >   their conjunction, (S1 ∧ S2), is a compound statement defined by
    >     (∀x)((x ⇒ (S1 ∧ S2)) ⟺ ((x ⇒ S1) ∧ (x ⇒ S2))).
    >   Their disjunction, (S1 ∨ S2), is a compound statement defined by
    >     (∀x)(((S1 ∨ S2) ⇒ x) ⟺ ((S1 ⇒ x) ∧ (S2 ⇒ x))).

    中译：
    > 当S1和S2是不同的陈述时，
    >   它们的合取(S1∧S2)是一个复合陈述，定义为
    >     (∀x)((x ⇒ (S1 ∧ S2)) ⟺ ((x ⇒ S1) ∧ (x ⇒ S2))).
    >   它们的析取(S1∨S2)是一个复合陈述，定义为
    >     (∀x)(((S1 ∨ S2) ⇒ x) ⟺ ((S1 ⇒ x) ∧ (S2 ⇒ x))).
    """ # 与「TermSet」不同的是：只使用最多两个词项（陈述）
    struct StatementLogicalSet{LogicOperation <: AbstractLogicOperation} <: AbstractStatementLogicalSet{LogicOperation}

        terms::Set{<:AbstractStatement}

        "陈述与 Conjunction / 陈述或 Disjunction"
        function StatementLogicalSet{T}(
            terms::Vararg{AbstractStatement}, # 实质上是个元组
            ) where {T <: Union{And, Or}} # 与或都行
            check_valid_explainable(
                new{T}(terms |> Set) # 收集元组成集合
            ) # 增加合法性检查
        end

        "陈述非 Negation"
        function StatementLogicalSet{Not}(ϕ::AbstractStatement)
            check_valid_explainable(
                new{Not}((ϕ,) |> Set{AbstractStatement}) # 只有一个
            ) # 增加合法性检查
        end

    end

    """
    [NAL-7]陈述时序集：{序列/平行} <: 抽象陈述逻辑集{合取}
    - 与 `&/`: 序列合取(有序)
    - 或 `&|`: 平行合取(无序)

    📌技术点: 此中的数据`terms`为一个指向「向量/集合」的引用
    - 即便其类型确定，它仍然是一个「指针」，不会造成效率干扰

    参考：《NAL》定义11.5
    > The conjunction connector (‘∧’) has two temporal variants: “sequential conjunction” (‘,’) and “parallel conjunction” (‘;’).
    > “(E1, E2)” corresponds to the compound event consisting of E1 followed by E2, and “(E1; E2)” corresponds to the compound event consisting of E1 accompanied by E2.

    中译：
    > 合取连接符 (‘∧’) 有两种时序变体变体:“序列合取” (‘,’) 和“平行合取” (‘;’)。
    > “(E1, E2)” 对应由E1后接E2，“(E1; E2)” 对应由E1伴随E2组成的复合事件。
    """ # 与「TermSet」不同的是：只使用最多两个词项（陈述）
    struct StatementTemporalSet{TemporalRelation <: AbstractTemporalRelation} <: AbstractStatementLogicalSet{And}

        # 【20230814 13:19:47】现在重新使用不可变的元组（使用`@code_llvm`比较）
        terms::Union{
            Set{AbstractStatement}, # 无序使用这个
            Tuple{Vararg{AbstractStatement}} # 有序使用这个
        }

        "序列合取 Sequential Conjunction"
        StatementTemporalSet{Sequential}(terms::Tuple{Vararg{AbstractStatement}}) = check_valid_explainable(
            new{Sequential}(terms) # 直接转换元组
        ) # 增加合法性检查

        "平行合取 Parallel Conjunction"
        StatementTemporalSet{Parallel}(terms::Set{AbstractStatement}) = check_valid_explainable(
            new{Parallel}(Set{AbstractStatement}(terms)) # 收集元组成集合(标注好类型)
        ) # 增加合法性检查

    end

    "外部构造方法：支持任意参数 @ 序列合取 Sequential Conjunction"
    StatementTemporalSet{Sequential}(terms::Vararg{AbstractStatement}) = check_valid_explainable(
        StatementTemporalSet{Sequential}(terms) # 直接转换元组
    ) # 增加合法性检查

    "外部构造方法：支持任意参数 @ 平行合取 Parallel Conjunction"
    StatementTemporalSet{Parallel}(terms::Vararg{AbstractStatement}) = check_valid_explainable(
        StatementTemporalSet{Parallel}(terms |> Set{AbstractStatement}) # 收集元组成集合(标注好类型)
    ) # 增加合法性检查

end

# 引入:后置 #

# 别名
include("Terms/aliases.jl")

# 方法
include("Terms/methods.jl")

# 快捷构造方式
include("Terms/constructor_shortcuts.jl")

# 副系词
include("Sentences/secondary_copulas.jl")

end # module

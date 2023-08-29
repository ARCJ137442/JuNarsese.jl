#= 📝NAL: 关于「为何没有『外延并/内涵并』的问题」：

    - 核心：**外延交=内涵并，外延并=内涵交**
    - 源：《NAL》2012版，定理 7.4

    原文：

    > The above definition and theorem show that the duality of extension
    > and intension in NAL corresponds to the duality of intersection and union
    > in set theory — intensional intersection corresponds to extensional union,
    > and extensional intersection corresponds to intensional union. Since set
    > theory is purely extensional, the ‘∪’ is associated to union only. To stress
    > the symmetry between extension and intense in NAL, here it is called “intensional intersection」, rather than “extensional union」, though the latter
    > is also correct, and sounds more natural to people familiar with set theory.

    中译：

    > 上述定义和定理证明了NAL中的外延与内涵的对偶性，对应于集合论中的交与并的对偶性——内涵交对应于外延并，而外延交对应于内涵并。
    > 因为集合论是纯外延的，所以'∪'只与并集有关。
    > 为了强调NAL中外延与内涵的对称性，这里称之为「内涵交」，而不是「外延并」，尽管后者也是正确的，对熟悉集合论的人来说听起来更自然。

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

# 导出 #

export AbstractVariableType, VariableTypeIndependent, VariableTypeDependent, VariableTypeQuery
export AbstractStatementType, StatementTypeInheritance, StatementTypeSimilarity, StatementTypeImplication, StatementTypeEquivalence
export AbstractLogicOperation, And, Or, Not
export AbstractEI, Extension, Intension
export AbstractTemporalRelation, Sequential, Parallel
export AbstractCompoundType, CompoundTypeTermSet, CompoundTypeTermLogicalSet, CompoundTypeTermProduct, CompoundTypeTermImage, CompoundTypeStatementLogicalSet, CompoundTypeStatementTemporalSet

export AbstractTerm, AbstractAtom, AbstractCompound

export terms, ϕ1, ϕ2

export Word, PlaceHolder, Variable, Interval, Operator, CommonCompound, TermImage, Statement
export placeholder, isplaceholder



# 作为「类型标记」的类型参数 #

"[NAL-1|NAL-2|NAL-5]陈述类型：继承&相似、蕴含&等价"
abstract type AbstractStatementType end
abstract type StatementTypeInheritance <: AbstractStatementType end # NAL-1
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

# 复合词项类型

"""
所有复合词项类型的基类
"""
abstract type AbstractCompoundType end
"[NAL-2]词项集"
abstract type CompoundTypeTermSet{EI <: AbstractEI} <: AbstractCompoundType end
"[NAL-2]词项の复合：集合操作⇒复合集"
abstract type CompoundTypeTermLogicalSet{EIType <: AbstractEI, LogicOperation <: AbstractLogicOperation} <: AbstractCompoundType end
"[NAL-4]乘积"
abstract type CompoundTypeTermProduct <: AbstractCompoundType end
"[NAL-4]像"
abstract type CompoundTypeTermImage{EIType <: AbstractEI} <: AbstractCompoundType end
"[NAL-5]陈述逻辑集: {与/或/非}"
abstract type CompoundTypeStatementLogicalSet{LogicOperation <: AbstractLogicOperation} <: AbstractCompoundType end
"[NAL-7]陈述时序集 <: 陈述逻辑集{与}"
abstract type CompoundTypeStatementTemporalSet{TemporalRelation <: AbstractTemporalRelation} <: CompoundTypeStatementLogicalSet{And} end

# 正式对象 #

"一切词项的总基础" # OpenJunars所谓「FOTerm」实际上就是此处的「AbstractTerm」，只因OpenJunars把「变量类型」也定义成了词项
abstract type AbstractTerm end


"[NAL-1]所有的原子词项 | 协议：支持`nameof`方法"
abstract type AbstractAtom <: AbstractTerm end
import Base: nameof

"[NAL-2]复合词项の基石 | 协议：支持`terms`方法（无需绑定属性）"
abstract type AbstractCompound{type <: AbstractCompoundType} <: AbstractTerm end
function terms end

"[NAL-1]陈述词项の基石 | 协议：支持`terms`、`ϕ1`和`ϕ2`方法（无需绑定属性）"
abstract type AbstractStatement{type <: AbstractStatementType} <: AbstractTerm end
function ϕ1 end; function ϕ2 end

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
    > 本书中字母表包括英文字母、数字0 ~ 9和一些特殊符号，如「-」，并常用常见的英语名词来表示术语，例如bird和animal，只是为了使示例易于理解。
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
    Word(name::Union{AbstractString, AbstractChar}) = name |> Symbol |> Word

    raw"""
    [NAL-4]像占位符
    - 现在作为一个独立的类，而非使用Nothing类型
    - 单例模式，只有一个`PlaceHolder()`对象
    - 按照原子词项的原则处理
    - 可以被视作「Narsese中的Nothing」
    - ⚠《NAL》定义中「像占位符不可出现在第一个位置，其为关系词项所保留」的特性，留给构造时合法性检查
    - 实现参考：OpenJunars `terms.jl`；其它NARS实现的处理方式：
        - OpenNARS：设置一个字符串常量为`_`，并在解析「像」时直接识别，作为「占位符位置」存入`ImageXXt`类型中
            - 参见：OpenNARS 3.1.2 `Symbols.java` `StringParser.java`
        - ONA：直接在解析时解析成「占位符位置」``
            - 参见：ONA 0.9.2 `Narsese.c`
        - PyNARS：设置一个名为`_`的词语，在解析时直接识别，作为「占位符位置」存入`XXtensionalImage`类型中
            - 参见：PyNARS `Term.py` `Compound.py`

    参考：《NAL》定义8.4
    > where ‘⋄’ is a special symbol indicating the location of T1 or T2 in the product, 
    > and in the component list it can appear in any place, except the first (which is reserved for the relational term). 
    > When it appears at the second place, the image can also be written in infix format as (R / T2) or (R \ T2).

    中译：
    > 其中『⋄』是表示T1或T2在乘积中的位置的特殊符号;
    > 在组分列表中，它可以出现在任何位置，除了第一个位置（它是为关系词项保留的）。
    > 当它出现在第二位时，像也可以用中缀格式写成 (R / T2) 或 (R \ T2)。
    """
    struct PlaceHolder <: AbstractAtom end
    "像占位符单例模式下的唯一实例"
    const placeholder::PlaceHolder = PlaceHolder()
    "检测是否为像占位符: 类似`isnothing`"
    isplaceholder(x) = x === PlaceHolder
    isplaceholder(::PlaceHolder) = true

    "【！即将弃用：请使用`Base.nameof`方法，而非直接调用属性`name`】兼容`.name`属性：对像占位符的任何属性访问都将返回空字符串"
    Base.getproperty(::PlaceHolder, ::Symbol)::String = ""
    "兼容构造方法`constructor(string|expr|...)`: 直接返回`placeholder`"
    PlaceHolder(::Any) = placeholder
    
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
    > 并以「#」前面的单词(或数字)命名。
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
    Variable{T}(name::Union{AbstractString, AbstractChar}) where {T<:AbstractVariableType} = name |> Symbol |> Variable{T}

    """
    [NAL-7]间隔(Interval)

    迁移自：PyNARS Interval.py
    - 其中Interval类继承Term
    - ⚠OpenNARS、OpenJunars中没有相关实现

    参考：《NAL》定义11.4
    
    > The real-time experience of a NARS is a sequence of Narsese sentences, separated by non-negative numbers indicating the interval between the arriving time of subsequent sentences, measured by the system’s internal clock.
    
    中译：
    > NARS的实时经验是一系列的Narsese句子，由非负数分隔，这些非负数表示后续句子到达时间之间的间隔，由系统的内部时钟测量。

    【20230815 17:19:44】因「字符串转换器字典查找问题」与「不同精度区分必要性小」不再区分精度：统一至UInt
    【20230817 15:03:35】作为NAL-7中的「事件」对象，「该对象为原子词项」只是在「组成结构」上的区分，其仍然可被认作是「事件」
    """
    struct Interval <: AbstractAtom

        "【！即将弃用：现在使用`nameof`方法，而非外加属性】（只读as缓存）继承自原子词项"
        name::Symbol # 【20230817 15:02:57】现在与其它原子词项统一使用Symbol
    
        "间隔长度"
        interval::UInt

        "内部构造方法：自动获得名称并缓存"
        Interval(interval::UInt) = check_valid_explainable(
            new(
                Symbol(interval), # 缓存名称
                interval # 存储值
            )
        )
    end

    "外部构造方法 兼容所有实数（浮点数亦兼容）"
    @inline Interval(interval::Real) = Interval(
        convert(UInt, interval)
    )

    "外部构造方法 兼容以自身名称「纯数字」定义的字符串"
    @inline Interval(s::Union{AbstractString, AbstractChar}) = Interval(parse(UInt, s))

    "外部构造方法 兼容以自身名称「纯数字」定义的符号"
    @inline Interval(s::Symbol) = Interval(string(s))

    """
    [NAL-8]操作词项(Action)

    参考：《NAL》定义12.2

    > An atomic operation is represented as an operator (a special term whose name starts with ‘⇑’)
    > followed by an argument list (a sequence of terms, though can be empty).
    > Within the system, operation “(⇑op a₁ ··· aₙ)” is treated as statement “(× self a₁ ··· aₙ) → op」,
    > where op belongs to a special type of term that has a procedural interpretation,
    > and self is a special term referring to the system itself.

    中译：
    > 一个原子操作表示为一个操作符(一个特殊的词项，其名以「⇑」开头)跟一个参数列表(一个词项序列，但可为空)。
    > 在系统内，操作「(⇑op a₁ ··· aₙ)」被视为语句「(× self a₁ ··· aₙ) → op」，
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
    Operator(name::Union{AbstractString, AbstractChar}) = name |> Symbol |> Operator

    """
    通用复合词项

    包括：
    - 词项集
        - 外延集
        - 内涵集
    - 词项逻辑集
        - 外延交/内涵交
        - 外延并/内涵并（自动重定向）
        - 外延差/内涵差
    - 陈述集
        - 陈述逻辑集
            - 合取
            - 析取
            - 否定
            - 陈述时序集
    
    不包括：
    - 外延像/内涵像（需要使用额外的「像占位符索引」）
        - 📄参考：`OpenNARS/ImageExt.java relationIndex`
    - 陈述
    
    <h1>    NAL参考    </h1>

    [NAL-2]词项集 {} []

        参考：《NAL》定义6.3、6.5
        > If T is a term, the extensional set with T as the only component, {T}, is defined by (∀x)((x → {T}) ⟺ (x ↔ {T})).
        > If T is a term, the intensional set with T as the only component, [T], is defined by (∀x)(([T] → x) ⟺ ([T] ↔ x)).

        中译：
        > 如果T是一个词项，则以T为唯一组分的外延集 {T} 定义为 (∀x)((x → {T}) ⟺ (x ↔ {T}))。
        > 如果T是一个词项，则以T为唯一组分的内涵集 [T] 定义为 (∀x)(([T] → x) ⟺ ([T] ↔ x))。
    
    [NAL-3]词项逻辑集 {外延/内涵, 交/并/差} # 此处「&」「|」是对应的「外延交&」「外延并|」
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
        
    [NAL-4]乘积 (*, ...)
        - 有序
        - 无内涵外延之分
        - 用于关系词项「(*, 水, 盐) --> 前者可被后者溶解」

        参考：《NAL》定义8.1
        > The product connector ‘×’ takes two or more terms as components,
        >   and forms a compound term that satisfies ((× S₁ ··· Sₙ) → (× P₁ ··· Pₙ)) ⟺ ((S₁ → P₁) ∧ ··· ∧ (Sₙ → Pₙ)).

        中译：
        > 乘积连接符「×」采用两个或多个词项作为组分，形成一个复合词项，
        >   满足 ((× S₁ ··· Sₙ) → (× P₁ ··· Pₙ)) ⟺ ((S₁ → P₁) ∧ ··· ∧ (Sₙ → Pₙ))。
    
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
    
        【20230817 15:44:10】细节：OpenJunars外其它NARS实现中，对复合词项的对待方法不同——是否要再度合并？
        - 在PyNARS中，陈述逻辑集、陈述时序集对元素类型无所限制，可以混用
        - 在OpenNARS中，所有复合词项统一使用`CompoundTerm`实现，并将连接词用单一的字符串存储
    
    [NAL-7]陈述时序集：{序列/平行} <: 抽象陈述逻辑集{合取}
        - 与 `&/`: 序列合取(有序)
        - 或 `&|`: 平行合取(无序)
    
        📌技术点: 此中的数据`terms`为一个指向「向量/集合」的引用
        - 即便其类型确定，它仍然是一个「指针」，不会造成效率干扰
    
        参考：《NAL》定义11.5
        > The conjunction connector (‘∧’) has two temporal variants: 「sequential conjunction」 (‘,’) and “parallel conjunction」 (‘;’).
        > 「(E1, E2)” corresponds to the compound event consisting of E1 followed by E2, and “(E1; E2)” corresponds to the compound event consisting of E1 accompanied by E2.
    
        中译：
        > 合取连接符 (‘∧’) 有两种时序变体变体:「序列合取」 (‘,’) 和「平行合取」 (‘;’)。
        > 「(E1, E2)」 对应由E1后接E2，「(E1; E2)」 对应由E1伴随E2组成的复合事件。
    """
    struct CommonCompound{type <: AbstractCompoundType} <: AbstractCompound{type}
    
        """
        有序不可变元组/集合
        - 承继旧`terms`字段
            - 保证词项构造之后不会改变
        - 一切语法上的限制，都交给「合法性检查」函数
            - 例如：陈述逻辑集只能装陈述
            - 例如：
        """
        terms::Tuple{Vararg{<:AbstractTerm}}

        """
        统一的内部构造方法
        - 统一具备合法性检查
        - 根据外部函数「构造器类型」获取构造器（支持重定向）
        - 根据「可重复性」筛选掉重复项
        """
        function CommonCompound{type}(terms::Tuple{Vararg{AbstractTerm}}) where {type <: AbstractCompoundType}
            # 根据「可重复性」筛选掉重复项，根据「可交换性」决定是否排序
            
            # 生成并处理数组
            terms_arr::Vector{AbstractTerm} = collect(terms) # 创建新数组
            is_repeatable(type) || unique!(terms_arr) # 若不可重复，筛选重复项（不会改变内容顺序）
            is_commutative(type) && sort!(terms_arr) # 若可交换，排序（不会改变内容）

            terms_tuple::Tuple = Tuple{Vararg{AbstractTerm}}(terms_arr) # 创建新元组
            constructor::Type = constructor_type(type) # 【20230818 0:30:25】注意：new不能当参数传递
            # 增加合法性检查
            return check_valid_explainable(
                constructor <: AbstractCompoundType ?
                    new{constructor}(terms_tuple) :
                    constructor(terms_tuple)
            )
        end

        #= 各个「具体类型」的内部构造方法 =#
        
        # 词项逻辑集
        
        "(有序)差集 Difference{外延/内涵} - ~" # 注意：这是二元的 参数命名参考自OpenJunars
        function CommonCompound{CompoundTypeTermLogicalSet{EIType, Not}}(ϕ₁::AbstractTerm, ϕ₂::AbstractTerm) where EIType # 此EIType构造时还会被检查类型
            ϕ₁ == ϕ₂ && error("不允许重复词项「$ϕ1==$ϕ2」！")
            check_valid_explainable(
                new{CompoundTypeTermLogicalSet{EIType, Not}}(
                    (ϕ₁, ϕ₂) # 【20230814 13:21:55】不可交换，直接构造元组，但因「不可重复」需要筛选；参考《NAL》中`different`
                )
            ) # 增加合法性检查
        end
        
        "陈述非 Negation"
        function CommonCompound{CompoundTypeStatementLogicalSet{Not}}(ϕ::AbstractTerm)
            check_valid_explainable(
                new{CompoundTypeStatementLogicalSet{Not}}((ϕ,)) # 只有一个，且不要求是陈述（留给「合法性检查」；PyNARS也兼容「非陈述元素」）
            ) # 增加合法性检查
        end # 内涵并=外延交

    end

    """
    统一的「类型重定向」函数：从
    - 避免「方法歧义冲突」`XXX is ambiguous.`
    - 开放给其它自定义复合词项类型

    @返回值：构造方法
    @默认逻辑：返回type自身，指导使用默认构造方法
    - 若为「复合词项类型」则指导构造方法重定向至`new{type}`
    """
    @inline constructor_type(type::Type)::Type = type
    @inline (constructor_type(::Type{CompoundTypeTermImage{EI}})::Type) where {EI <: AbstractEI} = @show TermImage{EI}

    "(无序，重定向)并集 Union{外延/内涵} ∪& ∪|" # 【20230724 14:12:33】暂且自动转换成交集（返回值类型参数转换不影响）（参考《NAL》定理7.4）
    @inline function constructor_type(::Type{T}) where T <: CompoundTypeTermLogicalSet{Extension, Or}
        CompoundTypeTermLogicalSet{Intension, And}
    end # 外延并=内涵交 【20230818 0:13:02】不知为何，不写成`where`就会报错「syntax: invalid variable expression in "where" around 」
    @inline function constructor_type(::Type{T}) where T <: CompoundTypeTermLogicalSet{Intension, Or}
        CompoundTypeTermLogicalSet{Extension, And}
    end
    
    "外部构造方法：统一的「任意长参数」"
    @inline function CommonCompound{type}(terms::Vararg{AbstractTerm}) where {type <: AbstractCompoundType}
        CommonCompound{type}(terms) # 直接传递封装好的Tuple
    end

    "除元组以外的支持的迭代器类型"
    const SUPPORTED_ALIAS_ITERATORS::Type = Union{
        Base.Generator,
        AbstractArray,
        Set,
    }

    "外部构造方法：重载各类迭代器"
    @inline function CommonCompound{type}(itr::SUPPORTED_ALIAS_ITERATORS) where {type}
        CommonCompound{type}(
            Tuple{Vararg{AbstractTerm}}(itr)
        )
    end

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
    > 对于关系R和乘积(× T1 T2)，乘积上关系的外延像连接符「/」和内延像连接符「\」分别定义为：
    >     ((× T1 T2) → R) ⟺ (T1 → (/ R ⋄ T2)) ⟺ (T2 → (/ R T1 ⋄))
    >     (R → (× T1 T2)) ⟺ ((\ R ⋄ T2) → T1) ⟺ ((\ R T1 ⋄) → T2)

    """
    struct TermImage{EIType <: AbstractEI} <: AbstractCompound{CompoundTypeTermImage{EIType}}
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
            # 其默认已无序
            check_valid_explainable(
                new{EIType}(terms, relation_index) # 加入合法性检查
            ) # 增加合法性检查
        end
    end

    "类型适配：对有符号整数的映射"
    @inline function TermImage{EIType}(terms::Tuple{Vararg{AbstractTerm}}, relation_index::Integer) where {EIType}
        TermImage{EIType}(terms, unsigned(relation_index))
    end

    "转换兼容支持：多参数构造(倒过来，占位符位置放在最前面)"
    @inline function TermImage{EIType}(relation_index::Integer, terms::Vararg{AbstractTerm}) where EIType
        TermImage{EIType}(terms, unsigned(relation_index))
    end

    "转换兼容支持：多参数构造(兼容「词项序列」，使用新的「像占位符」单例类型)"
    function TermImage{EIType}(terms::Vararg{AbstractTerm}) where EIType
        placeholder_index::Union{Integer, Nothing} = findfirst(isplaceholder, terms)
        isnothing(placeholder_index) && error("在参数「$terms」中未找到像占位符位置！")
        TermImage{EIType}(
            filter(!isplaceholder, terms), # 过滤出所有非占位符词项
            unsigned(placeholder_index),
        )
    end

    "转换兼容支持：从元组以外的其它迭代器构造"
    @inline function TermImage{EIType}(array::SUPPORTED_ALIAS_ITERATORS) where EIType
        TermImage{EIType}(array...)
    end

end

begin "陈述词项"

    raw"""
    [NAL=1|NAL-5]陈述Statement{继承/相似/蕴含/等价/...} --> <-> ==> <=> ...
    - 现只支持「二元」陈述，只表达两个词项之间的关系
    - ❎【20230804 14:17:30】现增加「时序」参数，以便在词项层面解析「时序关系」
    - 【20230804 14:44:13】现把「时序系词」作为「主系词」（参考自OpenNARS）
    - 【20230812 22:19:20】加入「合法性检查」机制

    参考：《NAL》定义2.2、6.1、9.1、9.5、11.6、11.7
        继承
            参考：《NAL》定义2.2
            > The basic form of a statement is an inheritance statement,
            >   「S → P」, where S is the subject term, P is the predicate term, and ‘→’ is the inheritance copula,
            >   defined as being a reflexive and transitive relation from one term to another term.
            
            中译：
            > 陈述的基本形式是继承陈述「S→P」，
            >   其中S为主词项，P为谓词项，「→」为继承系词，
            >   定义为从一个词项到另一个词项的自反传递关系。
        相似
            参考：《NAL》定义6.1
            > For any terms S and P, similarity ‘↔’ is a copula defined by
            >   (S ↔ P) ⟺ ((S → P) ∧ (P → S)).

            中译：
            > 对于任何词项S和P，相似『↔』是由下者定义之词项：
            >   (S ↔ P) ⟺ ((S → P) ∧ (P → S))。

        蕴含
            参考：《NAL》定义9.1
            > If S1 and S2 are statements, “S1 ⇒ S2” is true if and only if in IL S2 can be derived from S1 in a finite number of inference steps. 
            > Here ‘⇒’ is the implication copula. Formally, it means (S1 ⇒ S2) ⟺ {S1} ⊢ S2.

            中译：  
            > 如果 S1 和 S2 是陈述，则「S1 ⇒ S2」为真，如果且仅当在 IL 中，S2 可以从 S1 进行有限数量的推理步骤而得出。
            > 这里的『⇒』是「蕴含」系词。形式上，它的意思是 (S1 ⇒ S2) ⟺ {S1} ⊢ S2。
        等价
            参考：《NAL》定义9.5
            > The equivalence copula, ‘⇔’, is defined by 
            >   (A ⇔ C) ⟺ ((A ⇒ C) ∧ (C ⇒ A))
            > As a special type of compound terms, compound statements can be used to summarize existing statements.

            中译：
            > 「等价」系词『⇔』的定义是
            >   (A ⇔ C) ⟺ ((A ⇒ C) ∧ (C ⇒ A))

        时序蕴含/等价

            参考：《NAL》定义11.6
            > For an implication statement “S ⇒ T” between events S and T, three different temporal relations can be specified:
            > (1) If S happens before T happens, 
            > the statement is called “predictive implication」, and is rewritten as “S /⇒ T」, 
            > where S is called a sufficient precondition of T, 
            > and T a necessary postcondition of S.
            > (2) If S happens after T happens, 
            > the statement is called “retrospective implication」, and is rewritten as “S \⇒ T」, 
            > where S is called a sufficient postcondition of T, 
            > and T a necessary precondition of S.
            > (3) If S happens when T happens, 
            > the statement is called “concurrent implication」, and is rewritten as “S |⇒ T」, 
            > where S is called a sufficient co-condition of T, 
            > and T a necessary co-condition of S.

            中译：
            > 对于事件S和T之间的蕴含语句「S⇒T」，可以指定三种不同的时间关系:
            > (1)如果S发生在T发生之前，该陈述称为「预测性蕴含」，并重写为「S/⇒T」，
            > 其中S是T的充分前提，T是S的必要后置条件。
            > (2)如果S发生在T发生之后，该陈述称为「回顾性蕴含」，并重写为「S\⇒T」，
            > 其中S是T的充分后置条件，T是S的必要前提。
            > (3)如果T发生时S同时发生，该陈述称为「并发性蕴含」，并重写为「S|⇒T」，
            > 其中S是T的充分协条件，T是S的必要协条件。

            参考：《NAL》定义11.7
            Three “temporal equivalence」 (predictive, retrospective,
            and concurrent) relations are defined as the following:
            > (1) 「S /⇔ T」 (or equivalently, 「T \⇔ S」) means that S is an equivalent precondition of T, and T an equivalent postcondition of S.
            > (2) 「S |⇔ T” means that S and T are equivalent co-conditions of each other.
            > (3) To simplify the language, 「T \⇔ S” is always represented as “S /⇔ T」, so the copula “ \⇔” is not actually included in the grammar of Narsese.

            中译：
            三个「时间等价」(预测性、回顾性、并发性)关系定义如下:
            > (1)「S /⇔ T」(或等价地，「T \⇔ S」)表示S是T的等价前提，T是S的等价后置条件。
            > (2)「S |⇔ T」表示S和T是彼此的等价共条件。
            > (3)为了简化语言，「T \⇔ S」总是被表示为「S /⇔ T」，所以关联词「\⇔」实际上并不在Narsese语法中。
            >   - 译者注：此举与先前的「外延并/内涵并」类似
    """
    struct Statement{type <: AbstractStatementType} <: AbstractStatement{type}
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
                is_commutative(type) ? # 可交换⇒排序
                    new{type}(sort!([ϕ1, ϕ2])...) :
                    new{type}(ϕ1, ϕ2)
            ) # 增加合法性检查
        end
    end

    "转换兼容支持：从迭代器构造"
    Statement{type}(iter) where type = Statement{type}(iter...)

end

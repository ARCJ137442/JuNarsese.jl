#=
使用Unicode运算符/宏，辅助构建Narsese
=#

export @w_str
export ⋄
export →, ⇒, ↔, ⇔
export ∧, ∨, ¬

begin "单体词项"
    
    FLAG_TYPE_DICT::Dict{String, DataType} = Dict(
        "i" => Variable{VTIndependent},
        "d" => Variable{VTDependent},
        "q" => Variable{VTQuery},
        "o" => Operator,
    )

    """
    字符串宏，用于构建原子词项（词/变量）
    - 📌Julia直接返回字面量，也是可以的
    """
    macro w_str(name::String)
        return name |> Symbol |> Word
    end

    "可用后缀指定是否为变量(词语/变量/操作)"
    macro w_str(name::String, flag::String)
        if flag in keys(FLAG_TYPE_DICT)
            return name |> Symbol |> FLAG_TYPE_DICT[flag]
        else
            return name |> Symbol |> Word
        end
    end
end

begin "复合词项"

    """
    外延集
    
    示例：A & B & C (&, A, B, C)
    """
    Base.:(&)(t1::Term, t2::Term) = ExtSet(t1, t2)
    Base.:(&)(t1::ExtSet, t2::Term) = ExtSet(t1.terms..., t2)
    Base.:(&)(t1::Term, t2::ExtSet) = t2 & t1 # 交换律
    Base.:(&)(t1::ExtSet, t2::ExtSet) = ExtSet(t1.terms..., t2.terms...)

    """
    内涵集
    
    示例：A | B | C -> (|, A, B, C)
    """
    Base.:(|)(t1::Term, t2::Term) = IntSet(t1, t2)
    Base.:(|)(t1::IntSet, t2::Term) = IntSet(t1.terms..., t2)
    Base.:(|)(t1::Term, t2::IntSet) = t2 | t1 # 交换律
    Base.:(|)(t1::IntSet, t2::IntSet) = IntSet(t1.terms..., t2.terms...)

    """
    外延交=内涵并
    
    示例：注意：Julia保留了「&&」运算符，也无法使用「∩& ∩|」
    """
    Base.:(∩)(t1::Term, t2::Term) = ExtIntersection(t1, t2) # 默认是外延交(后续就直接递推)
    Base.:(∩)(t1::TermLogicalSet{EI, And}, t2::Term) where EI <: AbstractEI = TermLogicalSet{EI, And}(t1.terms..., t2)
    Base.:(∩)(t1::Term, t2::TermLogicalSet{EI, And}) where EI <: AbstractEI = t2 ∩ t1 # 交换律
    Base.:(∩)(t1::TermLogicalSet{EI, And}, t2::TermLogicalSet{EI, And}) where EI <: AbstractEI = TermLogicalSet{EI, And}(t1.terms..., t2.terms...)

    """
    内涵交=外延并
    """
    Base.:(∪)(t1::Term, t2::Term) = IntIntersection(t1, t2) # 默认是外延交(后续就直接递推)
    Base.:(∪)(t1::TermLogicalSet{EI, And}, t2::Term) where EI <: AbstractEI = TermLogicalSet{EI, And}(t1.terms..., t2)
    Base.:(∪)(t1::Term, t2::TermLogicalSet{EI, And}) where EI <: AbstractEI = t2 ∪ t1 # 交换律
    Base.:(∪)(t1::TermLogicalSet{EI, And}, t2::TermLogicalSet{EI, And}) where EI <: AbstractEI = TermLogicalSet{EI, And}(t1.terms..., t2.terms...)

    """
    内涵/外延 差
    - 只有二元运算符
    """
    Base.:(-)(t1::Term, t2::Term) = ExtDiff(t1, t2) # 默认是外延交(后续就直接递推)
    Base.:(~)(t1::Term, t2::Term) = IntDiff(t1, t2) # 默认是外延交(后续就直接递推)

    """
    像(外/内\\)，再加「占位符」
    - 这里需要「临时非法」，方可在后面构造出「合法」（必须含有一个「占位符」）
    - 实际上只有第一个符号决定了类型，如下例中的「c / b」
         - 考虑把「连接符」用「-」表示？

    示例：`a / b ⋄ c` ⇔ (/, a, b, _, c)
    """
    Base.:(/)(t1::Term, t2::Term) = ExtImage(0, t1, t2)
    # 「0」作为「没有占位符」的状态标记
    Base.:(\)(t1::Term, t2::Term) = IntImage(0, t1, t2)

    """
    只作为一个「连接符」而存在
    - ⚠不创建新Term，而是改变已知Term t1
    """
    function Base.:(/)(t1::TermImage{EI}, t2::Term) where EI <: AbstractEI
        push!(t1.terms, t2)
        t1
    end

    "一样的连接符"
    Base.:(\)(t1::TermImage{EI}, t2::Term) where EI <: AbstractEI = t1 / t2

    """
    根据词项序列构造像
    - 例：`/(A, B, ⋄, C)` == "(/, A, B, _, C"
    """
    function _construct_image(::Type{EI}, terms::Tuple)::TermImage where EI <: AbstractEI
        # 获取索引
        for (i, t) in enumerate(terms)
            if t == ⋄ # 等于「占位符」
                return TermImage{EI}(
                    Tuple{AbstractTerm}(
                        term
                        for term in terms
                        if term isa AbstractTerm # 过滤
                    )
                    i,
                )
            end
        end
        return nothing # 会报错
    end

    # TODO: 可以使用多元函数/(A,B,⋄,C)这样构造
    Base.:(/)(terms...) = _construct_image(Extension, terms)

    "一样的连接符"
    Base.:(\)(terms...) = _construct_image(Intension, terms)

    """
    【20230724 22:03:40】注意：「⋄」不是Base包里面的
    - 后续可能length(t1) ≠ length(t1.terms)
    - 此处之「+1」是为了把「_」安插在「新词项的本来位置」
    """
    function ⋄(t1::TermImage{EI}, t2::Term) where EI <: AbstractEI
        TermImage{EI}(
            length(t1.terms)+1, # 因为这个量不可变，所以需要构造新词项（TODO：考虑用mutable+const？）
            t1.terms..., t2, 
        )
    end

    """
    乘积(*)
    - 还是「链式构造」
    """
    Base.:(*)(t1::Term, t2::Term) = TermProduct(t1, t2)
    Base.:(*)(t1::TermProduct, t2::Term) = TermProduct(t1.terms..., t2)
    Base.:(*)(t1::Term, t2::TermProduct) = TermProduct(t1, t2.terms...)
    Base.:(*)(t1::TermProduct, t2::TermProduct) = TermProduct(t1.terms..., t2.terms...)

    # 各类语句
    """
    各类语句的「快速构造方式」
    1. 继承
    2. 相似
    3. 蕴含
    4. 等价

    - 📌【20230727 19:57:39】现在只支持二元构造
    - 📌关于这些语句「是否是对称的」，交给下一层次的「NAL」处理
        - 本质上只是「视觉上看起来对称」而已
    """
    →(t1::Term, t2::Term) = Inheriance(t1, t2)
    ↔(t1::Term, t2::Term) = Similarity(t1, t2)
    ⇒(t1::Term, t2::Term) = Implication(t1, t2)
    ⇔(t1::Term, t2::Term) = Equivalance(t1, t2)

    """
    语句「非」
    """
    ¬(t::AbstractStatement) = Negation(t)

    """
    语句「与」
    """
    ∧(t1::Term, t2::Term) = Conjunction(t1, t2) # 默认是外延交(后续就直接递推)
    ∧(t1::Conjunction, t2::Term) = Conjunction(t1.terms..., t2)
    ∧(t1::Term, t2::Conjunction) = Conjunction(t1, t2.terms...)
    ∧(t1::Conjunction, t2::Conjunction) = Conjunction(t1.terms..., t2.terms...)

    """
    语句「或」
    """
    ∨(t1::Term, t2::Term) = Disjunction(t1, t2) # 默认是外延交(后续就直接递推)
    ∨(t1::Disjunction, t2::Term) = Disjunction(t1.terms..., t2)
    ∨(t1::Term, t2::Disjunction) = Disjunction(t1, t2.terms...)
    ∨(t1::Disjunction, t2::Disjunction) = Disjunction(t1.terms..., t2.terms...)

end

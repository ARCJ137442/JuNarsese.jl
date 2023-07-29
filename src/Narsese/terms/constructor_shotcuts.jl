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
    - 根据词项序列构造像

    示例：`a / b ⋄ c` ⇔ (/, a, b, _, c)
    """
    function _construct_image(::Type{EI}, terms::Tuple)::TermImage where EI <: AbstractEI
        # 获取索引
        for (i, t) in enumerate(terms)
            if (t == ⋄) || isnothing(t) || ismissing(t) # 判断「占位符」的条件 📌注意用括号避免运算符歧义「syntax: "⋄" is not a unary operator」
                return TermImage{EI}( # 一次性生成，然后break
                    Tuple{Vararg{Term}}( # 📌不能使用Tuple{AbstractTerm}，这样会删掉后续的元素
                        term
                        for term in terms
                        if term isa AbstractTerm # 过滤
                    ),
                    i,
                )
            end
        end
        return nothing # 会报错
    end

    "使用多元函数构造"
    Base.:(/)(terms...) = _construct_image(Extension, terms)

    "一样的构造符"
    Base.:(\)(terms...) = _construct_image(Intension, terms)

    """
    【20230724 22:03:40】注意：「⋄」不是Base包里面的
    - 【20230730 0:39:07】只需要声明下已定义即可
    """
    function ⋄ end
    """
    乘积(*)
    - 还是「链式构造」
    """
    Base.:(*)(terms::Vararg{Term}) = TermProduct(terms...)

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

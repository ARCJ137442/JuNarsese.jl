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
    
    示例：&(A, B, C) -> {A, B, C}
    """ # TODO: 修复「syntax: invalid syntax &(1, 2) around」
    Base.:(&)(terms::Vararg{Term}) = ExtSet(terms...)

    """
    内涵集
    
    示例：|(A, B, C) -> [A, B, C]
    """
    Base.:(|)(terms::Vararg{Term}) = IntSet(terms...)

    """
    外延交=内涵并
    
    示例：∩(A, B, C) -> (&, A, B, C)
    注意：Julia保留了「&&」运算符，也无法使用「∩& ∩|」
    """
    Base.:(∩)(terms::Vararg{Term}) = ExtIntersection(terms...) # 默认是外延交

    """
    内涵交=外延并

    示例：∪(A, B, C) -> (|, A, B, C)
    """
    Base.:(∪)(terms::Vararg{Term}) = IntIntersection(terms...) # 内涵交

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

    # 各类陈述
    """
    各类陈述的「快速构造方式」
    1. 继承
    2. 相似
    3. 蕴含
    4. 等价

    - 📌【20230727 19:57:39】现在只支持二元构造
    - 📌关于这些陈述「是否是对称的」，交给下一层次的「NAL」处理
        - 本质上只是「视觉上看起来对称」而已
    """
    →(t1::Term, t2::Term) = Inheriance(t1, t2)
    ↔(t1::Term, t2::Term) = Similarity(t1, t2)
    ⇒(t1::Term, t2::Term) = Implication(t1, t2)
    ⇔(t1::Term, t2::Term) = Equivalance(t1, t2)
    # TODO 链式方法

    """
    陈述「非」
    """
    ¬(t::AbstractStatement) = Negation(t)

    """
    陈述「与」
    """
    ∧(terms::Vararg{Term}) = Conjunction(terms...)

    """
    陈述「或」
    """
    ∨(terms::Vararg{Term}) = Disjunction(terms...)

end

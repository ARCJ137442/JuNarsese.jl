#=
使用Unicode运算符/宏，辅助构建Narsese
=#

export ⩀, ⊍
export ⋄
export →, ⇒, ↔, ⇔
export ∧, ∨, ¬
export ⩚, ⩜

begin "单体词项"
    
    """
    定义在「定义字符串宏」时用到的头

    例："w" ==> `w_str` ==> `w"词语名"`

    【20230815 17:14:16】对「间隔」网开一面（Type而非DataType）
    """
    HEAD_TYPE_DICT::Dict{String, Type} = Dict(
        "w" => Word,
        "i" => IVar,
        "d" => DVar,
        "q" => QVar,
        "n" => Interval, # 🆕间隔
        "o" => Operator,
    )

    # 循环添加相应宏
    for (head::AbstractString, type::Type) in HEAD_TYPE_DICT
        macro_name::Symbol = Symbol(head, :_str)
        quote
            """
            字符串宏，用于构建原子词项（词/变量）
            - 📌Julia直接返回字面量，也是可以的
            """
            macro $macro_name(name::String)
                return name |> Symbol |> $type
            end
            
        end |> eval
        # 导出各个宏
        Expr(:export, Symbol("@", head, :_str)) |> eval
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
    外延集：使用另一种兼容格式
    
    示例：⩀(A, B, C) -> {A, B, C}
    """ # TODO: 修复「syntax: invalid syntax &(1, 2) around」
    ⩀(terms::Vararg{Term}) = ExtSet(terms...)

    """
    内涵集：使用另一种兼容格式
    
    示例：⊍(A, B, C) -> [A, B, C]
    """
    ⊍(terms::Vararg{Term}) = IntSet(terms...)

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

    "外延像：使用多元函数构造"
    Base.:(/)(terms...) = TermImage{Extension}(terms...)

    "内涵像：类似的构造方式"
    Base.:(\)(terms...) = TermImage{Intension}(terms...)

    """
    【20230724 22:03:40】注意：「⋄」不是Base包里面的
    - 【20230730 0:39:07】只需要声明下已定义即可
    - 【20230818 16:41:56】现在「⋄」等价于「像占位符」，不再是「任意值」了
        - 仍然向下兼容
    """
    const ⋄ = placeholder # 不能标注类型，因为其原本为「运算符」`Base.isoperator(:⋄) == true`

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
    →(t1::Term, t2::Term) = Inheritance(t1, t2)
    ↔(t1::Term, t2::Term) = Similarity(t1, t2)
    # 基于陈述而非全体词项 【20230817 20:38:23】交给构造时检验合法性
    ⇒(t1::Term, t2::Term) = Implication(t1, t2)
    ⇔(t1::Term, t2::Term) = Equivalence(t1, t2)

    """
    陈述逻辑「非」
    """
    ¬(t::Term) = Negation(t)

    """
    陈述逻辑「与」
    """
    ∧(terms::Vararg{Term}) = Conjunction(terms...)

    """
    陈述逻辑「或」
    """
    ∨(terms::Vararg{Term}) = Disjunction(terms...)

    """
    陈述时序「平行」（原创）
    - LaTeX: `\\wedgemidvert`
    """
    ⩚(terms::Vararg{Term}) = ParConjunction(terms...)

    """
    陈述时序「序列」（原创）
    - LaTeX: `\\midbarwedge`
    """
    ⩜(terms::Vararg{Term}) = SeqConjunction(terms...)


end

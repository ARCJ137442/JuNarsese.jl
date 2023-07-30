#=
提供所有与字符串相关的方法
=#
export StringParser_basical, StringParser_latex

"""
定义「字符串转换器」
- 使用「结构+实例」的形式实现「个性化」
    - 可复用的常量参数
- 提供字符串处理方法
- 可以通过其中存储的常量，特化出不同的转换器
    - 此用法将在latex.jl中使用，以便重用代码
"""
struct StringParser <: AbstractParser

    "原子到字符串的字典"
    atom_prefixes::Dict{DataType, String}
    "反转的字典"
    prefixes2atom::Dict{String, DataType}

    "像占位符的位置"
    placeholder_string::String

    """
    词项集类型 => (前缀, 后缀)
    用于`前缀 * 词项组 * 后缀`
    """
    term_set_brackets::Dict{DataType, Tuple{String, String}}

    """
    词项类型 => 符号
    用于`(符号, 内部词项...)`

    - 暂时不写「并」：在「代码表示」（乃至Latex原文）中都没有对应的符号
    """
    compound_symbols::Dict{DataType, String}

    """
    陈述类型 => 联结词(字符串)
    """
    copulas::Dict{DataType, String}

    """
    副联结词
    """
    secondary_copulas::Dict{DataType, String}

    """
    时态
    """
    tenses::Dict{DataType, String}

    """
    标点
    """
    punctuations::Dict{DataType, String}

    "构造函数"
    function StringParser(
        atom_prefixes::Dict{DataType, String},
        placeholder_string::String,
        term_set_brackets::Dict{DataType, Tuple{String, String}},
        compound_symbols::Dict{DataType, String},
        copulas::Dict{DataType, String},
        # secondary_copulas::Dict{DataType, String},
        # tenses::Dict{DataType, String},
        # punctuations::Dict{DataType, String},
        )
        new(
            atom_prefixes,
            Dict( # 自动反转字典
                @reverse_dict_content atom_prefixes
            ),
            placeholder_string,
            term_set_brackets,
            compound_symbols,
            copulas,
            # secondary_copulas,
            # tenses,
            # punctuations,
        )
    end

end

"""
（默认）实例化，并作为一个「转换器」导出
- 来源：文档 `NARS ASCII Input.pdf`
"""
StringParser_basical::StringParser = StringParser(
    Dict(
        Word => "", # 置空
        IVar => "\$",
        DVar => "#",
        QVar => "?",
        Operator => "^", # 操作
    ),
    "_",
    Dict(
        TermSet{Extension} => ("{", "}"), # 外延集
        TermSet{Intension} => ("[", "]"), # 内涵集
    ),
    Dict(
        ExtIntersection => "&",
        IntIntersection => "|",
        ExtDifference => "-",
        IntDifference => "~",
        # 像
        ExtImage => "/",
        IntImage => "\\",
        # 乘积
        TermProduct => "*",
        # 陈述逻辑集
        Conjunction => "&&",
        Disjunction => "||",
        Negation => "--",
    ),
    Dict(
        STInheriance => "-->",
        STSimilarity => "<->",
        STImplication => "==>",
        STEquivalance => "<=>",
    ),
    #=
    Dict( # 副联结词（语法糖）
        # 实例&属性
        SecondaryCopula{Extension, STInheriance}            => "{--",
        SecondaryCopula{STInheriance, Intension}            => "--]",
        SecondaryCopula{Extension, STInheriance, Intension} => "{-]",
        # 时序蕴含
        SecondaryCopula{STImplication, Past}    => raw"=\>",
        SecondaryCopula{STImplication, Present} => raw"=/>",
        SecondaryCopula{STImplication, Future}  => raw"=|>",
        # 时序等价
        SecondaryCopula{STEquivalance, Past}    => raw"<\>",
        SecondaryCopula{STEquivalance, Present} => raw"<|>",
        SecondaryCopula{STEquivalance, Future}  => raw"</>",
    ),
    Dict( # 时态
        Past       => ":\\:",
        Present    => ":|:",
        Future     => ":/:",
        Sequential => "&/",
        Parallel   => "&|",
    ),
    Dict( # 标点
        Judgment => ".",
        Question => "?",
        Goal     => "!",
        Query    => "@",
    ),
    =#
)

"""
（Latex扩展）实例化，并作为一个「转换器」导出
- 来源：文档 `NARS ASCII Input.pdf`
"""
StringParser_latex::StringParser = StringParser(
    Dict(
        Word => "", # 置空
        IVar => "\$",
        DVar => "\\#",
        QVar => "?",
        Operator => "\\Uparrow", # 操作
    ),
    "\\diamond",
    Dict(
        TermSet{Extension} => ("{", "}"), # 外延集
        TermSet{Intension} => ("[", "]"), # 内涵集
    ),
    Dict(
        ExtIntersection => "\\cap",
        IntIntersection => "\\cup",
        ExtDifference => "\\minus",
        IntDifference => "\\minus",
        # 像
        ExtImage => "/",
        IntImage => "\\",
        # 乘积
        TermProduct => "\\times",
        # 陈述逻辑集
        Conjunction => "\\wedge",
        Disjunction => "\\vee",
        Negation => "\\neg",
    ),
    Dict(
        STInheriance => "\\rightarrow",
        STSimilarity => "\\leftrightarrow",
        STImplication => "\\Rightarrow",
        STEquivalance => "\\LeftRightArrow",
    ),
    #=
    Dict( # 副联结词（语法糖）
        # 实例&属性
        SecondaryCopula{Extension, STInheriance}            => raw"\circ\!\!\!\rightarrow",
        SecondaryCopula{STInheriance, Intension}            => raw"\rightarrow\!\!\!\circ",
        SecondaryCopula{Extension, STInheriance, Intension} => raw"\circ\!\!\!\rightarrow\!\!\!\circ",
        # 时序蕴含
        SecondaryCopula{STImplication, Past}    => raw"\\!\!\!\!\Rightarrow",
        SecondaryCopula{STImplication, Present} => raw"|\!\!\!\!\Rightarrow",
        SecondaryCopula{STImplication, Future}  => raw"/\!\!\!\!\Rightarrow",
        # 时序等价
        SecondaryCopula{STEquivalance, Past}    => raw"\\!\!\!\!\Leftrightarrow",
        SecondaryCopula{STEquivalance, Present} => raw"|\!\!\!\!\Leftrightarrow",
        SecondaryCopula{STEquivalance, Future}  => raw"/\!\!\!\!\Leftrightarrow",
    ),
    Dict( # 时态
        Past         => raw"\\!\!\!\!\Rightarrow",
        Present      => raw"|\!\!\!\!\Rightarrow",
        Future       => raw"/\!\!\!\!\Rightarrow",
        Sequential   => ",",
        Parallel     => ";",
    ),
    Dict( # 标点
        Judgment => ".",
        Question => "?",
        Goal     => "!",
        Query    => "\\questiondown",
    ),
    =#
)


"普通字符串"
Base.eltype(::StringParser) = String

## 已在template.jl导入
# using ..Util
# using ..Narsese

# 【特殊链接】词项↔字符串 #
Base.parse(::Type{T}, s::String) where T <: Term = data2term(StringParser_basical, T, s)

Base.string(t::Term)::String = term2data(StringParser_basical, t) # 若想一直用term2data，则其也需要注明类型变成term2data(String, t)
Base.repr(t::Term)::String = term2data(StringParser_basical, t)
Base.show(io::IO, t::Term) = print(io, term2data(StringParser_basical, t)) # 📌没有注明「::IO」会引发歧义

"构造函数支持"
(::Type{Narsese.Term})(s::String) = data2term(StringParser_basical, Term, s)

# 正式开始 #

begin "陈述形式"

    """
    原子词项：前缀+内容
    例子："^操作"
    """
    function form_atom(prefix::String, content::String)::String
        prefix * content # 自动拼接
    end

    """
    陈述：<词项+连接符+词项>
    例子："<A ==> B>
    """
    function form_statement(first::String, copula::String, last::String)::String
        "<$first $copula $last>"
    end
    
    """
    词项集：前缀+插入分隔符的内容+后缀
    例子："[A, B, C]"
    """
    function form_term_set(prefix::String, suffix::String, contents::Vector{String}, separator::String)::String
        prefix * join(contents, separator) * suffix # 字符也能拼接
    end

    """
    逻辑集：(符号+插入分隔符的内容)
    例子："(/, A, B, _, C)"
    """
    function form_logical_set(symbol::String, contents, separator::String)::String
        "($symbol$separator$(join(contents, separator)))"
    end
end

"总「解析」方法"
function data2term(parser::StringParser, ::Type{Term}, s::String)
    @info "WIP!"
end

begin "原子↔字符串"

    "（通用）原子→字符串：前缀+名"
    function term2data(parser::StringParser, a::Narsese.Atom)::String
        form_atom(
            parser.atom_prefixes[typeof(a)],
            string(a.name)
        )
    end

    """
    （通用）字符串→原子
    1. 识别前缀(自动查字典)
    2. 统一构造
        - 协议：默认类型有一个「类型(名字)」的构造方法
    """
    function data2term(parser::StringParser, ::Type{Atom}, s::String)::Atom
        type::DataType = get(parser.prefixes2atom, s[1], Word)
        s[2:end] |> Symbol |> type
    end

    # 词语↔字符串
    "字符串→词语：沿用其名"
    data2term(parser::StringParser, ::Type{Word}, s::String)::Word = s |> Symbol |> Word

    # 变量↔字符串

    """
    字符串→变量
    1. 由头符号识别变量类型（独立、非独、询问）
    2. 把去头后的名字变为「变量标识名」

    示例：`data2term(StringParser, Variable, "#exists") == w"exists"d`
    """
    function data2term(parser::StringParser, ::Type{Variable}, s::String)::Variable
        parser.prefixes2atom[s[1] |> string](s[2:end] |> Symbol)
    end

    # 操作符↔字符串

    "字符串→操作：截取⇒转换"
    function data2term(parser::StringParser, ::Type{Operator}, s::String)::Operator
        s[2:end] |> Symbol |> Operator
    end

end

begin "复合词项↔字符串"

    # 陈述
    """
    陈述→字符串
    """
    function term2data(parser::StringParser, s::Statement{Type}) where Type
        form_statement(
            string(s.ϕ1), 
            parser.copulas[Type], 
            string(s.ϕ2),
        )
    end

    # TODO 字符串→陈述
    
    # 词项集↔字符串
    "词项集→字符串：join+外框"
    term2data(parser::StringParser, t::TermSet)::String = form_term_set(
        parser.term_set_brackets[typeof(t)]..., # 前后缀
        t.terms .|> string, # 内容
        ", "
    )

    # 字符串→词项

    """
    字符串→外延集/内涵集：
    1. 去头尾
    2. 逗号分割

    例子(无额外空格)
    - `data2term(StringParser, TermSet{Extension}, "{A,B,C}") == TermSet{Extension}(A,B,C)`
    """
    function data2term(parser::StringParser, ::Type{TermSet{EI}}, s::String)::TermSet{EI} where {EI <: AbstractEI}
        TermSet{EI}(
            split(s[2:end-1],",") .|> String .|> Data2Term{StringParser_basical, Term}
        )
    end

    "左括号→类型"
    BRACE_TYPE_DICT::Dict{String, Type} = Dict(
        "{" => TermSet{Extension},
        "[" => TermSet{Intension},
    )

    "更一般的情况"
    function data2term(parser::StringParser, ::Type{TermSet}, s::String)::TermSet
        data2term(
            StringParser_basical, 
            TermSet{BRACE_TYPE_DICT[s[1]]},
            s
        )
    end

    # 词项逻辑集：交并差

    """
    三项通用：
    1. 词项逻辑集
    2. 乘积
    3. 陈述逻辑集
    """
    term2data(
        parser::StringParser, 
        t::Union{TermLSet,TermProduct,StatementLSet}
    ) = form_logical_set(
        parser.compound_symbols[typeof(t)],
        t.terms .|> string,
        ", "
    )

    # TODO 字符串→词项

    # 像

    """
    外延/内涵 像
    - 特殊处理：位置占位符
    """
    term2data(parser::StringParser, t::TermImage) = form_logical_set(
        parser.compound_symbols[typeof(t)],
        [
            t.terms[1:t.relation_index-1]...,
            parser.placeholder_string,
            t.terms[t.relation_index:end]...,
        ],
        ", "
    )

end

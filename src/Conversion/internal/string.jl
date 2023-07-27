export StringParser

"定义抽象的「字符串转换器」，提供字符串处理方法"
abstract type StringParser <: AbstractParser end

"短别名"
TSParser = Type{StringParser}

"普通字符串"
Base.eltype(::TSParser) = String

## 已在template.jl导入
# using ..Util
# using ..Narsese

# 【特殊链接】词项↔字符串 #
Base.parse(::Type{T}, s::String) where T <: Term = data2term(StringParser, T, s)

Base.string(t::Term)::String = term2data(StringParser, t) # 若想一直用term2data，则其也需要注明类型变成term2data(String, t)
Base.repr(t::Term)::String = term2data(StringParser, t)
Base.show(io::IO, t::Term) = print(io, term2data(StringParser, t)) # 📌没有注明「::IO」会引发歧义

"构造函数支持"
(::Type{Narsese.Term})(s::String) = data2term(StringParser, Term, s)

# 正式开始 #

begin "常量区"
    
    "原子到字符串的字典"
    const ATYPE_PREFIX_DICT::Dict{DataType, String} = Dict(
        Word => "", # 置空
        IVar => "\$",
        DVar => "#",
        QVar => "?",
        Operator => "^", # 操作
    )
    "反转的字典"
    const PREFIX_ATYPE_DICT::Dict{String, DataType} = Dict(
        @reverse_dict_content ATYPE_PREFIX_DICT
    )

    """
    词项集类型 => (前缀, 后缀)
    用于`前缀 * 词项组 * 后缀`
    """
    const TYPE_SET_FIX_DICT::Dict{DataType, Tuple{String, String}} = Dict(
        TermSet{Extension} => ("{", "}"), # 外延集
        TermSet{Intension} => ("[", "]"), # 内涵集
    )

    """
    词项类型 => 符号
    用于`(符号, 内部词项...)`

    - 暂时不写「并」：在「代码表示」（乃至Latex原文）中都没有对应的符号
    """
    const TYPE_SYMBOL_DICT::Dict{DataType, String} = Dict(
        ExtIntersection => "&",
        IntIntersection => "|",
        ExtDifference => "-",
        IntDifference => "~",
        # 像
        ExtImage => "/",
        IntImage => "\\",
        # 乘积
        TermProduct => "*",
        # 语句逻辑集
        Conjunction => "&&",
        Disjunction => "||",
        Negation => "--",
    )

    """
    语句类型 => 连接符(字符串)
    """
    const COPULA_DICT::Dict{DataType, String} = Dict(
        STInheriance => "-->",
        STSimilarity => "<->",
        STImplication => "==>",
        STEquivalance => "<=>",
    )

end

begin "语句形式"

    """
    原子词项：前缀+内容
    例子："^操作"
    """
    function form_atom(prefix::String, content::String)::String
        prefix * content # 自动拼接
    end

    """
    语句：<词项+连接符+词项>
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
function data2term(::TSParser, ::Type{Term}, s::String)
    @info "WIP!"
end

begin "原子↔字符串"

    "（通用）原子→字符串：前缀+名"
    function term2data(::TSParser, a::Narsese.Atom)::String
        form_atom(
            ATYPE_PREFIX_DICT[typeof(a)],
            string(a.name)
        )
    end

    """
    （通用）字符串→原子
    1. 识别前缀(自动查字典)
    2. 统一构造
        - 协议：默认类型有一个「类型(名字)」的构造方法
    """
    function data2term(::TSParser, ::Type{Atom}, s::String)::Atom
        type::DataType = get(PREFIX_ATYPE_DICT, s[1], Word)
        s[2:end] |> Symbol |> type
    end

    # 词语↔字符串
    "字符串→词语：沿用其名"
    data2term(::TSParser, ::Type{Word}, s::String)::Word = s |> Symbol |> Word

    # 变量↔字符串

    """
    字符串→变量
    1. 由头符号识别变量类型（独立、非独、询问）
    2. 把去头后的名字变为「变量标识名」

    示例：`data2term(StringParser, Variable, "#exists") == w"exists"d`
    """
    function data2term(::TSParser, ::Type{Variable}, s::String)::Variable
        PREFIX_ATYPE_DICT[s[1] |> string](s[2:end] |> Symbol)
    end

    # 操作符↔字符串

    "字符串→操作：截取⇒转换"
    function data2term(::TSParser, ::Type{Operator}, s::String)::Operator
        s[2:end] |> Symbol |> Operator
    end

end

begin "复合词项↔字符串"

    # 语句
    """
    语句→字符串
    """
    function term2data(::TSParser, s::Statement{Type}) where Type
        form_statement(
            string(s.ϕ1), 
            COPULA_DICT[Type], 
            string(s.ϕ2),
        )
    end

    # TODO 字符串→语句
    
    # 词项集↔字符串
    "词项集→字符串：join+外框"
    term2data(::TSParser, t::TermSet)::String = form_term_set(
        TYPE_SET_FIX_DICT[typeof(t)]..., # 前后缀
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
    function data2term(::TSParser, ::Type{TermSet{EI}}, s::String)::TermSet{EI} where {EI <: AbstractEI}
        TermSet{EI}(
            split(s[2:end-1],",") .|> String .|> Data2Term{StringParser, Term}
        )
    end

    "左括号→类型"
    BRACE_TYPE_DICT::Dict{String, Type} = Dict(
        "{" => TermSet{Extension},
        "[" => TermSet{Intension},
    )

    "更一般的情况"
    function data2term(::TSParser, ::Type{TermSet}, s::String)::TermSet
        data2term(
            StringParser, 
            TermSet{BRACE_TYPE_DICT[s[1]]},
            s
        )
    end

    # 词项逻辑集：交并差

    """
    三项通用：
    1. 词项逻辑集
    2. 乘积
    3. 语句逻辑集
    """
    term2data(
        ::TSParser, 
        t::Union{TermLSet,TermProduct,StatementLSet}
    ) = form_logical_set(
        TYPE_SYMBOL_DICT[typeof(t)],
        t.terms .|> string,
        ", "
    )

    # TODO 字符串→词项

    # 像

    """
    外延/内涵 像
    - 特殊处理：位置占位符
    """
    term2data(::TSParser, t::TermImage) = form_logical_set(
        TYPE_SYMBOL_DICT[typeof(t)],
        [
            t.terms[1:t.relation_index-1]...,
            "_",
            t.terms[t.relation_index:end]...,
        ],
        ", "
    )

end
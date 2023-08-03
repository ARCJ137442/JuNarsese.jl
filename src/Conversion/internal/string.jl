#=
提供所有与字符串相关的方法
=#
#= 📝Julia: 参数类型的「不变性」：具体类型，具体实现，不因参数互为子类
> Julia 的类型参数是不变的，而不是协变的（或甚至是逆变的）
> 即使 Float64 <: Real 也没有 Point{Float64} <: Point{Real}
=#

export StringParser_ascii, StringParser_latex

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
    atom_prefixes::Dict
    "反转的字典"
    prefixes2atom::Dict

    "显示「像占位符」的符号"
    placeholder_t2d::String
    "识别「像占位符」的符号"
    placeholder_d2t::String

    """
    用于「词项→字符串」的逗号（显示用）
    """
    comma_t2d::String
    "用于「字符串→词项」的逗号（识别用）"
    comma_d2t::String

    """
    词项集类型 => (前缀, 后缀)
    用于`前缀 * 词项组 * 后缀`
    """
    term_set_brackets::Dict
    "前缀 => 词项集类型"
    brackets_term_set::Dict

    """
    词项集类型 => 符号
    用于`(符号, 内部词项...)`

    - 暂时不写「并」：在「代码表示」（乃至Latex原文）中都没有对应的符号
    """
    compound_symbols::Dict

    """
    陈述类型 => 系词(字符串)
    """
    copulas::Dict

    """
    时态 => 时态表示（字符串）
    """
    tenses::Dict

    """
    标点 => 标点表示（字符串）
    """
    punctuations::Dict

    "内部构造方法"
    function StringParser(
        atom_prefixes::Dict,
        placeholder_t2d::String, placeholder_d2t::String,
        comma_t2d::String, comma_d2t::String, 
        term_set_brackets::Dict,
        compound_symbols::Dict,
        copulas::Dict,
        tenses::Dict,
        punctuations::Dict,
        )
        new(
            atom_prefixes,
            Dict( # 自动反转字典
                @reverse_dict_content atom_prefixes
            ),
            placeholder_t2d, placeholder_d2t,
            comma_t2d, comma_d2t,
            term_set_brackets,
            Dict( # 自动反转字典
                @reverse_dict_content term_set_brackets
            ),
            compound_symbols,
            copulas,
            tenses,
            punctuations,
        )
    end

end

"""
（默认）实例化，并作为一个「转换器」导出
- 来源：文档 `NARS ASCII Input.pdf`
"""
StringParser_ascii::StringParser = StringParser(
    Dict( # 原子前缀
        Word     => "", # 置空
        IVar     => "\$",
        DVar     => "#",
        QVar     => "?",
        Operator => "^", # 操作
    ),
    "_", "_",
    ", ", ",",
    Dict( # 集合括弧
        TermSet{Extension} => ("{", "}"), # 外延集
        TermSet{Intension} => ("[", "]"), # 内涵集
    ),
    Dict( # 集合操作
        ExtIntersection => "&",
        IntIntersection => "|",
        ExtDifference   => "-",
        IntDifference   => "~",
        # 像
        ExtImage => "/",
        IntImage => "\\",
        # 乘积
        TermProduct => "*",
        # 陈述逻辑集
        Conjunction => "&&",
        Disjunction => "||",
        Negation    => "--",
        # 陈述时序集
        ParConjunction  => "&|",
        SeqConjunction  => "&/",
    ),
    Dict( # 系词
        STInheriance       => "-->",
        STSimilarity       => "<->",
        STImplication      => "==>",
        STEquivalance      => "<=>",
        # 副系词: 实例&属性
        Instance           => "{--",
        Property           => "--]",
        InstanceProperty   => "{-]",
        # 副系词: 时序蕴含
        ImplicationPast    => raw"=\>",
        ImplicationPresent => raw"=/>",
        ImplicationFuture  => raw"=|>",
        # 副系词: 时序等价
        EquivalancePast    => raw"<\>",
        EquivalancePresent => raw"<|>",
        EquivalanceFuture  => raw"</>",
    ),
    Dict( # 时态
        Eternal    => "",
        Past       => ":\\:",
        Present    => ":|:",
        Future     => ":/:",
        # Sequential => "&/", # 这两个只是因为与之相关，所以才放这里
        # Parallel   => "&|",
    ),
    Dict( # 标点
        Judgement => ".",
        Question  => "?",
        Goal      => "!",
        Query     => "@",
    ),
)

"""
（Latex扩展）实例化，并作为一个「转换器」导出
- 来源：文档 `NARS ASCII Input.pdf`
"""
StringParser_latex::StringParser = StringParser(
    Dict( # 原子前缀
        Word     => "", # 置空
        IVar     => "\$",
        DVar     => "\\#",
        QVar     => "?",
        Operator => "\\Uparrow", # 操作
    ),
    "\\diamond", "\\diamond",
    " ", " ", # 【20230803 14:14:50】Latex格式中没有逗号，使用\u202f的空格「 」以分割
    Dict( # 集合括弧
        TermSet{Extension} => ("{", "}"), # 外延集
        TermSet{Intension} => ("[", "]"), # 内涵集
    ),
    Dict( # 集合操作
        ExtIntersection => "\\cap",
        IntIntersection => "\\cup",
        ExtDifference   => "\\minus",
        IntDifference   => "\\minus",
        # 像
        ExtImage        => "/",
        IntImage        => "\\",
        # 乘积
        TermProduct     => "\\times",
        # 陈述逻辑集
        Conjunction     => "\\wedge",
        Disjunction     => "\\vee",
        Negation        => "\\neg",
        # 陈述时序集
        ParConjunction  => ";",
        SeqConjunction  => ",",
    ),
    Dict( # 系词
        STInheriance       => "\\rightarrow",
        STSimilarity       => "\\leftrightarrow",
        STImplication      => "\\Rightarrow",
        STEquivalance      => "\\LeftRightArrow",
        # 副系词: 实例&属性
        Instance           => raw"\circ\!\!\!\rightarrow",
        Property           => raw"\rightarrow\!\!\!\circ",
        InstanceProperty   => raw"\circ\!\!\!\rightarrow\!\!\!\circ",
        # 副系词: 时序蕴含
        ImplicationPast    => raw"\\!\!\!\!\Rightarrow",
        ImplicationPresent => raw"|\!\!\!\!\Rightarrow",
        ImplicationFuture  => raw"/\!\!\!\!\Rightarrow",
        # 副系词: 时序等价
        EquivalancePast    => raw"\\!\!\!\!\Leftrightarrow",
        EquivalancePresent => raw"|\!\!\!\!\Leftrightarrow",
        EquivalanceFuture  => raw"/\!\!\!\!\Leftrightarrow",
    ),
    Dict( # 时态
        Eternal      => "",
        Past         => raw"\\!\!\!\!\Rightarrow",
        Present      => raw"|\!\!\!\!\Rightarrow",
        Future       => raw"/\!\!\!\!\Rightarrow",
    ),
    Dict( # 标点
        Judgement => ".",
        Question  => "?",
        Goal      => "!",
        Query     => "\\questiondown",
    ),
)


"普通字符串"
Base.eltype(::StringParser) = String

## 已在template.jl导入
# using ..Util
# using ..Narsese

# 【特殊链接】词项↔字符串 #
Base.parse(::Type{T}, s::String) where T <: Term = data2term(StringParser_ascii, T, s)

@redirect_SRS t::Term term2data(StringParser_ascii, t) # 若想一直用term2data，则其也需要注明类型变成term2data(String, t)

# 【特殊链接】语句(时间戳/真值)↔字符串 #
@redirect_SRS s::ASentence term2data(StringParser_ascii, s)
@redirect_SRS s::Stamp term2data(StringParser_ascii, s)
@redirect_SRS t::Truth term2data(StringParser_ascii, t)


"构造方法支持"
(::Type{Narsese.Term})(s::String) = data2term(StringParser_ascii, Term, s)

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
    陈述：<词项+系词+词项>
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

    "_autoIgnoreEmpty: 字串为空⇒不变，字串非空⇒加前导分隔符"
    function _aie(s::String, sept::String=" ")
        isempty(s) ? s : sept * s
    end

    raw"""
    语句：词项+标点+时态+真值
    - 自动为「空参数」省去空格
        - 本为："$(term_str)$punctuation $tense $truth"
    """
    function form_sentence(
        term_str::String, punctuation::String, 
        tense::String, truth::String
        )::String
        "$(term_str)$punctuation" * "$(_aie(tense))$(_aie(truth))"
    end

    """
    根据开括号的位置，寻找同级的闭括号(返回第一个位置)
    """
    function find_braces(
        s::AbstractString, i_begin::Integer, 
        s_start::AbstractString, s_end::AbstractString
        )::Integer
        # 顺序查找
        l_start::Integer = length(s_start)
        level::Unsigned = 0
        sl::AbstractString = ""
        for i in (i_begin+1):length(s)
            sl = s[i:i+l_start-1] # ⚠此处可能溢出
            if sl == s_start
                level += 1
            elseif sl == s_end
                level == 0 && return i # 当同级括号闭上时
                level -= 1
            end
        end
        return -1 # 无效值
    end
end

"""
所有词项的「总解析方法」
"""
function data2term(parser::StringParser, ::Type{Term}, s::String)
    # 去空格
    s1::String = replace(s, " " => "")

    @info "WIP!" s1
end

begin "原子↔字符串"

    """
    原子词项的「总解析方法」
    1. 识别前缀(自动查字典)
    2. 统一构造
        - 协议：默认类型有一个「类型(名字)」的构造方法
    """
    function data2term(parser::StringParser, ::Type{Atom}, s::String)::Atom
        type::Type = get(parser.prefixes2atom, s[1], Word)
        s[2:end] |> Symbol |> type
    end

    "原子→字符串：前缀+名"
    function term2data(parser::StringParser, a::Narsese.Atom)::String
        form_atom(
            parser.atom_prefixes[typeof(a)],
            string(a.name)
        )
    end

end

begin "复合词项↔字符串"

    "从开括号到闭括号"
    CLOSURE_DICT::Dict = Dict(
        "(" => ")",
        "[" => "]",
        "{" => "}",
        "<" => ">",
    )

    """
    复合词项的「总解析方法」(语句除外)
    - 总是「无空格」的
    """
    function data2term(parser::StringParser, ::Type{Compound}, s::String)
        s_open::AbstractString = s[1]
        i_close::Integer = first(findlast(CLOSURE_DICT[s_open], s))
        content::AbstractString = s[2:i_close]
        
        @info "WIP!"
    end

    # 陈述
    """
    陈述→字符串
    """
    function term2data(parser::StringParser, s::Statement{Type}) where Type
        form_statement(
            term2data(parser, s.ϕ1), 
            parser.copulas[Type], 
            term2data(parser, s.ϕ2),
        )
    end

    # TODO 字符串→陈述
    
    # 词项集↔字符串
    "词项集→字符串：join+外框"
    term2data(parser::StringParser, t::TermSet)::String = form_term_set(
        parser.term_set_brackets[typeof(t)]..., # 前后缀
        [
            term2data(parser, term)
            for term in t.terms
        ], # 内容
        # ↑📌不能使用「term2data.(parser, t.terms)」：报错「MethodError: no method matching length(::JuNarsese.Conversion.StringParser)」
        parser.comma_t2d
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
            data2term.(
                parser, Term, # 内部元素再根据需要转换
                split(s[2:end-1], parser.comma_d2t) .|> String # 根据逗号切分
            )
        )
    end

    """
    更一般的情况: 字符串→词项集
    """
    function data2term(parser::StringParser, ::Type{TermSet}, s::String)::TermSet
        data2term(
            parser, 
            TermSet{parser.brackets_term_set[s[1]]},
            s
        )
    end

    # 词项逻辑集：交并差

    """
    通用：形如`(操作符, 词项...)`的复合词项
    1. 词项逻辑集
    2. 乘积
    3. 陈述逻辑集
    4. 陈述时序集
    """
    term2data(
        parser::StringParser, 
        t::TermOperatedSetLike
    ) = form_logical_set(
        parser.compound_symbols[typeof(t)],
        [
            term2data(parser, term)
            for term in t.terms
        ], # 内容
        parser.comma_t2d
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
            parser.placeholder_t2d,
            t.terms[t.relation_index:end]...,
        ],
        parser.comma_t2d
    )

end

begin "语句" # TODO: 这到底是不是「term」？可能需要改名

    function term2data(parser::StringParser, t::Truth)
        "%$(t.f); $(t.c)%"
    end
    
    function term2data(parser::StringParser, s::ASentence{punctuation}) where punctuation
        form_sentence(
            term2data(parser, s.term),
            parser.punctuations[punctuation],
            parser.tenses[Base.get(s, Tense)],
            term2data(parser, s.truth)
        )
    end

end

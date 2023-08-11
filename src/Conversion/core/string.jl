#=
提供所有与字符串相关的方法
=#
#= 📝Julia: 参数类型的「不变性」：具体类型，具体实现，不因参数互为子类
    > Julia 的类型参数是不变的，而不是协变的（或甚至是逆变的）
    > 即使 Float64 <: Real 也没有 Point{Float64} <: Point{Real}
=#
#= 📝Julia: 函数可以动态添加方法，但只能在顶层起效（不能在构造方法中添加）
    - 局部添加方法的报错信息：
        >  syntax: Global method definition around [...] needs to be placed at the top level, or use "eval".
=#

export StringParser_ascii, StringParser_latex, StringParser_han

const CONTENT::Type = Union{
    AbstractString,
    AbstractChar,
    Regex
}

"""
定义「字符串转换器」
- 使用「结构+实例」的形式实现「个性化」
    - 可复用的常量参数
- 提供字符串处理方法
- 可以通过其中存储的常量，特化出不同的转换器
    - 此用法将在LaTeX.jl中使用，以便重用代码
"""
struct StringParser{Content} <: AbstractParser where {Content <: CONTENT}

    "显示用名称"
    name::String

    "原子到文本的字典"
    atom_prefixes::Dict{Type, Content}
    "反转的字典"
    prefixes2atom::Dict{Content, Type}

    "显示「像占位符」的符号"
    placeholder_t2d::Content
    "识别「像占位符」的符号"
    placeholder_d2t::Content

    "用于「文本→词项」的逗号（识别用）"
    comma_d2t::Content
    """
    （自动生成）用于「词项→文本」的逗号（显示用）
    - 由「识别用符号」与「空白符」拼接而成
    """
    comma_t2d::Content

    """
    空白符
    - 为了更加可自定义化，一般仅在「打包成字串」时使用
    - 用于
        - 词项-系词 分隔
        - 逗号尾缀
    """
    space::Content

    """
    词项类型 => (前缀, 后缀)
    - 用于词项集/复合词项/陈述的转换
        - `前缀 * 内容 * 后缀`
    """
    compound_brackets::Dict{Type, Tuple{Content, Content}}
    "（自动生成）前后缀 => 词项集类型"
    brackets_compound::Dict{Tuple{Content, Content}, Type}
    "（自动生成）前缀集"
    bracket_openers::Vector{Content}
    "（自动生成）后缀集"
    bracket_closures::Vector{Content}

    """
    词项集合类型 => 符号
    用于`(符号, 内部词项...)`

    - 暂时不写「并」：在「代码表示」（乃至LaTeX原文）中都没有对应的符号
    """
    compound_symbols::Dict{Type, Content}
    "（自动生成）符号 => 词项集合类型"
    symbols_compound::Dict{Content, Type}

    """
    陈述类型 => 系词(文本)
    """
    copula_dict::Dict{Type, Content}
    "（自动生成）所有系词"
    copulas::Vector{Content}
    "（自动生成）判断文本是否前缀有系词"
    startswith_copula::Function

    """
    时态 => 时态表示（文本）
    """
    tense_dict::Dict{Type, Content}
    "（自动生成）反向字典"
    tense2type::Dict{Content, Type}
    "（自动生成）所有时态"
    tenses::Vector{Content}

    """
    标点 => 标点表示（文本）
    """
    punctuation_dict::Dict{Type, Content}
    "（自动生成）反向字典"
    punctuation2type::Dict{Content, Type}
    "（自动生成）所有标点"
    punctuations::Vector{Content}

    """
    真值の括弧
    """
    truth_brackets::Tuple{Content, Content}
    "真值の分隔符"
    truth_separator::Content

    """
    预处理函数::Function `(::Content) -> Content`
    """
    preprocess::Function

    "内部构造方法"
    function StringParser{Content}(
        name::String,
        atom_prefixes::Dict,
        placeholder_t2d::Content, placeholder_d2t::Content,
        comma_d2t::Content, 
        space::Content,
        compound_brackets::Dict,
        compound_symbols::Dict,
        copula_dict::Dict,
        tense_dict::Dict,
        punctuation_dict::Dict,
        truth_brackets::Tuple{Content, Content},
        truth_separator::Content,
        preprocess::Function,
        ) where {Content <: CONTENT}
        copulas = values(copula_dict) |> collect # 📌不能放在new内，不然会被识别为关键字参数
        new(
            name,
            atom_prefixes,
            Dict( # 自动反转字典
                @reverse_dict_content atom_prefixes
            ),
            placeholder_t2d, placeholder_d2t,
            comma_d2t, 
            comma_d2t * space, # 自动拼接空格
            space, 
            compound_brackets,
            Dict( # 自动反转字典: (左括弧, 右括弧) => 类型
                @reverse_dict_content compound_brackets
            ),
            [left for (left,_) in values(compound_brackets)],
            [right for (_,right) in values(compound_brackets)],
            compound_symbols,
            Dict( # 自动反转字典
                @reverse_dict_content compound_symbols
            ),
            copula_dict,
            copulas,
            # 自动生成函数：判断是否前缀为系词
            s -> begin
                # 遍历所有系词
                for copula in copulas
                    startswith(s, copula) && return copula
                end
                return empty(Content) # 【20230809 10:55:18】默认返回空文本（详见Util.jl扩展的方法）
            end,
            tense_dict,
            Dict( # 自动反转字典: 标点 => 类型
                @reverse_dict_content tense_dict
            ),
            values(tense_dict) |> collect,
            punctuation_dict,
            Dict( # 自动反转字典: 标点 => 类型
                @reverse_dict_content punctuation_dict
            ),
            values(punctuation_dict) |> collect,
            truth_brackets,
            truth_separator,
            preprocess,
        )
    end

end

"外部构造方法：无参数类型⇒字符串参数"
StringParser(args::Vararg) = StringParser{String}(args...)

# 重定向字符串方法
@redirect_SRS parser::StringParser parser.name

# 在外部文件中存储具体实现
include("string/definitions.jl")

"""
定义「字符串转换」的「目标类型」
- String↔词项/语句
"""
const STRING_PARSE_TARGETS::Type = DEFAULT_PARSE_TARGETS

"目标类型：词项/语句"
parse_target_types(::StringParser) = STRING_PARSE_TARGETS

"数据类型：普通字符串"
Base.eltype(::StringParser)::Type = String

begin "【特殊链接】词项/语句↔字符串"
    
    "词项集↔字符串（ASCII）"
    Base.parse(::Type{T}, s::String) where T <: Term = data2narsese(StringParser_ascii, T, s)

    @redirect_SRS t::Term narsese2data(StringParser_ascii, t) # 若想一直用narsese2data，则其也需要注明类型变成narsese2data(String, t)

    # 【特殊链接】语句(时间戳/真值)↔字符串 #
    @redirect_SRS s::ASentence narsese2data(StringParser_ascii, s)
    # @redirect_SRS s::Stamp narsese2data(StringParser_ascii, s) # 把时间戳当做「默认对象」
    @redirect_SRS t::Truth narsese2data(StringParser_ascii, t)

    "构造方法支持"
    (::Type{T})(s::String) where {T <: STRING_PARSE_TARGETS} = data2narsese(StringParser_ascii, Term, s)

end

# 正式开始 #

begin "陈述形式"

    """
    原子词项：前缀+内容
    例子："^操作"
    """
    function form_atom(prefix::CONTENT, content::CONTENT)::CONTENT
        prefix * content # 自动拼接
    end

    """
    陈述：前缀+词项+系词+词项+后缀
    例子："<A ==> B>
    """
    function form_statement(
        prefix::CONTENT, suffix::CONTENT, # 前后缀
        first::CONTENT, copula::CONTENT, last::CONTENT, # 词项+系词+词项
        space::CONTENT
        )::CONTENT
        "$prefix$first$space$copula$space$last$suffix"
    end
    
    """
    词项集(无「操作符」，仅以括号相区分)：前缀+插入分隔符的内容+后缀
    例子："[A, B, C]"
    - ⚠注意：Julia类型的「不变性」注定「带类参数组」参数约束麻烦
    """
    function form_term_set(prefix::CONTENT, suffix::CONTENT, contents::Vector, separator::String)::CONTENT
        prefix * join(contents, separator) * suffix # 字符也能拼接
    end

    """
    有操作集：前缀+符号+插入分隔符&空格的内容
    例子："(/, A, B, _, C)"

    【20230811 11:46:15】此中之「connector」名自《NAL》定义7.3
    """
    function form_compound_set(
        prefix::CONTENT, suffix::CONTENT, # 前后缀
        connector::CONTENT, contents::Vector, # 符号+内容
        separator::CONTENT,
        # 此处无需额外空格参数：已包含于separator中
        )::CONTENT
        "$prefix$connector$separator" * join(contents, separator) * suffix
    end

    "_autoIgnoreEmpty: 字串为空⇒不变，字串非空⇒加前导分隔符"
    _aie(s::CONTENT, sept::CONTENT=" ") = (
        isempty(s) ? 
            s : 
            sept * s
    )
    

    raw"""
    语句：词项+标点+时态+真值
    - 自动为「空参数」省去空格
        - 本为："$(term_str)$punctuation $tense $truth"
    """
    function form_sentence(
        term_str::CONTENT, punctuation::CONTENT, 
        tense::CONTENT, truth::CONTENT,
        space::CONTENT,
        )::CONTENT
        "$(term_str)$punctuation" * "$(_aie(tense, space))$(_aie(truth, space))"
    end

    """
    格式化真值: 左 + f + 分隔符 + c + 右
    """
    function form_truth(
        left::CONTENT, right::CONTENT, separator::CONTENT,
        f::Real, c::Real
        )
        left * "$f$separator$c" * right
        
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

    """
    自动给词项「剥皮」
    - 在「括号集」中寻找对应的「词缀」
    - 自动去除词项两边的括号，并返回识别结果
    - 返回值: 对应类型, 前缀, 后缀, 切割后的字符串
    """
    function auto_strip_term(type_brackets::Dict, s::String)::Tuple
        for ( # 遍历所有「类型 => (前缀, 后缀)对」
                type::Type, # 对Pair进行解构
                (prefix::AbstractString, suffix::AbstractString) # 对其中元组进行解构
            ) in type_brackets
            if startswith(s, prefix) && endswith(s, suffix) # 前后缀都符合(兼容「任意长度词缀」)
                stripped::String = s[
                    nextind(
                        s, firstindex(s), length(prefix)
                    ):prevind(
                        s, lastindex(s), length(suffix)
                    )
                ]
                return type, prefix, suffix, stripped # 避免如"<词项-->^操作>"中「多字节Unicode字符无效索引」的问题
            end
        end
        # 找不到：返回nothing，并返回字串本身(未切割)
        nothing, nothing, nothing, nothing
    end

    "一系列判断「括弧开闭」的方法（默认都是「作为前缀识别」，以兼容「多字节字串」）"
    match_opener(parser::StringParser, s::AbstractString)::String  = match_first(str -> startswith(s, str), parser.bracket_openers, "")
    match_closure(parser::StringParser, s::AbstractString)::String = match_first(str -> startswith(s, str), parser.bracket_closures, "")
    match_opener(parser::StringParser, c::Char)::String  = match_opener(parser, string(c))
    match_closure(parser::StringParser, c::Char)::String = match_closure(parser, string(c))
end

"""
所有词项的「总解析方法」
- 先去语法无关的空格
- 可能情况（格式：`文本`: 调用方法 => `调用时处理的文本`）：
    - `<A==>B>`: 陈述 => `A==>B`
    - `(--,A,B)`: 复合集
    - `[A,B]`/`{A,B}`: 词项集
    - `?A`: 原子词项
"""
function data2narsese(parser::StringParser, ::TYPE_TERMS, s::String)
    # 预处理覆盖局部变量
    s::String = parser.preprocess(s)

    # 识别并自动切分(若返回nothing，隐含报错TypeError)
    type::Union{Type, Nothing}, _, _, stripped::Union{AbstractString, Nothing} = auto_strip_term(
        parser.compound_brackets,
        s
    )

    # 无词缀：解析为原子词项
    isnothing(type) && return data2narsese(
        parser, Atom,
        s # 未能切分，使用原字串
    )

    # 返回对应的「专用解析」结果: Atom|Compound|Statement
    return data2narsese(
        parser, type, 
        stripped, # 截取后中间的部分
        true, # 代表「已去除前后缀」（否则需要自行去除前后缀）
    )
end

begin "原子↔字符串"

    """
    原子词项的「总解析方法」
    1. 识别前缀(遍历字典)
    2. 统一构造
        - 协议：默认类型有一个「类型(名字)」的构造方法
    - 对原子词项而言，「去除了词缀的方法」就是本来的方法
    """
    function data2narsese(parser::StringParser, ::Type{Atom}, s::String, ::Bool=false)::Atom
        # 判空
        isempty(s) && error("尝试解析空字符串！")
        # 无前缀的默认类型/名称
        term_type::Type, term_literal::String = Word, s
        # 遍历比对前缀（支持变长字符串）
        for (type::Type, prefix::String) in parser.atom_prefixes
            # 若为前缀→获得类型&截取（空字串是任意类型的前缀，为避免提前被索引，此处跳过）
            if !isempty(prefix) && startswith(s, prefix)
                term_type = type
                term_literal = s[nextind(s, 1, length(prefix)):end] # 📌`0+n`兼容多字节Unicode字符
                break
            end
        end
        # 合法性检查
        if !isnothing(findfirst(r"[^\w]", term_literal))
            "非法词项名「$s」" |> ArgumentError |> throw
        end
        term_literal |> Symbol |> term_type # 根据前缀自动截取
    end

    "原子→字符串：前缀+名"
    function narsese2data(parser::StringParser, a::Narsese.Atom)::String
        form_atom(
            parser.atom_prefixes[typeof(a)],
            string(a.name)
        )
    end

end

begin "复合词项↔字符串"

    # 外延/内涵集 的问题
    """
    从一个「同级分隔符」（的下一个位置）到另一个「同级分隔符」（的位置）
    - 忽略其间的所有系词：避免「子词项の系词中有括弧」的干扰
    - 返回：下一个「同级分隔符」的位置（同级分隔符的起始点）
    """
    function _next_main_separator_ignore_copulas(
        parser::StringParser, 
        s::AbstractString,
        start::Integer, 
        separator::AbstractString, 
        )::AbstractRange
        level::Unsigned = 0
        i::Integer = start
        i_last::Integer = lastindex(s)
        copula::String = ""
        si::String = ""
        while i ≤ i_last # 📌不能使用enumerate，因为其中的「索引」只是「序数」不是「实际索引」
            si = s[i:end] # 截取指定长字符串
            # 跳过子词项系词
            if level > 0
                copula = parser.startswith_copula(
                    s[i:i_last]
                )
                if !isempty(copula)
                    i = nextind(s, i, length(copula))
                    continue
                end
            # 识别底层分隔符
            elseif startswith(s[i:end], separator) # 兼容「任意长度分隔符」
                # 返回范围：分隔符的起止位置(加到外面去后，要「-1」回来)
                return i:nextind(s, i, length(separator)-1)
            end
            # 处理层级(必须保证这个「层级出入口」不能是系词的一部分)
            if !isempty(match_opener(parser, si))
                level += 1
            elseif !isempty(match_closure(parser, si))
                level -= 1
            end
            # 自增：下一个字符
            i = nextind(s, i, 1)
        end
        # 默认返回值（找不到分隔符）：(末尾+1):(末尾)（此处+1是为了使用时「自动退格」）
        return (i_last+1):i_last
    end

    """
    解析以分隔符分隔的「词项序列」

    前提假定：
    - 无多余空白字符
    - 开括弧、闭括弧**长度均为1**
    
    返回值：
    - 分隔后的字符串数组(留给调用者解析)

    例：
    - `A,B,C`
    - `(|,A,B,C),<S-->P>,{SELF},[good]`
    """
    function _parse_term_series(
        parser::StringParser, s::String
        )::Vector{String}
        # 初始化返回值
        components::Vector{String} = String[]
        # 沿着索引遍历
        i::Integer = 1
        i_last::Integer = lastindex(s) # 📌不能使用长度代替索引：多字节Unicode字符可能会变短
        term_start::Integer = i
        term_str::String = ""
        # term_end
        while i ≤ i_last
            # 获取词项末尾（下一个分隔符位置/字符串末尾）
            separator_next::AbstractRange = _next_main_separator_ignore_copulas(
                parser,
                s,
                term_start,
                parser.comma_d2t
            )
            # 截取
            term_end = prevind(s, first(separator_next), 1) # 使用first而非separator_next[begin]，更精准获得索引
            term_str = s[term_start:term_end]
            # 解析&追加
            push!(components, term_str)
            # 更新词项头索引
            term_start = nextind(s, last(separator_next), 1)
            # 递增
            i = term_start
        end
        # 返回
        return components
    end

    """
    复合词项的「总解析方法」(语句除外)
    - 总是「无空格」的
    """
    function data2narsese(parser::StringParser, ::Type{Compound}, s::String)
        # 自动剥皮并跳转
        return data2narsese(
            parser, Compound,
            auto_strip_term(
                parser.compound_brackets,
                s
            )[4], # 第四个是切割后的字符串
            true
        )
    end
    """
    复合词项「去除了词缀」的方法(使用多分派区别于「有词缀」方法)
    - 无空格

    解决的几个重要问题：
    - 【20230804 15:54:20】不能简单地用split拆分：「子词项因分隔符被裂开」的情形
    - 【20230804 16:56:45】子词项「系词中含有括号」的干扰
    - 【20230804 17:31:46】去掉分隔符导致「无法识别子词项类型」的问题
    - 【20230804 18:30:08】对「多字节Unicode字符」索引无效的问题
    - 【20230804 19:47:14】代码量过多&不通用，难以维护的问题（拆分）

    借鉴自：
    - OpenJunars/parser.jl

    - 例：
        - `&&,A,B,C` => `Conjunction`, (`A`, `B`, `C`)
        - `||,(/,A,B,_,C),D` => `Disjunction`, (`(/,A,B,_,C)`,`D`)
    """
    function data2narsese(parser::StringParser, ::Type{Compound}, s::String, ::Bool)
        # 解析出「词项序列字串」
        term_strings::Vector{String} = _parse_term_series(parser, s)
        # 解析词项类型: 使用第一项
        connector_str::String = popfirst!(term_strings)
        if connector_str in keys(parser.symbols_compound)
            compound_type::Type = parser.symbols_compound[connector_str]
        else
            error("无效的复合词项符号「$connector_str")
        end
        # 解析剩余词项
        components::Vector{Union{Term, Nothing}} = Union{Term, Nothing}[
            term_str == parser.placeholder_d2t ?
                nothing : # 使用nothing兼容「像占位符」
                data2narsese(parser, Term, term_str)
            for term_str in term_strings
        ]
        
        result = compound_type(components...)
        return result # 调用构造函数
    end
    
    # 词项集↔字符串
    "词项集→字符串：join+外框"
    narsese2data(parser::StringParser, t::TermSet)::String = form_term_set(
        parser.compound_brackets[typeof(t)]..., # 前后缀
        [
            narsese2data(parser, term)
            for term in t.terms
        ], # 内容
        # ↑📌不能使用「narsese2data.(parser, t.terms)」：报错「MethodError: no method matching length(::JuNarsese.Conversion.StringParser)」
        parser.comma_t2d
    )

    """
    字符串→外延集/内涵集（有词缀）：自动剥皮并转换
    """
    function data2narsese(parser::StringParser, ::Type{TermSet{EI}}, s::String)::TermSet{EI} where {EI <: AbstractEI}
        # 自动剥皮并跳转
        return data2narsese(
            parser, TermSet{EI},
            auto_strip_term(
                parser.compound_brackets,
                s
            )[4], # 第四个是切割后的字符串
            true
        )
    end
    """
    字符串→外延集/内涵集（无词缀）：
    1. 去头尾
    2. 分割

    例子(无额外空格)
    - `data2narsese(StringParser, TermSet{Extension}, "A,B,C", true) == TermSet{Extension}(A,B,C)`
    """
    function data2narsese(parser::StringParser, ::Type{TermSet{EI}}, s::String, ::Bool)::TermSet{EI} where {EI <: AbstractEI}
        term_strings::Vector{String} = _parse_term_series(parser, s) # 使用新的「词项序列解析法」
        TermSet{EI}(
            Set(
                data2narsese(parser, Term, term_str)
                for term_str in term_strings
            )
        )
    end

    # 字符串↔陈述
    """
    陈述→字符串
    """
    function narsese2data(parser::StringParser, s::Statement{Type}) where Type
        form_statement(
            parser.compound_brackets[Statement]...,
            narsese2data(parser, s.ϕ1), 
            parser.copula_dict[Type], 
            narsese2data(parser, s.ϕ2),
            parser.space,
        )
    end

    """
    字符串→陈述（有词缀）：自动剥皮并转换
    """
    function data2narsese(parser::StringParser, ::Type{Statement}, s::String)::Statement
        # 自动剥皮并跳转
        return data2narsese(
            parser, Statement,
            auto_strip_term(
                parser.compound_brackets,
                s
            )[4], # 第四个是切割后的字符串
            true
        )
    end

    """
    字符串→陈述(无词缀)
    1. 先识别系词，根据系词切割
        1. 子词项内系词问题
        2. 系词内有括号问题
    2. 分别转换：系词⇒陈述类型，子词项字符串⇒子词项
    3. 构造陈述{陈述类型}(子词项1, 子词项2)

    前提假定：
    - 开括弧、闭括弧**长度均为1**

    开放式兼容：
    - 不定长系词

    借鉴自：
    - OpenJunars/parser.jl

    例：
    - `A-->B`
    - `<A==>B><->C`
    - `(&&,<A-->B>,<B-->C>)==><A-->C>`
    """
    function data2narsese(parser::StringParser, ::Type{Statement}, s::String, ::Bool)::Statement
        # 识别并匹配在「顶层」的系词（避免子词项中系词的干扰）
        # 循环变量(📌不使用local)
        i::Integer, level::Unsigned = firstindex(s), 0
        i_last::Integer = lastindex(s)
        while i <= i_last
            # 系词识别：当前位置是否以任意系词为前缀
            for (type::Type, copula::String) in parser.copula_dict
                # 此时i停在系词字串的开头
                if startswith(s[i:end], copula)
                    # 若是「顶层系词」，获取参数&返回(return后面不用else)
                    level == 0 && return Statement{type}(
                        data2narsese(
                            parser, Term, 
                            s[begin:prevind(s, i, 1)] # ϕ1 📌
                        ),
                        data2narsese(
                            parser, Term, 
                            s[nextind(s, i, length(copula)):end] # ϕ2
                        )
                    )
                    # 若非顶层，跳过整个系词部分（匹配到了，就直接忽略，避免后续被认作括弧）
                    i = nextind(s, i, length(copula)) # 跳到系词后第一个字符的位置(这个位置不可能再是系词)
                    break
                end
            end
            # 没匹配到系词：识别括弧→变更层级
            if     !isempty(match_opener(parser, s[i:end]))  level += 1     # 截取の字串∈开括弧→增加层级
            elseif !isempty(match_closure(parser, s[i:end])) level -= 1 end # 截取の字串∈闭括弧→降低层级
            # 索引自增
            i = nextind(s, i) # 📌避免多字节Unicode字符识别无效
        end
        # 识别失败的情况
        @error "无法识别陈述！" s
        nothing # 识别失败：返回nothing（会报错）
    end

    # 词项逻辑集：交并差

    """
    通用：形如`(操作符, 词项...)`的复合词项
    1. 词项逻辑集
    2. 乘积
    3. 陈述逻辑集
    4. 陈述时序集
    """
    narsese2data(
        parser::StringParser, 
        t::TermCompoundSetLike
    ) = form_compound_set(
        parser.compound_brackets[Compound]...,
        parser.compound_symbols[typeof(t)],
        [
            narsese2data(parser, term)
            for term in t.terms
        ], # 内容
        parser.comma_t2d
    )

    # 像

    """
    外延/内涵 像
    - 特殊处理：位置占位符
    """
    narsese2data(parser::StringParser, t::TermImage) = form_compound_set(
        parser.compound_brackets[Compound]...,
        parser.compound_symbols[typeof(t)],
        insert!( # 使用「插入元素」的处理办法，因为数组是新建的
            [narsese2data(parser, term) for term in t.terms], # 自动转换字符串
            t.relation_index, parser.placeholder_t2d # 在对应索引处插入元素，并返回
        ),
        parser.comma_t2d
    )

end

begin "语句相关"

    "真值→字符串"
    narsese2data(parser::StringParser, t::Truth) = form_truth(
        parser.truth_brackets..., parser.truth_separator,
        t.f, t.c
    )

    "标点→字符串"
    function narsese2data(parser::StringParser, ::Type{P}) where {P <: Punctuation}
        parser.punctuation_dict[P]
    end

    "时态→字符串: 有默认值"
    function narsese2data(
        parser::StringParser, ::Type{T}, 
        default::Type{T1} = Eternal
        ) where {T <: Tense, T1 <: Tense}
        get(parser.tense_dict, T, default)
    end
    
    "语句→字符串"
    function narsese2data(parser::StringParser, s::ASentence{punctuation}) where punctuation <: Punctuation
        form_sentence(
            narsese2data(parser, s.term),
            narsese2data(parser, punctuation),
            narsese2data(parser, Base.get(s, Tense)),
            narsese2data(parser, s.truth),
            parser.space
        )
    end

    """
    字符串→标点

    默认值：判断 Judgement

    例：
    - `.` => Judgement
    """
    function data2narsese(
        parser::StringParser, ::Type{Punctuation}, 
        s::String,
        default::Type = Judgement, # 📌【20230808 9:46:21】此处不能用Type{P}限制，会导致类型变量连锁，类型转换失败
        )::Type{ <: Union{Punctuation, Nothing}}
        get(parser.punctuation2type, s, default)
    end

    """
    字符串→时态

    默认值：永恒 Eternal

    例：
    - `:|:` => Present
    """
    function data2narsese(
        parser::StringParser, ::Type{Tense}, 
        s::String,
        default = Eternal,
        )
        get(parser.tense2type, s, default)
    end

    """
    字符串→真值
    - 默认有前后缀（未剥皮）：自动剥皮

    例：
    - `%1.00;0.90%` => `1.00;0.90` => Truth64(1.0, 0.9)
    """
    function data2narsese(
        parser::StringParser, ::Type{Truth{F, C}}, s::String,
        stripped::Bool = false
        ) where {F, C}
        if !stripped
            left::String, right::String = parser.truth_brackets
            return data2narsese(
                parser, Truth{F, C}, 
                s[nextind(s, begin, length(left)):prevind(s, end, length(right))], # 自动剥皮
                true # 标示已经剥皮
            )
        end
        # 剥皮后
        f_str::AbstractString, c_str::AbstractString = split(
            s, # 已剥皮，待分割
            parser.truth_separator # 分隔符
        )
        Truth{F, C}( # 分别解析
            parse(F, f_str),
            parse(C, c_str),
        )
    end
    "只指定一个参数类型，相当于复制两个类型"
    function data2narsese(
        parser::StringParser, ::Type{Truth{V}},
        args...
        ) where {V}
        data2narsese(parser, Truth{V, V}, args...)
    end
    "最默认的情况：配置指定的精度（默认64）"
    function data2narsese(
        parser::StringParser, ::Type{Truth},
        args...
        )
        data2narsese(parser, Truth{DEFAULT_FLOAT_PRECISION}, args...)
    end

    """
    总解析方法 : 词项+标点+时态+真值
    - 【20230808 9:34:22】兼容模式：词项语句均可
        - 在「目标类型」中统一使用Any以避免「各自目标类型不同」的歧义
        - 「真值」「时态」「标点」俱无⇒转换为词项

    默认真值 default_truth
    - 核心功能：在没有真值时，自动创建真值
    - 留给后续具体NARS实现的自定义化
        - 例子：有些实现会默认c=0.5，而有些是0.9

    例：
    - `<A --> B>. :|: %1.00;0.90%`
    - （预处理去空格后）`<A-->B>.:|:%1.00;0.90%`
    """
    function data2narsese(
        parser::StringParser, 
        ::Type{Any}, # 兼容模式
        s::String,
        F::Type=DEFAULT_FLOAT_PRECISION, C::Type=DEFAULT_FLOAT_PRECISION;
        default_truth::Truth = Truth{DEFAULT_FLOAT_PRECISION}(1.0, 0.5), # 动态创建
        default_punctuation::Type = Judgement # 默认类型
        )::STRING_PARSE_TARGETS
        # 预处理覆盖局部变量
        str::String = parser.preprocess(s)
        # 从尾部到头部，逐一解析「真值→时态→标点→词项」
        index_start::Integer = lastindex(str)

        truth::Truth, index = _match_truth(parser, str, F, C; default_truth)
        str = str[begin:index] # 反复剪裁

        tense::Type, index = _match_tense(parser, str)
        str = str[begin:index] # 反复剪裁

        punctuation::Type, index = _match_punctuation(parser, str, default_punctuation)
        str = str[begin:index] # 反复剪裁

        term::Term = data2narsese(parser, Term, str) # 剩下就是词项

        # 「真值」「时态」「标点」俱无⇒转换为词项
        index == index_start && return term

        # 构造
        return Sentence{punctuation}(term, truth, tense)
    end

    """
    兼容化后的「语句转换方法」：兼容+类型断言
    """
    function data2narsese(
        parser::StringParser, ::TYPE_SENTENCES,
        s::String,
        F::Type=DEFAULT_FLOAT_PRECISION, C::Type=DEFAULT_FLOAT_PRECISION;
        default_truth::Truth = Truth{DEFAULT_FLOAT_PRECISION}(1.0, 0.5), # 动态创建
        default_punctuation::Type = Nothing # 默认类型
        )::AbstractSentence # 使用类型断言限制
        data2narsese(
            parser, Any, # Any对接兼容模式
            s, 
            F, C; 
            default_truth, 
            default_punctuation,
        )
    end

    """
    倒序匹配真值（可选）

    返回：(真值对象, 真值字符串前一个索引)

    例：
    - `<A-->B>.:|:%1.00;0.90%` => (Truth16(1.00,0.90), end-11)
    """
    function _match_truth(
        parser::StringParser, s::String,
        F::Type{F_TYPE}, C::Type{C_TYPE};
        default_truth::Truth
        ) where {F_TYPE <: Real, C_TYPE <: Real}
        left::String, right::String = parser.truth_brackets
        if endswith(s, right)
            # 获取前括弧的索引范围
            start_range::AbstractRange = findlast(
                left, s[1:prevind(s, end, length(right))]
            )
            stripped = s[
                nextind( # 跳到「前括弧最后一个索引」的下一个索引
                    s, last(start_range), 1
                ):prevind( # 跳到「后括弧第一个索引」的上一个索引
                    s, end, length(right)
                )
            ]
            return (
                data2narsese(
                    parser, Truth{F, C},
                    stripped,
                    true
                ),
                # 「前括弧第一个索引」的上一个索引
                prevind(
                    s, first(start_range), 1
                )
            )
        else # 否则采用默认真值
            return (
                default_truth,
                lastindex(s) # 最后一个索引
            )
        end
    end

    """
    倒序匹配时态（可选）

    前提假定：
    - 先前已匹配完真值，字串末尾就是时态

    返回：(时态类型, 时态字符串前一个索引)

    默认值：找不到→「永恒 Eternal」

    例：
    - `<A-->B>.:|:` => (, end-11)
    """
    function _match_tense(parser::StringParser, s::String)::Tuple
        # 自动匹配
        tense_string::String = match_first(
            tense_str -> !isempty(tense_str) && endswith(s, tense_str), # 避免空字符串提前结束匹配
            parser.tenses,
            ""
        )
        # 解析返回
        return (
            data2narsese(parser, Tense, tense_string, Eternal),
            prevind( # 跳转到「字符串末尾-时态字符串长度」的地方
                s, lastindex(s), # 【20230806 23:05:48】不能用length：实际长度≠第一个索引
                length(tense_string)
            )
        )
    end

    """
    倒序匹配标点

    前提假定：
    - 先前已匹配完真值&时态，字串末尾就是标点

    返回：(标点类型, 标点字符串前一个索引)

    默认值：无(必须有标点)

    例：
    - `<A-->B>.` => (Judgement, end-1)
    """
    function _match_punctuation(parser::StringParser, s::String, default_punctuation::Type)::Tuple
        # 自动匹配
        punctuation_string::String = match_first(
            punctuation_str -> endswith(s, punctuation_str),
            parser.punctuations,
            ""
        )
        # 解析返回
        return (
            data2narsese(parser, Punctuation, punctuation_string, default_punctuation),
            prevind( # 跳转到「字符串末尾-标点字符串长度」的地方
                s, lastindex(s), # 【20230806 23:05:48】不能用length：实际长度≠第一个索引
                length(punctuation_string)
            )
        )
    end
end

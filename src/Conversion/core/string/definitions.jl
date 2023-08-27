export StringParser_ascii, StringParser_latex, StringParser_han
export PRESET_STRING_PARSERS

"""
默认 ASCII版本
- 来源：文档 `NARS ASCII Input.pdf`
- 另可参考：<https://github.com/opennars/opennars/wiki/Narsese-Grammar-(Input-Output-Format)>
"""
const StringParser_ascii::StringParser = StringParser{String}(
    "StringParser_ascii",
    Dict( # 原子前缀
        Word        => "", # 置空
        IVar        => "\$",
        DVar        => "#",
        QVar        => "?",
        Interval    => "+", # 间隔
        Operator    => "^", # 操作
        PlaceHolder => "_", # 像占位符
    ),
    ",",
    " ", # 空格符（一般是无关紧要的分隔成分）
    Dict( # 集合括弧
        ExtSet    => ("{", "}"), # 外延集
        IntSet    => ("[", "]"), # 内涵集
        Statement => ("<", ">"), # 陈述
        Compound  => ("(", ")"), # 复合词项
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
        STInheritance      => "-->",
        STSimilarity       => "<->",
        STImplication      => "==>",
        STEquivalence      => "<=>",
        # 副系词: 实例&属性
        STInstance           => "{--",
        STProperty           => "--]",
        STInstanceProperty   => "{-]",
        # 副系词: 时序蕴含
        STImplicationRetrospective => raw"=\>",
        STImplicationConcurrent    => raw"=|>",
        STImplicationPredictive    => raw"=/>",
        # 副系词: 时序等价
        STEquivalenceRetrospective => raw"<\>",
        STEquivalenceConcurrent    => raw"<|>",
        STEquivalencePredictive    => raw"</>",
    ),
    Dict( # 时态
        Eternal => "",
        Past    => ":\\:",
        Present => ":|:",
        Future  => ":/:",
        # Sequential => "&/", # 这两个只是因为与之相关，所以才放这里
        # Parallel   => "&|",
    ),
    (":!", ":"), # 带时刻时间戳
    Dict( # 标点
        Judgement => ".",
        Question  => "?",
        Goal      => "!",
        Quest     => "@",
    ),
    Narsese.DEFAULT_PUNCTUATION_SENTENCE_DICT, # 使用默认映射表
    # 真值: 括号&分隔符
    ("%", "%"),
    ";",
    # 预算值: 括号&分隔符
    ("\$", "\$"),
    ";",
    # 预处理：去除空白符
    (s::AbstractString) -> filter(!isspace, s)
)

"""
LaTeX扩展
- 来源：文档 `NARS ASCII Input.pdf`
- 【20230809 10:22:34】注：暂未找到官方格式模板，此仅基于个人观察
- 【20230811 0:26:55】不能很好地兼容「二元运算」表达（需要更专业者优化）
"""
const StringParser_latex::StringParser = StringParser{String}(
    "StringParser_latex",
    Dict( # 原子前缀
        Word        => "", # 置空
        IVar        => "\$",
        DVar        => "\\#",
        QVar        => "?", # 【20230811 12:54:54】！自《NAL》定义10.2得知，非独变量的LaTeX包括后缀，后续兼容成问题
        Interval    => "+", # 间隔
        Operator    => "\\Uparrow", # 操作
        PlaceHolder => "\\diamond", # 像占位符
    ),
    " ", # 【20230819 21:59:24】现在使用「多空白符合并」的方式，故不再强制与空格区分
    "", # 空字串（本身就是空格，无需再切分）
    Dict( # 集合括弧
        ExtSet    => ("\\left\\{", "\\right\\}"), # 外延集
        IntSet    => ("\\left[", "\\right]"), # 内涵集
        Statement => ("\\left<", "\\right>"), # 陈述
        Compound  => ("\\left(", "\\right)"), # 复合词项
    ),
    Dict( # 集合操作 【20230810 22:37:50】对中缀表达式支持不是很好
        ExtIntersection => "\\cap",
        IntIntersection => "\\cup",
        ExtDifference   => "\\minus",
        IntDifference   => "\\sim",
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
        STInheritance      => "\\rightarrow",
        STSimilarity       => "\\leftrightarrow",
        STImplication      => "\\Rightarrow",
        STEquivalence      => "\\LeftRightArrow",
        # 副系词: 实例&属性
        STInstance           => raw"\circ\!\!\!\rightarrow",
        STProperty           => raw"\rightarrow\!\!\!\circ",
        STInstanceProperty   => raw"\circ\!\!\!\rightarrow\!\!\!\circ",
        # 副系词: 时序蕴含
        STImplicationRetrospective    => raw"\\!\!\!\!\Rightarrow",
        STImplicationConcurrent => raw"|\!\!\!\!\Rightarrow",
        STImplicationPredictive  => raw"/\!\!\!\!\Rightarrow",
        # 副系词: 时序等价
        STEquivalenceRetrospective    => raw"\\!\!\!\!\Leftrightarrow",
        STEquivalenceConcurrent => raw"|\!\!\!\!\Leftrightarrow",
        STEquivalencePredictive  => raw"/\!\!\!\!\Leftrightarrow",
    ),
    Dict( # 时态
        Eternal      => "",
        Past         => raw"\\!\!\!\!\Rightarrow",
        Present      => raw"|\!\!\!\!\Rightarrow",
        Future       => raw"/\!\!\!\!\Rightarrow",
    ),
    ("t=", ""), # 📌TODO：LaTeX的语法未知
    Dict( # 标点
        Judgement => ".",
        Question  => "?",
        Goal      => "!",
        Quest     => "¿", # 【20230806 23:46:18】倒问号没有对应的LaTeX。。。
    ),
    Narsese.DEFAULT_PUNCTUATION_SENTENCE_DICT, # 使用默认映射表
    # 真值: 括号&分隔符
    ("\\langle", "\\rangle"),
    ",",
    # 预算值: 括号&分隔符
    ("\\\$", "\\\$"), # 【20230820 18:46:30】目前尚未找到LaTeX有关规范
    ";",
    # 预处理：把多个空白符统一转换成单个空格
    (s::AbstractString) -> replace(s, r"\s+" => ' ')
)

"""
漢文扩展
- 📌原创
"""
const StringParser_han::StringParser = StringParser{String}(
    "StringParser_han",
    Dict( # 原子前缀
        Word        => "", # 置空
        IVar        => "任一",
        DVar        => "其一",
        QVar        => "所问",
        Interval    => "间隔", # 间隔
        Operator    => "操作", # 操作
        PlaceHolder => "某", # 像占位符
    ),
    "，", # 词项集/复合词项中的分隔符（可以用顿号，但徒增复杂度）
    "", # 空格符（一般是无关紧要的分隔成分）
    Dict( # 集合括弧
        ExtSet    => ("『", "』"), # 外延集
        IntSet    => ("【", "】"), # 内涵集
        Statement => ("「", "」"), # 陈述
        Compound  => ("（", "）"), # 复合词项
    ),
    Dict( # 集合操作
        ExtIntersection => "外交",
        IntIntersection => "内交",
        ExtDifference   => "外差",
        IntDifference   => "内差",
        # 像
        ExtImage        => "外像",
        IntImage        => "内像",
        # 乘积
        TermProduct     => "积",
        # 陈述逻辑集
        Conjunction     => "与",
        Disjunction     => "或",
        Negation        => "非",
        # 陈述时序集
        ParConjunction  => "同时",
        SeqConjunction  => "接连",
    ),
    Dict( # 系词 【20230809 11:42:04】注意！因字串判断机制为「前缀判断」，因此这里不能存在「一个词是另一个词的前缀」的情况
        STInheritance      => "是",
        STSimilarity       => "似",
        STImplication      => "得",
        STEquivalence      => "同",
        # 副系词: 实例&属性
        STInstance           => "为",
        STProperty           => "有",
        STInstanceProperty   => "具有",
        # 副系词: 时序蕴含
        STImplicationRetrospective    => "曾得",
        STImplicationConcurrent => "现得",
        STImplicationPredictive  => "将得",
        # 副系词: 时序等价
        STEquivalenceRetrospective    => "曾同",
        STEquivalenceConcurrent => "现同",
        STEquivalencePredictive  => "将同",
    ),
    Dict( # 时态
        Eternal      => "",
        Past         => "曾经",
        Present      => "现在",
        Future       => "将来",
    ),
    ("时刻=", ""), # 带时刻时间戳
    Dict( # 标点
        Judgement => "。",
        Question  => "？",
        Goal      => "！",
        Quest     => "；", # 【20230809 10:35:15】这里的「请求」没有常用的中文标点做替代，暂且用个「分号」
    ),
    Narsese.DEFAULT_PUNCTUATION_SENTENCE_DICT, # 使用默认映射表
    # 真值: 括号&分隔符
    ("真值=", "信"), # 此处不能留空！！！
    "真",
    # 预算值: 括号&分隔符
    ("预", "算"), # `预0.5、0.8、0.1算`，尚未找到更好的显示方法
    "、",
    # 预处理：去除空白符
    (s::AbstractString) -> filter(!isspace, s)
)

#= 【20230827 10:21:40】TODO：尝试支持NARS-Swift方言，但因语法差异与内置字符串解析器过大而搁置
    - 主要缘由：
        - 不统一的原子词项前缀表示：独立变量与非独变量不统一使用前缀表示
        - 复合词项的输入是上下文无关的：在输入上下文（即向终端输入）时，复合词项需使用额外的尖括号括起来
    - 参见：
        - https://github.com/maxeeem/NARS-Swift/blob/main/Sources/Narsese/Narsese.swift
        - https://github.com/maxeeem/NARS-Swift/blob/main/Sources/Narsese/Dialects.swift
=#

"""
所有预置的字符串解析器
- 所有字符串解析器的字典，便于其它地方遍历
- 结构：`后缀符号 => 解析器`
- 用法如：批量导出名称
"""
const PRESET_STRING_PARSERS::Dict{Symbol,StringParser} = Dict(
    :ascii => StringParser_ascii,
    :latex => StringParser_latex,
    :han   => StringParser_han,
    # :swift => StringParser_swift,
)

begin "字符串宏解析支持"
    
    "空字串⇒ASCII"
    Conversion.get_parser_from_flag(::Val{Symbol()})::TAbstractParser = StringParser_ascii

    # 遍历所有解析器，批量增加解析支持（如：StringParser_han ⇒ `han`）
    for (symbol::Symbol, parser::StringParser) in PRESET_STRING_PARSERS
        Conversion.get_parser_from_flag(::Val{symbol})::TAbstractParser = parser
    end

    # 漢文扩展的两个别名
    ":汉"
    Conversion.get_parser_from_flag(::Val{:汉})::TAbstractParser = StringParser_han

    ":漢"
    Conversion.get_parser_from_flag(::Val{:漢})::TAbstractParser = StringParser_han
    
end

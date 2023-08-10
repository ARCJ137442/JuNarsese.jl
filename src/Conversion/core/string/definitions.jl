"""
默认 ASCII版本
- 来源：文档 `NARS ASCII Input.pdf`
- 另可参考：<https://github.com/opennars/opennars/wiki/Narsese-Grammar-(Input-Output-Format)>
"""
const StringParser_ascii::StringParser = StringParser{String}(
    "StringParser_ascii",
    Dict( # 原子前缀
        Word     => "", # 置空
        IVar     => "\$",
        DVar     => "#",
        QVar     => "?",
        Operator => "^", # 操作
    ),
    "_", "_",
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
        STInheriance       => "-->",
        STSimilarity       => "<->",
        STImplication      => "==>",
        STEquivalance      => "<=>",
        # 副系词: 实例&属性
        Instance           => "{--",
        Property           => "--]",
        InstanceProperty   => "{-]",
        # 副系词: 时序蕴含
        STImplicationPast    => raw"=\>",
        STImplicationPresent => raw"=|>",
        STImplicationFuture  => raw"=/>",
        # 副系词: 时序等价
        STEquivalancePast    => raw"<\>",
        STEquivalancePresent => raw"<|>",
        STEquivalanceFuture  => raw"</>",
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
    # 真值: 括号&分隔符
    ("%", "%"),
    ";",
    # 预处理：去空格
    (s::String) -> replace(s, " " => "")
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
        Word     => "", # 置空
        IVar     => "\$",
        DVar     => "\\#",
        QVar     => "?",
        Operator => "\\Uparrow", # 操作
    ),
    "\\diamond", "\\diamond",
    " ", # 【20230803 14:14:50】LaTeX格式中没有逗号，使用\u202f的空格「 」以分割
    " ", # 空格符（一般是无关紧要的分隔成分）
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
        STInheriance       => "\\rightarrow",
        STSimilarity       => "\\leftrightarrow",
        STImplication      => "\\Rightarrow",
        STEquivalance      => "\\LeftRightArrow",
        # 副系词: 实例&属性
        Instance           => raw"\circ\!\!\!\rightarrow",
        Property           => raw"\rightarrow\!\!\!\circ",
        InstanceProperty   => raw"\circ\!\!\!\rightarrow\!\!\!\circ",
        # 副系词: 时序蕴含
        STImplicationPast    => raw"\\!\!\!\!\Rightarrow",
        STImplicationPresent => raw"|\!\!\!\!\Rightarrow",
        STImplicationFuture  => raw"/\!\!\!\!\Rightarrow",
        # 副系词: 时序等价
        STEquivalancePast    => raw"\\!\!\!\!\Leftrightarrow",
        STEquivalancePresent => raw"|\!\!\!\!\Leftrightarrow",
        STEquivalanceFuture  => raw"/\!\!\!\!\Leftrightarrow",
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
        Query     => "¿", # 【20230806 23:46:18】倒问号没有对应的LaTeX。。。
    ),
    # 真值: 括号&分隔符
    ("\\langle", "\\rangle"),
    ",",
    # 预处理：去空格
    (s::String) -> replace(s, " " => "")
)

"""
漢文扩展
- 📌原创
"""
const StringParser_han::StringParser = StringParser{String}(
    "StringParser_han",
    Dict( # 原子前缀
        Word     => "", # 置空
        IVar     => "任一",
        DVar     => "其一",
        QVar     => "所问",
        Operator => "操作", # 操作
    ),
    "某", "某",
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
        STInheriance       => "是",
        STSimilarity       => "似",
        STImplication      => "得",
        STEquivalance      => "同",
        # 副系词: 实例&属性
        Instance           => "为",
        Property           => "有",
        InstanceProperty   => "具有",
        # 副系词: 时序蕴含
        STImplicationPast    => "曾得",
        STImplicationPresent => "现得",
        STImplicationFuture  => "将得",
        # 副系词: 时序等价
        STEquivalancePast    => "曾同",
        STEquivalancePresent => "现同",
        STEquivalanceFuture  => "将同",
    ),
    Dict( # 时态
        Eternal      => "",
        Past         => "曾经",
        Present      => "现在",
        Future       => "将来",
    ),
    Dict( # 标点
        Judgement => "。",
        Question  => "？",
        Goal      => "！",
        Query     => "；", # 【20230809 10:35:15】这里的「请求」没有常用的中文标点做替代，暂且用个「分号」
    ),
    # 真值: 括号&分隔符
    ("真值=", "信"), # 此处不能留空！！！
    "真",
    # 预处理：去空格
    (s::String) -> replace(s, " " => "")
)

begin "字符串宏解析支持"
    
    "空字串⇒ASCII"
    Conversion.get_parser_from_flag(::Val{SYMBOL_NULL})::TAbstractParser = StringParser_ascii

    ":ascii"
    Conversion.get_parser_from_flag(::Val{:ascii})::TAbstractParser = StringParser_ascii

    ":latex"
    Conversion.get_parser_from_flag(::Val{:latex})::TAbstractParser = StringParser_latex

    ":han"
    Conversion.get_parser_from_flag(::Val{:han})::TAbstractParser = StringParser_han

    ":汉"
    Conversion.get_parser_from_flag(::Val{:汉})::TAbstractParser = StringParser_han

    ":漢"
    Conversion.get_parser_from_flag(::Val{:漢})::TAbstractParser = StringParser_han
    # 【20230809 11:31:05】日文韩文都可以？？？
end

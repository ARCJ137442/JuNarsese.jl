#= 📝Julia：泛型类的继承，对应类型参数继承就行
    例：
        1. 使用「子类{参数} <: 父类{参数}」
        2. 使用「子类{参数} <: 父类{常量}」
        3. 使用「子类      <: 父类{常量}」

=#

# 导出 #
export AbstractSentence, SentenceJudgement, SentenceQuestion, SentenceGoal, SentenceQuest

# 代码 #

"""
抽象Narsese语句{标点}
- 包含: 
    - term        词项: 任意词项（参照自OpenNARS）
    - {punctuation} 标点：标定语句的类型（语气/情态）
    - truth       真值: 包含语句的真实度
    - stamp       时间戳: 包含一切「时序信息」
- 以上属性分别定义了相应的get方法

【20230814 20:14:35】因其中「truth」的不同用法，改用新方法
- 现在使用「共同继承基类」而非「数据类+泛型」的方式实现
- 四种标点的语句分别实现
    - 分别继承自`抽象语句{标点}`
"""
abstract type AbstractSentence{punctuation <: Punctuation} end

# 实现 #

"""
判断 <: 语句{判断}：词项+时间戳+真值
"""
struct SentenceJudgement <: AbstractSentence{Judgement}
    term::Term
    stamp::Stamp
    truth::Truth
end

"""
（API实现@解析器）外部构造方法：提供可选参数
"""
@inline function SentenceJudgement(
    term::Term; # 下面无顺序，作为可选参数
    stamp::Stamp = StampBasic{Eternal}(),
    truth::Truth = Truth64(1.0, 0.5),
    )
    SentenceJudgement(
        term, 
        stamp,
        truth,
    )
end

"""
外部构造方法：提供顺序默认值
"""
@inline function SentenceJudgement(
    term::Term, # 下面无顺序，作为可选参数
    tense::Type, # 把「只有一个参数」的情况交给上面
    truth::Truth = Truth64(1.0, 0.5),
    )
    SentenceJudgement(
        term; # 基于「可选参数」版本
        truth, tense
    )
end

"""
目标 <: 语句{目标}：词项+时间戳+欲望值(以真值的形式实现)
"""
struct SentenceGoal <: AbstractSentence{Goal}
    term::Term
    stamp::Stamp
    truth::Truth # 与Judgement「判断」统一（参考自Sentence.py）
end

"""
（API实现@解析器）外部构造方法：提供可选参数
- 此处真值当欲望值用
"""
@inline function SentenceGoal(
    term::Term; # 下面无顺序，作为可选参数
    stamp::Stamp = StampBasic{Eternal}(),
    truth::Truth = Truth64(1.0, 0.5),
    )
    SentenceGoal(
        term, 
        stamp,
        truth, 
    )
end

"""
外部构造方法：提供顺序默认值
"""
@inline function SentenceGoal(
    term::Term, # 下面无顺序，作为可选参数
    tense::Type, # 把「只有一个参数」的情况交给上面
    desire::Truth = Truth64(1.0, 0.5),
    )
    SentenceGoal(
        term; # 基于「可选参数」版本
        desire, tense
    )
end

"""
问题 <: 语句{问题}：词项+时间戳(无真值)
"""
struct SentenceQuestion <: AbstractSentence{Question}
    term::Term
    stamp::Stamp
end

"""
（API实现@解析器）外部构造方法：提供可选参数
- 不提供「顺序参数」因：定义会产生「方法定义覆盖`overwritten at`」
"""
@inline function SentenceQuestion(
    term::Term; # 下面无顺序，作为可选参数
    stamp::Stamp = StampBasic{Eternal}(),
    truth::UNothing{Truth} = nothing # 📝Julia: 可选参数中不能省略参数变量名，会导致「畸形表达式」错误
    )
    SentenceQuestion(
        term,
        stamp
    )
end

"""
请求 <: 语句{请求}：词项+时间戳(无真值)
"""
struct SentenceQuest <: AbstractSentence{Quest}
    term::Term
    stamp::Stamp
end

"""
（API实现@解析器）外部构造方法：提供可选参数
"""
@inline function SentenceQuest(
    term::Term; # 下面无顺序，作为可选参数
    stamp::Stamp = StampBasic{tense}(), # 将「只有一个参数」的情况交给上面
    truth::UNothing{Truth} = nothing
    )
    SentenceQuest(
        term,
        stamp
    )
end


begin "别名(用于在语句转换时简化表达)"

    # 导出
    export ASentence, ASentenceJudgement, ASentenceQuestion, ASentenceGoal, ASentenceQuest
    export  Sentence,  SentenceJudgement,  SentenceQuestion,  SentenceGoal,  SentenceQuest
    export DEFAULT_PUNCTUATION_SENTENCE_DICT

    const Sentence    = ASentence          = AbstractSentence
    const ASJudgement = ASentenceJudgement = AbstractSentence{Judgement}
    const ASQuestion  = ASentenceQuestion  = AbstractSentence{Question}
    const ASGoal      = ASentenceGoal      = AbstractSentence{Goal}
    const ASQuest     = ASentenceQuest     = AbstractSentence{Quest}
    
    "默认的「标点→语句类型」映射表"
    const DEFAULT_PUNCTUATION_SENTENCE_DICT::Dict{TPunctuation, Type{<:ASentence}} = Dict(
        Judgement => SentenceJudgement,
        Question  => SentenceQuestion,
        Goal      => SentenceGoal,
        Quest     => SentenceQuest,
    )
end

begin "方法集"

    # 导出
    export get_term, get_stamp, get_tense, get_punctuation, get_truth
    
    """
    获取词项
    - 【20230814 20:49:19】现在使用自定义方法，而非扩展Base方法
        - 根据：Julia官方库亦非一昧扩展get方法
    """
    @inline get_term(s::Sentence)::Term = s.term
    "获取时间戳"
    @inline get_stamp(s::Sentence)::Stamp = s.stamp
    "获取时态（从时间戳中拿）"
    @inline get_tense(s::Sentence)::TTense = get_tense(get_stamp(s)) # 获取第一个类型参数
    "获取标点（直接就是泛型类）" # 📌单行函数有where时不能使用`::类型`注释，否则报错「参数类型未定义」
    @inline get_punctuation(::Sentence{punctuation}) where {punctuation <: Punctuation} = punctuation

    "获取「真值」（总体来说，是`UNothing{Truth}`，可能为空）"
    @inline get_truth(s::Sentence{P}) where {P <: Union{Judgement, Goal}} = s.truth
    @inline get_truth( ::Sentence{P}) where {P <: Union{Question, Quest}} = nothing
    

    """
    判等の法：相等@词项&真值&时间戳
    """
    Base.:(==)(s1::Sentence, s2::Sentence)::Bool = (
        s1.term  == s2.term &&
        get_truth(s1) == get_truth(s2) && # 可能无真值
        s1.stamp == s2.stamp 
    )

end

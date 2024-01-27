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
    truth::ATruth
end

"""
（API实现@解析器）外部构造方法：提供可选参数
"""
@inline function SentenceJudgement(
    term::Term; # 下面无顺序，作为可选参数
    stamp::Stamp = StampBasic(),
    truth::ATruth = truth_null, # !【2024-01-27 16:29:04】现在默认为空真值（未指定状态）
    )
    SentenceJudgement(
        term, 
        stamp,
        truth,
    )
end

"""
目标 <: 语句{目标}：词项+时间戳+欲望值(以真值的形式实现)
"""
struct SentenceGoal <: AbstractSentence{Goal}
    term::Term
    stamp::Stamp
    truth::ATruth # 与Judgement「判断」统一（参考自Sentence.py）
end

"""
（API实现@解析器）外部构造方法：提供可选参数
- 此处真值当欲望值用
"""
@inline function SentenceGoal(
    term::Term; # 下面无顺序，作为可选参数
    stamp::Stamp = StampBasic(),
    truth::ATruth = truth_null, # !【2024-01-27 16:29:04】现在默认为空真值（未指定状态）
    )
    SentenceGoal(
        term, 
        stamp,
        truth, 
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
    stamp::Stamp = StampBasic(),
    truth::UNothing{ATruth} = nothing # 📝Julia: 可选参数中不能省略参数变量名，会导致「畸形表达式」错误
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
    stamp::Stamp = StampBasic(), # 将「只有一个参数」的情况交给上面
    truth::UNothing{ATruth} = nothing
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

    # 导入
    import ..Terms: get_syntactic_complexity, get_syntactic_simplicity # 添加方法

    # 导出
    export get_term, get_stamp, get_tense, get_punctuation, get_truth
    
    """
    获取词项
    
    【20230822 10:39:55】单行函数Julia编译器会自动内联，无需可以添加
    """
    get_term(s::Sentence)::Term = s.term
    "获取时间戳"
    get_stamp(s::Sentence)::Stamp = s.stamp
    "获取时态（从时间戳中拿）"
    get_tense(s::Sentence)::TTense = get_tense(get_stamp(s)) # 获取第一个类型参数
    "获取标点（直接就是泛型类）" # 📌单行函数有where时不能使用`::类型`注释，否则报错「参数类型未定义」
    get_punctuation(::Sentence{punctuation}) where {punctuation <: Punctuation} = punctuation

    "获取「真值」（总体来说，是`UNothing{Truth}`，可能为空）"
    (get_truth(s::Sentence{P})::Truth) where {P <: Union{Judgement, Goal}} = s.truth
    (get_truth( ::Sentence{P})::Nothing) where {P <: Union{Question, Quest}} = nothing
    

    """
    判等の法：词项⇒真值⇒时间戳⇒标点
    """
    Base.isequal(s1::AbstractSentence, s2::AbstractSentence)::Bool = (
        get_term(s1) == get_term(s2) &&
        get_truth(s1) == get_truth(s2) && # 兼容nothing
        get_stamp(s1) == get_stamp(s2) &&
        get_punctuation(s1) == get_punctuation(s2)
    )

    "重定向等号（否则无法引至isequal）"
    Base.:(==)(s1::AbstractSentence, s2::AbstractSentence)::Bool = isequal(s1, s2)
    
    #= 抽象类型 的抽象方法，与真值一脉相承 =#
    for method_name in [:get_f, :get_c]
        @eval begin
            $method_name(s::AbstractSentence) = $method_name(get_truth(s))
        end
    end

    #= 【20230820 12:45:09】语句和词项、语句和语句之间的「比大小」过于反直觉
    """
    重定向「语句🆚词项」比大小：取语句的「内含词项」作对比
    - 相同条件下，语句更大
    """
    Base.isless(s::AbstractSentence, t::AbstractTerm)::Bool = (
        isless(get_term(s), t) #=|| (!isless(get_term(s), t) && # 后面断言第一项相等
        false)=# # 这里按格式是false，但完全可以省略掉
    )
    """
    交换顺序：`t < s == s > t != s < t`（不可在调用中交换顺序）
    - ⚠修改前者时，此方法须一并修改
    """
    Base.isless(t::AbstractTerm, s::AbstractSentence)::Bool = isless(t, get_term(s))

    """
    由「比大小」衍生出的「判等」方法
    - 与「不大于又不小于」/「不（大于或小于）」一致
    """
    Base.isequal(t::AbstractTerm, s::AbstractSentence)::Bool = isequal(t, get_term(s))
    =#

    
    #= 
    =#
    
    """
    抽象类型 的抽象方法，与词项一脉相承
    - 重定向至「内含词项」的方法
    """
    get_syntactic_complexity(s::AbstractSentence) = get_syntactic_complexity(get_term(s))
    "带额外参数的「语法简单度」需要另外实现"
    get_syntactic_simplicity(s::AbstractSentence, r::Number) = get_syntactic_simplicity(get_term(s), r)

end

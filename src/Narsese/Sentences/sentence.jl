# 导出 #
export AbstractSentence, SentenceBasic

# 别名
export ASentence, ASentenceJudgement, ASentenceQuestion, ASentenceGoal, ASentenceQuery
export  Sentence,  SentenceJudgement,  SentenceQuestion,  SentenceGoal,  SentenceQuery

# 代码 #

"""
抽象Narsese语句{标点}
- 包含: 
    - term        词项: 任意词项（参照自OpenNARS）
    - {punctuation} 标点：标定语句的类型（语气/情态）
    - truth       真值: 包含语句的真实度
    - stamp       时间戳: 包含一切「时序信息」
- 以上属性分别定义了相应的get方法
"""
abstract type AbstractSentence{punctuation <: Punctuation} end

# 实现 #

"一个简单实现: 基础语句{标点}"
struct SentenceBasic{punctuation <: Punctuation} <: AbstractSentence{punctuation}
    term::Term
    truth::Truth
    stamp::Stamp

    """
    提供默认值的构造方法
    - 真值の默认: Truth64(1.0, 0.5)
    - 时间戳の默认: StampBasic{Eternal}()
    """
    function SentenceBasic{punctuation}(
        term::Term,
        truth::Truth = Truth64(1.0, 0.5),
        stamp::Stamp = StampBasic{Eternal}()
        ) where {punctuation <: Punctuation}
        new(term, truth, stamp)
    end
end

"""
外部构造方法：词项+真值+时态
- 面向「字符串解析器」

TODO: 对不同NARS实现，支持自定义构造时间戳
"""
function SentenceBasic{punctuation}(
    term::Term,
    truth::Truth,
    ::Type{tense}
    ) where {punctuation <: Punctuation, tense <: Tense}
    SentenceBasic{punctuation}(
        term, truth, 
        StampBasic{tense}() # 自动构建与时态对应的时间戳
    )
end

begin "别名(用于在语句转换时简化表达)"

    const ASentence = AbstractSentence
    const ASentenceJudgement = AbstractSentence{Judgement}
    const ASentenceQuestion  = AbstractSentence{Question}
    const ASentenceGoal      = AbstractSentence{Goal}
    const ASentenceQuery     = AbstractSentence{Query}
    
    const Sentence = SentenceBasic
    const SentenceJudgement = Sentence{Judgement}
    const SentenceQuestion  = Sentence{Question}
    const SentenceGoal      = Sentence{Goal}
    const SentenceQuery     = Sentence{Query}

end

begin "方法集"
    
    """
    各类get方法
    - 丰富Base.get方法，而非添加新方法
    - 使用`get(语句, 目标类型)::目标类型`的形式
    """
    Base.get(s::AbstractSentence, ::Type{Term})::Term = s.term
    Base.get(s::AbstractSentence, ::Type{Truth})::Truth = s.truth
    Base.get(s::AbstractSentence, ::Type{Stamp})::Stamp = s.stamp
    Base.get(s::AbstractSentence, ::Type{Tense})::Type{T} where {T <: Tense} = typeof(s.stamp).parameters[1] # 获取第一个类型参数
    Base.get(s::AbstractSentence, ::Type{Punctuation})::Type{T} where {T <: Punctuation} = typeof(s).parameters[1] # 获取第一个类型参数
    
    """
    判等の法：相等@词项&真值&时间戳
    """
    Base.:(==)(s1::AbstractSentence, s2::AbstractSentence)::Bool = (
        s1.term  == s2.term &&
        s1.truth == s2.truth &&
        s1.stamp == s2.stamp 
    )

end

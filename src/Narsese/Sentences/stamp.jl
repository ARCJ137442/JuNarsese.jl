#=
有关「时间戳」的结构
=#
#= 📝Julia：泛型类的继承，对应类型参数继承就行
    例：使用「子类{参数} <: 父类{参数}」
        `StampBasic{Eternal} <: AbstractStamp{Eternal}` # true
        `StampBasic{Eternal} <: AbstractStamp{Future}` # false
=#
#= 📝Julia：类型的Type
    只有「复合类型」struct是DataType
    - 对「赋予别名」时，不能声明为`别名::DataType`
=#

# 导出
export AbstractStamp, Stamp
export StampBasic


"""
抽象时间戳{时态}
- 统一对接的数据类型
    - 时态（类型参数）：存储语句作为事件所发生的时间
        - 参考：
            - ONA(并列决定)
            - OpenNARS(放在Stamp内)
            - Python(Stemp自动读取)
    - 实现其所需之四个共有属性：
        - 证据基础 evidential_base
        - 创建时间 creation_time
        - 置入时间 put_in_time
        - 发生时间 occurrence_time

【NAL原文参考】
> To allow the “now” to be a moving reference point, 
> each sentence in NARS is given a time stamp to record the moment (according to the internal clock) when the sentence is formed, 
> either from outside (experience) or inside (inference). 
> Furthermore, if the content of the sentence is an event,
> the time stamp also contains a tense defined above, 
> to indicate the happening time of the event with respect to the current moment recorded in the time stamp. 
> If the content of a sentence is not treated as an event, then its time stamp only contains its creation time, 
> while its happening time is taken to be eternal.

【中译文】
> 为了让“现在”成为一个移动的参考点，
> 当句子形成时，NARS中的每个句子都有一个时间戳来记录这个时刻(根据内部时钟)，
> 其要么来自外部(经验)，要么来自内部(推理)。
> 更进一步，如果句子的内容是一个事件，时间戳还包含上面定义的时态，表示事件相对「时间戳中记录的当前时刻」的发生时间。
> 如果一个句子的内容不被视为一个事件，那么它的时间戳只包含它的创建时间，而它发生的时间被认为是永恒的。
> 【源】《NAL》2012，P149
"""
abstract type AbstractStamp{tense <: AbstractTense} end
const Stamp = AbstractStamp # 别名

"记录「数值时间」的类型"
TIME_TYPE::DataType = Int # 整数(具体类型)

"""
源：OpenNARS
记录一个「永恒」的「数值时间」
- 只有在「判断/问题」时能「永恒」
- 而在「目标/请求」时必须「当下」
"""
TIME_ETERNAL::TIME_TYPE = typemin(TIME_TYPE)


"""
源：OpenNARS

基础时间戳结构
- 时态（类型参数）：存储总体的时间状态
- 证据基础：存储「语句被推理出」时所基于的语句（数值引用）
- 各类「数值时间」参数
"""
struct StampBasic{tense <: AbstractTense} <: AbstractStamp{tense}
    # 证据基础
    evidential_base::Vector{TIME_TYPE}

    # 三个时间
    creation_time  ::TIME_TYPE
    put_in_time    ::TIME_TYPE # 这两个在OpenJunars中未出现
    occurrence_time::TIME_TYPE # 这两个在OpenJunars中未出现

    """
    基础构造方法
    - 默认值: 三个时间全部取零
    - ⚠为了对接「表达式协议」，需要暴露其中的全部信息
        - 参见：Conversion/core/ast.jl
    """
    function StampBasic{T}(
        evidential_base::Vector = TIME_TYPE[], # 【20230805 23:52:28】限制类型太严格，会导致用Vector{Any}承装的TIME_TYPEs报错
        creation_time::TIME_TYPE = 0,
        put_in_time::TIME_TYPE = 0,
        occurrence_time::TIME_TYPE = 0,
        ) where {T <: AbstractTense}
        new(
            evidential_base,
            creation_time,
            put_in_time,
            occurrence_time,
        )
    end
end

"类型参数の默认值：无时态⇒「永恒」时态"
StampBasic(args...) = StampBasic{Eternal}(args...)

"""
判等の法：相等@各个属性
"""
Base.:(==)(s1::StampBasic, s2::StampBasic)::Bool = (
    s1.evidential_base  == s2.evidential_base &&
    s1.creation_time    == s2.creation_time &&
    s1.put_in_time      == s2.put_in_time &&
    s1.occurrence_time  == s2.occurrence_time
)

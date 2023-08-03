#=
构建「Narsese语句」的支持

📝Julia: 如何获取「参数类型の实例」中的「类型参数」？以Array{类型, 维数}举例
- 类型属性: 对类型使用propertynames
    - 不完整时: `(Array{Int}) |> propertynames == (:var, :body)`
        - `var`: 缺省的参数类型变量（这里是维数N）
            - 类型: `TypeVar`（类型变量）
            - `(Array{Int}).var.name == :N`
        - `body`: 由上述「类型变量」组成的「完整类型」
            - `(Array{Int}).body` ⇒ Array{Int64, N}
    - 完整时: `(Array{Int,1}) |> propertynames == (:name, :super, :parameters, :types, :instance, :layout, :hash, :flags)`
        - `name`: 类名
        - `super`: 超类
        - `parameters`: 📌类的参数，即所包含的「类型参数」
            - `(Array{Int,1}).parameters` ⇒ svec(Int64, 1)
            - `(Array{Int,1}).parameters[2] == 1`
=#

# 前置导入 #

# 真值
include("sentence/truth.jl")

# 时态
include("sentence/tense.jl")

# 标点
include("sentence/punctuation.jl")

# 时间戳(依赖：时态)
include("sentence/stamp.jl")

# 副系词(依赖：时态)
include("sentence/secondary_copulas.jl")

# 导出 #
export AbstractSentence, ASentence
export Sentence

# 代码 #

"""
抽象Narsese语句
- 包含: 
    - term        词项: 任意词项（参照自OpenNARS）
    - punctuation 标点：标定语句的类型（语气/情态）
    - truth       真值: 包含语句的真实度
    - stamp       时间戳: 包含一切「时序信息」
- 以上属性分别定义了相应的get方法
"""
abstract type AbstractSentence{punctuation <: Punctuation} end
const ASentence = AbstractSentence # 别名

"一个简单实现: 语句{标点}"
struct Sentence{punctuation <: Punctuation} <: AbstractSentence{punctuation}
    term::Term
    truth::Truth
    stamp::Stamp

    """
    提供默认值的构造方法
    - 真值の默认: Truth64(1.0, 0.5)
    - 时间戳の默认: StampBasic{Eternal}()
    """
    function Sentence{punctuation}(
        term::Term,
        truth::Truth = Truth64(1.0, 0.5),
        stamp::Stamp = StampBasic{Eternal}()
        ) where {punctuation <: Punctuation}
        new(term, truth, stamp)
    end
end

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

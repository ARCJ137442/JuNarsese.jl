#=
实现Narsese中的「三元预算」数据结构
- ⚠只提供结构，不提供算法
=#

# 导出 #

export AbstractBudget, ABudget, Budget
export BudgetBasic
export Budget16, Budget32, Budget64, BudgetBig
export default_precision_budget
export get_p, get_d, get_q

# 结构 #

"""
抽象「预算值」类型
- 实现「优先级」「耐久性」「质量」三个属性
    - p priority 优先级 [0,1]
    - d durability 耐久性 [0,1]
    - q quality 质量 [0,1]
    - 实现对应的三个get方法：
        - `get_p(::AbstractBudget)`
        - `get_d(::AbstractBudget)`
        - `get_q(::AbstractBudget)`
- 其API便于后续实现与扩展
"""
abstract type AbstractBudget end

# 别名 #
const Budget = ABudget = AbstractBudget

# 抽象类方法 #

"获取优先级p"
get_p(b::Budget) = error("$(typeof(b)): 未实现的`get_p`方法！")
"获取耐久度d"
get_d(b::Budget) = error("$(typeof(b)): 未实现的`get_d`方法！")
"获取质量q"
get_q(b::Budget) = error("$(typeof(b)): 未实现的`get_q`方法！")

"""
判等の法：相等@p,d,q
- 判等忽略数值精度
"""
Base.:(==)(b1::Budget, b2::Budget)::Bool = (
    number_value_eq(get_p(b1), get_p(b2)) &&
    number_value_eq(get_d(b1), get_d(b2)) &&
    number_value_eq(get_q(b1), get_q(b2))
)

"""
实现迭代器协议
- 迭代の法：等价于迭代数组`[p,d,q]`
"""
Base.iterate(b::Budget, state=1) = iterate([get_p(b), get_d(b), get_q(b)], state)
"长度恒等于3"
Base.length(b::Budget) = 3

# 基础结构 #

"""
基础的「预算值」类型
- 提供「优先级」「耐久性」「质量」的统一
"""
struct BudgetBasic{precision <: AbstractFloat} <: AbstractBudget
    p::precision
    d::precision
    q::precision

    "内部构造方法: 检查数值是否越界"
    function BudgetBasic{precision}(p::precision, d::precision, q::precision) where {precision <: AbstractFloat}

        # 检查边界
        0 ≤ p ≤ 1 || throw(ArgumentError("数值`$p`越界！"))
        0 ≤ d ≤ 1 || throw(ArgumentError("数值`$d`越界！"))
        0 ≤ q ≤ 1 || throw(ArgumentError("数值`$q`越界！"))
        
        # 构造
        new{precision}(p, d, q)
    end
end

"外部构造方法：对于任意实数，都尝试转换为目标类型"
BudgetBasic{precision}(p::Real, d::Real, q::Real) where {precision<:AbstractFloat} = BudgetBasic{precision}(
    convert(precision, p),
    convert(precision, d),
    convert(precision, q),
)

"外部构造方法（面向默认）：使用默认精度"
BudgetBasic(p::Real, d::Real, q::Real) = BudgetBasic{DEFAULT_FLOAT_PRECISION}(
    DEFAULT_FLOAT_PRECISION(p),
    DEFAULT_FLOAT_PRECISION(d),
    DEFAULT_FLOAT_PRECISION(q),
)

"外部构造方法（面向默认）：提供默认精度，并统一提供默认值"
default_precision_budget(p::Real = 0.5, d::Real = 0.5, q::Real = 0.5) = BudgetBasic(p, d, q)

# 别名：各类精度的真值 #
const Budget16::DataType = BudgetBasic{Float16}
const Budget32::DataType = BudgetBasic{Float32}
const Budget64::DataType = BudgetBasic{Float64}

const BudgetBig::DataType = BudgetBasic{BigFloat} # 大浮点

"获取优先级p"
(get_p(b::BudgetBasic{precision})::precision) where {precision <: AbstractFloat} = b.p

"获取耐久度d"
(get_d(b::BudgetBasic{precision})::precision) where {precision <: AbstractFloat} = b.d

"获取质量q"
(get_q(b::BudgetBasic{precision})::precision) where {precision <: AbstractFloat} = b.q

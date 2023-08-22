#=
实现Narsese中的「二元真值」数据结构
- ⚠只提供结构，不提供算法
=#

# 导出 #

export AbstractTruth, ATruth, Truth
export TruthBasic
export Truth16, Truth32, Truth64, TruthBig
export get_f, get_c, default_precision_truth

# 结构 #

"""
抽象「真值」类型
- 实现「频率」「信度」两个属性
    - f frequency 频率 [0,1]
    - c confidence 信度 [0,1]
- 实现对应的两个get方法：
    - `get_f(::AbstractTruth)`
    - `get_c(::AbstractTruth)`
- 其API便于后续实现与扩展
"""
abstract type AbstractTruth end

# 别名
const Truth = ATruth = AbstractTruth

"""
判等の法：相等@f,c
- 判等忽略数值精度
"""
Base.:(==)(t1::Truth, t2::Truth)::Bool = (
    number_value_eq(get_f(t1), get_f(t2)) &&
    number_value_eq(get_c(t1), get_c(t2))
)

"""
实现迭代器协议
- 迭代の法：等价于迭代数组`[f,c]`
"""
Base.iterate(t::Truth, state=1) = iterate([get_f(t), get_c(t)], state)
"长度恒等于2"
Base.length(t::Truth) = 2


"""
可配置的「真值」类型
- 允许背后对f、c值类型的自定义
    - 二者必须是[0,1]的浮点数
"""
struct TruthBasic{F_TYPE <: AbstractFloat, C_TYPE <: AbstractFloat} <: AbstractTruth
    f::F_TYPE
    c::C_TYPE

    "内部构造方法: 检查数值是否越界"
    function TruthBasic{F_TYPE, C_TYPE}(f::F_TYPE, c::C_TYPE) where {
        F_TYPE <: AbstractFloat,
        C_TYPE <: AbstractFloat,
        }

        # 检查边界
        @assert 0 ≤ f ≤ 1 "数值`$f`越界！"# 闭区间
        @assert 0 ≤ c ≤ 1 "数值`$c`越界！"# 【20230803 14:43:07】不涉及NAL，不限制开区间
        
        # 构造
        new{F_TYPE, C_TYPE}(f, c)
    end
end

"外部构造方法：对于任意实数，都尝试转换为目标类型"
function TruthBasic{F_TYPE, C_TYPE}(f::Real, c::Real) where {
    F_TYPE <: AbstractFloat,
    C_TYPE <: AbstractFloat,
    }

    TruthBasic{F_TYPE, C_TYPE}(
        convert(F_TYPE, f),
        convert(C_TYPE, c),
    )
end

"外部构造方法：只指定一个参数类型，相当于复制两个类型"
@inline TruthBasic{V_TYPE}(args...) where {V_TYPE} = TruthBasic{V_TYPE, V_TYPE}(args...)

"外部构造方法（面向默认）：使用默认精度"
@inline TruthBasic(f::Real, c::Real) = TruthBasic{DEFAULT_FLOAT_PRECISION}(
    DEFAULT_FLOAT_PRECISION(f), DEFAULT_FLOAT_PRECISION(c)
)

"外部构造方法（面向默认）：提供默认精度，并统一提供默认值"
default_precision_truth(f::Real = 1.0, c::Real = 0.5) = TruthBasic(f, c)

# 别名：各类精度的真值 #
const Truth16::DataType = TruthBasic{Float16, Float16}
const Truth32::DataType = TruthBasic{Float32, Float32}
const Truth64::DataType = TruthBasic{Float64, Float64}

const TruthBig::DataType = TruthBasic{BigFloat, BigFloat} # 大浮点

"获取频率f"
(get_f(t::TruthBasic{F_TYPE, C_TYPE})::F_TYPE) where {F_TYPE, C_TYPE} = t.f

"获取信度c"
(get_c(t::TruthBasic{F_TYPE, C_TYPE})::C_TYPE) where {F_TYPE, C_TYPE} = t.c

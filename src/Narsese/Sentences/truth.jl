#=
实现Narsese中的「二元真值」数据结构
- ⚠只提供结构，不提供算法
- 📝因「语法缺省」引出的几个概念：
    - 空真值：f、c均缺省，二值均未定义的真值（占位符）
    - 单真值：f已指定，但c仍缺省的真值（部分占位符）
    - 双真值：f、c均已指定的真值（完全体）
=#

# 导出 #

export AbstractTruth, ATruth, Truth
export TruthNull, truth_null
export TruthSingle
export TruthSingle16, TruthSingle32, TruthSingle64, TruthSingleBig
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

# 抽象类方法 #

"获取频率f: get_f(t::Truth)::Real"
# function get_f end # !【2024-01-27 16:57:06】暂不启用「抽象函数」的定义方式
# ! 其在作为Truth子类型，但【未实现获取f、c值，也未特化iterate方法（但string默认能collect）】并获取f/c报错时，会因「打印又需f/c」而继发报错
get_f(t::Truth) = error("$(typeof(t)): 未实现的`get_f`方法！")
"获取信度c: get_c(t::Truth)::Real"
# function get_c end
get_c(t::Truth) = error("$(typeof(t)): 未实现的`get_c`方法！")

"""
【通用】判等の法：相等@f,c
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

# 空结构（作占位符） #

"""
定义在CommonNarsese中因【缺省】而对应的真值
- 在一个语句中充当【真值f、c完全缺省】的占位符
    - 即：f、c均未指定
- 🔗参考：OpenNARS、PyNARS

@example nse"<A --> B>. :|:" ⇔ 空真值
"""
struct TruthNull <: AbstractTruth end

"空真值的单例常量"
const truth_null = TruthNull()

#= "锁定单例模式"
# !【2024-01-27 16:04:52】📝Juliaの无参结构 默认为单例模式
# * Juliaの单例模式：不管怎样，使用`TruthNull()`构造出来的都是一个对象（使用`===`仍然相等）
TruthNull() = truth_null =#

"判等逻辑"
Base.:(==)(::TruthNull, ::TruthNull) = true
Base.:(==)(::TruthNull, ::Truth) = false
Base.:(==)(::Truth, ::TruthNull) = false

"迭代为空：直接结束"
Base.iterate(::TruthNull) = nothing
Base.iterate(::TruthNull, ::Any) = nothing

"长度恒为0（便于区分）"
Base.length(::TruthNull) = 0

"获取f、c报错"
get_f(::TruthNull) = error("尝试获取空真值的f值")
get_c(::TruthNull) = error("尝试获取空真值的c值")

# 单值结构（作占位符） #

"""
定义在CommonNarsese中因【缺省】而对应的真值
- 在一个语句中充当【具有真值f，但c缺省】的占位符
    - f值已指定 为实数
    - c值交由对应「NARS实现」决定
- 🔗参考：OpenNARS、PyNARS

@example nse"<A --> B>. %0.5%" ⇔ 单真值(0.5)
"""
struct TruthSingle{F_TYPE <: Real} <: AbstractTruth
    f::F_TYPE

    "内部构造方法: 检查数值是否越界"
    function TruthSingle{F_TYPE}(f::F_TYPE) where {F_TYPE <: Real}
        # 检查边界
        @assert 0 ≤ f ≤ 1 "数值`$f`越界！"# 闭区间
        # 构造
        new{F_TYPE}(f)
    end
end

"外部构造方法：对于任意实数，都尝试转换为目标类型"
TruthSingle{F_TYPE}(f::Real) where {F_TYPE <: Real} = TruthSingle{F_TYPE}(convert(F_TYPE, f))

"外部构造方法（面向默认）：使用默认精度"
@inline TruthSingle(f::Real) = TruthSingle{DEFAULT_FLOAT_PRECISION}(DEFAULT_FLOAT_PRECISION(f))

"【专用】判等逻辑：仅判断f相等"
Base.:(==)(t1::TruthSingle, t2::TruthSingle) = number_value_eq(get_f(t1), get_f(t2))
Base.:(==)(::TruthSingle, ::Truth) = false
Base.:(==)(::Truth, ::TruthSingle) = false

"迭代为空：直接结束"
Base.iterate(t::TruthSingle, state=1) = iterate([get_f(t)], state)

"长度恒等于1"
Base.length(t::TruthSingle) = 1

"获取f有值"
get_f(t::TruthSingle) = t.f
"获取c报错"
get_c(::TruthSingle) = error("尝试获取单真值的c值")

# 别名：各类精度的单真值 #
const TruthSingle16::DataType = TruthSingle{Float16}
const TruthSingle32::DataType = TruthSingle{Float32}
const TruthSingle64::DataType = TruthSingle{Float64}

const TruthSingleBig::DataType = TruthSingle{BigFloat} # 大浮点

# 基础结构 #

"""
可配置的「真值」类型
- 允许背后对f、c值类型的自定义
    - 二者必须是[0,1]的实数
"""
struct TruthBasic{F_TYPE <: Real, C_TYPE <: Real} <: AbstractTruth
    f::F_TYPE
    c::C_TYPE

    "内部构造方法: 检查数值是否越界"
    function TruthBasic{F_TYPE, C_TYPE}(f::F_TYPE, c::C_TYPE) where {
        F_TYPE <: Real,
        C_TYPE <: Real,
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
    F_TYPE <: Real,
    C_TYPE <: Real,
    }

    TruthBasic{F_TYPE, C_TYPE}(
        convert(F_TYPE, f),
        convert(C_TYPE, c),
    )
end

"外部构造方法：只指定一个参数类型，相当于复制两个类型（但仍然是双真值）"
@inline TruthBasic{V_TYPE}(args...) where {V_TYPE} = TruthBasic{V_TYPE, V_TYPE}(args...)

"外部构造方法（面向默认）：使用默认精度"
@inline TruthBasic(f::Real, c::Real) = TruthBasic{DEFAULT_FLOAT_PRECISION}(
    DEFAULT_FLOAT_PRECISION(f), DEFAULT_FLOAT_PRECISION(c)
)

"外部构造方法（面向默认）" # ! 不再提供默认真值，而是经由「空真值/单真值」交给下游处理（以保证可互转）
default_precision_truth() = truth_null
default_precision_truth(f::Real) = TruthSingle(f)
default_precision_truth(f::Real, c::Real) = TruthBasic(f, c)

# 别名：各类精度的双真值 #
const Truth16::DataType = TruthBasic{Float16, Float16}
const Truth32::DataType = TruthBasic{Float32, Float32}
const Truth64::DataType = TruthBasic{Float64, Float64}

const TruthBig::DataType = TruthBasic{BigFloat, BigFloat} # 大浮点

"获取频率f"
(get_f(t::TruthBasic{F_TYPE, C_TYPE})::F_TYPE) where {F_TYPE, C_TYPE} = t.f

"获取信度c"
(get_c(t::TruthBasic{F_TYPE, C_TYPE})::C_TYPE) where {F_TYPE, C_TYPE} = t.c

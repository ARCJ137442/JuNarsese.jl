#=
实现Narsese中的「二元真值」数据结构
- ⚠只提供结构，不提供算法
=#

# 导出 #

export Truth
export Truth16, Truth32, Truth64, TruthBig

# 结构 #

"""
可配置的「真值」类型
- 允许背后对f、c值类型的自定义
"""
struct Truth{
    F_TYPE <: AbstractFloat, # f值必须是浮点数
    C_TYPE <: AbstractFloat, # c值必须是浮点数
    }
    f::F_TYPE
    c::C_TYPE
end

"外部构造函数：只指定一个参数类型，相当于复制两个类型"
Truth{V_TYPE}(args...) where {V_TYPE} = Truth{V_TYPE, V_TYPE}(args...)

# 别名：各类精度的真值 #
const Truth16::DataType = Truth{Float16, Float16}
const Truth32::DataType = Truth{Float32, Float32}
const Truth64::DataType = Truth{Float64, Float64}

const TruthBig::DataType = Truth{BigFloat, BigFloat} # 大浮点

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
    - 二者必须是[0,1]的浮点数
"""
struct Truth{
    F_TYPE <: AbstractFloat,
    C_TYPE <: AbstractFloat,
    }
    f::F_TYPE
    c::C_TYPE

    "内部构造方法: 检查数值是否越界"
    function Truth{F_TYPE, C_TYPE}(f::F_TYPE, c::C_TYPE) where {
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
function Truth{F_TYPE, C_TYPE}(f::Real, c::Real) where {
    F_TYPE <: AbstractFloat,
    C_TYPE <: AbstractFloat,
    }

    Truth{F_TYPE, C_TYPE}(
        convert(F_TYPE, f),
        convert(C_TYPE, c),
    )
end

"外部构造方法：只指定一个参数类型，相当于复制两个类型"
Truth{V_TYPE}(args...) where {V_TYPE} = Truth{V_TYPE, V_TYPE}(args...)

# 别名：各类精度的真值 #
const Truth16::DataType = Truth{Float16, Float16}
const Truth32::DataType = Truth{Float32, Float32}
const Truth64::DataType = Truth{Float64, Float64}

const TruthBig::DataType = Truth{BigFloat, BigFloat} # 大浮点

"""
判等の法：相等@f,c
"""
Base.:(==)(t1::Truth, t2::Truth)::Bool = (
    t1.f == t2.f &&
    t1.c == t2.c
)
"""
Narsese
- 提供有关Narsese的Julia数据结构

"""
module Narsese

# 配置类参数（可更改） #

import ..Util

"默认有符号整数精度"
DEFAULT_INT_PRECISION::Type{<:Signed} = Int
"默认无符号整数精度"
DEFAULT_UINT_PRECISION::Type{<:Unsigned} = UInt
"默认浮点精度"
DEFAULT_FLOAT_PRECISION::Type{<:AbstractFloat} = Float64

"按照「默认浮点精度」解析字符串(📝Julia这样定义函数不会形成闭包)"
parse_default_float(s) = Base.parse(DEFAULT_FLOAT_PRECISION, s)

"按照「默认有符号整型精度」解析字符串"
parse_default_int(s) = Base.parse(DEFAULT_INT_PRECISION, s)

"按照「默认无符号整型精度」解析字符串"
parse_default_uint(s) = Base.parse(DEFAULT_UINT_PRECISION, s)
# export DEFAULT_FLOAT_PRECISION, DEFAULT_INT_PRECISION, DEFAULT_UINT_PRECISION # 【20230822 11:46:53】「内部配置」参数不会被导出
export parse_default_float, parse_default_int, parse_default_uint

"异类转换精度"
@inline (Util.number_value_eq(a::F1, b::F2)::Bool) where {F1 <: AbstractFloat, F2 <: AbstractFloat} = (
    DEFAULT_FLOAT_PRECISION(a) == DEFAULT_FLOAT_PRECISION(b)
)

# 导入&导出 #

using Reexport

include("Narsese/Terms.jl")
@reexport using .Terms

include("Narsese/Sentences.jl")
@reexport using .Sentences

include("Narsese/Tasks.jl")
@reexport using .Tasks

# 严格模式 #

"""
严格模式的相关代码
"""
const _STRICT_CODE::Expr = include("Narsese/use_strict.jl")

"""
    use_strict!()

启用Narsese的严格模式
- 启用方法：直接调用`Narsese.use_strict()`
- 逻辑：动态include引入一个文件，为「合法性检查」添加方法
- 内容：主要是遵循Narsese本身的限制
    - 其它：详见文件本身
"""
use_strict!() = Narsese.eval(_STRICT_CODE)

end

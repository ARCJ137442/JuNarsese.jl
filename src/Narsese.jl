"""
Narsese
- 提供有关Narsese的Julia数据结构

"""
module Narsese

# 导入&导出

using Reexport

include("Narsese/Terms.jl")
@reexport using .Terms

include("Narsese/Sentences.jl")
@reexport using .Sentences

# 严格模式

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

"""
Conversion
- 提供Julia结构与其它格式的互转

"""
module Conversion

# 依赖：Narsese（数据结构）
import ..Narsese

# 各个模块 #

# Julia内置格式
include("Conversion/ast.jl")
include("Conversion/serialization.jl")

# 外部文件格式
include("Conversion/string.jl")
include("Conversion/json.jl")
include("Conversion/xml.jl")

end

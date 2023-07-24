"""
Conversion
- 提供Julia结构与其它格式的互转

"""
module Conversion

# 依赖：Narsese（数据结构）
import ..Narsese

# 导出
export term2data, data2term # 数据互转
export Term2Data, Data2Term


# 统一定义的逻辑: 用「泛型类」化二元函数为一元函数

abstract type Term2Data{TargetType} end
abstract type Data2Term{TargetType} end

"自动转换方法"
Term2Data{TargetType}(source) where TargetType = term2data(TargetType, source)
Data2Term{TargetType}(source) where TargetType = data2term(TargetType, source)


# 各个模块 #

# Julia内置格式
include("Conversion/ast.jl")
include("Conversion/serialization.jl")

# 外部文件格式
include("Conversion/string.jl")
include("Conversion/json.jl")
include("Conversion/xml.jl")

end

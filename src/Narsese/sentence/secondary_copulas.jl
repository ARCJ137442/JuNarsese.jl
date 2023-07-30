#=
提供仅作为Narsese语法糖的「副系词」支持

📝Julia: 【20230730 18:15:24】任意长类型参数泛型类，似乎不支持
- 但「先定义足够多的参数，后省略定义」是可以的
示例：
```
julia> abstract type S{U,V,} end

julia> S{Int,Int}
S{Int64, Int64}

julia> S{Int}
S{Int64}
```
=#

export SecondaryCopula
export Instance, Property, InstanceProperty
export ImplicationPast, ImplicationPresent, ImplicationFuture
export EquivalancePast, EquivalancePresent, EquivalanceFuture


"""
副系词：只是Narsese中的「语法糖」
- 相对于「主系词」而言
- 实际解析时要转换成「状态+主系词」的形式
- 仅使用「参数类型」提供一个「元素组合」的标签
"""
abstract type SecondaryCopula{U,V,W} end

# 三个「实例/属性」副系词: {-- | --] | {-]
const Instance         = SecondaryCopula{Extension, STInheriance}
const Property         = SecondaryCopula{STInheriance, Intension}
const InstanceProperty = SecondaryCopula{Extension, STInheriance, Intension}

# 三个「带时态蕴含」
const ImplicationPast    = SecondaryCopula{STImplication, Past}
const ImplicationPresent = SecondaryCopula{STImplication, Present}
const ImplicationFuture  = SecondaryCopula{STImplication, Future}

# 三个「带时态等价」
const EquivalancePast    = SecondaryCopula{Equivalance, Past}
const EquivalancePresent = SecondaryCopula{Equivalance, Present}
const EquivalanceFuture  = SecondaryCopula{Equivalance, Future}

# TODO: `ImplicationPast <: Implication == false`, 是否要再定义「所属」关系？

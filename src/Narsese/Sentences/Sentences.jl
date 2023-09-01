#= 📝Julia: 如何获取「参数类型の实例」中的「类型参数」？以Array{类型, 维数}举例
    - 类型属性: 对类型使用propertynames
        - 不完整时: `(Array{Int}) |> propertynames == (:var, :body)`
            - `var`: 缺省的参数类型变量（这里是维数N）
                - 类型: `TypeVar`（类型变量）
                - nameof(`(Array{Int}).var) == :N`
            - `body`: 由上述「类型变量」组成的「完整类型」
                - `(Array{Int}).body` ⇒ Array{Int64, N}
        - 完整时: `(Array{Int,1}) |> propertynames == (:name, :super, :parameters, :types, :instance, :layout, :hash, :flags)`
            - `name`: 类名
            - `super`: 超类
            - `parameters`: 📌类的参数，即所包含的「类型参数」
                - `(Array{Int,1}).parameters` ⇒ svec(Int64, 1)
                - `(Array{Int,1}).parameters[2] == 1`
=#

"""
构建「Narsese语句」的支持

## 数据结构
（最后更新于20230901 9:22:27）

- ^真值
    - 基础真值{F精度 <: 抽象浮点, C精度 <: 抽象浮点}
        + 优先级
        + 耐久性
        + 质量
- ^标点
    - ^判断
    - ^问题
    - ^目标
    - ^请求
- ^时间戳
    - 基础时间戳{时态}
        + 证据基础
        + 创建时间
        + 置入时间
        + 发生时间
    - Py风时间戳
        + 证据基础
        + 创建时间
        + 置入时间
        + 发生时间
- ^语句{标点}
    - 判断句 <: 语句{判断}
        + 词项
        + 时间戳
        + 真值
    - 目标句 <: 语句{目标}
        + 词项
        + 时间戳
        + 真值
    - 问题句 <: 语句{问题}
        + 词项
        + 时间戳
    - 请求句 <: 语句{请求}
        + 词项
        + 时间戳
（使用`^`标注抽象类，`+`表示成员）
"""
module Sentences

# 导入:前置 #

using ...Util # 默认启用(每个模块都无法使用父模块的东西)

using ..Terms # 使用「词项」作前置

# 📌子模块导入父模块变量：需要多个「.」溯源到父路径！
import ..Narsese.DEFAULT_FLOAT_PRECISION as DEFAULT_FLOAT_PRECISION

# 真值
include("truth.jl")

# 标点
include("punctuation.jl")

# 时间戳
include("stamp.jl")

# 语句
include("sentence.jl")

end # module

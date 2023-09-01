"""
构建「Narsese任务」的支持

## 数据结构
（最后更新于20230901 9:19:02）

- ^预算
    - 基础预算{精度 <: 抽象浮点}
        + 优先级
        + 耐久性
        + 质量
- ^物品
- ^任务
    - 基础任务
        + 语句
        + 预算值
（使用`^`标注抽象类，`+`表示成员）
"""
module Tasks

# 导入:前置 #

using ...Util # 默认启用(每个模块都无法使用父模块的东西)

using ..Sentences # 使用「语句」作前置

# 📌子模块导入父模块变量：需要多个「.」溯源到父路径！
import ..Narsese.DEFAULT_FLOAT_PRECISION as DEFAULT_FLOAT_PRECISION

# 预算值
include("budget.jl")

# 抽象物品
include("item.jl")

# 任务
include("task.jl")

end # module

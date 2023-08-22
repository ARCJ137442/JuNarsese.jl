# 导出

export AbstractItem
export get_budget

# 实现

"""
NARS中的「物品」类型
- 可以被放入缓冲区与记忆
- （抽象属性）拥有用于描述「优先级」的「预算值」

【20230822 10:38:45】整体参照OpenNARS与PyNARS的架构
"""
abstract type AbstractItem end

"""
默认的「读取预算」方法
"""
get_budget(item::AbstractItem) = item.budget

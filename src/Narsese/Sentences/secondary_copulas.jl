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


"""
副系词：只是Narsese中的「语法糖」
- 相对于「主系词」而言
- 实际解析时要转换成「状态+主系词」的形式
- 仅使用「参数类型」提供一个「元素组合」的标签
- 扩展「陈述类型」，然后扩展构造函数，使之与「陈述{陈述类型}匹配」
- 📌【20230804 14:52:41】现把「时序蕴含/等价」升级为「主系词」
"""
abstract type SecondaryCopula{U,V,W} <: AbstractStatementType end

# 三个「实例/属性」副系词: {-- | --] | {-]
const Instance         = SecondaryCopula{Extension, STInheriance}
const Property         = SecondaryCopula{STInheriance, Intension}
const InstanceProperty = SecondaryCopula{Extension, STInheriance, Intension}

begin "构造函数扩展：提供自动解析の方法"

    # 实例&属性
    
    """
    实例 `A {-- B` ⇔ `{A} --> B`
    """
    Statement{Instance}(ϕ1::Term, ϕ2::Term) = Inheriance(
        ExtSet(ϕ1),
        ϕ2
    )
    
    """
    属性 `A --] B` ⇔ `A --> [B]`
    """
    Statement{Property}(ϕ1::Term, ϕ2::Term) = Inheriance(
        ϕ1,
        IntSet(ϕ2)
    )
    
    """
    实例-属性 `A {-] B` ⇔ `{A} --> [B]`
    """
    Statement{InstanceProperty}(ϕ1::Term, ϕ2::Term) = Inheriance(
        ExtSet(ϕ1),
        IntSet(ϕ2)
    )
    
end
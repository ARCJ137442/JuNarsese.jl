#=
存放通用编程接口
=#

# 依赖：Narsese（数据结构）
using ..Util # 默认启用
import ..Narsese
using ..Narsese

# 导出
export narsese2data, data2narsese # 数据互转
export narsese2data, data2narsese # 泛型构造方法

"""
陈述转换器的抽象类型模板

使用方法：
1. 其它「类型转换器」注册一个type继承AbstractParser
    - 目标(data)类型「TargetData」：`Base.eltype(type)::DataType = TargetData`
2. 转换「词项→数据」: 使用`narsese2data(type, term)::TargetData`
3. 转换「数据→词项」: 使用`data2narsese(type, T <: Term, data::TargetData)::T`
    - 「总转换入口」：使用「根部方法」`data2narsese(type, T::Type{Term}, data::TargetData)::Term`
"""
abstract type AbstractParser end

"""
（默认）返回其对应「词项↔数据」中「数据」的类型
""" # 📌【20230727 15:59:03】只写在一行会报错「UndefVarError: `T` not defined」
function Base.eltype(::Type{T})::DataType where {T <: AbstractParser}
    Any
end

"""
纳思语→数据 声明
"""
function narsese2data end

"""
数据→纳思语 声明
"""
function data2narsese end

"""
直接调用(类型)：根据参数类型自动转换（词项）
- 用处：便于简化成「一元函数」以便使用管道运算符
- 自动转换逻辑：
    - 数据→词项
    - 词项→数据
- 参数 target：词项/数据
"""
function (parserType::Type{TParser})(
    target, # 目标对象（可能是「数据」也可能是「词项」）
    TermType::Type{TType} = Term, # 只有「数据→词项」时使用（默认为「Term」即「解析成任意词项」）
) where {TParser <: AbstractParser, TType <: Term}
    if target isa eltype(parserType)
        return data2narsese(parserType, TermType, target)
    else
        return narsese2data(parserType, target)
    end
end

"""
直接调用(实例)：根据参数类型自动转换（词项）
- 用处：便于简化成「一元函数」以便使用管道运算符
- 自动转换逻辑：
    - 数据→词项
    - 词项→数据
- 参数 target：词项/数据
"""
function (parser::AbstractParser)(
    target, # 目标对象（可能是「数据」也可能是「词项」）
    TermType::Type{TType} = Term, # 只有「数据→词项」时使用（默认为「Term」即「解析成任意词项」）
    ) where {TType <: Term}
    if target isa eltype(parser)
        return data2narsese(parser, TermType, target)
    else
        return narsese2data(parser, target)
    end
end

"""
数组索引(类型)：根据参数类型自动转换（语句）
- 用处：便于简化成「一元函数」以便使用索引
- 自动转换逻辑：
    - 数据→词项
    - 词项→数据
- 参数 target：词项/数据
"""
function Base.getindex(
    parserType::Type{TParser},
    target, # 目标对象（可能是「数据」也可能是「语句」）
) where {TParser <: AbstractParser}
    if target isa eltype(parserType)
        return data2narsese(parserType, AbstractSentence, target)
    else
        return narsese2data(parserType, target)
    end
end

"""
直接调用(实例)：根据参数类型自动转换（语句）
- 用处：便于简化成「一元函数」以便使用索引
- 自动转换逻辑：
    - 数据→词项
    - 词项→数据
- 参数 target：词项/数据
"""
function Base.getindex(
    parser::AbstractParser,
    target, # 目标对象（可能是「数据」也可能是「语句」）
    )
    if target isa eltype(parser)
        return data2narsese(parser, AbstractSentence, target)
    else
        return narsese2data(parser, target)
    end
end

"""
设定「解析器」的广播行为
- 默认和「函数」是一样的
- 用于`x .|> 解析器`的语法
- 参考：broadcast.jl/713
"""
Base.broadcastable(parser::AbstractParser) = Ref(parser)

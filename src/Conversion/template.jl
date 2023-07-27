#=
存放通用编程接口
=#

# 依赖：Narsese（数据结构）
using ..Util # 默认启用
import ..Narsese
using ..Narsese

# 导出
export term2data, data2term # 数据互转
export Term2Data, Data2Term # 泛型构造函数

"""
语句转换器的抽象类型模板

使用方法：
1. 其它「类型转换器」注册一个type继承AbstractParser
    - 目标(data)类型「TargetData」：`Base.eltype(type)::DataType = TargetData`
2. 转换「词项→数据」: 使用`term2data(type, term)::TargetData`
3. 转换「数据→词项」: 使用`data2term(type, T <: Term, data::TargetData)::T`
    - 「总转换入口」：使用「根部方法」`data2term(type, T::Type{Term}, data::TargetData)::Term`
"""
abstract type AbstractParser end

"默认方法" # 📌【20230727 15:59:03】只写在一行会报错「UndefVarError: `T` not defined」
function Base.eltype(::Type{T})::DataType where {T <: AbstractParser}
    Any
end

# 统一定义的逻辑: 用「泛型类」化二元函数为一元函数 #

abstract type Term2Data{ParserSymbol} end
abstract type Data2Term{ParserSymbol, TermType} end

"自动转换方法"
Term2Data{Parser}(source) where {Parser <: AbstractParser} = term2data(Parser, source)
Data2Term{Parser}(source) where {Parser <: AbstractParser} = data2term(Parser, Term, source)
Data2Term{Parser, TType}(source) where {Parser <: AbstractParser, TType <: Term} = data2term(Parser, TType, source)

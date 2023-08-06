import Serialization

export S11nParser

"""
提供字节流(序列化/反序列化)处理方法
- ⚠尚不稳定：读取可能会出错
"""
abstract type SerializationParser <: AbstractParser end
const S11nParser = SerializationParser

const Bytes8::DataType = Vector{UInt8}

"类型の短别名"
TSParser = Type{S11nParser}

"字节流对象：Vector{UInt8}"
Base.eltype(::TSParser) = Bytes8

# 正式开始 #

# 具体词项对接

"""
总「解析」方法：任意词项都可序列化
- 任意词项类型都适用
"""
function data2narsese(::TSParser, ::Type{T}, bytes::Bytes8)::T where {T <: Conversion.DEFAULT_PARSE_TARGETS}
    Serialization.deserialize(
        IOBuffer(bytes)
    )
end

"""
所有词项的序列化方法
"""
function narsese2data(::TSParser, t::Conversion.DEFAULT_PARSE_TARGETS)::Bytes8
    b::IOBuffer = IOBuffer()
    Serialization.serialize(b, t)
    return b.data::Bytes8 # 断言其必须是Bytes8
end

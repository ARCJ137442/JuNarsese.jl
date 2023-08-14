#=
存放通用编程接口
=#
#= 📝Julia: 获取类名的`string``Symbol`与`nameof`三者的区别
    `string`、`Symbol`：都能获取类型的名称，但会返回类型的完整（相对）路径
        - 例如：在被外部库调用时，`Term`变成了`JuNarsese.Narsese.Term`（字符串/Symbol）
    `nameof`：只获取类型的名称，但会被忽略掉「别名」与「参数类型」
        - 在明确类型所属模块（解析の上下文）时，表示形式相对简洁
        - 例如：不论被什么库调用，`ASentence{Judgement}`都只会是`:ASentenceJudgement`
=#

# 依赖：Narsese（数据结构）
using ..Util # 默认启用
import ..Narsese
using ..Narsese

# 导出
export AbstractParser, TAbstractParser # API对接
export narsese2data, data2narsese # 主函数：数据互转
export DEFAULT_PARSE_TARGETS, TYPE_TERMS, TYPE_SENTENCES # API对接
export parse_target_types # API对接
export parse_type, pack_type_string, pack_type_symbol # API对接
export @narsese_str, @nse_str # 字符串宏(📌短缩写只要不盲目using就没有冲突问题)

"""
陈述转换器的抽象类型模板

使用方法：
1. 其它「类型转换器」注册一个type继承AbstractParser
    - 目标(data)类型「TargetData」：`Base.eltype(type)::Type = TargetData`
2. 转换「词项→数据」: 使用`narsese2data(type, term)::TargetData`
3. 转换「数据→词项」: 使用`data2narsese(type, T <: Term, data::TargetData)::T`
    - 「总转换入口」：使用「根部方法」`data2narsese(type, T::Conversion.TYPE_TERMS, data::TargetData)::Term`
"""
abstract type AbstractParser end

"""
类の别名：控制在调用时解析器可能出现的对象类型
- 作为实例：直接属于`AbstractParser`类
- 作为类型：直接属于`Type{<:AbstractParser}`类

【20230806 21:49:42】已知问题：作为函数调用的「类型参数」签名时报错：
`LoadError: Method dispatch is unimplemented currently for this method signature`
"""
const TAbstractParser::Type = Union{
    AbstractParser,
    Type{<:AbstractParser},
}

"""
声明默认的「目标类型」
- 词项
- 语句
"""
const DEFAULT_PARSE_TARGETS::Type = Union{
    AbstractTerm,
    AbstractSentence,
    }

"""
    const TYPE_SENTENCES::Type = Type{<:AbstractSentence}

声明用于「目标类型参数」转换所需的「词项类型」
"""
const TYPE_TERMS::Type = Type{<:AbstractTerm}

"""
    const TYPE_SENTENCES::Type = Type{<:AbstractSentence}

声明用于「目标类型参数」转换所需的「语句类型」
- 【20230808 10:26:34】「兼容模式」的出现，是否意味着「类型参数」转换的过时？
"""
const TYPE_SENTENCES::Type = Type{<:AbstractSentence}

"""
（默认）返回其对应「词项↔数据」中「数据」的类型
- 未注册→报错
"""
Base.eltype(::TAbstractParser)::ErrorException = error("未注册「数据类型」！")

"解析器将「目标类型」转换成的「数据类型」"
# function Base.eltype end

"""
解析器的「目标类型」：一般是词项/语句
- 未注册→报错
"""
parse_target_types(::Any)::ErrorException = error("未注册「目标类型」！")

"""
纳思语→数据 声明
"""
function narsese2data end

"""
数据→纳思语 声明
"""
function data2narsese end

"""
通用类名解析函数
- 字符串→类名

参数集
- type_name: 类の名
- eval_function: 用于执行eval的函数
    - 方便指定解析的上下文
    - 例：`Narsese.eval`用于解析词项/语句类型
"""
parse_type(type_name::String, eval_function::Function)::Type = eval_function(
    Meta.parse(type_name) |> assert_type_expr # 【20230810 20:33:56】安全锁定
)

"""
适用于符号的解析函数
- 支持解析「泛型类符号」
    - 如`Symbol("Tuple{Int}")`
    - 直接eval不能解析此类Symbol
"""
parse_type(type_name::Symbol, eval_function::Function)::Type = eval_function(
    Meta.parse(
        string(type_name)
    ) |> assert_type_expr # 【20230810 20:33:56】安全锁定
)

"""
通用类名封装函数
- 类名→同名字符串

【20230808 13:31:11】暂为API提供用
【20230808 17:26:50】Julia的`string``Symbol`返回的是完整类名，而nameof不保留别名&泛型，故自行构造字典
【20230810 0:57:19】现在使用正则替换掉类名的「模块路径前缀」，并提升到Util库中
"""
pack_type_string(T::Any)::String = get_pure_type_name(T)

"""
通用类名封装函数@符号
- 相当于Symbol(pack_type_string(type))

【20230808 13:31:11】暂为API提供用
【20230808 17:26:50】Julia的`string``Symbol`返回的是完整类名，而nameof不保留别名&泛型，故自行构造字典
【20230810 0:58:06】现在直接重定向至String，以复用String的方法
"""
pack_type_symbol(T::Any)::Symbol = get_pure_type_symbol(T)


"""
直接调用(解析器作为类型)：根据参数类型自动转换（目标）
- 用处：便于简化成「一元函数」以便使用管道运算符
- 自动转换逻辑：
    - 数据→目标
    - 目标→数据
- 参数 target：目标/数据
"""
function (parser::Type{TParser})(
    target, # 目标对象（可能是「数据」也可能是「目标」）
    TargetType::Type = Any, # 只有「数据→目标」时使用（默认为「Term」即「解析成任意目标」）
) where {TParser <: AbstractParser}
    if target isa eltype(parser)
        return data2narsese(parser, TargetType, target)
    else
        return narsese2data(parser, target)#::eltype(parser) # 莫乱用断言
    end
end

"""
直接调用(解析器作为实例)：根据参数类型自动转换（词项）
- 用处：便于简化成「一元函数」以便使用管道运算符
- 自动转换逻辑：
    - 数据→目标
    - 目标→数据
- 参数 target：目标/数据
"""
function (parser::AbstractParser)(
    target, # 目标对象（可能是「数据」也可能是「目标」）
    TargetType::Type = Any, # 【20230808 9:38:26】现采用「兼容模式」，默认为Any
    )::Any
    if target isa eltype(parser)
        return data2narsese(parser, TargetType, target)::parse_target_types(parser) # 使用「目标类型」检测是否合法
    else
        return narsese2data(parser, target)::eltype(parser)
    end
end

"""
设定「解析器」的广播行为
- 默认和「函数」是一样的
- 用于`x .|> 解析器`的语法
- 参考：broadcast.jl/713
"""
Base.broadcastable(parser::TAbstractParser) = Ref(parser)


raw"""
快捷构造宏
- 📌自带`@raw`效果
- 词项语句均可
- 默认使用ASCII方法
- 支持Latex互转：使用尾缀`latex`

例：
```
julia> narsese"<A --> B>."
<A --> B>. %1.0;0.5%

julia> narsese"\left<A \rightarrow B\right>. \langle1.0,0.5\rangle"latex
<A --> B>. %1.0;0.5%

julia> narsese"「A是B」。"han
<A --> B>. %1.0;0.5%
"""
macro narsese_str(s::String, flag::String="ascii")

    # 符号拼接⇒变量名⇒解析器
    parser_symbol::Symbol = Symbol(:StringParser_, flag)
    # 变量名⇒解析器
    parser::TAbstractParser = Conversion.get_parser_from_flag(
        Val(Symbol(flag)) # 直接采用Val(Symbol)做分派（String不行）
    )
    
    # 解析器（解析对象）
    return :(($parser)($s)) |> esc
end

# 通过Symbol设置别名 @nse_str
Expr(:(=), Symbol("@nse_str"), Symbol("@narsese_str")) |> eval

"""
声明：从字符串宏的「尾缀」中获得解析器
- 协议：`get_parser_from_flag(flag::Val)::TAbstractParser`
- 因为使用`Val{::Symbol}`（实例即Val(::Symbol)），故可以使用多分派特性「动态增加方法」
    - 而无需改变宏の代码
    - 但宏因此需要在对应的「解析器获取方法」声明后才能正常使用
- 默认⇒报错
"""
get_parser_from_flag(::Val)::TAbstractParser = error("未定义的解析器符号！")

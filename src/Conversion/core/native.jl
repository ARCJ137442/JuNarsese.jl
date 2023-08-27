#=
将Narsese转换为Julia原生对象，仅包含：
- 字符串
- 数组(向量)
- 字典(仅「字典」变体)

这些「原生对象」被用于以下解析器：
- JSON
- S-Expr
- YAML
- TOML
=#

# 导出

export NativeParser
export NativeParser_dict, NativeParser_vector

"""
Native转换的两种形式

1. 字典形式
    ```
    Dict(
        "Word" => ["词项"]
    )
    Dict(
        "ExtDifference" => [
            Dict(
                "Operator" => "操作"
            ),
            Dict(
                "IVar" => "独立变量"
            )
        ]
    )
    ```
2. 数组形式
    ```
    [
        "Word",
        "词项"
    ]
    [ # 反正head只有一个
        "ExtDifference",
        [
            "Operator", "操作"
        ]
        [
            "IVar", "独立变量"
        ]
    ]
    ```
"""
const Native_VTypes::Type = Union{
    Dict,
    Vector,
}

"""
基于AST的「原生对象-Narsese对象」互转方法

初步实现方式：
- Native↔object↔AST↔Narsese对象
"""
abstract type NativeParser{Variant <: Native_VTypes} <: AbstractParser end

"转换器の类型"
const TNativeParser::Type = Type{<:NativeParser}

# 别名
const NativeParser_dict::TNativeParser = NativeParser{Dict}
const NativeParser_vector::TNativeParser = NativeParser{Vector}

"用于识别「作为字符串保存的数值」的前导标签"
const NUMBER_PREFLAG::String = "_NUM_"

"""
定义「Native转换」的「目标类型」
- 原生对象↔Narsese对象
"""
const Native_PARSE_TARGETS::Type = Conversion.DEFAULT_PARSE_TARGETS

"目标类型：Narsese对象"
Conversion.parse_target_types(::TNativeParser) = Native_PARSE_TARGETS

"数据类型：向量/字典"
Base.eltype(::TNativeParser)::Type = Native_VTypes

begin "基础方法集"

    "预处理：字符串⇒自身"
    native_preprocess(::Type, val::String)::String = val

    "预处理：数值⇒数组" # 保留数值类型&精度
    native_preprocess(::Type{NativeParser_vector}, n::Number)::Vector{String} = [
        NUMBER_PREFLAG, 
        string(typeof(n)), 
        string(n)
    ]

    "预处理：数值⇒字典" # 保留数值类型&精度
    native_preprocess(::Type{NativeParser_dict}, n::Number)::Dict{String,Dict{String,String}} = Dict(
        NUMBER_PREFLAG => Dict(
            string(typeof(n)) => string(n) # 内部还嵌套一层
        )
    )

    "预处理：符号⇒字串" # 数据结构处必须兼容字符串的构建方法
    native_preprocess(::Type, s::Symbol)::String = string(s)
    
    "预处理：表达式⇒字典"
    native_preprocess(parser::Type{NativeParser_dict}, ast::Expr)::Dict = Dict(
        string(ast.head) => native_preprocess.(parser, ast.args),
    )

    "预处理：表达式⇒数组（向量）"
    native_preprocess(parser::Type{NativeParser_vector}, ast::Expr)::Vector{Union{String,Vector}} = [
        string(ast.head), # 头
        native_preprocess.(parser, ast.args)... # 批量处理并展开
    ]

    "字符串⇒自身"
    native_preparse(::Type, s::String)::String = s

    "符号⇒字符串(不会还原)"
    native_preparse(::Type, s::Symbol)::String = string(s)

    """
    预解析：字典⇒表达式|数值
    - 针对数值这一特殊类型，需要特别进行parse而非直接调用构造函数
    """
    function native_preparse(parser::Type{NativeParser_dict}, d::Dict)::Union{Expr, Number}
        pair::Pair = collect(d)[1] # 只取第一个
        if pair.first == NUMBER_PREFLAG # 解析「数值类型字串-数值字串」对
            num_pair::Pair = collect(pair.second)[1]
            return parse(
                parse_type(num_pair.first, Narsese.eval), 
                num_pair.second
            )
        end
        return Expr(
            Symbol(pair.first), # 只取第一个键当类名
            native_preparse.(parser, pair.second)..., # 只取第一个值当做参数集
        )
    end

    """
    预解析：数组（向量）⇒表达式|数值
    - 针对数值这一特殊类型，需要特别进行parse而非直接调用构造函数
    """
    function native_preparse(parser::Type{NativeParser_vector}, v::Vector)::Union{Expr, Number}
        v[1] == NUMBER_PREFLAG && return parse( # 解析数值
            parse_type(v[2], Narsese.eval), 
            v[3]
        )
        return Expr(
            Symbol(v[1]), # 取第一个当类名
            native_preparse.(parser, v[2:end])..., # 其后当做参数
        )
    end
end

begin "具体转换实现"
    
    "Native字符串⇒表达式⇒Narsese对象"
    function data2narsese(parser::TNativeParser, ::Type, obj::Native_VTypes)::Native_PARSE_TARGETS
        expr::Expr = native_preparse(parser, obj)
        return data2narsese(ASTParser, Any, expr)
    end
    
    "Narsese对象⇒表达式⇒Native字符串"
    function narsese2data(parser::TNativeParser, t::Native_PARSE_TARGETS)::Native_VTypes
        expr::Expr = narsese2data(ASTParser, t)
        return native_preprocess(parser, expr)
    end

end

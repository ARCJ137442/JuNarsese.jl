#=
JSON转换
- 基于AST的原理
=#

# 导入

import JSON

# 导出

export JSONParser

"""
JSON转换的两种形式

1. 「字典形式」
```
{
    "Word": ["词项"]
}
{
    "ExtDifference": [
        {
            "Operator": "操作"
        },
        {
            "IVar": "独立变量"
        }
    ]
}
```
2. 「数组形式」
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
VTypes = Union{Dict, Vector}

"""
提供JSON互转方法

初步实现方式：
- JSON↔object↔AST↔词项
"""
abstract type JSONParser{Variant <: VTypes} <: AbstractParser end

"以JSON表示的字符串"
Base.eltype(::Type{JSONParser{T}}) where T = String

begin "基础方法集"

    "默认方法：用于递归处理参数（无需类型判断，只需使用多分派）"
    function _preprocess(::Type{T}, val::Any) where T
        val # 数字/字符串
    end
    
    "预处理：表达式⇒字典"
    _preprocess(::Type{Dict}, ast::Expr)::Dict = Dict(
        string(ast.head) => _preprocess.(Dict, ast.args) # 批量处理
    )

    "预处理：表达式⇒数组（向量）"
    _preprocess(::Type{Vector}, ast::Expr)::Vector = [
        string(ast.head), # 头
        _preprocess.(Vector, ast.args)... # 批量处理并展开
    ]

    "默认方法：用于递归处理参数（无需类型判断，只需使用多分派）"
    _preparse(::Type, v::Any) = v # 数字/字符串

    "预解析：字典⇒表达式"
    _preparse(::Type{Dict}, d::Dict)::Expr = begin
        pair::Pair = collect(d)[1]
        return Expr(
            Symbol(pair.first), # 只取第一个键当类名
            _preparse.(Dict, pair.second)..., # 只取第一个值当做参数集
        )
    end

    "预解析：数组（向量）⇒表达式"
    _preparse(::Type{Vector}, v::Vector)::Expr = Expr(
        Symbol(v[1]), # 取第一个当类名
        _preparse.(Vector, v[2:end])..., # 其后当做参数
    )
end

begin "具体转换实现（使用AST）"
    
    "JSON字符串⇒表达式⇒词项"
    function data2term(::Type{JSONParser{V}}, ::Type{T}, json::String)::T where {T <: Term, V}
        obj = JSON.parse(json)
        expr::Expr = _preparse(V, obj)
        return data2term(ASTParser, T, expr)
    end
    
    "词项⇒表达式⇒JSON字符串"
    function term2data(::Type{JSONParser{V}}, t::Term)::String where V
        expr::Expr = term2data(ASTParser, t)
        obj = _preprocess(V, expr)
        return JSON.json(obj)
    end
end

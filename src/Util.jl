"""
提供一些辅助开发的实用代码
"""
module Util

export @reverse_dict_content, @redirect_SRS, @exceptedError
export match_first, allproperties, allproperties_generator
export get_pure_type_name, get_pure_type_symbol, verify_type_expr, assert_type_expr
export SYMBOL_NULL

# "可变长参数的自动转换支持" # 用于terms.jl的构造方法 ！添加报错：Unreachable reached at 000002d1cdac1f57
# Base.convert(::Type{Vector{T}}, args::Tuple) where T = args |> collect |> Vector{T}
# Base.convert(::Type{Set{T}}, args::Tuple) where T = args |> Set{T}
# Base.convert(::Type{Tuple{T}}, args::Tuple) where T = args |> Tuple{T}

"反转字典"
macro reverse_dict_content(name::Symbol)
    :(
        v => k
        for (k,v) in $name
    ) |> esc # 避免立即解析
end

"重定向显示方式：从string到repr到show"
function redirect_SRS(para::Expr, code::Expr)
    quote
        Base.string($para)::String = $code
        Base.repr($para)::String = $code
        Base.show(io::IO, $para) = print(io, $code) # 📌没有注明「::IO」会引发歧义
    end |> esc
end
"重定向从string到repr到show"
macro redirect_SRS(para::Expr, code::Expr)
    return redirect_SRS(para, code)
end

"【用于调试】判断「期望出错」（仿官方库show语法）"
macro exceptedError(exs...)
    Expr(:block, [ # 生成一个block，并使用列表推导式自动填充args
        quote
            local e = nothing
            try
                $(esc(ex))
            catch e
                @info "Excepted error! $e"
            end
            # 不能用条件语句，否则局部作用域访问不到ex；也不能去掉这里的双重$引用
            isnothing(e) && "Error: No error expected in code $($(esc(ex)))!" |> error
            !isnothing(e)
        end
        for ex in exs
    ]...) # 别忘展开
end

"""
根据某个「检查函数」寻找匹配的元素，并返回首个匹配的元素
- 提供默认值, 默认为nothing
"""
function match_first(
    criterion::Function,
    collection::Union{Array, Set, Dict, Tuple}, 
    default_value::Any = nothing,
    )::Any
    index = findfirst(criterion, collection)
    return !isnothing(index) ? collection[index] : default_value
end

"""
获取对象的所有属性，并返回包含其所有属性的元组
- 对结构对象struct，属性的出现顺序由其定义顺序决定

原理：
- 使用`propertynames`遍历对象所有属性名
- 使用`isdefined`判断对象属性是否定义
- 使用`getproperty`获取对象属性
"""
allproperties(object::Any) = Tuple(
    allproperties_generator(object)
)

"""
获取对象的所有属性，并返回包含其所有属性的生成器
- 对结构对象struct，属性的出现顺序由其定义顺序决定

原理：
- 使用`propertynames`遍历对象所有属性名
- 使用`isdefined`判断对象属性是否定义
- 使用`getproperty`获取对象属性
"""
allproperties_generator(object::Any) = (
    getproperty(object, name)
    for name::Symbol in propertynames(object)
    if isdefined(object, name)
)

raw"""
扩展字符串、字符、正则表达式、符号的empty方法
- ⚠【20230809 10:44:39】注意：实际上Char无「空字符」一说，
    - 为兼容起见，使用「\u200c」零宽无连接符作占位符
- 返回空字串，「空字符」（\u200c）、「空正则」
"""
Base.empty(::Union{T, Type{T}}) where {T <: AbstractString} = 
    ""
Base.empty(::Union{T, Type{T}}) where {T <: AbstractChar} = 
    '\u200c'
Base.empty(::Union{T, Type{T}}) where {T <: Regex} = 
    r""
Base.empty(::Union{T, Type{T}}) where {T <: Symbol} = 
    Symbol()

"空符号"
SYMBOL_NULL::Symbol = empty(Symbol)

"""
删除「父模块路径」的正则替换对
"""
PURE_TYPE_NAME_REGEX::Pair{Regex, String} = r"([^.{}, ]+\.)+" => ""

"""
获取「纯粹的类名」
- 不随「模块是否被外部导入」而改变

例：
- `JuNarsese.Narsese.StampBasic{JuNarsese.Narsese.TensePresent}`将永远被解析成`StampBasic{TensePresent}`

⚠注意：此方法也不会被「类别名」影响，例如Vector就是返回Array
"""
get_pure_type_name(T::Type)::String = replace(
    string(T), 
    PURE_TYPE_NAME_REGEX
)
"重定向：自动typeof"
get_pure_type_name(T::Any)::String = get_pure_type_name(typeof(T))

"""
获取「纯粹的类名」（Symbol版）
"""
get_pure_type_symbol(T::Any)::Symbol = Symbol(
    get_pure_type_name(T)
)

"""
验证表达式是否**只是**「类名符号」
- 🎯确保`eval`只用于获取类名，从而保证代码运行的安全性
"""
verify_type_expr(expr::Expr)::Bool = (
    expr.head == :curly # 参数类型「类型{参数}」的形式
)
"符号就直接通过"
verify_type_expr(expr::Symbol)::Bool = true

"""
表达式断言：若「只是类名符号」返回本身，否则报错
"""
assert_type_expr(expr::Expr)::Expr = (
    verify_type_expr(expr) ? 
        expr : 
        error("非法符号表达式「$expr」！")
)
"符号总是通过"
assert_type_expr(symbol::Symbol)::Symbol = symbol

end

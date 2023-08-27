"""
提供一些辅助开发的实用代码
"""
module Util

export UNothing
export @reverse_dict_content, @redirect_SRS, @expectedError
export match_first, match_first_view
export allproperties, allproperties_generator, allproperties_named, allproperties_named_generator
export empty_content
export get_pure_type_string, get_pure_type_symbol, verify_type_expr, assert_type_expr
export @generate_ifelseif, @rand

"便捷の可空の支持（同时不与Nullable.jl冲突）"
const UNothing{T} = Union{T, Nothing} where T

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
macro expectedError(exs...)
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
同`match_first`，但返回「元素切片」而非「元素子集」
- 在一些无需修改元素的地方，可以有效减少内存分配，并提高性能
"""
function match_first_view(
    criterion::Function,
    collection::Union{Array, Set, Dict, Tuple}, 
    default_value::Any = nothing,
    )::Any
    index = findfirst(criterion, collection)
    return !isnothing(index) ? (@views collection[index]) : default_value
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

"""
同`allproperties_generator`：获取对象的所有属性，并返回包含其所有`属性名=>属性值`的生成器
"""
allproperties_named_generator(object::Any) = (
    name => getproperty(object, name)
    for name::Symbol in propertynames(object)
    if isdefined(object, name)
)

"""
同`allproperties`：获取对象的所有属性，并返回形式为`属性名=属性值`的属性具名元组
"""
allproperties_named(object::Any) = NamedTuple(
    allproperties_named_generator(object)
)

raw"""
字符串、字符、正则表达式、符号的`empty_content`方法
- ⚠【20230809 10:44:39】注意：实际上Char无「空字符」一说，
    - 为兼容起见，使用「\u200c」零宽无连接符作占位符
- 返回空字串，「空字符」（\u200c）、「空正则」

【20230815 16:19:31】现在加上括号，便可类型注释✅
- 参考链接：https://github.com/JuliaLang/julia/issues/21847#issuecomment-301263779

【20230827 13:55:39】为避免类型盗版，现使用独立的函数，而非扩展`Base`包
"""
(empty_content(::Union{T, Type{T}})::AbstractString) where {T <: AbstractString} = 
    ""
(empty_content(::Union{T, Type{T}})::AbstractChar) where {T <: AbstractChar} = 
    '\u200c'
(empty_content(::Union{T, Type{T}})::Regex) where {T <: Regex} = 
    r""
(empty_content(::Union{T, Type{T}})::Symbol) where {T <: Symbol} = 
    Symbol()

"""
删除「父模块路径」的正则替换对
"""
const PURE_TYPE_NAME_REGEX::Pair{Regex, String} = r"([^.{}, ]+\.)+" => ""

"""
获取「纯粹的类名」
- 不随「模块是否被外部导入」而改变

例：
- `JuNarsese.Narsese.StampBasic{JuNarsese.Narsese.TensePresent}`将永远被解析成`StampBasic{TensePresent}`

⚠注意：此方法也不会被「类别名」影响，例如Vector就是返回Array
"""
get_pure_type_string(T::Type)::String = replace(
    string(T), 
    PURE_TYPE_NAME_REGEX
)
"重定向：自动typeof"
get_pure_type_string(T::Any)::String = get_pure_type_string(typeof(T))

"""
获取「纯粹的类名」（Symbol版）
"""
get_pure_type_symbol(T::Any)::Symbol = Symbol(
    get_pure_type_string(T)
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

"""
自动生成if-elseif-else表达式
使得其中的表达式只有在运行到时才会计算

参数：
- 元组：(条件, 内容)
"""
function generate_ifelseif_macro(exprs::Vararg{Pair}; default=nothing)
    return generate_ifelseif_macro!(Expr(:block), exprs...; default)
end

"""
基于已有的:block表达式，附带默认情况
- 使用`nothing`开关默认情况
"""
function generate_ifelseif_macro!(parent::Expr, exprs::Vararg{Pair}; default=nothing)

    current_args::Vector = parent.args
    is_first::Bool = true
    for expr_pair::Pair in exprs
        push!(
            current_args, 
            Expr(
                is_first ? begin
                    is_first = false
                    :if
                end : :elseif,
                expr_pair.first, 
                expr_pair.second
            )
        )
        current_args = current_args[end].args # 跳到if/elseif表达式的末尾
    end

    # 默认情况：增加else
    !isnothing(default) && push!(
        current_args, 
        default
    )

    return parent
end

"""
宏の形式
注意：传入的每个Pair表达式都是`Expr(:call, :(=>), 前, 后)`的形式

格式：

"""
macro generate_ifelseif(default, exprs::Vararg{Expr})
    # 直接获取第二、第三个参数
    return generate_ifelseif_macro(
        (
            expr.args[2] => expr.args[3]
            for expr in exprs
        )...;
        default
    ) |> esc
end

"""
宏的等价函数
用于自动
1. 构造随机数
2. 生成`if-elseif-else`表达式
"""
function rand_macro(exprs...)::Union{Symbol, Expr}

    # 预先计算表达式数量
    n = length(exprs)

    # 可能是封装到数组里面去了
    if n == 1
        exprs = exprs[1].args
        n = length(exprs)
    end

    # 只有一个⇒优化：直接返回
    if n == 1
        return exprs[1] # 可能是Symbol
    end
    # @assert n > 1 "随机选择至少需要两个备选结果"

    rand_variable::Symbol = Symbol(":rand_n:")

    # 构造代码块
    blk::Expr = generate_ifelseif_macro(
        (
            :($rand_variable == $i) => expr
            for (i, expr) in enumerate(exprs)
        )...;
        default=nothing
    )

    # 在最前方插入随机数代码，以便复用`generate_ifelseif_macro`
    pushfirst!(blk.args, :(local $rand_variable = rand(1:$n)))

    return blk
end

"""
一个用于随机选择代码执行的宏
避免「在随机选择之前，预先计算出所有的备选结果」
"""
macro rand(exprs...)
    esc(rand_macro(exprs...))
end

    
"""
根据「可交换性/无序性」判断元组内元素是否相等
- 可交换性：默认不可交换

【20230820 12:20:10】弃用自`methods.jl`
"""
function check_tuple_equal(
    t1::Tuple, t2::Tuple;
    is_commutative::Bool = false, 
    eq_func = Base.isequal,
    )::Bool
    length(t1) == length(t2) || return false # 元素数相等
    # 开始根据「可交换性」判断相等（可重复/不重复交给构造时构建）
    i::Int, l::Int = 1, length(t1)
    while i ≤ l # 使用「while+递增索引」跳出作用域
        eq_func((@inbounds t1[i]), (@inbounds t2[i])) || break # 不相等⇒退出循环
        i += 1 # 索引递增
    end
    # 全部依次相等(已超过末尾) 或 未到达末尾(有组分不相等)但可交换，否则返回false
    (i>l || is_commutative) || return false
    # 从第一个不等的地方开始，使用「无序比较」的方式比对检查 O(n²)
    # 例子：A ^C D B
    # 　　　A ^B C D
    for j in i:l # 从i开始：避免(A,^B)与(B,^A)的谬误
        any(
            eq_func((@inbounds t1[i]), (@inbounds t2[k]))
            for k in i:l # 这里的i是个常量
        ) || return false # 找不到一个匹配的⇒false（不可能在「第一个不等的地方」之前，两个无序集不可能再相等）
    end
    # 检查成功，返回true
    return true
end

begin "（移植自`truth.jl`）适用于不同精度的数值判等方法"

    export number_value_eq

    """
    类型脱敏判断数值相等
    - 用于应对「不同类型但值相同的Float『fallback到全等』导致不相等」
        - 方法：类型不等⇒转换到「默认精度」进行比较
            - 此举仍有可能不等。。。
    - fallback到「相等」
    """
    @inline number_value_eq(a::Number, b::Number)::Bool = (a == b)

    "同类直接比较"
    @inline (number_value_eq(a::F, b::F)::Bool) where {F <: AbstractFloat} = (
        a == b
    )

    # "异类转换精度" # 在`Narsese.jl`中实现

end

end

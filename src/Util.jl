"""
提供一些辅助开发的实用代码
"""
module Util

export @reverse_dict_content, @redirect_SRS, @exceptedError

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

"重定向从string到repr到show"
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

end

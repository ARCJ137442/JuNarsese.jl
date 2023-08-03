"""
提供一些辅助开发的实用代码
"""
module Util

export @reverse_dict_content, @redirect_SRS

# "可变长参数的自动转换支持" # 用于terms.jl的构造函数 ！添加报错：Unreachable reached at 000002d1cdac1f57
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

end

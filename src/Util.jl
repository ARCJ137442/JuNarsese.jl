"""
提供一些辅助开发的实用代码
"""
module Util

export @reverse_dict_content

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

end

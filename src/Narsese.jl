"""
Narsese
- 提供有关Narsese的Julia数据结构

"""
module Narsese

# 声明待填充常量

"""
类名索引集
【20230808 17:34:37】为实现「类名稳定」，生成一个「类型⇒名字索引集」
- 避免额外的「Narsese.[...]」
"""
const TYPE_NAME_DICT::Dict{Any, Tuple{Symbol, String}} = Dict()
"类の集合"
const TYPE_VALUES::Vector = []

# 导入&导出

using Reexport

include("Narsese/Terms.jl")
@reexport using .Terms

include("Narsese/Sentences.jl")
@reexport using .Sentences

"类名集"
const TYPE_NAMES::Vector = names(Narsese)

let value::Any
    for name::Symbol in TYPE_NAMES
        value = Narsese.eval(name)
        push!(TYPE_VALUES, value)
        push!(TYPE_NAME_DICT, value => (name, string(name)))
    end
end

"稳定地获取类名（包括别名、参数类型）"
get_type_name(type::Type, default::Any) = type in TYPE_NAMES ? TYPE_NAME_DICT[type] : default

end

"""
Narsese
- 提供有关Narsese的Julia数据结构

"""
module Narsese

# 导入&导出

using Reexport

include("Narsese/Terms.jl")
@reexport using .Terms

include("Narsese/Sentences.jl")
@reexport using .Sentences

end

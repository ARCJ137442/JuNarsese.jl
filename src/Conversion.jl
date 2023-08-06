"""
Conversion
- 提供Julia结构与其它格式的互转

标准方法集：为narsese2data、data2narsese添加方法
- 实现「词项→数据」: narsese2data(Term类型, 数据)::Term
    - 因：具体转换成哪个层次的词项，需要在参数（而非返回值）指定
- 实现「数据→词项」: data2narsese(数据类型, Term)::数据类型
    - 总「解析」方法：data2narsese(数据类型, ATerm)
    - 其它类型的解析方法，只针对narsese2data对应类型的返回值
"""
module Conversion

# 前置导入 #

import ..Narsese

using ..Narsese

# 各个模块 #

# 模板
include("Conversion/template.jl")

# 核心
include("Conversion/core/string.jl")
include("Conversion/core/ast.jl")

# 附加
include("Conversion/extra/string_shortcut.jl") # 使用eval的字符串

# 外部文件格式 # TODO: 整体完成后分离独立成包，以便让整体支持轻量化
include("Conversion/extra/serialization.jl") # 序列化支持
include("Conversion/extra/json.jl")
include("Conversion/extra/xml.jl")

end

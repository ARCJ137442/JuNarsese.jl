"""
Conversion
- 提供Julia结构与其它格式的互转

标准方法集：为term2data、data2term添加方法
- 实现「词项→数据」: term2data(Term类型, 数据)::Term
    - 因：具体转换成哪个层次的词项，需要在参数（而非返回值）指定
- 实现「数据→词项」: data2term(数据类型, Term)::数据类型
    - 总「解析」方法：data2term(数据类型, ATerm)
    - 其它类型的解析方法，只针对term2data对应类型的返回值
"""
module Conversion

# 各个模块 #

# 模板
include("Conversion/template.jl")

# Julia内置格式
include("Conversion/internal/string_shortcut.jl")
include("Conversion/internal/ast.jl")
include("Conversion/internal/string.jl")
include("Conversion/internal/serialization.jl")

# 外部文件格式
include("Conversion/extra/json.jl")
include("Conversion/extra/xml.jl")

end

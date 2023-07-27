export ShortcutParser

"""
提供字符串处理方法，但依靠`constructor_shotcuts.jl`提供的定义方式
- 【20230727 16:10:39】暂且只提供「字符串→词项」的方法
"""
abstract type ShortcutParser <: AbstractParser end

"短别名"
TSCParser = Type{ShortcutParser}

"以代码表示的字符串"
Base.eltype(::TSCParser) = String

## 已在template.jl导入
# using ..Util
# using ..Narsese

"""
总「解析」方法
- ！问题：遇到没有语法对应的「词项」无法处理
"""
function data2term(::TSCParser, ::Type{Term}, s::String)
    return s |> Meta.parse |> Narsese.eval
end

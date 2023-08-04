export ShortcutParser

"""
提供字符串处理方法，但依靠`constructor_shortcuts.jl`提供的定义方式
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
function data2narsese(::TSCParser, ::Type{Term}, s::String)
    try # 尝试解析
        expr::Expr = s |> Meta.parse
        # TODO: 替换其中的符号，使原子词项正常显示
        return expr |> Narsese.eval
    catch e
        @error e
        return nothing
    end
end

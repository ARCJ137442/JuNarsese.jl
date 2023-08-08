export ShortcutParser

"""
提供字符串处理方法，但依靠`constructor_shortcuts.jl`提供的定义方式
- 【20230727 16:10:39】暂且只提供「字符串→词项」的方法
"""
abstract type ShortcutParser <: AbstractParser end

"类型の短别名"
const TSCParser::Type = Type{ShortcutParser}

"目标类型：默认"
const SHORTCUT_PARSE_TARGETS::Type = Conversion.DEFAULT_PARSE_TARGETS

"数据类型：以代码表示的字符串"
Base.eltype(::TSCParser)::Type = String

## 已在template.jl导入
# using ..Util
# using ..Narsese

"""
翻译其中会导致「变量未定义」错误的符号
- ⚠会改变对象本身
"""
function _translate_words!(expr::Expr)::Expr
    expr
end

"""
总「解析」方法
- ！问题：遇到没有语法对应的「词项」无法处理
"""
function data2narsese(::TSCParser, ::Conversion.TYPE_TERMS, s::String)
    try # 尝试解析
        expr::Expr = s |> Meta.parse
        # TODO: 替换其中的符号，使原子词项正常显示
        return expr |> _translate_words! |> Narsese.eval
    catch e
        @error e
        return nothing
    end
end

"""
重定向：兼容模式→词项
-【20230808 10:18:31】此实为缓兵之计
"""
function data2narsese(::TSCParser, ::Type{Any}, s::String)
    try # 尝试解析
        expr::Expr = s |> Meta.parse
        # TODO: 替换其中的符号，使原子词项正常显示
        return expr |> _translate_words! |> Narsese.eval
    catch e
        @error e
        return nothing
    end
end

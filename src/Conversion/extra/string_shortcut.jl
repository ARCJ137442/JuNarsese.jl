export ShortcutParser

"""
提供一个基于Julia代码的Narsese字符串解析方法
- ⚠依赖`constructor_shortcuts.jl`提供的定义方式
    - 随时可能发生变化
- 【20230727 16:10:39】暂且只提供「字符串→词项」的方法
- 【20230810 21:18:45】拟弃用
    - 目前而言，这个解析通道只是为了「乘Julia代码的便利」，而非用于生产用途
    - 直接使用eval的方式，安全性难以保障
"""
abstract type ShortcutParser <: AbstractParser end

"类型の短别名"
const TSCParser::Type = Type{ShortcutParser}

"目标类型：只有词项"
const SHORTCUT_PARSE_TARGETS::Type = AbstractTerm

"数据类型：以代码表示的字符串"
Base.eltype(::TSCParser)::Type = String

"目标类型"
parse_target_types(::TSCParser) = SHORTCUT_PARSE_TARGETS

"""
翻译其中会导致「变量未定义」错误的符号
- ⚠会改变对象本身
""" # 【20230810 21:16:58】或许这个功能有些多余
function _translate_words!(expr::Expr)::Expr
    expr
end

"""
总「解析」方法
- ！问题：遇到没有语法对应的「词项」无法处理
"""
function data2narsese(::TSCParser, ::Conversion.TYPE_TERMS, s::AbstractString)
    expr::Expr = s |> Meta.parse
    # TODO: 替换其中的符号，使原子词项正常显示
    return expr |> _translate_words! |> Narsese.eval # ⚠直接使用eval，危险！
end

"""
重定向：兼容模式→词项
- 【20230810 21:21:01】仅为了兼容「直接调用解析器」的用法
    - 因其使用了`Any`参数
"""
data2narsese(::TSCParser, ::Type{Any}, s::AbstractString) = data2narsese(
    ShortcutParser, Term, s
)

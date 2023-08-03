export ASTParser

"""
提供抽象语法树(AST)处理方法
- 一个Expr对应一个词项
"""
abstract type ASTParser <: AbstractParser end

"短别名"
TAParser = Type{ASTParser}

"Julia的Expr对象"
Base.eltype(::TAParser) = Expr

# 【特殊链接】词项↔字符串 #

Base.Expr(t::Term)::Expr = term2data(ASTParser, t)

"构造方法支持"
(::Type{Narsese.Term})(e::Expr) = data2term(ASTParser, Term, e)

# 正式开始 #

# 元解析方法 #

"""
词项类型→Expr头（符号）
"""
function form_type_symbol(type::DataType)::Symbol
    type |> string |> Symbol
end

"""
Expr头→词项类型
- 暂时使用eval从Narsese模块中找类名
"""
function parse_type(name::Symbol)::DataType
    Narsese.eval(name)
end

"""
Expr→词项
- 类名→类→构造方法
- 构造方法(参数...)
    - 协议：构造方法必须要有「构造方法(参数...)」的方法
    - 或：构造出来的表达式，需要与构造方法一致

原理：使用递归「从上往下构造」
"""
function parse_basical(ex::Expr)::Term
    type::DataType = parse_type(ex.head)
    for (i,v) in enumerate(ex.args)
        if v isa Expr # 一个Expr对应一个词项
            ex.args[i] = parse_basical(v) # 递归
        end
    end
    # 返回构造方法构造的词项: 直接将参数按顺序填入其中
    return type(ex.args...)
end

"""
词项→Expr
「类名-参数」格式：(:类名, 参数...)
- 字符串形式
- 嵌套形式
- 混合形式(Image中要使用「占位符位置」)
    - 💭日后若Image中使用「占位符左边之词项」与「占位符右边之词项」记录，此处似乎会有歧义
"""
function form_basical(type::DataType, args::Vararg)::Expr
    Expr(
        form_type_symbol(type), # 头
        args... # 其它符号
    )
end

# 具体词项对接

"""
总「解析」方法：直接调用parse_basical
- 任意词项类型都适用
"""
function data2term(::TAParser, ::Type{T}, ex::Expr)::T where {T <: Term}
    return parse_basical(ex)
end

"""
原子词项的打包方法：(:类名, "名称")
"""
term2data(::TAParser, a::Atom)::Expr = form_basical(
    typeof(a),
    a.name
)
    
"""
词项集的打包方法：(:类名, 各内容)
- 词项集
- 词项逻辑集
- 乘积
"""
term2data(::TAParser, ts::ATermSet)::Expr = form_basical(
    typeof(ts),
    (ts.terms .|> Base.Expr)... # 无论有序还是无序
)

"""
特殊重载：像
- 内容
- 占位符索引
"""
term2data(::TAParser, i::TermImage)::Expr = form_basical(
    typeof(i),
    i.relation_index, # 占位符索引
    (i.terms .|> Base.Expr)... # 所有内容
)

"""
陈述的打包方法
"""
term2data(::TAParser, s::Statement) = form_basical(
    typeof(s),
    Base.Expr(s.ϕ1),
    Base.Expr(s.ϕ2),
)

"""
抽象陈述集的打包方法
- 陈述逻辑集
"""
term2data(::TAParser, s::AStatementSet)::Expr = form_basical(
    typeof(s),
    (s.terms .|> Base.Expr)... # 无论有序还是无序
)

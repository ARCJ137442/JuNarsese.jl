export ASTParser

"""
提供抽象语法树(AST)处理方法
- 一个Expr对应一个词项
"""
abstract type ASTParser <: AbstractParser end

"类型の短别名"
TAParser = Type{ASTParser}

"Julia的Expr对象"
Base.eltype(::TAParser) = Expr

"""
声明「保留类型」
- 解析器直接返回自身
"""
const AST_PRESERVED_TYPES = Union{
    Real, # 实数：s针对真值Truth
    String # 字符串
}

"""
声明「目标类型」
- 能被解析器支持解析
"""
const AST_PARSE_TARGETS = DEFAULT_PARSE_TARGETS

"""
声明「非保留非目标类型」的特征符号头
- ⚠限制条件：Narsese包中不能有任何类名与之重合

例：
- `[1,2,3]` => `Expr(:__PRESERVED__, :vect, 1, 2, 3)`（非保留非『解析目标』类型）
- `1.0` => `1.0`（保留类型）
- "<A --> B>" => `Expr(:Inheriance, Expr(:Word, A), Expr(:Word, B))`（目标类型）
"""
AST_ESCAPE_HEAD::Symbol = :__PRESERVED__

# 【特殊链接】词项↔字符串 #

"表达式→词项"
narsese2data(parser, t::AST_PARSE_TARGETS)::Expr = narsese2data(ASTParser, t)

"构造方法支持"
(::Type{T})(e::Expr) where {T <: AST_PARSE_TARGETS} = data2narsese(ASTParser, Term, e)


# 正式开始 #

begin "元解析方法"

    """
    词项类型→Expr头（符号）
    """
    function form_type_symbol(type::DataType)::Symbol
        type |> string |> Symbol
    end
    
    """
    Expr头→词项类型
    - 【20230805 23:48:56】现在使用`Meta.parse`先把字符串的类型转换为Julia代码
        - 因：Julia不能直接eval带参数类型的Symbol
        - 错の例：`UndefVarError: `Narsese.Sentence{Narsese.PunctuationJudgement}` not defined`
    """
    parse_type(name::Symbol)::Type = parse_type(string(name))
    
    """
    Expr头→词项类型（字符串版本）
    - 先`parse`再`eval`
    """
    parse_type(name::String)::Type = Narsese.eval(Meta.parse(name))
    
    """
    Expr→一般对象
    - 类名→类→构造方法
    - 构造方法(参数...)
        - 协议：构造方法必须要有「构造方法(参数...)」的方法
        - 或：构造出来的表达式，需要与构造方法一致
    
    原理：使用递归「从上往下构造」
    """
    function parse_ast_basical(ex::Expr)::Any
        # 特殊表达式头
        ex.head == AST_ESCAPE_HEAD ?
            # 「特殊表达式头」⇒解析成Julia的默认表达式
            Expr( # 去头，用参数
                ex.args[1], # 第一个是类型
                parse_ast_basical(ex.args[2:end])... # 其它作参数
            ) |> Narsese.eval :
            # 否则解析成`类型(参数集...)`
            parse_type(ex.head)( # 将头解析成对象类型
                parse_ast_basical(ex.args)...
            )
    end
    
    """
    复用代码：返回一个「解析一系列参数」的生成器
    """
    function parse_ast_basical(args::Union{Vector, Tuple, Base.Generator})::Base.Generator
        return ( # 构造生成器
            v isa Expr ?
                parse_ast_basical(v) :  # [递归]一个Expr对应一个对象
                v # 否则不作处理：返回其本身
            for v in args # 遍历预处理表达式
        )
    end
    """
    对象→Expr
    「类名-参数」格式：(:类名, 参数...)
    - 字符串形式
    - 嵌套形式
    - 混合形式(Image中要使用「占位符位置」)
        - 💭日后若Image中使用「占位符左边之词项」与「占位符右边之词项」记录，此处似乎会有歧义
    """
    function form_ast_basical(type::DataType, args::Vararg)::Expr
        Expr(
            form_type_symbol(type), # 类型
            args... # 其它符号
        )
    end

    """
    单对象形式，避免二次遍历
    - 对一切结构都适合的通用形式
    - 仅支持单层遍历
    """
    function form_ast_basical(object::Any)::Expr
        Expr(
            form_type_symbol(typeof(object)), # 类名
            allproperties_generator(object)... # 所有属性
        )
    end
    
end

# 具体解析功能

"""
总「解析」方法：直接调用parse_basical
- 适用：任意词项/语句
"""
function data2narsese(
    parser::TAParser, ::Type{T}, 
    ex::Expr
    )::T where {T <: AST_PARSE_TARGETS}
    return parse_ast_basical(ex)
end

begin "对非「目标类型」的打包方法："
    
    """
    对象→表达式@保留类型
    - 打包方法：直接返回具体值，不作打包处理
    - 不一定保留到对象的类型，需要提前指定
    """
    function narsese2data(
        ::TAParser, object::T
        )::T where {T <: AST_PRESERVED_TYPES}
        return object
    end

    "辅助函数：递归打包の生成器"
    _ast_pack_args(parser, v)::Base.Generator = (
        narsese2data(parser, arg) # 递归打包
        for arg in v # 遍历
    )
    
    """
    对象→表达式@向量
    - 使用特殊的「表达式形式」`:vect`
    - 打包方法：返回`Expr(:vect, :对象类型, 递归解析后的所有属性...)`
    """
    narsese2data(parser::TAParser, v::Vector)::Expr = Expr(
        AST_ESCAPE_HEAD,
        :vect,
        _ast_pack_args(parser, v)...
    )
    
    """
    对象→表达式@元组
    - 使用特殊的「表达式形式」`:tuple`
    - 打包方法：返回`Expr(:tuple, :对象类型, 递归解析后的所有属性...)`
    """
    narsese2data(parser::TAParser, v::Tuple)::Expr = Expr(
        AST_ESCAPE_HEAD,
        :tuple,
        _ast_pack_args(parser, v)...
    )

    """
    数据→对象@默认
    - 打包方法：返回`(:对象类型, 递归解析后的所有属性...)`
    - 包括的对象：
        - Pair
        - 字典（依赖Pair）
    """
    function narsese2data(
        parser::TAParser, object::T
        )::T where {T <: Any}
        return form_ast_basical(
            typeof(object),
            ( # 遍历所有属性
                narsese2data(parser, property)
                for property in allproperties_generator(object)
            )
        )
    end

end

begin "词项の解析"

    """
    原子词项的打包方法：(:类名, "名称")
    """
    narsese2data(::TAParser, a::Atom)::Expr = form_ast_basical(
        typeof(a),
        a.name
    )

    """
    陈述的打包方法
    """
    narsese2data(parser::TAParser, s::Statement) = form_ast_basical(
        typeof(s),
        narsese2data(parser, s.ϕ1),
        narsese2data(parser, s.ϕ2),
    )
    
    """
    词项集的打包方法：(:类名, 各内容)
    - 适用范围：所有集合类的词项（Image会被特别重载）
    """
    narsese2data(parser::TAParser, ts::TermSetLike)::Expr = form_ast_basical(
        typeof(ts),
        narsese2data.(parser, ts.terms)... # 无论有序还是无序
    )

    """
    特殊重载：像
    - 内容
    - 占位符索引
    """
    narsese2data(parser::TAParser, i::TermImage)::Expr = form_ast_basical(
        typeof(i),
        i.relation_index, # 占位符索引(直接存储整数)
        narsese2data.(parser, i.terms)... # 广播所有内容
    )

end

begin "语句の解析"

    """
    真值的打包方法(:类名, f, c)
    
    协议@真值：
    - 属性「f」
    - 属性「c」
    """
    narsese2data(parser::TAParser, t::Truth)::Expr = form_ast_basical(
        typeof(t), # 这里包含了f、c的精度信息, 如「Truth64」
        narsese2data(parser, t.f),
        narsese2data(parser, t.c),
    )

    """
    时间戳的打包方法(:类名, 属性...)
    
    协议@时间戳：
    - 时态：默认包含在类名中，如`StampBasic{Eternal}`
    - 其它属性：统一使用`propertynames`访问
        - 确保构造函数可以控制其所有属性
    """
    narsese2data(parser::TAParser, s::Stamp)::Expr = form_ast_basical(
        typeof(s), # 这里包含了时间戳的时态信息，如「StampBasic{Eternal}」
        (
            narsese2data(parser, property)
            for property in allproperties_generator(s) # 使用生成器避免二次遍历
        )...
    )
    
    """
    抽象语句的打包方法(:类名, 词项, 真值, 时间戳)
    
    协议@语句：
    - 属性「term」：词项
    - 属性「truth」：真值
    - 属性「stamp」：时间戳
    """
    narsese2data(parser::TAParser, s::AbstractSentence)::Expr = form_ast_basical(
        typeof(s),
        narsese2data(parser, s.term),
        narsese2data(parser, s.truth),
        narsese2data(parser, s.stamp),
    )

end

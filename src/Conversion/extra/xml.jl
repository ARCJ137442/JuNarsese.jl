#=
XML转换
- 基于AST的原理
=#

# 导入

import XML

# 导出

export XMLParser

"""
提供XML互转方法

初步实现方式：
- 词项↔AST↔XML

## 例
源Narsese陈述：`<(|, A, ?B) --> (/, A, _, ^C)>`
AST:
```
:Inheriance,
    :IntIntersection,
        :Word,
            "A" # 字符串与符号通用
        :QVar,
            "B"
    :ExtImage,
        2,
        :Word,
            "A"
        :Operator,
            "C"
```

```
<Inheriance>
    <IntIntersection>
        <Word name="A" />
        <QVar name="B" />
        </IntIntersection>
    </IntIntersection>
    <ExtImage relation_index="1">
        <Word name="A" />
        <Operator name = "C" />
    </ExtImage>
</Inheriance>
```
"""
abstract type XMLParser <: AbstractParser end

"类型の短别名"
TXMLParser = Type{XMLParser}

"""
声明「目标类型」
- 能被解析器支持解析
"""
const XML_PARSE_TARGETS = DEFAULT_PARSE_TARGETS

"保留类型"
const XML_PRESERVED_TYPES = Union{
    Real, # 实数：s针对真值Truth
    String # 字符串
}

"以XML表示的字符串"
Base.eltype(::TXMLParser) = String

begin "基础方法集"

    """
    预打包：保留类型⇒XML节点：
    - 用于处理可以直接转换的原始类型数据
    - 最终会变成字符串
    """
    _preprocess_xml(val::XML_PRESERVED_TYPES)::XML.Node =  XML.Node(
        XML.Element, 
        typeof(val) |> string,
        nothing,
        nothing,
        val
    )

    """
    预解析@保留类型(作为默认情况)
    - 🎯用于对时间戳Stamp对象的自动解析
    """
    function _preparse_xml(::Type, v::XML_PRESERVED_TYPES)
        str::String = n[1].value # 文本⇒字符串
        # 【20230806 0:58:54】对「潜在的数值」：使用最大精度，剩下交给构造函数自动转换 TODO 兼容
        value::Union{Real,Nothing} = tryparse(BigFloat, str)
        return isnothing(value) ? str : value # 尝试转换，失败则返回原字串（无法识别类型）
    end

    """
    默认预打包：通用默认类型⇒XML节点：用于「非目标非保留」对象
    1. 先使用AST解析器解析成表达式
    2. 再把表达式转换成XML节点

    例：
    - `[1,2,3]` => <__PRESERVED__ head="vect">
    
    </__PRESERVED__>
    """
    function _preprocess_xml(val::Any)::XML.Node
        # 非表达式⇒打包成表达式: (Conversion.AST_ESCAPE_HEAD, :类名, 参数集...)
        expr::Expr = narsese2data(ASTParser, val) # TODO：需要分离AST中的功能
        # 这时候语句里的元素也一起解析掉了。。。没法_preprocess_xml预处理格式
        _preprocess_xml(expr) # 当表达式解析
    end

    """
    默认预打包：表达式⇒节点
    """
    function _preprocess_xml(expr::Expr)::XML.Node
        # 「非目标非保留」对象
        if expr.head == Conversion.AST_ESCAPE_HEAD # 需要转义
            attributes = (head=string(expr.args[1]),)
            args = expr.args[2:end]
        else # 否则是「目标对象」
            attributes = nothing
            args = expr.args
        end
        children = XML.Node[ # 遍历打包剩余参数（表达式）
            _preprocess_xml(arg)
            for arg in args
        ]
        return XML.Node(
            XML.Element, # 类型：元素
            expr.head, # 使用Symbol也行
            attributes,
            nothing, # 无value
            children,
        )
    end

    """
    默认预解析：XML节点⇒目标对象/「非目标非保留」对象：用于「具有属性的对象」
    1. 先把节点转换成Expr表达式（可能转发）
    2. 再把表达式转换成目标对象

    用于：
    - 数组
    - 元组
    - 字典

    """
    function _preparse_xml(::Type{T}, n::XML.Node)::Any where {T <: Any}
        local head::String
        local children::Vector{XML.Node}
        # 判断tag
        if n.tag == String(Conversion.AST_ESCAPE_HEAD) # 「非目标非保留」对象
            head = n.attributes["head"]
            children = n[2:end]
        else # 转为「对应类型」的解析(目标对象)
            head = n.tag
            children = n.children
        end

        # 生成表达式
        expr::Expr = Expr(
            head |> string,
            ( # 参数逐个解析
                _preparse_xml(Any, node)
                for node in children
            )...
        )
        # 调用AST的解析
        return Conversion.parse_ast_basical(expr)
    end


    """
    预打包：原子词项⇒XML节点
    - 示例：`A` ⇒ `<Word name="A"/>`
    """
    _preprocess_xml(t::Atom)::XML.Node = XML.Node(
        XML.Element, # 类型：元素
        typeof(t) |> string, # 词项类型⇒元素标签
        (name=string(t.name),), # 属性：name=名称（字符串）
    )
    
    """
    预打包：陈述⇒XML节点
    - 示例：`<A --> B>` ⇒ ```
        <Implication>
            <Word name="A"/>
            <Word name="B"/>
        </Implication>
    ```
    """
    _preprocess_xml(t::Statement)::XML.Node = XML.Node(
        XML.Element, # 类型：元素
        typeof(t) |> string, # 词项类型⇒元素标签
        nothing, # 无属性
        nothing, # 无value
        XML.Node[
            _preprocess_xml(t.ϕ1) # 第一个词项
            _preprocess_xml(t.ϕ2) # 第二个词项
        ]
    )
    
    """
    预打包：词项集/陈述集(像除外)
    - 特点：逐一打包其元素terms
    """
    _preprocess_xml(t::Union{ATermSet, AStatementSet})::XML.Node = XML.Node(
        XML.Element, # 类型：元素
        typeof(t) |> string, # 词项类型⇒元素标签
        nothing, # 无属性
        nothing, # 无value
        t.terms .|> _preprocess_xml # 统一预处理
    )
    
    """
    预打包：像
    - 唯一区别就是有「占位符位置」
    """
    _preprocess_xml(t::TermImage)::XML.Node = XML.Node(
        XML.Element, # 类型：元素
        typeof(t) |> string, # 词项类型⇒元素标签
        (relation_index=string(t.relation_index),), # relation_index属性：整数
        nothing, # 无value
        t.terms .|> _preprocess_xml # 统一预处理
    )

    """
    预解析：节点⇒原子词项
    """
    function _preparse_xml(::Type{T}, n::XML.Node)::Term where {T <: Atom}
        type::DataType = Narsese.eval(Symbol(n.tag)) # 获得类型
        name::Symbol = n.attributes["name"] |> Symbol
        return type(name) # 构造原子词项
    end

    """
    预解析：节点⇒陈述
    """
    function _preparse_xml(::Type{T}, n::XML.Node)::Term where {T <: Statement}
        type::DataType = Narsese.eval(Symbol(n.tag)) # 获得类型
        ϕ1::Term = _preparse_xml(Term, n[1])
        ϕ2::Term = _preparse_xml(Term, n[2])
        return type(ϕ1, ϕ2) # 构造原子词项
    end

    """
    预解析：节点⇒词项集/陈述集(像除外)
    """
    function _preparse_xml(::Type{T}, n::XML.Node)::Term where {T <: Union{ATermSet, AStatementSet}}
        type::DataType = Narsese.eval(Symbol(n.tag)) # 获得类型
        terms::Vector = _preparse_xml.(Term, n.children) # 广播
        return type(terms...) # 构造原子词项
    end

    """
    预解析：节点⇒像
    """
    function _preparse_xml(::Type{T}, n::XML.Node)::Term where {T <: TermImage}
        type::DataType = Narsese.eval(Symbol(n.tag)) # 获得类型
        terms::Vector = _preparse_xml.(Term, n.children) # 广播
        relation_index::Integer = parse(UInt, n.attributes["relation_index"]) # 📌parse不能使用抽象类型
        return type(relation_index, terms...) # 构造原子词项
    end
    
    """
    总解析：节点⇒词项
    """
    function _preparse_xml(::Type{Term}, n::XML.Node)::Term
        type::DataType = Narsese.eval(Symbol(n.tag)) # 获得具体的类型
        return _preparse_xml(type, n)
    end
end

begin "具体转换实现（使用AST）"
    
    "XML字符串⇒XML节点⇒表达式⇒目标对象"
    function data2narsese(::TXMLParser, ::Type{T}, xml::String)::T where {T <: XML_PARSE_TARGETS}
        document::XML.Node = XML.parse(xml, XML.Node) # 使用parse(字符串, Node)实现「字符串→Node」
        @assert document[1].nodetype == XML.Element "文档字符串的首个子节点$(document[1])不是元素！"
        return _preparse_xml(T, document[1]) # 「文档节点」一般只有一个元素
    end
    
    "目标对象⇒表达式⇒XML节点⇒XML字符串"
    function narsese2data(::TXMLParser, t::XML_PARSE_TARGETS)::String
        node::XML.Node = _preprocess_xml(t)
        @assert node.nodetype == XML.Element "转换成的子节点$(document[1])不是元素！"
        return XML.write(node) # 使用write实现「Node→字符串」
    end
end

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

"以XML表示的字符串"
Base.eltype(::Type{XMLParser}) = String

begin "基础方法集"

    "默认方法：用于递归处理参数（无需类型判断，只需使用多分派）"
    _preprocess_xml(val::Any)::XML.Node = XML.Node(val)
    
    """
    预处理：原子词项⇒XML节点
    - 示例：`A` ⇒ `<Word name="A"/>`
    """
    _preprocess_xml(t::Atom)::XML.Node = XML.Node(
        XML.Element, # 类型：元素
        typeof(t) |> string, # 词项类型⇒元素标签
        (name=string(t.name),), # 属性：name=名称（字符串）
    )
    
    """
    预处理：陈述⇒XML节点
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
    预处理：词项集/陈述集(像除外)
    """
    _preprocess_xml(t::Union{ATermSet, AStatementSet})::XML.Node = XML.Node(
        XML.Element, # 类型：元素
        typeof(t) |> string, # 词项类型⇒元素标签
        nothing, # 无属性
        nothing, # 无value
        t.terms .|> _preprocess_xml # 统一预处理
    )
    
    """
    预处理：像集
    - 唯一区别就是有「占位符位置」
    """
    _preprocess_xml(t::TermImage)::XML.Node = XML.Node(
        XML.Element, # 类型：元素
        typeof(t) |> string, # 词项类型⇒元素标签
        (relation_index=string(t.relation_index),), # relation_index属性：整数
        nothing, # 无value
        t.terms .|> _preprocess_xml # 统一预处理
    )

    "默认方法：用于递归处理参数（无需类型判断，只需使用多分派）"
    _preparse_xml(::Type, v::Union{Integer, String}) = v # 数字/字符串: 纯值

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
    
    "XML字符串⇒表达式⇒词项"
    function data2term(::Type{XMLParser}, ::Type{T}, xml::String)::T where {T <: Term}
        document::XML.Node = XML.parse(xml, XML.Node) # 使用parse(字符串, Node)实现「字符串→Node」
        @assert document[1].nodetype == XML.Element "文档字符串的首个子节点$(document[1])不是元素！"
        return _preparse_xml(T, document[1]) # 「文档节点」一般只有一个元素
    end
    
    "词项⇒表达式⇒XML字符串"
    function term2data(::Type{XMLParser}, t::Term)::String
        node::XML.Node = _preprocess_xml(t)
        @assert node.nodetype == XML.Element "转换成的子节点$(document[1])不是元素！"
        return XML.write(node) # 使用write实现「Node→字符串」
    end
end

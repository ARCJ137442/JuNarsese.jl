#=
XML转换
- 基于AST的原理
=#

# 导入

import XML

# 导出

export XMLParser, XMLParser_optimized, XMLParser_pure

"""
提供XML互转方法

## 初步实现方式
- 词项↔AST↔XML
- 📄解析后XML内只有：
    - String(位于「文本」类型的XML.Node)
        - 这意味着Number、Symbol类型需先从String中解析
            - Number => parse(类型, 字符串值)
                - 照应AST中的`数字 => Expr(:类型, 值)（视作「结构类型」）`
            - Symbol => Symbol(字符串值)
                - 非保留特征头⇒类名
    - 其它XML.Node

## 「基于AST解析器+附带优化」的一般逻辑

核心：半「AST机翻」半「自行润色」
0. 可扩展性：
    - 区分「AST方法」与「私有方法」
    - 使用ASTの递归回调机制，回调指向「私有方法」实现「内层预润色」
1. 解析の逻辑（XML：XML.Node⇒目标对象）
    - 参数集：解析器，被解析对象（XML.Node）
        - 「eval函数」「递归回调函数」均由「私有解析方法」决定
        - 其它参数用法同AST
    - 若有「特别解析通道」：（XML：纯翻译模式不走此路）
        - 协议：特别解析函数(解析器, 识别出的类型, 被解析对象)
        1. 通过「特别方式」直接组装成Expr
            - （XML）原生类型String：节点类型==XML.Text
                - 返回value
        2. 用AST解析Expr，其中回调「解析函数」（XML：`recurse_callback=xml_parse`）
            - 此举相当于「先回调解析，再AST解析单层Expr」
    - 默认：
        1. 拆分XML，得到「数据对象」+未解析参数集（可能中途返回）
            - （XML）ASTの结构类型：自动消转义（或根据类分派「特别方式」）
                1. 类名::String = 标签==结构转义标签 ? 取type属性 : 标签
                2. 类::Type = AST解析类名
                3. 分派「特别方式」：调用「特别解析函数」
                    - 用于「带优化模式」中词项、语句的优化
                    - 同时存在
                4. 若无分派（返回「被解析对象」自身）：获取头
                    - 头::Symbol = Symbol(类名)
            - （XML）ASTの保留类型：标签==保留类标签
                - 头::Symbol = Symbol(取head属性)
            - （XML）[新] 数值类型：标签==数值类标签
                1. 读取「类型」「字符串值」属性
                2. 调用「字符串⇒数值」方法：`Base.parse(type, value)`
                3. 直接返回解析后的数值
                - 例：`<Number type="Int8" value="127"/>` => `Base.parse(Int8, "127")` => `127::Int8`
        2. 将「未解析参数集」作为args，组装出Expr（XML：子节点children）
        3. 用AST解析Expr(头, args)，其中回调「解析函数」（XML：`recurse_callback=xml_parse`）
            - 相当于「先拆分XML，再逐一转换参数集，最后用AST解析单层」
2. 打包の逻辑（XML：目标对象⇒XML.Node）
    - 参数集：解析器，被打包对象
        - 「eval函数」「递归回调函数」均由「私有打包方法」决定
        - 其它参数用法同AST
    - 若走「特别打包通道」：（XML：纯翻译模式不走此路）
        - 实现方法：「被打包对象」的类型派发
        - 对其内所有参数回调「打包函数」
        - 通过「特别方式」直接组装成数据对象（XML）
            - （XML）例：
                - 字符串：返回「纯文本」`XML.Node(字符串)`
                - 数值：返回「数值类型」
                    - `127::Int8` => `<Number type="Int8" value="127"/>`
    - 默认：
        1. 用AST打包一层得Expr，其中回调「解析函数」（XML：`recurse_callback=xml_parse`）
            - 或：翻译一层对「待解析参数集」回调「打包函数」
        2. 拆分Expr，得到「数据对象」（XML）+已解析参数集（Any）
            - （XML）ASTの结构类型：根据类名决定是否转义
                - 转义：<结构转义标签 type="类名">...
            - （XML）ASTの保留类型：<保留类标签 head="表达式头">
            - （XML）ASTの原生类型：会被「特别打包通道」分派
                - 字符串
                - 数值
        3. 组装成分，得到完整的「数据对象」（XML）

    
## 已知问题

### 对节点标签带特殊符号的XML解析不良

例1：前导冒号丢失——影响「保留特征头」
```
julia> s1 = XML.Node(XML.Element,":a:", 1,1,1) |> XML.write
"<:a: 1=\"1\">1</:a:>"

julia> XML.parse(s1, Node) |> XML.write
"<a:>1</a:>\n"
```

例2：带花括号文本异位——影响「结构类型の解析」
```
julia> n = XML.Node(XML.Element,"a{b}", (type="Vector{Int}",),1,1)
Node Element <a{b} type="Vector{Int}"> (1 child)

julia> XML.write(n)
"<a{b} type=\"Vector{Int}\">1</a{b}>"

julia> XML.parse(XML.write(n),Node)[1]
Node Element <a b="Vector{Int}"> (1 child)
```

### 对单自闭节点解析失败

例：
```
julia> s1 = XML.Node(XML.Element,"a") |> XML.write
"<a/>"

julia> XML.parse(s1, Node) |> XML.write
ERROR: MethodError: no method matching isless(::Int64, ::Nothing)

Closest candidates are:
  isless(::Real, ::AbstractFloat)
   @ Base operators.jl:178
  isless(::Real, ::Real)
   @ Base operators.jl:421
  isless(::Any, ::Missing)
   @ Base missing.jl:88
  ...
```

## 例
源Narsese：
`<(|, A, ?B) --> (/, A, _, ^C)>. :|: %1.0;0.5%`

AST:
```
:SentenceJudgement
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
    :Truth
        1.0
        0.5
    :Stamp{Present}
        【保留特征头】
            :vect
        :Int
            0
        :Int
            0
        :Int
            0
```

纯翻译模式`XMLParser{Expr}`
```
<SentenceJudgement>
    <Inheriance>
        <IntIntersection>
            <Word><Symbol>A</Symbol></Word>
            <QVar><Symbol>B</Symbol></QVar>
        </IntIntersection>
        <ExtImage>
            <Int>1<Int>
            <Word><Symbol>A</Symbol></Word>
            <Operator><Symbol>C</Symbol></Operator>
        </ExtImage>
    </Inheriance>
    <Truth16>
        <Float16>1.0<Float16>
        <Float16>0.5<Float16>
    </Truth16>
    <结构转义标签 type="Stamp{Present}">
        <保留类标签 head="vect"/>
        <Int>0<Int>
        <Int>0<Int>
        <Int>0<Int>
    </结构转义标签>
</SentenceJudgement>
```

带优化模式`XMLParser`
```
<SentenceJudgement>
    <Inheriance>
        <IntIntersection>
            <Word name="A"/>
            <QVar name="B"/>
        </IntIntersection>
        <ExtImage relation_index="1">
            <Word name="A"/>
            <Operator name="C"/>
        </ExtImage>
    </Inheriance>
    <Truth16 f="1.0", c="0.5"/>
    <Stamp tense="Present">
        <保留类标签 head="vect"/>
        <Int value="0">
        <Int value="0">
        <Int value="0">
    </Stamp>
</SentenceJudgement>
```
"""
abstract type XMLParser{Varient} <: AbstractParser end

"类型の短别名"
const TXMLParser::Type = Type{<:XMLParser} # 泛型の不变性の要求

"声明各个「子模式」：纯翻译、带优化"
const XMLParser_optimized::Type = XMLParser # 不带参数类
const XMLParser_pure::Type = XMLParser{Dict} # 带参数类Dict

const TXMLParser_optimized::Type = Type{XMLParser_optimized} # 仅一个Type
const TXMLParser_pure::Type = Type{XMLParser_pure}

"""
声明「目标类型」
- 能被解析器支持解析
"""
const XML_PARSE_TARGETS::Type = DEFAULT_PARSE_TARGETS

"""
声明「原生类型」
- 解析器直接返回Node(自身)
"""
const XML_NATIVE_TYPES = Union{
    String # 字符串
}

"""
声明用于「保留类型识别」的「保留类标签」
- ⚠已知问题：该「保留类标签」可能与AST中「保留特征头」不同
    - 前导冒号缺失：如`:a:` => `a:`
        - 【20230806 18:07:36】目前尚不影响
"""
const XML_PRESERVED_TAG::String = XML.parse(
    XML.Node(
        XML.Element,
        string(Conversion.AST_PRESERVED_HEAD), # 作为字串
        1,1,1 # 后面几个是占位符，避免「单自闭节点解析失败」的Bug
    ) |> XML.write,
    XML.Node
)[1].tag # `[1]`从Document到Element，`.tag`获取标签（字符串）

"""
声明「结构转义标签」
- 用于可能的「Vector{Int}」的转义情况
"""
const XML_ESCAPE_TAG::String = "XML_ESCAPE"

"""
用于判断「是否需要转义」的正则表达式
- 功能：判断一个「构造函数名」是否「符合XML节点标签」标准
- 逻辑：不符合标准⇒需要转义
"""
const XML_ESCAPE_REGEX::Regex = r"^\w+$"

"""
声明「数值类标签」
- 用于定义XML「字符串⇒数值」的「数值类」
"""
const XML_NUMBER_TAG::String = "Number"

"""
声明「数值类」（用于打包）
"""
const XML_NUMBER_TYPES = Union{
    Number
}

"以XML表示的字符串"
Base.eltype(::TXMLParser) = String

begin "解析の逻辑"

    """
    默认解析方法
    - 仅用于：
        - XML.Element
        - XML.Text
    """
    function xml_parse(
        parser::TXMLParser, n::XML.Node,
        eval_function = Narsese.eval
    )::Any
        # 原生类型：字符串
        if n.nodetype == XML.Text
            return n.value
        end
        
        local tag::String = n.tag
        local head::Symbol, args::Vector, type::Type, literal::String
        # 保留类型
        if tag == XML_PRESERVED_TAG
            head = Symbol(n.attributes["head"])
            args = n.children
        # 数值类型
        elseif tag == XML_NUMBER_TAG
            return xml_parse_special(parser, Number, n)
        # 结构类型
        else
            literal = (
                tag == XML_ESCAPE_TAG ? 
                Base.eval(n.attributes["type"]) : 
                tag
            )
            # 字符串⇒类型
            type = eval_function(Meta.parse(literal)) # 可能解析出错
            # 尝试「特别解析」：取捷径解析对象
            parse_special::Any = xml_parse_special(
                parser, type, n
            )
            if parse_special isa XML.Node # 返回自身⇒继续
                head = Symbol(literal)
                args = n.children
            else
                # 直接返回原对象
                return parse_special
            end
        end
        # 统一解析
        expr::Expr = Expr(head, args...)
        return Conversion.ast_parse(
            ASTParser, 
            expr,
            Narsese.eval,
            xml_parse,
            parser, # 递归回调解析器
        )
    end

    """
    （面向Debug）预打包@Symbol：xml将Symbol解析成构造函数
    """
    xml_pack(parser::TXMLParser, s::Symbol)::XML.Node = XML.Node(
        "Symbol", 
        nothing,
        nothing,
        nothing,
        xml_pack(parser, string(s))
    )

    """
    默认预打包：任意对象⇒节点
    """
    function xml_pack(parser::TXMLParser, v::Any)::XML.Node
        # 先打包一层得「args全是Node的Expr」
        expr::Expr = Conversion.ast_pack(
            ASTParser, v, xml_pack,
            parser, # 递归回调解析器
        )

        local tag::Union{String,Symbol}
        local attributes::Union{NamedTuple,Nothing}
        local children::Vector{XML.Node}
        # 保留类型：此时是Expr(保留特征头, 表达式头, 表达式参数...)
        if expr.head == Conversion.AST_PRESERVED_HEAD
            tag = XML_PRESERVED_TAG # 保留类标签
            attributes = (head=String(expr.args[1]),) # 获取第一个元素作「类名」（Symbol）
            children = expr.args[2:end] # 从第二个开始
        # 结构类型：此时是Expr(:类名, 表达式参数...)
        else
            tag = string(expr.head) # Symbol→string
            # 转义的条件：类名包含特殊符号
            if isnothing(match(XML_ESCAPE_REGEX, tag))
                tag = XML_ESCAPE_TAG
                attributes = (type=tag,) # 具名元组
            else # 否则无需转义
                attributes = nothing
            end
            children = expr.args
        end
        # 返回节点
        return XML.Node(
            XML.Element, # 类型：元素
            tag,
            attributes,
            nothing, # 无value
            children,
        )
    end

    """
    默认「特别解析」：返回节点自身
    - 亦针对「原生类型」
    """
    xml_parse_special(::TXMLParser, ::Type, n::XML.Node)::XML.Node = n

    """
    预打包：原生类型⇒XML节点：
    - 用于处理可以直接转换的原始类型数据
    - 最终会变成字符串
    """
    xml_pack(::TXMLParser, val::XML_NATIVE_TYPES)::XML.Node =  XML.Node(val)

    """
    特别解析@数值：节点⇒数值
    """
    xml_parse_special(::TXMLParser, ::Type{Number}, n::XML.Node) = Base.parse(
        Base.eval(n.attributes["type"]), 
        n.attributes["value"]
    )

    """
    预打包：数值类型⇒XML节点：
    - 任何XML解析器都支持解析
    - 用于处理可以直接转换的原始类型数据
    - 最终会变成字符串

    【20230806 20:32:37】已知问题：对带有Rational的数字类型，parse会产生解析错误
    """
    xml_pack(::TXMLParser, num::Number)::XML.Node = XML.Node(
        XML.Element,
        XML_NUMBER_TAG, # 数值打包
        ( # 两个属性：类型&字符串值
            type=string(typeof(num)), # 类型
            value=string(num), # 数值
        ) # 后续属性空着不写
    )

    """
    特别解析@带优化：节点⇒原子词项
    """
    function xml_parse_special(::TXMLParser_optimized, ::Type{T}, n::XML.Node)::Term where {T <: Atom}
        type::DataType = Narsese.eval(Symbol(n.tag)) # 获得类型
        name::Symbol = n.attributes["name"] |> Symbol
        return type(name) # 构造原子词项
    end
    
    """
    预打包：原子词项⇒XML节点
    - 示例：`A` ⇒ `<Word name="A"/>`
    """
    xml_pack(::TXMLParser_optimized, t::Atom)::XML.Node = XML.Node(
        XML.Element, # 类型：元素
        typeof(t) |> string, # 词项类型⇒元素标签
        (name=string(t.name),), # 属性：name=名称（字符串）
    )

    """
    特别解析@带优化：节点⇒陈述
    """
    function xml_parse_special(parser::TXMLParser_optimized, ::Type{T}, n::XML.Node)::Statement where {T <: Statement}
        type::DataType = Narsese.eval(Symbol(n.tag)) # 获得类型
        ϕ1::Term = xml_parse(parser, n[1])
        ϕ2::Term = xml_parse(parser, n[2])
        return type(ϕ1, ϕ2) # 构造原子词项
    end
    
    """
    预打包：陈述⇒XML节点
    - 示例：`<A --> B>` ⇒ ```
        <Implication>
            <Word name="A"/>
            <Word name="B"/>
        </Implication>
    ```
    """
    xml_pack(parser::TXMLParser_optimized, t::Statement)::XML.Node = XML.Node(
        XML.Element, # 类型：元素
        typeof(t) |> string, # 词项类型⇒元素标签
        nothing, # 无属性
        nothing, # 无value
        XML.Node[
            xml_pack(parser, t.ϕ1) # 第一个词项
            xml_pack(parser, t.ϕ2) # 第二个词项
        ]
    )

    """
    特别解析@带优化：节点⇒词项集/陈述集(像除外)
    """
    function xml_parse_special(parser::TXMLParser_optimized, ::Type{T}, n::XML.Node)::Term where {T <: Union{ATermSet, AStatementSet}}
        type::DataType = Narsese.eval(Symbol(n.tag)) # 获得类型
        args = isnothing(n.children) ? [] : n.children # n.children可能是nothing
        terms::Vector = [
            xml_parse(parser, child)::Term
            for child::XML.Node in args
        ] # 广播
        return type(terms...) # 构造原子词项
    end
    
    """
    预打包：词项集/陈述集(像除外)
    - 特点：逐一打包其元素terms
    """
    xml_pack(parser::TXMLParser_optimized, t::Union{ATermSet, AStatementSet})::XML.Node = XML.Node(
        XML.Element, # 类型：元素
        typeof(t) |> string, # 词项类型⇒元素标签
        nothing, # 无属性
        nothing, # 无value
        [ # 子节点
            xml_pack(parser, term)::XML.Node
            for term::Term in t.terms # 统一预处理
        ]
    )

    """
    特别解析@带优化：节点⇒像
    """
    function xml_parse_special(parser::TXMLParser_optimized, ::Type{T}, n::XML.Node)::TermImage where {T <: TermImage}
        type::DataType = Narsese.eval(Symbol(n.tag)) # 获得类型
        args = isnothing(n.children) ? [] : n.children
        terms::Vector = [
            xml_parse(parser, child)::Term
            for child::XML.Node in args
        ] # 广播
        relation_index::Integer = parse(UInt, n.attributes["relation_index"]) # 📌parse不能使用抽象类型
        return type(relation_index, terms...) # 构造原子词项
    end
    
    """
    预打包：像
    - 唯一区别就是有「占位符位置」
    """
    xml_pack(parser::TXMLParser_optimized, t::TermImage)::XML.Node = XML.Node(
        XML.Element, # 类型：元素
        typeof(t) |> string, # 词项类型⇒元素标签
        (relation_index=string(t.relation_index),), # relation_index属性：整数
        nothing, # 无value
        [ # 子节点
            xml_pack(parser, term)::XML.Node
            for term::Term in t.terms # 统一预处理
        ]
    )

    """
    特别解析@带优化：节点⇒真值
    """
    function xml_parse_special(::TXMLParser_optimized, ::Type{T}, n::XML.Node)::Truth where {T <: Truth}
        type::DataType = Narsese.eval(Symbol(n.tag)) # 获得类型
        # 解析其中的f、c值：从类名中获得精度信息
        f_str::String, c_str::String = n.attributes["f"], n.attributes["c"]
        f_type::Type, c_type::Type = type.types # 获取所有类型参数（一定是两个参数，不受别名影响）
        f::f_type, c::c_type = parse(f_type, f_str), parse(c_type, c_str)
        # 构造
        return type(f, c)
    end
    
    """
    预打包：真值⇒XML节点
    - 示例：`%1.0;0.5%` ⇒ `<Truth16 f="1.0", c="0.5"/>`
    """
    xml_pack(::TXMLParser_optimized, t::Truth)::XML.Node = XML.Node(
        XML.Element, # 类型：元素
        typeof(t) |> string, # 词项类型⇒元素标签
        (f=string(t.f),c = string(t.c)), # 属性：f、c
    )

    """
    特别解析@带优化：节点⇒时间戳
    """
    function xml_parse_special(
        parser::TXMLParser_optimized, 
        ::Type{T}, 
        n::XML.Node
        )::Stamp where {T <: Stamp}
        type::Type = Narsese.eval(Symbol(n.tag)) # 获得根类型
        tense::Type{<:Tense} = Narsese.eval(Symbol(n.attributes["tense"])) # 获得类型参数
        # 构造：当结构类型
        args = isnothing(n.children) ? [] : n.children
        return type{tense}(
            (
                # 这里把第四个参数留作默认值
                xml_parse(parser, arg)
                for arg::XML.Node in args
            )...
        )
    end
    
    """
    预打包：时间戳⇒XML节点
    - 前提假定：此中Stamp的「类型参数」一定是实例所属类型的「类型参数」
        - 亦即协议：`具体时间戳类{tense <: AbstractTense} <: AbstractStamp{tense}`
    
    例：对`StampBasic{Eternal}`
    - `StampBasic{Eternal} <: Stamp{Eternal}`提取出「时态」`Eternal`
    - `StampBasic{Eternal}.name.name == :StampBasic`提取出「母类名」
    """
    function xml_pack(parser::TXMLParser_optimized, s::T)::XML.Node where {
        tense <: Tense, # 先有时态
        T <: Stamp{tense} # 然后通过「继承Stamp{时态}」断言，提取出「时态类型」
        }
        # 先打包一层得「args全是Node的Expr」
        expr::Expr = Conversion.ast_pack(
            ASTParser, s, xml_pack,
            parser, # 递归回调解析器
        )
        # 再利用里面的「子节点」构建节点
        XML.Node(
            XML.Element, # 类型：元素
            typeof(s).name.name,
            (tense=string(tense),), # 属性：时态类型
            expr.args
        )
    end

end

begin "入口"
    
    "XML字符串⇒XML节点⇒表达式⇒目标对象"
    function data2narsese(parser::TXMLParser, ::Type{T}, xml::String)::T where {T <: XML_PARSE_TARGETS}
        document::XML.Node = XML.parse(xml, XML.Node) # 使用parse(字符串, Node)实现「字符串→Node」
        @assert document[1].nodetype == XML.Element "文档字符串的首个子节点$(document[1])不是元素！"
        return xml_parse(parser, document[1])::XML_PARSE_TARGETS # 「文档节点」一般只有一个元素
    end
    
    "目标对象⇒表达式⇒XML节点⇒XML字符串"
    function narsese2data(parser::TXMLParser, t::XML_PARSE_TARGETS)::String
        node::XML.Node = xml_pack(parser, t)
        @assert node.nodetype == XML.Element "转换成的子节点$(document[1])不是元素！"
        return XML.write(node)::eltype(parser) # 使用write实现「Node→字符串」
    end
end

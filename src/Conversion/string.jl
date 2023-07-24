#=
提供字符串处理方法

标准方法集：为term2data、data2term添加方法
- 实现「词项→数据」: term2data(Term类型, 数据)::Term
    - 因：具体转换成哪个层次的词项，需要在参数（而非返回值）指定
- 实现「数据→词项」: data2term(数据类型, Term)::数据类型
=#

#= 📝短路表达式@方法声明
- 用处：可以用来动态给函数添加方法
- 加上「自动抵消换行」可以实现「条件定义」
=#

# using ..Util

using ..Narsese # 日后为「模组化」做准备

# term2data
Base.parse(::Type{T}, s::String) where T <: Term = data2term(T, s)

# 链接词项&字符串
Base.string(t::Term)::String = term2data(String, t) # 若想一直用term2data，则其也需要注明类型变成term2data(String, t)
Base.repr(t::Term)::String = term2data(String, t)
Base.show(io::IO, t::Term) = print(io, term2data(String, t)) # 📌没有注明「::IO」会引发歧义


# 词语↔字符串
term2data(::Type{String}, w::Narsese.Word)::String = string(w.name)

function data2term(::Type{Word}, s::String)::Word
    s |> Symbol |> Word
end

# 变量↔字符串
VTYPE_PREFIX_DICT::Dict{DataType, String} = Dict(
    VTIndependent => "\$",
    VTDependent => "#",
    VTQuery => "?",
)

function term2data(::Type{String}, v::Variable{VType})::String where VType
    VTYPE_PREFIX_DICT[VType] * string(v.name)
end

function data2term(::Type{Variable{VType}}, s::String)::Variable where {VType <: AbstractVariableType}
    Variable{VType}(s |> Symbol)
end


# 操作符↔字符串

term2data(::Type{String}, v::Narsese.Operator)::String = "^$(v.name)"

function data2term(::Type{Operator}, s::String)::Operator
    s |> Symbol |> Operator
end


# 词项集↔字符串
"外延集"
term2data(::Type{String}, tse::TermSet{Extension})::String = "{$(join(tse.terms .|> string, ", "))}"
"内涵集"
term2data(::Type{String}, tsi::TermSet{Intension})::String = "[$(join(tsi.terms .|> string, ", "))]"

# TODO 字符串→词项


# 词项逻辑集：交并差

term2data(::Type{String}, t::TermLogicalSet{Extension, And}) = "(&, $(join(t.terms .|> string, ", ")))"
term2data(::Type{String}, t::TermLogicalSet{Intension, And}) = "(|, $(join(t.terms .|> string, ", ")))"

# 暂时不写「并」：在「代码表示」（乃至Latex原文）中都没有对应的符号

term2data(::Type{String}, t::TermLogicalSet{Extension, Not}) = "(-, $(join(t.terms .|> string, ", ")))"
term2data(::Type{String}, t::TermLogicalSet{Intension, Not}) = "(~, $(join(t.terms .|> string, ", ")))"

# TODO 字符串→词项


# 像

term2data(::Type{String}, t::TermImage{Extension}) = 
    "(/, $(join(t.terms[1:t.relation_index-1] .|> string, ", ")), _, $(join(t.terms[t.relation_index:end] .|> string, ", ")))"

term2data(::Type{String}, t::TermImage{Intension}) = 
    "(\\, $(join(t.terms[1:t.relation_index-1] .|> string, ", ")), _, $(join(t.terms[t.relation_index:end] .|> string, ", ")))"

# 乘积
term2data(::Type{String}, t::TermProduct) = "(*, $(join(t.terms .|> string, ", ")))"


# 语句
term2data(::Type{String}, t::Inheriance) = "<$(join(t.terms .|> string, " --> "))>"
term2data(::Type{String}, t::Similarity) = "<$(join(t.terms .|> string, " <-> "))>"
term2data(::Type{String}, t::Implication) = "<$(join(t.terms .|> string, " ==> "))>"
term2data(::Type{String}, t::Equivalance) = "<$(join(t.terms .|> string, " <=> "))>"

# 语句集

term2data(::Type{String}, t::Conjunction) = "(&&, $(join(t.terms .|> string, ", ")))"
term2data(::Type{String}, t::Disjunction) = "(||, $(join(t.terms .|> string, ", ")))"
term2data(::Type{String}, t::Negation) = "(--, $(join(t.terms .|> string, ", ")))"

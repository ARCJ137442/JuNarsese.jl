# 用于后续「语法扩展测试」
import JuNarsese.Narsese.Terms: TermBasedSTs, StatementBasedSTs, FOTerm

# 临时定义陈述合法性：改变「内联合法性检查」逻辑
"继承&相似⇒是否为「一等公民」"
JuNarsese.check_valid(t::Statement{T}) where {T <: TermBasedSTs} = (
    t.ϕ1 ≠ t.ϕ2 && t.ϕ1 isa FOTerm && t.ϕ2 isa FOTerm
)

"继承&相似⇒是否为「一等公民」"
JuNarsese.check_valid_explainable(t::Statement{T}) where {T <: TermBasedSTs} = begin
    @assert t.ϕ1 ≠ t.ϕ2 "禁止重言式！"
    @assert t.ϕ1 isa FOTerm "主项「$(t.ϕ1)」必须是「一等公民词项」！"
    @assert t.ϕ2 isa FOTerm "谓项「$(t.ϕ2)」必须是「一等公民词项」！"
    t
end

"蕴含&等价⇒是否为「陈述词项」"
JuNarsese.check_valid(t::Statement{T}) where {T <: StatementBasedSTs} = (
    t.ϕ1 ≠ t.ϕ2 && t.ϕ1 isa AbstractStatement && t.ϕ2 isa AbstractStatement
)

"蕴含&等价⇒是否为「陈述词项」"
JuNarsese.check_valid_explainable(t::Statement{T}) where {T <: StatementBasedSTs} = begin
    @assert t.ϕ1 ≠ t.ϕ2 "禁止重言式！"
    @assert t.ϕ1 isa AbstractStatement "检测到非陈述词项：$(t.ϕ1)"
    @assert t.ϕ2 isa AbstractStatement "检测到非陈述词项：$(t.ϕ2)"
    t
end
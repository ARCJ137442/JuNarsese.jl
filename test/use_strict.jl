# 用于后续「语法扩展测试」
import JuNarsese.Narsese.Terms: TermBasedSTs, StatementBasedSTs, StatementBasedCTs, StatementLike, FOTerm

# 临时定义陈述合法性：改变「内联合法性检查」逻辑
"继承&相似⇒是否为「一等公民」"
@inline function JuNarsese.check_valid(t::Statement{<:TermBasedSTs})
    t.ϕ1 ≠ t.ϕ2 && t.ϕ1 isa FOTerm && t.ϕ2 isa FOTerm
end

"继承&相似⇒是否为「一等公民」"
@inline function JuNarsese.check_valid_explainable(t::Statement{<:TermBasedSTs})
    @assert t.ϕ1 ≠ t.ϕ2 "禁止重言式「$(t.ϕ1)==$(t.ϕ2)」！"
    @assert t.ϕ1 isa FOTerm "主项「$(t.ϕ1)」必须是「一等公民词项」！"
    @assert t.ϕ2 isa FOTerm "谓项「$(t.ϕ2)」必须是「一等公民词项」！"
    t
end

"蕴含&等价⇒是否为「陈述词项」"
@inline function JuNarsese.check_valid(t::Statement{<:StatementBasedSTs})
    t.ϕ1 ≠ t.ϕ2 && t.ϕ1 isa AbstractStatement && t.ϕ2 isa AbstractStatement
end

"蕴含&等价⇒是否为「陈述词项」"
@inline function JuNarsese.check_valid_explainable(t::Statement{<:StatementBasedSTs})
    @assert t.ϕ1 ≠ t.ϕ2 "禁止重言式「$(t.ϕ1)==$(t.ϕ2)」！"
    @assert t.ϕ1 isa StatementLike "检测到非陈述词项：$(t.ϕ1)"
    @assert t.ϕ2 isa StatementLike "检测到非陈述词项：$(t.ϕ2)"
    t
end


"陈述逻辑集、陈述时序集：词项数>1 && 不支持「非陈述词项」"
@inline function JuNarsese.check_valid(t::ACompound{<:StatementBasedCTs})
    length(t.terms) > 1 && all(term isa StatementLike for term in t.terms)
end
"陈述逻辑集、陈述时序集：词项数>1 && 不支持「非陈述词项」"
@inline function JuNarsese.check_valid_explainable(t::ACompound{<:StatementBasedCTs})
    @assert length(t.terms) > 1 "复合词项「$t」的词项数过少！"
    @assert all(term isa StatementLike for term in t.terms) "检测到元素集「$(t.terms)」中存在非陈述词项！"
    t
end


"否定：不支持「非陈述词项」"
@inline function JuNarsese.check_valid(t::ACompound{<:CTStatementLogicalSet{Not}})
    t.terms[1] isa StatementLike
end
"否定：不支持「非陈述词项」"
@inline function JuNarsese.check_valid_explainable(t::ACompound{<:CTStatementLogicalSet{Not}})
    @assert t.terms[1] isa StatementLike "检测到非陈述词项「$(t.terms[1])」！"
    t
end

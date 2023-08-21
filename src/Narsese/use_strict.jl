begin "预加载部分"

export TermSetLike, TermCompoundSetLike

# 集合类的词项: 形如`(操作符, 词项...)`与其它「有`terms`字段，且有多个元素的集合」
const TermLogicalSetLike  = Union{TermLSet, StatementLSet{And}, StatementLSet{Or}, StatementTSet} # 「逻辑非」不含在内
const TermCompoundSetLike = Union{TermLogicalSetLike, TermImage, TermProduct, StatementLSet{Not}}
const TermSetLike         = Union{TermSet, TermCompoundSetLike} # 与OpenJunars不同的是，还包括「乘积」与「像」

"（内置）陈述的类型：基于词项"
const TermBasedSTs = Union{ # 因其「内部不可扩展性」不予导出
    STInheritance,
    STSimilarity
}
"（内置）陈述的类型：基于陈述"
const StatementBasedSTs = Union{ # 不予导出，理由同上
    StatementTypeImplication, # 注意：ST开头的是「永恒」时态变种
    StatementTypeEquivalence, # 注意：ST开头的是「永恒」时态变种
}
"（内置）一等公民词项" # 不予导出，理由同上
const FOTerm = FirstOrderTerm = Union{Atom, ACompound} # 原子词项&词项集
"（内置）基于陈述的词项集（复合词项类型）"
const StatementBasedCTs = Union{ # 不予导出，理由同上
    CTStatementLogicalSet,
    CTStatementTemporalSet,
}
"（内置）「基于陈述」所言之「陈述」：陈述+陈述逻辑集"
const StatementLike = Union{ # 不予导出，理由同上
    AbstractStatement, 
    StatementLogicalSet, 
    StatementTemporalSet,
    Interval, # 「间隔」表示在「时序推理」中的「时间间隔」
}

end

quote # 在「使用严格模式」时执行的代码

# 用于后续「语法扩展」
# import ..Terms: TermBasedSTs, StatementBasedSTs, StatementBasedCTs, StatementLike, FOTerm # 【20230821 22:17:38】现在不在`Terms.jl`中了
# 导入待更改函数
import ..Terms: check_valid, check_valid_explainable, check_valid_external, check_valid_external_explainable

# 临时定义陈述合法性：改变「内联合法性检查」逻辑
"继承&相似⇒是否为「一等公民」"
@inline function check_valid(t::Statement{<:TermBasedSTs})
    t.ϕ1 ≠ t.ϕ2 && t.ϕ1 isa FOTerm && t.ϕ2 isa FOTerm
end

"继承&相似⇒是否为「一等公民」"
@inline function check_valid_explainable(t::Statement{<:TermBasedSTs})
    @assert t.ϕ1 ≠ t.ϕ2 "禁止重言式「$(t.ϕ1)==$(t.ϕ2)」！"
    @assert t.ϕ1 isa FOTerm "主项「$(t.ϕ1)」必须是「一等公民词项」！"
    @assert t.ϕ2 isa FOTerm "谓项「$(t.ϕ2)」必须是「一等公民词项」！"
    t
end

"蕴含&等价⇒是否为「陈述词项」"
@inline function check_valid(t::Statement{<:StatementBasedSTs})
    t.ϕ1 ≠ t.ϕ2 && t.ϕ1 isa AbstractStatement && t.ϕ2 isa AbstractStatement
end

"蕴含&等价⇒是否为「陈述词项」"
@inline function check_valid_explainable(t::Statement{<:StatementBasedSTs})
    @assert t.ϕ1 ≠ t.ϕ2 "禁止重言式「$(t.ϕ1)==$(t.ϕ2)」！"
    @assert t.ϕ1 isa StatementLike "检测到非陈述词项：$(t.ϕ1)"
    @assert t.ϕ2 isa StatementLike "检测到非陈述词项：$(t.ϕ2)"
    t
end


"陈述逻辑集、陈述时序集：词项数>1 && 不支持「非陈述词项」"
@inline function check_valid(t::ACompound{<:StatementBasedCTs})
    length(t.terms) > 1 && all(term isa StatementLike for term in t.terms)
end
"陈述逻辑集、陈述时序集：词项数>1 && 不支持「非陈述词项」"
@inline function check_valid_explainable(t::ACompound{<:StatementBasedCTs})
    @assert length(t.terms) > 1 "复合词项「$t」的词项数过少！"
    @assert all(term isa StatementLike for term in t.terms) "检测到元素集「$(t.terms)」中存在非陈述词项！"
    t
end


"否定：不支持「非陈述词项」"
@inline function check_valid(t::ACompound{<:CTStatementLogicalSet{Not}})
    t.terms[1] isa StatementLike
end
"否定：不支持「非陈述词项」"
@inline function check_valid_explainable(t::ACompound{<:CTStatementLogicalSet{Not}})
    @assert t.terms[1] isa StatementLike "检测到非陈述词项「$(t.terms[1])」！"
    t
end

# 最后显示「成功启用」消息，并使得返回值为nothing
@info "JuNarsese: 严格模式启用成功！"

end

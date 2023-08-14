#=
存放各类Narsese词项类名的别名
- 缩写
- 归类（Union）

现况：
- 【20230724 18:08:29】使用连等号🆚使用常量（连等号定义常量问题）
=#

# 导出
export Term, ATerm, Atom, AAtom, Compound, ACompound
export AStatement, ATSet, ATermSet, ASSet, AStatementSet
export Var, Op
export TSet
export TLSet, TermLSet, TLogicSet
export TImage, TProduct
export ASLSet, AStatementLSet, ASLogicSet
export SLSet, StatementLSet, SLogicSet

export AVType, AVariableType
# export Independent, VTIndependent # 【20230730 22:54:28】删去非VT别名，因：与「标点」的「Query请求」重名
# export Dependent, VTDependent
# export Query, VTQuery
export ALOperation, ALogicOperation

export IVar, DVar, QVar
export STInheritance, STSimilarity, STImplication, STEquivalence,
      Inheritance,   Similarity,   Implication,   Equivalence
export TemporalStatementTypes

export STImplicationRetrospective, STImplicationConcurrent, STImplicationPredictive
export   ImplicationRetrospective,   ImplicationConcurrent,   ImplicationPredictive
export STEquivalenceRetrospective, STEquivalenceConcurrent, STEquivalencePredictive
export   EquivalenceRetrospective,   EquivalenceConcurrent,   EquivalencePredictive
export STImplicationPast, STImplicationPresent, STImplicationFuture
export   ImplicationPast,   ImplicationPresent,   ImplicationFuture
export STEquivalencePast, STEquivalencePresent, STEquivalenceFuture
export   EquivalencePast,   EquivalencePresent,   EquivalenceFuture

export Negation, Conjunction, Disjunction
export ExtSet, ExtensionSet, 
    IntSet, IntensionSet
export ExtImage, ExtensionImage, 
    IntImage, IntensionImage
export ExtIntersection, ExtensionIntersection, 
    IntIntersection, IntensionIntersection
export ExtUnion, ExtensionUnion, IntUnion, IntensionUnion
export ExtDiff, ExtensionDiff, ExtDifference, ExtensionDifference, 
    IntDiff, IntensionDiff, IntDifference, IntensionDifference
export ParConjunction, SeqConjunction
export TermSetLike, TermCompoundSetLike

# 正式开始 #

const AVType = AVariableType = AbstractVariableType
const VTIndependent = VariableTypeIndependent
const VTDependent = VariableTypeDependent
const VTQuery = VariableTypeQuery # 【20230730 22:54:28】删去非VT别名，因：与「标点」的「Query请求」重名

const ALOperation = ALogicOperation = AbstractLogicOperation

# 这仨可以省去Abstract前缀
const Term     = ATerm     = AbstractTerm
const Atom     = AAtom     = AbstractAtom
const Compound = ACompound = AbstractCompound

const AStatement = AbstractStatement
const ATSet      = ATermSet      = AbstractTermSet
const ASSet      = AStatementSet = AbstractStatementSet

# 省字母
const Var = Variable
const Op  = Operator

const TSet     = TermSet
const TLSet    = TermLSet    = TLogicSet    = TermLogicalSet
const TImage   = TermImage
const TProduct = TermProduct
const ASLSet   = AStatementLSet = ASLogicSet   = AbstractStatementLogicalSet
const SLSet    = StatementLSet  = SLogicSet    = StatementLogicalSet
const STSet    = StatementTSet  = STemporalSet = StatementTemporalSet

# 陈述类型
const STInheritance  = StatementTypeInheritance
const STSimilarity  = StatementTypeSimilarity
const STImplication = StatementTypeImplication{Eternal} # 【20230804 14:48:54】此处变成了特值「Eternal」
const STEquivalence = StatementTypeEquivalence{Eternal} # 【20230804 14:48:54】此处变成了特值「Eternal」
# 三个「带时态蕴含」
const STImplicationRetrospective = StatementTypeImplication{Retrospective}
const STImplicationConcurrent    = StatementTypeImplication{Concurrent}
const STImplicationPredictive    = StatementTypeImplication{Predictive}
# 三个「带时态等价」
const STEquivalenceRetrospective = StatementTypeEquivalence{Retrospective}
const STEquivalenceConcurrent    = StatementTypeEquivalence{Concurrent}
const STEquivalencePredictive    = StatementTypeEquivalence{Predictive}
# 三个「带时态蕴含」（【20230814 15:55:24】简化别名）
const STImplicationPast    = STImplicationRetrospective
const STImplicationPresent = STImplicationConcurrent
const STImplicationFuture  = STImplicationPredictive
# 三个「带时态等价」（【20230814 15:55:24】简化别名）
const STEquivalencePast    = STEquivalenceRetrospective
const STEquivalencePresent = STEquivalenceConcurrent
const STEquivalenceFuture  = STEquivalencePredictive

# 对接OpenJunars #

# 各类型变量
const IVar = Variable{VTIndependent}
const DVar = Variable{VTDependent}
const QVar = Variable{VTQuery}

# 各类型陈述
const Inheritance  = Statement{STInheritance}
const Similarity  = Statement{STSimilarity}
const Implication = Statement{STImplication}
const Equivalence = Statement{STEquivalence}
"「有时态系词」：需要有格式`ST{时态<:Tense}`"
const TemporalStatementTypes = Union{
    STImplication, # 所有蕴含
    STEquivalence  # 所有等价
}
# 三个「带时态蕴含」
const ImplicationRetrospective = Statement{STImplicationRetrospective}
const ImplicationConcurrent    = Statement{STImplicationConcurrent}
const ImplicationPredictive    = Statement{STImplicationPredictive}
# 三个「带时态等价」
const EquivalenceRetrospective = Statement{STEquivalenceRetrospective}
const EquivalenceConcurrent    = Statement{STEquivalenceConcurrent}
const EquivalencePredictive    = Statement{STEquivalencePredictive}
# 三个「带时态蕴含」（【20230814 15:55:01】现作为简化别名）
const ImplicationPast    = Statement{STImplicationPast}
const ImplicationPresent = Statement{STImplicationPresent}
const ImplicationFuture  = Statement{STImplicationFuture}
# 三个「带时态等价」（【20230814 15:55:01】现作为简化别名）
const EquivalencePast    = Statement{STEquivalencePast}
const EquivalencePresent = Statement{STEquivalencePresent}
const EquivalenceFuture  = Statement{STEquivalenceFuture}

# 词项集
const Negation = StatementLSet{Not}
const Conjunction = StatementLSet{And}
const Disjunction = StatementLSet{Or}

const ExtSet = ExtensionSet = TermSet{Extension}
const IntSet = IntensionSet = TermSet{Intension}

const ExtImage = ExtensionImage = TermImage{Extension}
const IntImage = IntensionImage = TermImage{Intension}

# 交集
const ExtIntersection = ExtensionIntersection = TermLSet{Extension, And}
const IntIntersection = IntensionIntersection = TermLSet{Intension, And}

# 并集（一般不使用）
const ExtUnion = ExtensionUnion = TermLSet{Extension, Or}
const IntUnion = IntensionUnion = TermLSet{Intension, Or}

const ExtDiff = ExtensionDiff = ExtDifference = ExtensionDifference = TermLogicalSet{Extension, Not}
const IntDiff = IntensionDiff = IntDifference = IntensionDifference = TermLogicalSet{Intension, Not}

# 陈述时序集（原创）
const ParConjunction = STSet{Parallel}
const SeqConjunction = STSet{Sequential}

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
const FOTerm = FirstOrderTerm = Union{Atom, AbstractTermSet} # 原子词项&词项集

# 集合类的词项: 形如`(操作符, 词项...)`与其它「有`terms`字段，且有多个元素的集合」
const TermLogicalSetLike  = Union{TermLSet, StatementLSet{And}, StatementLSet{Or}, StatementTSet} # 「逻辑非」不含在内
const TermCompoundSetLike = Union{TermLogicalSetLike, TermImage, TermProduct, StatementLSet{Not}}
const TermSetLike      = Union{TermSet, TermCompoundSetLike} # 与OpenJunars不同的是，还包括「乘积」与「像」
# const TermSetSymmetric    = Union{
#     TermSet, 
#     TermLSet{Extension, And}, TermLSet{Extension, Or}, TermLSet{Intension, And}, TermLSet{Intension, Or},
#     StatementLSet{And}, StatementLSet{Or}, 
#     StatementTemporalSet{Parallel}
# } # 所有具有「对称性」的词项/陈述集合 【20230811 13:55:37】这个应该被更灵活地定义，以便后续扩展

# const SymmetricStatementTypes = Union{STSimilarity, STEquivalence} # 同上，需要更好地扩展

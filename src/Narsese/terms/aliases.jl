#=
存放各类Narsese词项类名的别名
- 缩写
- 归类（Union）

现况：
- 【20230724 18:08:29】使用连等号🆚使用常量（连等号定义常量问题）
=#

# 导出
export Term, ATerm, Atom, AAtom, ACompound
export Compound, CCompound
export Var, Op
export TermSet, TermLogicalSet, TermProduct, StatementLogicalSet, StatementTemporalSet
export TSet
export TLSet, TermLSet, TLogicSet
export TImage, TProduct
export SLSet, StatementLSet, SLogicSet

export AVType, AVariableType
export VTIndependent, VTDependent, VTQuery
# export Independent, VTIndependent # 【20230730 22:54:28】删去非VT别名，因：与「标点」的「Query请求」重名
# export Dependent, VTDependent
# export Query, VTQuery

export ACType, ACompoundType, AbstractCompoundType

export ALOperation, ALogicOperation

export IVar, DVar, QVar
export STInheritance, STSimilarity, STImplication, STEquivalence,
      Inheritance,   Similarity,   Implication,   Equivalence
export TemporalStatementTypes
export AStatement, AbstractStatement

export STImplicationRetrospective, STImplicationConcurrent, STImplicationPredictive
export   ImplicationRetrospective,   ImplicationConcurrent,   ImplicationPredictive
export STEquivalenceRetrospective, STEquivalenceConcurrent, STEquivalencePredictive
export   EquivalenceRetrospective,   EquivalenceConcurrent,   EquivalencePredictive
export STImplicationRetrospective, STImplicationConcurrent, STImplicationPredictive
export   ImplicationRetrospective,   ImplicationConcurrent,   ImplicationPredictive
export STEquivalenceRetrospective, STEquivalenceConcurrent, STEquivalencePredictive
export   EquivalenceRetrospective,   EquivalenceConcurrent,   EquivalencePredictive

export CTTermSet, CTTermLogicalSet, CTTermProduct, CTTermImage, CTStatementLogicalSet, CTStatementTemporalSet

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


# 抽象类型 #
const AVType = AVariableType = AbstractVariableType
const VTIndependent = VariableTypeIndependent
const VTDependent = VariableTypeDependent
const VTQuery = VariableTypeQuery # 【20230730 22:54:28】删去非VT别名，因：与「标点」的「Query请求」重名

const ALOperation = ALogicOperation = AbstractLogicOperation

const ACType = ACompoundType = AbstractCompoundType

# 根类型 #
# 省去Abstract前缀
const Term     = ATerm     = AbstractTerm # 省去Abstract前缀

# 原子词项 #
const Atom = AAtom     = AbstractAtom
const Var  = Variable
const Op   = Operator

# 各类型变量
const IVar = Variable{VTIndependent}
const DVar = Variable{VTDependent}
const QVar = Variable{VTQuery}

# 复合词项 #
# 结构
const ACompound = AbstractCompound
const  Compound = CCompound = CommonCompound
# 类型
const CTTermSet              = CompoundTypeTermSet
const CTTermLogicalSet       = CompoundTypeTermLogicalSet
const CTTermProduct          = CompoundTypeTermProduct
const CTTermImage            = CompoundTypeTermImage
const CTStatementLogicalSet  = CompoundTypeStatementLogicalSet
const CTStatementTemporalSet = CompoundTypeStatementTemporalSet

const AStatement = AbstractStatement

# 复合词项：先定义泛型，再定义别名
const TermSet{EI}                     = Compound{CTTermSet{EI}} where EI <: AbstractEI
const TermLogicalSet{EI, LO}          = Compound{CTTermLogicalSet{EI, LO}} where {EI <: AbstractEI, LO <: AbstractLogicOperation}
# const TermImage                     = Compound{CTTermImage} # 默认就是「像」，无需重定向
const TermProduct                     = Compound{CTTermProduct}
const StatementLogicalSet{LO}         = Compound{CTStatementLogicalSet{LO}} where {LO <: AbstractLogicOperation}
const StatementTemporalSet{TR}        = Compound{CTStatementTemporalSet{TR}} where {TR <: AbstractTemporalRelation}

# 上述「泛型」的别名
const TSet     = TermSet
const TLSet    = TermLSet       = TLogicSet    = TermLogicalSet
const TImage   = TermImage
const TProduct = TermProduct
const SLSet    = StatementLSet  = SLogicSet    = StatementLogicalSet
const STSet    = StatementTSet  = STemporalSet = StatementTemporalSet

# 词项集
const Negation    = StatementLSet{Not}
const Conjunction = StatementLSet{And}
const Disjunction = StatementLSet{Or}

const ExtSet = ExtensionSet = Compound{CTTermSet{Extension}}
const IntSet = IntensionSet = Compound{CTTermSet{Intension}}

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

# 陈述 #

# 类型
const STInheritance = StatementTypeInheritance
const STSimilarity  = StatementTypeSimilarity
const STImplication = StatementTypeImplication{Eternal} # 【20230804 14:48:54】⚠此处变成了特值「Eternal」
const STEquivalence = StatementTypeEquivalence{Eternal} # 【20230804 14:48:54】⚠此处变成了特值「Eternal」
# 三个「带时态蕴含」
const STImplicationRetrospective = StatementTypeImplication{Retrospective}
const STImplicationConcurrent    = StatementTypeImplication{Concurrent}
const STImplicationPredictive    = StatementTypeImplication{Predictive}
# 三个「带时态等价」
const STEquivalenceRetrospective = StatementTypeEquivalence{Retrospective}
const STEquivalenceConcurrent    = StatementTypeEquivalence{Concurrent}
const STEquivalencePredictive    = StatementTypeEquivalence{Predictive}

"「有时态系词」：需要有格式`ST{时态<:Tense}`"
const TemporalStatementTypes = Union{
    STImplication, # 所有蕴含
    STEquivalence  # 所有等价
}

# 构造器
const Inheritance = Statement{STInheritance}
const Similarity  = Statement{STSimilarity}
const Implication = Statement{STImplication}
const Equivalence = Statement{STEquivalence}
# 三个「带时态蕴含」 【20230814 23:14:55】不再采用「Past/Present/Future」别名，此举会导致外部引用发生歧义（显示为原本的「参数类型」形式）
const ImplicationRetrospective = Statement{STImplicationRetrospective}
const ImplicationConcurrent    = Statement{STImplicationConcurrent}
const ImplicationPredictive    = Statement{STImplicationPredictive}
# 三个「带时态等价」
const EquivalenceRetrospective = Statement{STEquivalenceRetrospective}
const EquivalenceConcurrent    = Statement{STEquivalenceConcurrent}
const EquivalencePredictive    = Statement{STEquivalencePredictive}

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

# 集合类的词项: 形如`(操作符, 词项...)`与其它「有`terms`字段，且有多个元素的集合」
const TermLogicalSetLike  = Union{TermLSet, StatementLSet{And}, StatementLSet{Or}, StatementTSet} # 「逻辑非」不含在内
const TermCompoundSetLike = Union{TermLogicalSetLike, TermImage, TermProduct, StatementLSet{Not}}
const TermSetLike         = Union{TermSet, TermCompoundSetLike} # 与OpenJunars不同的是，还包括「乘积」与「像」

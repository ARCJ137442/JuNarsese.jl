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
# export Independent, VTIndependent
# export Dependent, VTDependent
# export Query, VTQuery
export ALOperation, ALogicOperation

export IVar, DVar, QVar
export STInheriance, STSimilarity, STImplication, STEquivalance,
         Inheriance,   Similarity,   Implication,   Equivalance
export TemporalStatementTypes
export STImplicationPast, STImplicationPresent, STImplicationFuture
export   ImplicationPast,   ImplicationPresent,   ImplicationFuture
export STEquivalancePast, STEquivalancePresent, STEquivalanceFuture
export   EquivalancePast,   EquivalancePresent,   EquivalanceFuture
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
export TermSetLike, TermOperatedSetLike

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
const TLSet    = TermLSet       = TLogicSet    = TermLogicalSet
const TImage   = TermImage
const TProduct = TermProduct
const ASLSet   = AStatementLSet = ASLogicSet   = AbstractStatementLogicalSet
const SLSet    = StatementLSet  = SLogicSet    = StatementLogicalSet
const STSet    = StatementTSet  = STemporalSet = StatementTemporalSet

# 陈述类型
const STInheriance  = StatementTypeInheriance
const STSimilarity  = StatementTypeSimilarity
const STImplication = StatementTypeImplication{Eternal} # 【20230804 14:48:54】此处变成了特值「Eternal」
const STEquivalance = StatementTypeEquivalance{Eternal} # 【20230804 14:48:54】此处变成了特值「Eternal」
# 三个「带时态蕴含」
const STImplicationPast    = StatementTypeImplication{Past}
const STImplicationPresent = StatementTypeImplication{Present}
const STImplicationFuture  = StatementTypeImplication{Future}
# 三个「带时态等价」
const STEquivalancePast    = StatementTypeEquivalance{Past}
const STEquivalancePresent = StatementTypeEquivalance{Present}
const STEquivalanceFuture  = StatementTypeEquivalance{Future}

# 对接OpenJunars #

# 各类型变量
const IVar = Variable{VTIndependent}
const DVar = Variable{VTDependent}
const QVar = Variable{VTQuery}

# 各类型陈述
const Inheriance  = Statement{STInheriance}
const Similarity  = Statement{STSimilarity}
const Implication = Statement{STImplication}
const Equivalance = Statement{STEquivalance}
"「有时态系词」：需要有格式`ST{时态<:Tense}`"
const TemporalStatementTypes = Union{
    STImplication, # 所有蕴含
    STEquivalance  # 所有等价
}
# 三个「带时态蕴含」
const ImplicationPast    = Statement{STImplicationPast}
const ImplicationPresent = Statement{STImplicationPresent}
const ImplicationFuture  = Statement{STImplicationFuture}
# 三个「带时态等价」
const EquivalancePast    = Statement{STEquivalancePast}
const EquivalancePresent = Statement{STEquivalancePresent}
const EquivalanceFuture  = Statement{STEquivalanceFuture}

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

# 集合类的词项: 形如`(操作符, 词项...)`与其它「有`terms`字段，且有多个元素的集合」
const TermLogicalSetLike  = Union{TermLSet, StatementLSet{And}, StatementLSet{Or}, StatementTSet} # 「逻辑非」不含在内
const TermOperatedSetLike = Union{TermLogicalSetLike, TermImage, TermProduct, StatementLSet{Not}}
const TermSetLike         = Union{TermSet, TermOperatedSetLike} # 与OpenJunars不同的是，还包括「乘积」与「像」

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
export SLSet, StatementLSet, SLogicSet

export AVType, AVariableType
export Independent, VTIndependent
export Dependent, VTDependent
export Query, VTQuery
export ALOperation, ALogicOperation

export IVar, DVar, QVar
export STInheriance, STSimilarity, STImplication, STEquivalance
export Inheriance, Similarity, Implication, Equivalance
export Negation, Conjunction, Disjunction
export ExtSet, ExtensionSet, IntSet, IntensionSet
export ExtImage, ExtensionImage, IntImage, IntensionImage
export ExtIntersection, ExtensionIntersection, IntIntersection, IntensionIntersection
export ExtUnion, ExtensionUnion, IntUnion, IntensionUnion
export ExtDiff, ExtensionDiff, ExtDifference, ExtensionDifference, IntDiff, IntensionDiff, IntDifference, IntensionDifference
export TermSetLike

# 正式开始 #

const AVType = AVariableType = AbstractVariableType
const Independent = VTIndependent = VariableTypeIndependent
const Dependent = VTDependent = VariableTypeDependent
const Query = VTQuery = VariableTypeQuery

const ALOperation = ALogicOperation = AbstractLogicOperation

# 这仨可以省去Abstract前缀
const Term = ATerm = AbstractTerm
const Atom = AAtom = AbstractAtom
const Compound = ACompound = AbstractCompound

const AStatement = AbstractStatement
const ATSet = ATermSet = AbstractTermSet
const ASSet = AStatementSet = AbstractStatementSet

# 省字母
const Var = Variable
const Op = Operator

const TSet = TermSet
const TLSet = TermLSet = TLogicSet = TermLogicalSet
const TImage = TermImage
const TProduct = TermProduct
const SLSet = StatementLSet = SLogicSet = StatementLogicalSet

const STInheriance = StatementTypeInheriance
const STSimilarity = StatementTypeSimilarity
const STImplication = StatementTypeImplication
const STEquivalance = StatementTypeEquivalance

# 对接OpenJunars #

# 各类型变量
const IVar = Variable{Independent}
const DVar = Variable{Dependent}
const QVar = Variable{Query}

# 各类型陈述
const Inheriance = Statement{STInheriance}
const Similarity = Statement{STSimilarity}
const Implication = Statement{STImplication}
const Equivalance = Statement{STEquivalance}

# 陈述逻辑集
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

# 集合类的词项(「逻辑非」不含在内)
const TermSetLike = Union{TermSet, TermLSet, StatementLSet{And}, StatementLSet{Or}}


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

# 各类型变量
const IVar = Variable{Independent}
const DVar = Variable{Dependent}
const QVar = Variable{Query}

# 各类型语句
const Inheriance = Statement{StatementTypeInheriance}
const Similarity = Statement{StatementTypeSimilarity}
const Implication = Statement{StatementTypeImplication}
const Equivalance = Statement{StatementTypeEquivalance}

# 语句逻辑集
const Negation = StatementLogicalSet{Not}
const Conjunction = StatementLogicalSet{And}
const Disjunction = StatementLogicalSet{Or}

const ExtSet = ExtensionSet = TermSet{Extension}
const IntSet = IntensionSet = TermSet{Intension}

const ExtImage = ExtensionImage = TermImage{Extension}
const IntImage = IntensionImage = TermImage{Intension}

# 交集
const ExtIntersection = ExtensionIntersection = TermLogicalSet{Extension, And}
const IntIntersection = IntensionIntersection = TermLogicalSet{Intension, And}

# 并集（一般不使用）
const ExtUnion = ExtensionUnion = TermLogicalSet{Extension, Or}
const IntUnion = IntensionUnion = TermLogicalSet{Intension, Or}

const ExtDiff = ExtensionDiff = ExtDifference = ExtensionDifference = TermLogicalSet{Extension, Not}
const IntDiff = IntensionDiff = IntDifference = IntensionDifference = TermLogicalSet{Intension, Not}

# 集合类的词项(「逻辑非」不含在内)
const TermSetLike = Union{TermSet, TermLogicalSet, StatementLogicalSet{And}, StatementLogicalSet{Or}}


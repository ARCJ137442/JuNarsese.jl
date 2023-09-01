
# 导出 #

export AbstractVariableType, VariableTypeIndependent, VariableTypeDependent, VariableTypeQuery
export AbstractLogicOperation, And, Or, Not
export AbstractEI, Extension, Intension
export AbstractTemporalRelation, Sequential, Parallel
export AbstractTense, TenseEternal, TensePast, TensePresent, TenseFuture # 【20230901 9:11:54】合并自tense.jl

export AbstractStatementType, StatementTypeInheritance, StatementTypeSimilarity, StatementTypeImplication, StatementTypeEquivalence
export AbstractCompoundType, CompoundTypeTermSet, CompoundTypeTermLogicalSet, CompoundTypeTermProduct, CompoundTypeTermImage, CompoundTypeStatementLogicalSet, CompoundTypeStatementTemporalSet


# 作为「类型参数」的抽象类型 #

"[NAL-2]区分「外延」与「内涵」"
abstract type AbstractEI end # NAL-2
abstract type Extension <: AbstractEI end
abstract type Intension <: AbstractEI end

"[NAL-3|NAL-5]集合论/一阶逻辑操作：与或非" # 原创
abstract type AbstractLogicOperation end
abstract type And <: AbstractLogicOperation end # 词项→交，陈述→与
abstract type Or  <: AbstractLogicOperation end # 词项→并，陈述→或
abstract type Not <: AbstractLogicOperation end # 词项→非，陈述→非

"[NAL-6]变量类型" # 【20230724 11:38:25】💭不知道OpenJunars中为何要让「AbstractVariableType」继承AbstractTerm
abstract type AbstractVariableType end # NAL-6
abstract type VariableTypeIndependent <: AbstractVariableType end # 独立变量 & 对于
abstract type VariableTypeDependent   <: AbstractVariableType end # 非独变量 # 存在
abstract type VariableTypeQuery       <: AbstractVariableType end # 查询变量 ? 疑问

"[NAL-7]时序合取：区分「序列」与「平行」"
abstract type AbstractTemporalRelation end
abstract type Sequential <: AbstractTemporalRelation end
abstract type Parallel   <: AbstractTemporalRelation end

"[NAL-7]时态：永恒、过去、现在、未来"
abstract type AbstractTense end
abstract type TenseEternal <: AbstractTense end
abstract type TensePast    <: AbstractTense end
abstract type TensePresent <: AbstractTense end
abstract type TenseFuture  <: AbstractTense end

# 陈述类型

"[NAL-1|NAL-2|NAL-5]陈述类型：继承&相似、蕴含&等价"
abstract type AbstractStatementType end
abstract type StatementTypeInheritance                     <: AbstractStatementType end # NAL-1
abstract type StatementTypeSimilarity                      <: AbstractStatementType end # NAL-2
abstract type StatementTypeImplication{T <: AbstractTense} <: AbstractStatementType end # NAL-5|NAL-7
abstract type StatementTypeEquivalence{T <: AbstractTense} <: AbstractStatementType end # NAL-5|NAL-7

# 复合词项类型

"[NAL-2|NAL-4|NAL-5|NAL-7]复合词项类型：词项集、词项逻辑集、乘积、像、陈述逻辑集、陈述时序集"
abstract type AbstractCompoundType end
abstract type CompoundTypeTermSet{EI <: AbstractEI}                                                      <: AbstractCompoundType end # [NAL-2]词项集
abstract type CompoundTypeTermLogicalSet{EIType <: AbstractEI, LogicOperation <: AbstractLogicOperation} <: AbstractCompoundType end # [NAL-2]词项の复合：集合操作⇒复合集
abstract type CompoundTypeTermProduct                                                                    <: AbstractCompoundType end # [NAL-4]乘积
abstract type CompoundTypeTermImage{EIType <: AbstractEI}                                                <: AbstractCompoundType end # [NAL-4]像
abstract type CompoundTypeStatementLogicalSet{LogicOperation <: AbstractLogicOperation}                  <: AbstractCompoundType end # [NAL-5]陈述逻辑集: {与/或/非}
abstract type CompoundTypeStatementTemporalSet{TemporalRelation <: AbstractTemporalRelation}             <: CompoundTypeStatementLogicalSet{And} end # [NAL-7]陈述时序集 <: 陈述逻辑集{与}

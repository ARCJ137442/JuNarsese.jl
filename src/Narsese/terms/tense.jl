#=
有关「时态」的结构
- 永恒 ETERNAL
- 过去 PAST
- 现在 PRESENT
- 未来 FUTURE

使用「抽象类型参数@Stamp」实现枚举
=#

export AbstractTense, Tense
export TenseEternal, TensePast, TensePresent, TenseFuture
export Eternal, Past, Present, Future


"抽象时态"
abstract type AbstractTense end
const Tense::DataType = AbstractTense # 别名

"时态：永恒、过去、现在、未来"
abstract type TenseEternal <: AbstractTense end
abstract type TensePast    <: AbstractTense end
abstract type TensePresent <: AbstractTense end
abstract type TenseFuture  <: AbstractTense end

"别名"
const Eternal::DataType = TenseEternal
const Past   ::DataType = TensePast
const Present::DataType = TensePresent
const Future ::DataType = TenseFuture

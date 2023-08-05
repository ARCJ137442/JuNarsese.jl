#=
定义Narsese语句的「标点」，反映语句的类型
- 判断 Judgement
- 问题 Question
- 目标 Goal
- 请求 Query
=#

export AbstractPunctuation, Punctuation
export PunctuationJudgement, PunctuationQuestion, PunctuationGoal, PunctuationQuery
export Judgement, Question, Goal, Query

abstract type AbstractPunctuation end
const Punctuation = AbstractPunctuation # 别名

abstract type PunctuationJudgement <: AbstractPunctuation end # 判断
abstract type PunctuationQuestion  <: AbstractPunctuation end # 问题
abstract type PunctuationGoal      <: AbstractPunctuation end # 目标
abstract type PunctuationQuery     <: AbstractPunctuation end # 请求

# 别名(附带「P」前缀可免重名)
const Judgement = PunctuationJudgement
const Question  = PunctuationQuestion
const Goal      = PunctuationGoal
const Query     = PunctuationQuery

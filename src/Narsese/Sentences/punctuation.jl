#=
定义Narsese语句的「标点」，反映语句的类型
- 判断 Judgement
- 问题 Question
- 目标 Goal
- 请求 Quest
=#

export AbstractPunctuation, Punctuation, TPunctuation
export PunctuationJudgement, PunctuationQuestion, PunctuationGoal, PunctuationQuest
export Judgement, Question, Goal, Quest

abstract type AbstractPunctuation end
const Punctuation = AbstractPunctuation # 别名
const TPunctuation = Type{<:AbstractPunctuation} # 类型简记

abstract type PunctuationJudgement <: AbstractPunctuation end # 判断
abstract type PunctuationQuestion  <: AbstractPunctuation end # 问题
abstract type PunctuationGoal      <: AbstractPunctuation end # 目标
abstract type PunctuationQuest     <: AbstractPunctuation end # 请求

# 别名(附带「P」前缀可免重名)
const Judgement = PunctuationJudgement
const Question  = PunctuationQuestion
const Goal      = PunctuationGoal
const Quest     = PunctuationQuest

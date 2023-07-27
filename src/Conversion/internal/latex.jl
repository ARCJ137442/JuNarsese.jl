#=
提供latex字串处理
=#

abstract type LatexParser <: AbstractParser end

"Latex字符串"
Base.eltype(::Type{LatexParser}) = String

# TODO: String处完善

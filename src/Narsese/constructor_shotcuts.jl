#=
使用Unicode运算符/宏，辅助构建Narsese
=#

export @w_str

begin "单体词项"
    
    FLAG_TYPE_DICT::Dict{String, DataType} = Dict(
        "i" => Variable{VTIndependent},
        "d" => Variable{VTDependent},
        "q" => Variable{VTQuery},
        "o" => Operator,
    )

    """
    字符串宏，用于构建原子词项（词/变量）
    - 📌Julia直接返回字面量，也是可以的
    """
    macro w_str(name::String)
        return name |> Symbol |> Word
    end

    "可用后缀指定是否为变量(词语/变量/操作)"
    macro w_str(name::String, flag::String)
        if flag in keys(FLAG_TYPE_DICT)
            return name |> Symbol |> FLAG_TYPE_DICT[flag]
        else
            return name |> Symbol |> Word
        end
    end

    "外延集" # A & B & C (&, A, B, C)
    Base.:(&)(t1::Term, t2::Term) = TermSet{Extension}(t1,t2)
    Base.:(&)(t1::TermSet{Extension}, t2::Term) = TermSet{Extension}(t1.terms...,t2)
    Base.:(&)(t1::Term, t2::TermSet{Extension}) = t2 & t1 # 交换律
    Base.:(&)(t1::TermSet{Extension}, t2::TermSet{Extension}) = TermSet{Extension}(t1.terms...,t2.terms...)

    "内涵集" # A | B | C -> (|, A, B, C)
    Base.:(|)(t1::Term, t2::Term) = TermSet{Intension}(t1,t2)
    Base.:(|)(t1::TermSet{Intension}, t2::Term) = TermSet{Intension}(t1.terms...,t2)
    Base.:(|)(t1::Term, t2::TermSet{Intension}) = t2 | t1 # 交换律
    Base.:(|)(t1::TermSet{Intension}, t2::TermSet{Intension}) = TermSet{Intension}(t1.terms...,t2.terms...)

    "外延交=内涵并" # 注意：Julia保留了「&&」运算符，也无法使用「∩& ∩|」
    Base.:(∩)(t1::Term, t2::Term) = TermLogicalSet{Extension, And}(t1,t2) # 默认是外延交(后续就直接递推)
    Base.:(∩)(t1::TermLogicalSet{EI, And}, t2::Term) where EI <: AbstractEI = TermLogicalSet{EI, And}(t1.terms...,t2)
    Base.:(∩)(t1::Term, t2::TermLogicalSet{EI, And}) where EI <: AbstractEI = t2 ∩ t1 # 交换律
    Base.:(∩)(t1::TermLogicalSet{EI, And}, t2::TermLogicalSet{EI, And}) where EI <: AbstractEI = TermLogicalSet{EI, And}(t1.terms...,t2.terms...)

    "内涵交=外延并"
    Base.:(∪)(t1::Term, t2::Term) = TermLogicalSet{Intension, And}(t1,t2) # 默认是外延交(后续就直接递推)
    Base.:(∪)(t1::TermLogicalSet{EI, And}, t2::Term) where EI <: AbstractEI = TermLogicalSet{EI, And}(t1.terms...,t2)
    Base.:(∪)(t1::Term, t2::TermLogicalSet{EI, And}) where EI <: AbstractEI = t2 ∪ t1 # 交换律
    Base.:(∪)(t1::TermLogicalSet{EI, And}, t2::TermLogicalSet{EI, And}) where EI <: AbstractEI = TermLogicalSet{EI, And}(t1.terms...,t2.terms...)

end

begin "复合词项"
    
end
(@isdefined JuNarsese) || include("commons.jl") # 已在此中导入JuNarsese、Test

A,B,C,D,E = "A B C D E" |> split .|> String .|> Symbol .|> Word
@assert (∨(⩜(A→B, B→C, C→D), ⩚(A→B, B→C, C→D))) == (∨(⩜(A→B, B→C, C→D), ⩚(A→B, B→C, C→D)))

@testset "Narsese" begin

    # 构造 #
    include("test_construction.jl")

    # 词项与数组等可迭代对象的联动方法 #
    include("test_methods.jl")

end

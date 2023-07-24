push!(LOAD_PATH, "../src") # 用于直接打开（..上一级目录）
push!(LOAD_PATH, "src") # 用于VSCode调试（项目根目录起）

using JuNarsese

using Test


@testset "Narsese" begin

    w,d,o = w"词项", w"非独立变量"d, w"操作"o

    @show "$w, $d, $o"

    @test "$w" == "词项"
    @test "$d" == "#非独立变量"
    @test "$o" == "^操作"

    @test w"词项" == Word(:词项)

    # 外延 内涵 集
    exSet = w & (d & o)
    inSet = d | w | o
    @show exSet inSet "$exSet and $inSet"

    @test exSet == ExtSet(w,d,o)

    # 像&乘积
    A,B,C = "A B C" |> split .|> String .|> Symbol .|> Word
    @show A ∩ B == ExtIntersection(A,B)
    @show A / B ⋄ C  A \ C ⋄ A \ B
    @test A \ C ⋄ A \ B == IntImage(3, A, C, A, B)
    @show A*B*C
    @test A*B*C == TermProduct(A, B, C)
end

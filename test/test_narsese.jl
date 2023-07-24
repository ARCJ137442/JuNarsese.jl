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

    # 外延 内涵 集
    exSet = w & (d & o)
    inSet = d | w | o
    @show exSet "$exSet and $inSet"
end

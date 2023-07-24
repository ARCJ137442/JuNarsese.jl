push!(LOAD_PATH, "../src") # 用于直接打开（..上一级目录）
push!(LOAD_PATH, "src") # 用于VSCode调试（项目根目录起）

using JuNarsese

using Test

@testset "Conversion" begin
    @show [w"词项", w"问题"q, w"操作"o] .|> string
    
    A,B,C = "A B C" |> split .|> String .|> Symbol .|> Word

    @test Term2Data{String}(A / B ⋄ C) == "(/, A, B, _, C)"
    @test A*B*C == TermProduct([A,B,C])

    # 语句
    @show s0 = A*B*C ⇔ w"op"o
    @test string(s0) == "<(*, A, B, C) <=> ^op>"
    @show s1 = (A → B) ∧ (B → C) ⇒ (A → C) # A是B且B是C
    @test string(s1) == "<(&&, <A --> B>, <B --> C>) ==> <A --> C>>"
    @show s2 = (A → B) ∨ (C → B) ⇒ ((A | C) → B) # A是B或C是B
    @test string(s2) == "<(||, <A --> B>, <C --> B>) ==> <[A, C] --> B>>"
end

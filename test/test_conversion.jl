push!(LOAD_PATH, "../src") # 用于直接打开（..上一级目录）
push!(LOAD_PATH, "src") # 用于VSCode调试（项目根目录起）

using JuNarsese

using Test

@testset "Conversion" begin
    @show [w"词项", w"问题"q, w"操作"o] .|> string 
    
end

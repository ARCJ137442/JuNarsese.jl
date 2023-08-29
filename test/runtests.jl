push!(LOAD_PATH, "../src") # 用于直接打开（..上一级目录）
push!(LOAD_PATH, "src") # 用于VSCode调试（项目根目录起）

include("commons.jl") # 已在此中导入JuNarsese

@testset "JuNarsese" begin
    include("test_readme.jl")
    include("test_util.jl")
    include("test_narsese.jl")
    include("test_conversion.jl")
end

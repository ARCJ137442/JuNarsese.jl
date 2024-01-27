(@isdefined JuNarsese) || include("test_commons.jl") # 已在此中导入JuNarsese、Test

@testset "Narsese/methods" begin

    # 解析器
    include("conversion/test_parsers.jl")
    # API #
    include("conversion/test_api.jl")

end

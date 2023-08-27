(@isdefined JuNarsese) || include("commons.jl") # 已在此中导入JuNarsese、Test

@testset "Narsese" begin
    
    # 配置类参数 #

    # 默认精度数值解析
    @test Narsese.parse_default_float("12.2") isa Narsese.DEFAULT_FLOAT_PRECISION
    @test Narsese.parse_default_float("12") == 12.0
    
    @test Narsese.parse_default_int("42") isa Narsese.DEFAULT_INT_PRECISION
    @test Narsese.parse_default_int("-1") == -1
    
    @test Narsese.parse_default_uint("42") isa Narsese.DEFAULT_UINT_PRECISION
    @test Narsese.parse_default_uint("0x1") == 0x0000000000000001

    # 构造 #
    include("test_construction.jl")

    # 类型 #
    include("test_types.jl")

    # 词项与数组等可迭代对象的联动方法 #
    include("test_methods.jl")

end

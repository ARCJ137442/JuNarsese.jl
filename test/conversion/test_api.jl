(@isdefined JuNarsese) || include("../test_commons.jl") # 已在此中导入JuNarsese、Test

@testset "Conversion/API" begin

    import JuNarsese.Conversion: get_parser_from_flag

    # 自定义解析器 #
    struct NParser <: AbstractParser end

    np = NParser()

    # 测试：未实现的抽象方法
    @test @expectedError eltype(np)
    @test @expectedError parse_target_types(np)
    @test @expectedError get_parser_from_flag(Val(:np))

    # 尝试实现

    @register_parser_string_flag [
        :n => np
        :np => np
    ]
    @test get_parser_from_flag(Val(:n)) == np
    @test get_parser_from_flag(Val(:np)) == np

    # 外接API代码 #
    @test pack_type_string(ExtSet) == "ExtSet"
    @test pack_type_string(ExtSet(A,B,C)) == "ExtSet"
    @test pack_type_symbol(IVar) == :IVar
    @test pack_type_symbol(i"独立变量") == :IVar

end

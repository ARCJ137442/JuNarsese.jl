(@isdefined JuNarsese) || include("commons.jl") # 已在此中导入JuNarsese、Test

begin "报错debug专用"
    # 测试@原生对象
    # @equal_test NativeParser_dict test_set
    # @equal_test NativeParser_vector test_set
end
@testset "Conversion" begin

    @testset "StringParser" begin
        # 测试@字符串
        @equal_test StringParser_ascii test_set
        
        # 测试@LaTeX
        @equal_test StringParser_latex test_set
        
        # 测试@漢
        @equal_test StringParser_han test_set

    end

    # @testset "ShortcutParser" begin # 这玩意儿只有解析器没有打包器
    #     @test s3 == (( q"A" * i"B" ) → o"C")
    # end

    @testset "ASTParser" begin
        @equal_test ASTParser test_set
    end

    @testset "NativeParser" begin
        @equal_test NativeParser_dict test_set
        @equal_test NativeParser_vector test_set
    end
end

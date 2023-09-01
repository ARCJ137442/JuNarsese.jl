(@isdefined JuNarsese) || include("../commons.jl") # 已在此中导入JuNarsese、Test

begin "报错debug专用"
    # 测试@原生对象
    # @equal_test NativeParser_dict test_set
    # @equal_test NativeParser_vector test_set
end
@testset "Conversion/Parsers" begin

    @testset "StringParser" begin

        @test (
            parse_target_types(StringParser_ascii) == 
            parse_target_types(StringParser_latex) == 
            parse_target_types(StringParser_han) == 
            Conversion.STRING_PARSE_TARGETS
        )

        # 测试@字符串
        @equal_test StringParser_ascii test_set
        
        # 测试@LaTeX
        @equal_test StringParser_latex test_set
        
        # 测试@漢
        @equal_test StringParser_han test_set

    end

    @testset "ShortcutParser" begin

        @test (
            parse_target_types(ShortcutParser) == 
            Conversion.SHORTCUT_PARSE_TARGETS
        )
        
        @test (
            ShortcutParser(""" ( w"A" * w"B" ) → o"op" """) ==
            ((A*B)→Operator(:op)) == 
            (( nse"A" * w"B" ) → o"op")
        )

        # 暂时只有解析器没有打包器
        @test @expectedError ShortcutParser("!一段注定失败的解析过程!#!")
    end

    @testset "ASTParser" begin

        @test (
            parse_target_types(ASTParser) == 
            Conversion.AST_PARSE_TARGETS
        )
        
        @equal_test ASTParser test_set
    end

    @testset "NativeParser" begin

        @test (
            parse_target_types(NativeParser_dict) == 
            parse_target_types(NativeParser_vector) == 
            Conversion.NATIVE_PARSE_TARGETS
        )
        
        @equal_test NativeParser_dict test_set
        @equal_test NativeParser_vector test_set
    end
end

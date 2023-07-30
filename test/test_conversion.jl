push!(LOAD_PATH, "../src") # 用于直接打开（..上一级目录）
push!(LOAD_PATH, "src") # 用于VSCode调试（项目根目录起）

using JuNarsese

using Test

@testset "Conversion" begin

    # 快捷构造 #

    w,i,d,q,o = w"词项", w"独立变量"i, w"非独变量"d, w"查询变量"q, w"操作"o
    A,B,C,D,R = "A B C D R" |> split .|> String .|> Symbol .|> Word
    @show s1 = (/(R, A, B, ⋄, D) → C) ⇒ (*(A, B, C, D) → R)
    @show s2 = (|(A, B, C) → D) ⇒ ∨((A → D), (B → D), (C → D))
    @show s3 = ShortcutParser.(
        """( w"A"q * w"B"i ) → w"C"o """
    )

    "测试集"
    test_set = [w, i, d, q, o, s1, s2, s3]

    @testset "StringParser" begin
        # 原子词项
    
        @show "$w, $d, $o"
    
        @test "$w" == "词项"
        @test "$i" == "\$独立变量"
        @test "$d" == "#非独变量"
        @test "$q" == "?查询变量"
        @test "$o" == "^操作"
    
        @test /(A, B, ⋄, C) |> StringParser_ascii == "(/, A, B, _, C)"

        @show StringParser_ascii.(test_set)
        StringParser_latex.(test_set) .|> println

        # 测试集
        # @test test_set .|> StringParser_ascii .|> StringParser_ascii == test_set
        # @test test_set .|> StringParser_latex .|> StringParser_latex == test_set
    
        # 陈述 #
    
        # 陈述↔字符串
        @show s0 = *(A,B,C) ⇔ w"op"o
        @test string(s0) == "<(*, A, B, C) <=> ^op>"
        # @test (
        #     string(s1) == "<(&&, <A --> B>, <B --> C>) ==> <A --> C>>" ||
        #     string(s1) == "<(&&, <B --> C>, <A --> B>) ==> <A --> C>>"
        # )
        # @test (
        #     string(s2) == "<(||, <A --> B>, <C --> B>) ==> <[A, C] --> B>>" ||
        #     string(s2) == "<(||, <C --> B>, <A --> B>) ==> <[A, C] --> B>>" ||
        #     string(s2) == "<(||, <A --> B>, <C --> B>) ==> <[C, A] --> B>>" ||
        #     string(s2) == "<(||, <C --> B>, <A --> B>) ==> <[C, A] --> B>>"
        # )
    
    end

    @testset "ShortcutParser" begin
        @test string(s3) == "<(*, ?A, \$B) --> ^C>"
        @test s3 == (( w"A"q * w"B"i ) → w"C"o)
    end

    @testset "ASTParser" begin
        s = ASTParser.(test_set)
        s .|> dump
        @show ASTParser.(s)
        @test ASTParser.(s) == test_set
    end

    @testset "S11nParser" begin
        s = S11nParser.(test_set)
        str = s .|> copy .|> String # 不知为何，转换多次字符串就空了
        @show join(str, "\n\n")
        # @test str .|> !isempty |> all # 所有转换过来都非空
        # 📌【20230730 11:52:26】避免「EOFError: read end of file」：使用数据前先copy
        @test S11nParser.(s .|> copy) == test_set # 确保无损转换
    end

    @testset "JSONParser" begin
        s = JSONParser{Dict}.(test_set)
        s .|> println
        @test JSONParser{Dict}.(s) == test_set # 确保无损转换
        
        s = JSONParser{Vector}.(test_set)
        s .|> println
        @test JSONParser{Vector}.(s) == test_set # 确保无损转换
    end

    @testset "XMLParser" begin
        s = XMLParser.(test_set)
        s .|> println
        @test XMLParser.(s) == test_set # 确保无损转换
    end
end

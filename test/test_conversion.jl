push!(LOAD_PATH, "../src") # 用于直接打开（..上一级目录）
push!(LOAD_PATH, "src") # 用于VSCode调试（项目根目录起）

using JuNarsese

using Test

@testset "Conversion" begin

    # 快捷构造 #

    w,i,d,q,o = w"词项", w"独立变量"i, w"非独变量"d, w"查询变量"q, w"操作"o
    A,B,C = "A B C" |> split .|> String .|> Symbol .|> Word
    @show s1 = (A → B) ∧ (B → C) ⇒ (A → C)
    @show s2 = (A → B) ∨ (C → B) ⇒ ((A | C) → B)
    @show s3 = Data2Term{ShortcutParser}(
        """( w"A"q * w"B"i ) → w"C"o """
    )

    @testset "StringParser" begin
        # 原子词项
    
        @show "$w, $d, $o"
    
        @test "$w" == "词项"
        @test "$i" == "\$独立变量"
        @test "$d" == "#非独变量"
        @test "$q" == "?查询变量"
        @test "$o" == "^操作"
    
        @test Data2Term{StringParser, Word    }(string(w)) == w
        @test Data2Term{StringParser, Variable}(string(i)) == i
        @test Data2Term{StringParser, Variable}(string(d)) == d
        @test Data2Term{StringParser, Variable}(string(q)) == q
        @test Data2Term{StringParser, Operator}(string(o)) == o
    
        @test Term2Data{StringParser}(A / B ⋄ C) == "(/, A, B, _, C)"
    
        # 语句 #
    
        # 语句↔字符串
        @show s0 = A*B*C ⇔ w"op"o
        @test string(s0) == "<(*, A, B, C) <=> ^op>"
        @test (
            string(s1) == "<(&&, <A --> B>, <B --> C>) ==> <A --> C>>" ||
            string(s1) == "<(&&, <B --> C>, <A --> B>) ==> <A --> C>>"
        )
        @test (
            string(s2) == "<(||, <A --> B>, <C --> B>) ==> <[A, C] --> B>>" ||
            string(s2) == "<(||, <C --> B>, <A --> B>) ==> <[A, C] --> B>>" ||
            string(s2) == "<(||, <A --> B>, <C --> B>) ==> <[C, A] --> B>>" ||
            string(s2) == "<(||, <C --> B>, <A --> B>) ==> <[C, A] --> B>>"
        )
    
    end

    @testset "ShortcutParser" begin
        @test string(s3) == "<(*, ?A, \$B) --> ^C>"
        @test s3 == (( w"A"q * w"B"i ) → w"C"o)
    end

    @testset "ASTParser" begin
        s = [w, i, d, q, o, s1, s2, s3] .|> Term2Data{ASTParser}
        s .|> dump
        @show s .|> Data2Term{ASTParser}
        @test s .|> Data2Term{ASTParser} == [w, i, d, q, o, s1, s2, s3]
    end

    @testset "S11nParser" begin
        s = [w, i, d, q, o, s1, s2, s3] .|> Term2Data{S11nParser}
        @show join(s .|> String, "\n\n")
        # @show s .|> Data2Term{S11nParser} # EOFError: read end of file
    end
end

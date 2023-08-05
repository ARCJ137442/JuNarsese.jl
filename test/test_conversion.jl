push!(LOAD_PATH, "../src") # 用于直接打开（..上一级目录）
push!(LOAD_PATH, "src") # 用于VSCode调试（项目根目录起）

using JuNarsese

using Test

# 快捷构造 #

# 原子词项
w,i,d,q,o = w"词项", w"独立变量"i, w"非独变量"d, w"查询变量"q, w"操作"o
A,B,C,D,R = "A B C D R" |> split .|> String .|> Symbol .|> Word
# 像、陈述、乘积
@show s1 = (/(R, A, B, ⋄, D) → C) ⇒ (*(A, B, C, D) → R)
# 词项集、陈述逻辑集
@show s2 = (|(A, B, C) → D) ⇒ ∨((A → D), (B → D), (C → D))
# 快捷方式解析
@show s3 = ShortcutParser.(
    """( w"A"q * w"B"i ) → w"C"o """
)
# 词项集&词项逻辑集
@show s4 = Base.:(&)(w, i, d, q, o) - Base.:(|)(w, i, d, q, o)
@show s5 = ∩(A, B, C) - ∪(A, B, C)
# 时序合取
@show s6 = ∨(⩜(A→B, B→C, C→D), ⩚(A→B, B→C, C→D)) ⇒ (A→D)
# 副系词|时序蕴含/等价
s7 = ParConjunction(StringParser_ascii.([
    "<A {-- B>"
    "<A --] B>"
    "<A {-] B>"
    
    raw"<A =/> B>"
    raw"<A =|> B>"
    raw"<A =\> B>"
    
    raw"<A </> B>"
    raw"<A <|> B>"
    raw"<A <\> B>"
])...)
@show s7
# 极端嵌套情况
s8 = *(
    ⩚(
        ⩜(A→B, B→C, C→D), 
        ∨(ExtSet(A, B, C)→D, w→o), ⩚(A→B, B→C, C→D)
    ), 
    ∧(s1, s2), 
    \(A, ⋄, s3, s5) → s2,
    /(s1, ⋄, B, s4) → s3,
    ¬(Base.:(&)(w, i, d, q, o) → IntSet(s6, ∩(A, B, C)))
) → (s6 ⇒ s7)
@show s8

# 测试语句
f_s = s -> StringParser_ascii[s]
test_set = f_s.([
    "<A-->B>. :|: %1.00;0.90% "
    "<SELF {-] good>! :|: "
    "<<(*, A, B) --> (*, C, D)> ==> (&&, <A --> C>, <B --> D>)>@ %1.00;0.90%"
    "<(*, A, B, C, D) --> R>? "
])
tss = f_s.(f_s.(test_set))
@info "sentences: " tss
# ASTParser.(ASTParser.(ASTParser.(test_set, Sentence), Sentence), Sentence)
XMLParser.(XMLParser.(XMLParser.(test_set, Sentence), Sentence), Sentence)
@info "sentences@AST: " ASTParser.(ASTParser.(ASTParser.(test_set, Sentence), Sentence), Sentence)
@info "sentences@XML: " XMLParser.(XMLParser.(XMLParser.(test_set, Sentence), Sentence), Sentence)
@info "sentences@JSON: " JSONParser{Dict}.(JSONParser{Dict}.(JSONParser{Dict}.(test_set, Sentence), Sentence), Sentence)
# # TODO: 1语句相等方法
# for (t1, t2) in zip(tss, test_set)
#     if t1 ≠ t2
#         # dump.(ASTParser.([t1, t2]); maxdepth=typemax(Int))
#         @info t1==t2 t1 t2
#     end
#     @assert t1 == t2 "Not eq!\n$t1\n$t2"
# end
# @show test_set

"标准测试集"
test_set = [w, i, d, q, o, s1, s2, s3, s4, s5, s6, s7, s8]
# test_set = [s7]

@testset "Conversion" begin

    @testset "StringParser" begin
        # 原子词项
    
        @test "$w" == "词项"
        @test "$i" == "\$独立变量"
        @test "$d" == "#非独变量"
        @test "$q" == "?查询变量"
        @test "$o" == "^操作"
    
        # 像
        @test /(A, B, ⋄, C) |> StringParser_ascii == "(/, A, B, _, C)"
        @test \(A, w, ⋄, q) |> StringParser_ascii == "(\\, A, 词项, _, ?查询变量)"
        @test \(/(A, B, ⋄, C), w, ⋄, q) |> StringParser_ascii == "(\\, (/, A, B, _, C), 词项, _, ?查询变量)"
        
        # 测试@字符串
        tss = StringParser_ascii.(StringParser_ascii.(test_set))
        @show tss
        for (t1, t2) in zip(tss, test_set)
            if t1 ≠ t2
                dump.(ASTParser.([t1, t2]); maxdepth=typemax(Int))
                @info t1==t2 t1 t2
            end
            @assert t1 == t2 "Not eq!\n$t1\n$t2"
        end
        
        # 测试@LaTeX
        tss = StringParser_LaTeX.(StringParser_LaTeX.(test_set))
        @show tss
        for (t1, t2) in zip(tss, test_set)
            if t1 ≠ t2
                dump.(ASTParser.([t1, t2]); maxdepth=typemax(Int))
                @info t1==t2 t1 t2
            end
            @assert t1 == t2 "Not eq!\n$t1\n$t2"
        end

        # 测试集试运行
        # @show StringParser_ascii.(test_set)
        # StringParser_LaTeX.(test_set) .|> println

        # 测试集

        @test test_set .|> StringParser_ascii .|> StringParser_ascii == test_set
        @test test_set .|> StringParser_LaTeX .|> StringParser_LaTeX == test_set

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

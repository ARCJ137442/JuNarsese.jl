include("commons.jl") # 已在此中导入JuNarsese、Test

A,B,C,D = "A B C D" |> split .|> String .|> Symbol .|> Word
@assert (∨(⩜(A→B, B→C, C→D), ⩚(A→B, B→C, C→D))) == (∨(⩜(A→B, B→C, C→D), ⩚(A→B, B→C, C→D)))

@testset "Narsese" begin

    @info "各个词项的复杂度："
    [println(get_syntactic_complexity(t), " of $t") for t in test_set.terms]

    # 原子词项

    @show w i d q o

    @test w == Word(:词项)
    @test i == IVar(:独立变量)
    @test d == DVar(:非独变量)
    @test q == QVar(:查询变量)
    @test o == Operator(:操作)

    # 词项集
    exSet = Base.:(&)(w, d, o)
    inSet = Base.:(|)(d, q, i) # 【20230730 23:34:29】TODO: 必须改掉这样的语法
    @show exSet inSet "$exSet and $inSet"

    @test exSet == ExtSet(w,o,d) # 无序
    @test inSet == IntSet(i,d,q) # 无序

    # 词项逻辑集
    extI = ExtIntersection(A, i)
    intI = IntIntersection(d, i, A, o)
    extD = ExtDifference(C, q)
    intD = IntDifference(d, B)
    @show extI intI
    println("外延交$(extI)与内涵交$(intI)\n外延差$(extD)与内涵差$intD")

    @test extI == ExtIntersection(i, A) # 无序
    @test intI == IntIntersection(A, i, o, d) # 无序
    @test extD == ExtDifference(C, q) ≠ ExtDifference(q, C) # 有序
    @test intD == IntDifference(d, B) ≠ IntDifference(B, d) # 有序

    # 像

    eI = ExtImage(2, A,B,C) # (/, A, _, B, C)
    iI = IntImage(3, C,B,A) # (\, C, B, _, A)
    @show eI iI

    @test eI == ExtImage(2, A,B,C) # 非唯一性
    @test iI == IntImage(3, C,B,A) # 非唯一性
    @test eI.relation_index == 2 && iI.relation_index == 3
    @test ExtImage(1, A,B,C) ≠ /(A, ⋄, B, C) == eI == ExtImage(2, A,B,C) ≠ ExtImage(2, A,C,B) # 唯一相等性
    @test IntImage(1, C,B,A) ≠ \(C, B, ⋄, A) == iI == IntImage(3, C,B,A) ≠ IntImage(3, C,A,B) # 唯一相等性

    # 乘积

    @show p = TermProduct(A,B,C)
    @test p == *(A, B, C) == (A*B*C) ≠ (B*A*C) # 有序性 老式构造方法仍可使用

    # 陈述

    # 陈述逻辑集
    @show s1 = ((A→B) ∧ ((A→B)⇒(B→C))) ⇒ (B→C)
    @test s1 == (((A→B) ∧ ((A→B)⇒(B→C))) ⇒ (B→C)) # 非唯一性
    @test ((A→B) ∨ ((A→B)∧(B→C))) == ((A→B) ∨ ((A→B)∧(B→C))) # 非唯一性: 嵌套集合的刁钻
    @test s1 == Implication( # 等价性
        Conjunction(
            Inheriance(A,B),
            Implication(
                Inheriance(A,B),
                Inheriance(B,C)
            )
        ),
        Inheriance(B,C)
    ) == ((((A→B)⇒(B→C)) ∧ (A→B)) ⇒ (B→C)) # 无序性
    @test get_syntactic_complexity(s1) == 1+(
        1+(
            1+(1+1) + 1+(
                1+(1+1) + 1+(1+1)
            )
        ) + 1+(1+1)
    ) # 复杂度
    @test get_syntactic_simplicity(s1, 0.5) ≈ 1/sqrt(15) # 方根简单度
    @test get_syntactic_simplicity(s1, 1) ≈ 1//15 # 方根简单度

    @show s2 = (
        ((i"甲"→w"人")⇒(i"甲"→w"会死")) ∧
        (w"苏格拉底"→w"人")
    ) ⇒ (w"苏格拉底"→w"会死")
    @test s2 == Implication(
        Conjunction(
            Inheriance(w"苏格拉底", w"人"),
            Implication(
                Inheriance(i"甲", w"人"),
                Inheriance(i"甲", w"会死")
            )
        ),
        Inheriance(w"苏格拉底", w"会死")
    )
    @test get_syntactic_complexity(s2) == 1+(
        1+(
            1+(1+(0+1) + 1+(0+1)) + 1+(
                1+1
            )
        ) + 1+(1+1)
    ) # 复杂度

    # 陈述时序集
    @show s3 = ⩚(s1, s2) s4 = ⩜(s1, s2)
    @test s3 == ParConjunction(s1, s2) == ⩚(s2, s1) # 无序性
    @test s4 == SeqConjunction(s1, s2) ≠  ⩜(s2, s1) # 有序性
    @test get_syntactic_complexity(s3) == 1 + (
        get_syntactic_complexity(s1) + 
        get_syntactic_complexity(s2)
    ) == get_syntactic_complexity(s4) # 复杂度，只由组分决定
    @show s5 = ∨(⩜(A→B, B→C, C→D), ⩚(A→B, B→C, C→D)) ⇒ (A→D)
    @test s5 == (∨(⩜(A→B, B→C, C→D), ⩚(A→B, B→C, C→D)) ⇒ (A→D)) # 非唯一性
    @test s5 == Implication(
        Disjunction(
            SeqConjunction(
                A→B, B→C, C→D
            ),
            ParConjunction(
                A→B, B→C, C→D
            ),
        ),
        Inheriance(A, D)
    )
    @test s5 == (∨(⩚(A→B, B→C, C→D), ⩜(A→B, B→C, C→D)) ⇒ (A→D))
    @test s5 == (∨(⩚(A→B, C→D, B→C), ⩜(A→B, B→C, C→D)) ⇒ (A→D))
    @test s5 ≠ (∨(⩚(A→B, B→C, C→D), ⩜(B→C, A→B, C→D)) ⇒ (A→D))

    # 语句
    se = Sentence{Question}(
        s5,
        Truth64(1, 0.9),
        StampBasic()
    )
    se0 = Sentence{Goal}(
        ExtSet(w"SELF") → IntSet(w"good"),
        Truth64(1, 0.9),
        StampBasic{Present}()
    )
    se2 = Sentence{Judgement}(s2)
    @show se se0 se2
    
    @test se0 == narsese"<{SELF} --> [good]>! :|: %1.0;0.9%"

    @test @JuNarsese.Util.exceptedError Sentence{Judgement}(
        s5,
        Truth64(1.1, 0.9), # f越界
        StampBasic()
    )

    @test @JuNarsese.Util.exceptedError Sentence{Judgement}(
        s5,
        Truth64(0, -1.0), # c越界
        StampBasic()
    )
    
end

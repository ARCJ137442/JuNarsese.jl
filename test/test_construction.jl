(@isdefined JuNarsese) || include("commons.jl") # 已在此中导入JuNarsese、Test

# 词项构建测试 #
@testset "construction" begin

    # 原子词项

    @show w i d q o

    @test w == Word(:词项)::Word
    @test i == IVar(:独立变量)::Variable{VTIndependent}
    @test d == DVar(:非独变量)::Variable{VTDependent}
    @test q == QVar(:查询变量)::Variable{VTQuery}
    @test o == Operator(:操作)::Operator
    @test n == Interval(+137)::Interval

    # 词项集
    exSet = ⩀(w, d, o)
    inSet = ⊍(n, q, i)
    @show exSet inSet "$exSet and $inSet"

    @test exSet == ExtSet(w,o,d) # 无序
    @test inSet == IntSet(i,n,q) # 无序

    # 词项逻辑集
    extI = ExtIntersection(w, i, d, E, n)
    intI = IntIntersection(d, i, A, o)
    extD = ExtDifference(A, i)
    intD = IntDifference(d, B)
    @show extI intI
    println("外延交$(extI)与内涵交$(intI)\n外延差$(extD)与内涵差$intD")

    @test extI == ExtIntersection(w, i, n, n, E, d) # 无序&不重复
    @test intI == IntIntersection(A, i, o, d) # 无序
    @test extD == ExtDifference(A, i) ≠ ExtDifference(i, A) # 有序
    @test intD == IntDifference(d, B) ≠ IntDifference(B, d) # 有序

    # 像

    eI = ExtImage(2, A,B,C) # (/, A, _, B, C)
    iI = IntImage(3, C,B,A) # (\, C, B, _, A)
    @show eI iI

    @test eI == ExtImage(2, A,B,C) # 非唯一性
    @test iI == IntImage(3, C,B,A) # 非唯一性
    @test eI.relation_index == 2 && iI.relation_index == 3
    @test ExtImage(4, A,B,C) ≠ /(A, ⋄, B, C) == eI == ExtImage(2, A,B,C) ≠ ExtImage(2, A,C,B) # 唯一相等性
    @test IntImage(4, C,B,A) ≠ \(C, B, ⋄, A) == iI == IntImage(3, C,B,A) ≠ IntImage(3, C,A,B) # 唯一相等性

    # 乘积

    @show p = TermProduct(A,B,C)
    @test p == *(A, B, C) == (A*B*C) ≠ (B*A*C) # 有序性 老式构造方法仍可使用

    # 快捷构造 #

    # 无「像占位符」会报错
    @test @expectedError /(A, B, C)
    @test @expectedError \(D, C, A)

    # 陈述逻辑集 #
    @show s1 = ((A→B) ∧ ((A→B)⇒(B→C))) ⇒ (B→C)
    @test s1 == (((A→B) ∧ ((A→B)⇒(B→C))) ⇒ (B→C)) # 非唯一性
    @test ((A→B) ∨ ((A→B)∧(B→C))) == ((A→B) ∨ ((A→B)∧(B→C))) # 非唯一性: 嵌套集合的刁钻
    @test s1 == Implication( # 等价性
        Conjunction(
            Inheritance(A,B),
            Implication(
                Inheritance(A,B),
                Inheritance(B,C)
            )
        ),
        Inheritance(B,C)
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
    @info "各语句的语法复杂度" get_syntactic_complexity.(test_set.sentences)

    @show s2 = (
        ((i"甲"→w"人")⇒(i"甲"→w"会死")) ∧
        (w"苏格拉底"→w"人")
    ) ⇒ (w"苏格拉底"→w"会死")
    @test s2 == Implication(
        Conjunction(
            Inheritance(w"苏格拉底", w"人"),
            Implication(
                Inheritance(i"甲", w"人"),
                Inheritance(i"甲", w"会死")
            )
        ),
        Inheritance(w"苏格拉底", w"会死")
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
        Inheritance(A, D)
    )

    @test s5 == (∨(⩚(A→B, B→C, C→D), ⩜(A→B, B→C, C→D)) ⇒ (A→D))
    @test s5 == (∨(⩚(A→B, C→D, B→C), ⩜(A→B, B→C, C→D)) ⇒ (A→D))
    @test s5 ≠ (∨(⩚(A→B, B→C, C→D), ⩜(B→C, A→B, C→D)) ⇒ (A→D))
    # 语句
    se = SentenceQuestion(
        s5,
        StampBasic(),
    )
    se0 = SentenceGoal(
        ExtSet(w"SELF") → IntSet(w"good"),
        StampBasic{Present}(),
        Truth64(1, 0.9),
    )
    se2 = SentenceJudgement(s2)
    @show se se0 se2

    @test se0 == narsese"<{SELF} --> [good]>! :|: %1.0;0.9%"

    # 真值/欲望值/预算值越界

    @test @expectedError SentenceJudgement(
        s5,
        StampBasic(),
        Truth64(1.1, 0.9), # f越界
    )

    @test @expectedError SentenceGoal(
        s5,
        StampBasic(),
        Truth64(0, -1.0), # c越界
    )

    # 合法情况
    @test BudgetBasic(1, 1.0, 0.1) isa Budget
    # 越界
    @test @expectedError BudgetBasic(2, 1.0, 0.1)
    @test @expectedError BudgetBasic(0, -1.0, 0)
    @test @expectedError BudgetBasic(0, 1.0, 023)

end

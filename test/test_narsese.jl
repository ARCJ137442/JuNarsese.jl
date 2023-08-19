include("commons.jl") # 已在此中导入JuNarsese、Test

A,B,C,D,E = "A B C D E" |> split .|> String .|> Symbol .|> Word
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

    # 测试Narsese特性之「有序可重复|无序不重复」 #

    # 外延集/内涵集(无序不重复)
    @test ExtSet(A,B,C,D,E) == ExtSet(C,E,A,B,D) # 无序
    @test IntSet(A,B,C,D,E) == IntSet(C,E,A,B,D) # 无序

    @test ExtSet(A,B,C,E,E) == ExtSet(C,E,B,A) # 不重复
    @test IntSet(E,A,B,C,E) == IntSet(C,E,B,A) # 不重复

    # 词项逻辑集 外延交/内涵交(无序不重复)+外延差/内涵差(有序可重复)
    @test ExtIntersection(A,B,C,D,E) == ExtIntersection(C,E,A,B,D) # 无序
    @test IntIntersection(A,B,C,D,E) == IntIntersection(C,E,A,B,D) # 无序

    @test ExtIntersection(A,B,C,E,E) == ExtIntersection(C,E,B,A) # 不重复
    @test IntIntersection(E,A,B,C,E) == IntIntersection(C,E,B,A) # 不重复

    @test ExtDiff(A,B) ≠ ExtDiff(B,A) # 有序性
    @test IntDiff(A,B) ≠ IntDiff(B,A) # 有序性

    @test ExtDiff(B,B) == ExtDiff(B,B) # 可重复
    @test IntDiff(B,B) == IntDiff(B,B) # 可重复

    # 乘积(有序可重复)
    @test TermProduct(A,B,C) ≠ TermProduct(A,C,B) ≠ TermProduct(B,A,C) ≠ TermProduct(B,C,A) # 有序性
    @test TermProduct(A,A,B,B) ≠ TermProduct(A,B) # 可重复

    # 像(有序可重复)
    @test ExtImage(A, B, placeholder, C) ≠ ExtImage(A, placeholder, B, C) ≠ ExtImage(A, C, placeholder, B) # 有序性
    @test IntImage(A, B, placeholder, C) ≠ IntImage(A, placeholder, B, C) ≠ IntImage(A, C, placeholder, B) # 有序性
    
    @test ExtImage(A, A, placeholder, B, B) ≠ ExtImage(A, placeholder, B, B) ≠ ExtImage(A, placeholder, B) # 可重复
    @test IntImage(A, A, placeholder, B, B) ≠ IntImage(A, placeholder, B, B) ≠ IntImage(A, placeholder, B) # 可重复

    # 陈述(继承&蕴含:有序 相似&等价:无序) 📌严格模式不可重复：禁止重言式
    iab,iba = Inheritance(A, B), Inheritance(B, A)
    iac,ica = Inheritance(A, C), Inheritance(C, A)

    @test iab ≠ iba # 有序性
    @test Implication(iab, iba) ≠ Implication(iba, iab) # 有序性
    
    @test Similarity(A, B) == Similarity(B, A) # 无序性
    @test Equivalence(iab, iba) == Equivalence(iba, iab) # 无序性

    # 陈述逻辑集(无序不重复)
    @test Conjunction(iab, iba) == Conjunction(iba, iab) # 无序性
    @test Disjunction(iab, iba) == Disjunction(iba, iab) # 无序性
    @test Negation(iab) == Negation(iab) # 特殊

    @test Conjunction(iab, iba, iab, iba) == Conjunction(iab, iba) # 不重复
    @test Disjunction(iab, iba, iab, iba) == Disjunction(iab, iba) # 不重复

    # 时序合取(有序可重复) 平行合取(无序不重复)
    @test SeqConjunction(iab, iba, iac, ica) ≠ SeqConjunction(iba, iab, iac, ica) ≠ SeqConjunction(iab, iac, iba, ica) # 有序性
    @test SeqConjunction(iab, iab, iac, iac) ≠ SeqConjunction(iab, iac, iac) ≠ SeqConjunction(iab, iab, iac) ≠ SeqConjunction(iab, iac) # 可重复
    
    @test ParConjunction(iab, iba, iac, ica) == ParConjunction(iab, iba, iac, ica) == ParConjunction(iba, iab, iac, ica) # 无序性
    @test ParConjunction(iab, iab, iac, iac) == ParConjunction(iab, iac, iac) == ParConjunction(iab, iab, iac) == ParConjunction(iab, iac) # 可重复

    # 测试Narsese特性之「同义重定向」 #

    # 外延/内涵 并 ⇒ 内涵/外延 交

    @test ExtUnion(A, B) isa IntIntersection # 外延并=内涵交
    @test IntUnion(A, B) isa ExtIntersection # 内涵并=外延交

    # 回顾性等价 = 预测性等价

    @test EquivalenceRetrospective(A→B, B→A) == EquivalencePredictive(B→A, A→B)

    # methods.jl #
    @test A + B == Word(:AB)
    @test @expectedError w + i + d + q + n + o # 不同类型不允许相加
    @test Interval(123) + Interval(234) == Interval(357) # 间隔相加

    # 合法性测试 & 严格模式 #

    # 原子词项名的合法性测试

    @test @expectedError Word(":A")
    @test @expectedError Word("<A --> B>") # 非法词项名！
    @test @expectedError IVar("\$A")
    @test @expectedError DVar("#A")
    @test @expectedError QVar("?A")
    @test @expectedError Operator("^A")
    @test @expectedError Operator(Symbol("A-B"))

    @test @expectedError Interval("A") # 间隔不能是非数字
    @test @expectedError Interval("-123") # 间隔不能是负数
    @test @expectedError Interval("1.5") # 间隔不能是浮点数
    @test @expectedError Interval("+123") # 间隔不能加上前缀

    # 前面「严格模式」的具体作用

    # 基于词项的陈述：必须是「一等公民」而非陈述
    @test @expectedError Inheritance(A, A)
    @test @expectedError Similarity(p, p)
    @test @expectedError Inheritance(w, A→B)
    @test @expectedError Inheritance(A→B, d)
    @test @expectedError Similarity(p, p→q)
    @test @expectedError Similarity(p→q, p)

    # 基于陈述的陈述：不能用「非陈述词项」构造蕴含、等价（【20230812 22:35:36】现在不再是「数据结构内嵌」）
    @test @expectedError Implication(A→B, A→B)
    @test @expectedError Equivalence(p↔C, p↔C)
    @test @expectedError Implication(Word(:a), Word(:b))
    @test @expectedError Equivalence(i, d)
    @test @expectedError Implication(q, o)
    @test @expectedError Equivalence(eI, iI)
    @test @expectedError Implication(p, A→B)
    @test @expectedError Equivalence(p, p)
    
    @test @expectedError (A ↔ B) ⇔ (B ↔ A) # 隐含的重言式
    
    @test @expectedError ((A ↔ B) ⇔ (B ↔ A)) ⇔ ((B ↔ A) ⇔ (A ↔ B)) # 隐含的重言式
    
    # 陈述逻辑集、陈述时序集都不支持「非陈述词项」
    @test @expectedError Conjunction(A→B, B→C, A↔D, C→D, D→o, p)
    @test @expectedError Disjunction(A→B, C→D, D→o, B→C, A↔D, d)
    @test @expectedError ParConjunction(A→B, C→D, A↔D, D→o, B→C, w)
    @test @expectedError SeqConjunction(A→B, D→o, B→C, A↔D, C→D, w)

    # 是否可交换

    @test !is_commutative(StatementTypeInheritance)
    @test !is_commutative(StatementTypeImplication)
    @test is_commutative(StatementTypeSimilarity)
    @test is_commutative(StatementTypeEquivalence)

    @test !is_commutative(TermProduct)
    @test !is_commutative(ExtImage)
    @test !is_commutative(IntDiff)
    @test !is_commutative(Negation)
    @test !is_commutative(SeqConjunction)
    @test is_commutative(ExtSet)
    @test is_commutative(IntIntersection)
    @test is_commutative(ExtUnion)
    @test is_commutative(Conjunction)
    @test is_commutative(Disjunction)
    @test is_commutative(ParConjunction)

    @test is_commutative(A ↔ B)
    @test is_commutative((A → B) ⇔ (B ↔ A))
    @test is_commutative(⩀(A, B, C))
    @test !is_commutative(\(A, B, nothing, C))
    @test !is_commutative(*(A, B, C))
    @test !is_commutative(*(A, B, C) → R)

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

    @test @expectedError SentenceJudgement(
        s5,
        StampBasic(),
        Truth64(1.1, 0.9), # f越界
    )

    @test @expectedError SentenceJudgement(
        s5,
        StampBasic(),
        Truth64(0, -1.0), # c越界
    )
    
end

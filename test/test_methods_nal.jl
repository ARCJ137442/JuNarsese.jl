(@isdefined JuNarsese) || include("commons.jl") # 已在此中导入JuNarsese、Test

@testset "methods/NAL" begin

    @info "各个词项的复杂度："
    [println(get_syntactic_complexity(t), " of $t") for t in test_set.terms]

    # 收集所有原子词项
    atoms_ = atoms((A→B)⇒(B→C))
    @test A in atoms_ && B in atoms_ && C in atoms_

    # 获取所有子词项
    @show terms_ = fetch_all_terms((A→B)⇒(B→C))
    @test A in terms_ && B in terms_ && C in terms_ &&
        (A→B) in terms_ && (B→C) in terms_ &&
        ((A→B)⇒(B→C)) in terms_

    # 获取所有索引
    t = ExtSet(A,B,C)
    @test eachindex(t) == Base.OneTo(3)
    @test nextind(t, 1) == 2
    @test prevind(t, 2) == 1

    # 是否可交换 #
    @test !is_commutative(StatementTypeInheritance)
    @test !is_commutative(StatementTypeImplication)
    @test is_commutative(StatementTypeSimilarity)
    @test is_commutative(StatementTypeEquivalence)
    
    @test !is_commutative(Term) # 默认不可交换
    @test !is_commutative(TermProduct)
    @test !is_commutative(ExtImage)
    @test !is_commutative(IntDiff)
    @test !is_commutative(SeqConjunction)
    # 不应该对「否定」判断「可交换性」：其本身无意义
    @test is_commutative(ExtSet)
    @test is_commutative(IntIntersection)
    @test is_commutative(ExtUnion)
    @test is_commutative(Conjunction)
    @test is_commutative(Disjunction)
    @test is_commutative(ParConjunction)

    @test is_commutative(A ↔ B)
    @test is_commutative((A → B) ⇔ (B ↔ A))
    @test is_commutative(⩀(A, B, C))
    @test !is_commutative(\(A, B, placeholder, C))
    @test !is_commutative(*(A, B, C))
    @test !is_commutative(*(A, B, C) → R)

    # 是否可重复：默认是`!(是否可交换)`，但**不用于判断陈述** #

    @test is_repeatable(Term) # 默认可重复
    @test is_repeatable(TermProduct)
    @test is_repeatable(ExtImage)
    @test is_repeatable(SeqConjunction)
    # 不应该对「否定」判断「可交换性」：其本身无意义
    @test !is_repeatable(ExtSet)
    @test !is_repeatable(IntIntersection)
    @test !is_repeatable(ExtUnion)
    @test !is_repeatable(IntDiff) # 【20230821 22:53:26】现在也不可重复了
    @test !is_repeatable(Conjunction)
    @test !is_repeatable(Disjunction)
    @test !is_repeatable(ParConjunction)

    @test !is_repeatable(⩀(A, B, C))
    @test is_repeatable(\(A, B, placeholder, C))
    @test is_repeatable(*(A, B, C))

    # 测试Narsese特性之「有序可重复|无序不重复」 #

    # 外延集/内涵集(无序不重复)
    @test ExtSet(A,B,C,D,E) == ExtSet(C,E,A,B,D) # 无序
    @test IntSet(A,B,C,D,E) == IntSet(C,E,A,B,D) # 无序

    @test ExtSet(A,B,C,E,E) == ExtSet(C,E,B,A) # 不重复
    @test IntSet(E,A,B,C,E) == IntSet(C,E,B,A) # 不重复

    # 词项逻辑集 外延交/内涵交(无序不重复)+外延差/内涵差(有序不重复)
    @test ExtIntersection(A,B,C,D,E) == ExtIntersection(C,E,A,B,D) # 无序
    @test IntIntersection(A,B,C,D,E) == IntIntersection(C,E,A,B,D) # 无序

    @test ExtIntersection(A,B,C,E,E) == ExtIntersection(C,E,B,A) # 不重复
    @test IntIntersection(E,A,B,C,E) == IntIntersection(C,E,B,A) # 不重复

    @test ExtDiff(A,B) ≠ ExtDiff(B,A) # 有序性
    @test IntDiff(A,B) ≠ IntDiff(B,A) # 有序性

    @test @expectedError ExtDiff(B,B) # 不重复（现在会报错）
    @test @expectedError IntDiff(B,B) # 不重复（现在会报错）

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

    # 序列合取(有序可重复) 平行合取(无序不重复)
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

    # 语句&任务 #

    # 时间戳 #

    sb = StampBasic()
    sp1 = StampPythonic()

    @test sb == sp1 # 默认值应该相等
    @test sb !== sp1 # 不全等

    sp2 = StampPythonic(occurrence_time = 1)
    # 相对时序
    @test get_tense(sp2) == Eternal # 默认永恒
    @test get_tense(sp2, 0) == Future  # sp2 是 0 的未来
    @test get_tense(sp2, 1) == Present # sp2 是 1 的现在
    @test get_tense(sp2, 2) == Past    # sp2 是 2 的过去

    @test sp2 == deepcopy(sp2)
    @test sp1 != sp2

    # 方法重定向
    for t in test_set.tasks, method_name in [:get_term, :get_stamp, :get_tense, :get_punctuation, :get_truth, :get_syntactic_complexity]
        @test @eval $method_name($t) == $method_name(get_sentence($t))
    end
    for t in test_set.tasks, method_name in [:get_p, :get_d, :get_q]
        @test @eval $method_name($t) == $method_name(get_budget($t))
    end
    for t in test_set.sentences, method_name in [:get_syntactic_complexity]
        @test @eval $method_name($t) == $method_name(get_term($t))
    end

end

(@isdefined JuNarsese) || include("../commons.jl") # 已在此中导入JuNarsese、Test

@testset "methods/arrays" begin
    
    # 测试原子词项的特殊运算符重载
    @test A + B == Word(:AB)
    @test @expectedError w + i + d + q + n + o # 不同类型不允许相加
    @test Interval(123) + Interval(234) == Interval(357) # 间隔相加

    # 测试原子的长度函数
    @test length(A) == 1

    # 测试原子的索引函数
    @test getindex(A) == A[] == A[typemax(Int)] == A[typemin(Int)] == :A

    # 测试除差、像以外的所有复合词项
    for compoundType::Type in [TermProduct, ExtSet, IntSet, ExtIntersection, IntIntersection]

        # 测试复合词项的长度函数
        @test 3 == length(compoundType([A, B, C])) > length(compoundType([A, B])) == 2

        # 测试复合词项的索引函数
        @test getindex(
            compoundType([A, B]), 
            2
        ) == compoundType([A, B])[2] == B ≠ compoundType([A, B])[1] == A

        # 测试复合词项的枚举函数
        @test [t for t in compoundType([A, B])] == [A, B]

        # 测试复合词项的映射函数
        @test map(
            t -> typeof(t)(Symbol(:_, nameof(t))), 
            compoundType([A, B])
        ) == compoundType([w"_A", w"_B"])

        # 测试复合词项的随机函数
        random_term = rand(compoundType([A, B]))
        @test random_term isa Atom
        @test random_term == A || random_term == B

        # 测试复合词项的 all 和 any 函数
        @test all(t -> t isa Atom, compoundType([A, B]))
        @test any(==(B), compoundType([A, B]))

        # 测试复合词项的倒转函数
        @test reverse(compoundType([A, B])) == compoundType([B, A])

    end

    # 测试继承、相似两类陈述（严格模式需要另作改变）
    for statementType in [Inheritance, Similarity]
        # 测试陈述的长度函数
        @test length(statementType(A, B)) == 2

        # 测试陈述的索引函数
        @test getindex(
            statementType(A, B),
            2
        ) == statementType(A, B)[2] == B ≠ statementType(A, B)[1] == A

        # 测试陈述的枚举函数
        @test [t for t in statementType(A, B)] == [A, B]

        # 测试陈述的映射函数
        @test map(
            t -> typeof(t)(Symbol(:_, nameof(t))), 
            statementType([A, B])
        ) == statementType([w"_A", w"_B"])

        # 测试陈述的随机函数
        random_element = rand(statementType(A, B))
        @test random_element isa Atom
        @test random_element == A || random_element == B

        # 测试陈述的 all 和 any 函数
        @test all(t -> t isa Atom, statementType(A, B))
        @test any(==(B), statementType(A, B))

        # 测试陈述的倒转函数
        @test reverse(statementType(A, B)) == statementType(B, A)

    end

end

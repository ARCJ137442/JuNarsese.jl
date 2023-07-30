push!(LOAD_PATH, "../src") # 用于直接打开（..上一级目录）
push!(LOAD_PATH, "src") # 用于VSCode调试（项目根目录起）

using JuNarsese

using Test


@testset "Narsese" begin

    # 快捷构造 #

    w,i,d,q,o = w"词项", w"独立变量"i, w"非独变量"d, w"查询变量"q, w"操作"o
    A,B,C = "A B C" |> split .|> String .|> Symbol .|> Word

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

    @test eI.relation_index == 2 && iI.relation_index == 3
    @test ExtImage(1, A,B,C) ≠ /(A, ⋄, B, C) == eI == ExtImage(2, A,B,C) ≠ ExtImage(2, A,C,B) # 唯一相等性
    @test IntImage(1, C,B,A) ≠ \(C, B, ⋄, A) == iI == IntImage(3, C,B,A) ≠ IntImage(3, C,A,B) # 唯一相等性

    # 乘积

    @show p = TermProduct(A,B,C)
    @test p == *(A, B, C) == (A*B*C) ≠ (B*A*C) # 有序性 老式构造方法仍可使用

    # 陈述

    # 陈述逻辑集
    @show s1 = ((A→B) ∧ ((A→B)⇒(B→C))) ⇒ (B→C)
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

    @show s2 = (
        ((w"甲"i→w"人")⇒(w"甲"i→w"会死")) ∧
        (w"苏格拉底"→w"人")
    ) ⇒ (w"苏格拉底"→w"会死")
    @test s2 == Implication(
        Conjunction(
            Inheriance(w"苏格拉底", w"人"),
            Implication(
                Inheriance(w"甲"i, w"人"),
                Inheriance(w"甲"i, w"会死")
            )
        ),
        Inheriance(w"苏格拉底", w"会死")
    )

    # 语句
    @show se = Sentence{Judgement}(
        A → B,
        Truth64(1, 0.5),
        StampBasic()
    )

    # TODO 其它语句测试
end

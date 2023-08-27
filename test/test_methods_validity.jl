(@isdefined JuNarsese) || include("commons.jl") # 已在此中导入JuNarsese、Test

# 判等/比大小逻辑 #
@testset "methods/validity" begin

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

end

if !isdefined(Main, :JuNarsese)
    push!(LOAD_PATH, "../src") # 用于直接打开（..上一级目录）
    push!(LOAD_PATH, "src") # 用于VSCode调试（项目根目录起）

    # 自动导入JuNarsese模块
    using JuNarsese
end
if !isdefined(Main, :Test)
    using Test
    """
    ========
    标准测试集：
    - 测试集类型：具名元组
        - terms: 测试用词项
        - sentences: 测试用语句
    ========
    """ |> println

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
    s7 = ParConjunction([
        narsese"<A {-- B>"
        narsese"<A --] B>"
        narsese"<A {-] B>"
        
        narsese"<A =/> B>"
        narsese"<A =|> B>"
        narsese"<A =\> B>"
        
        narsese"<A </> B>"
        narsese"<A <|> B>"
        narsese"<A <\> B>"
    ]...)
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

    terms = [w, i, d, q, o, s1, s2, s3, s4, s5, s6, s7, s8]
    @info "terms: " terms

    # 构建
    sentences = [
        narsese"<A-->B>. :|: %1.00;0.90% "
        narsese"<SELF {-] good>! :|: "
        narsese"<<(*, A, B) --> (*, C, D)> ==> (&&, <A --> C>, <B --> D>)>@ %1.00;0.90%"
        narsese"<(*, A, B, C, D) --> R>? "
        Sentence{Judgement}(s8)
    ]
    @info "sentences: " sentences
    # ASTParser.(ASTParser.(ASTParser.(sentences, Sentence), Sentence), Sentence)
    # XMLParser_optimized.(XMLParser_optimized.(XMLParser_optimized.(sentences, Sentence), Sentence), Sentence)
    # @info "sentences@AST: " ASTParser.(ASTParser.(ASTParser.(sentences, Sentence), Sentence), Sentence)
    # @info "sentences@XML: " XMLParser.(XMLParser.(XMLParser.(sentences, Sentence), Sentence), Sentence)
    # @info "sentences@JSON: " JSONParser{Dict}.(JSONParser{Dict}.(JSONParser{Dict}.(sentences, Sentence), Sentence), Sentence)
    # for (t1, t2) in zip(tss, sentences)
    #     if t1 ≠ t2
    #         # dump.(ASTParser.([t1, t2]); maxdepth=typemax(Int))
    #         @info t1==t2 t1 t2
    #     end
    #     @assert t1 == t2 "Not eq!\n$t1\n$t2"
    # end
    # @show sentences

    "标准测试集 = 词项 + 语句"
    test_set::NamedTuple = (;terms, sentences) # 具名元组
    # test_set = (;terms=[s7], sentences=[])

    "测试集：\n$test_set" |> println
end

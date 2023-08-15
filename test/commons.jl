if !isdefined(Main, :JuNarsese)
    push!(LOAD_PATH, "../src") # 用于直接打开（..上一级目录）
    push!(LOAD_PATH, "src") # 用于VSCode调试（项目根目录起）

    # 自动导入JuNarsese模块
    using JuNarsese
    using JuNarsese.Util # 特别using其中的「Util」

    # 启用「严格模式」
    include("use_strict.jl")
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
    w,i,d,q,n,o = w"词项", i"独立变量", d"非独变量", q"查询变量", n"137", o"操作"
    A,B,C,D,R = "A B C D R" |> split .|> String .|> Symbol .|> Word
    # 像、陈述、乘积
    @show s1 = (/(R, A, B, ⋄, D) → C) ⇒ (*(A, B, C, D) → R)
    # 词项集、陈述逻辑集
    @show s2 = (|(A, B, C) → D) ⇒ ∨((A → D), (B → D), (C → D))
    # 快捷方式解析
    @show s3 = ShortcutParser(
        """ (( q"A" * i"B" ) → o"C" ) ⇔ (d"D" ↔ (w"E" * n"12")) """
    )
    # 词项集&词项逻辑集
    
    @show s4 = ⩀(w, i, d, q, n, o) - ⊍(w, i, d, q, n, o)
    @show s5 = ∩(A, B, C) - ∪(A, B, C)
    # 时序合取
    @show s6 = ∨(⩜(A→B, B→C, C→D), ⩚(A→B, B→C, C→D)) ⇒ (A→D)
    # 副系词|时序蕴含/等价
    s7 = ParConjunction([
        nse"<A {-- B>"
        nse"<A --] B>"
        nse"<A {-] B>"
        
        nse"<<A --> B> =/> <B --> C>>" # 【20230812 18:27:20】现在必须要陈述才能输入进去
        nse"<<A --> B> =|> <B --> C>>" # 【20230812 18:27:20】现在必须要陈述才能输入进去
        nse"<<A --> B> =\> <B --> C>>" # 【20230812 18:27:20】现在必须要陈述才能输入进去
        
        nse"<<A --> B> </> <B --> C>>" # 【20230812 18:27:20】现在必须要陈述才能输入进去
        nse"<<A --> B> <|> <B --> C>>" # 【20230812 18:27:20】现在必须要陈述才能输入进去
        nse"<<A --> B> <\> <B --> C>>" # 【20230812 18:27:20】现在必须要陈述才能输入进去
    ]...)
    @show s7
    # 极端嵌套情况
    s8 = (*(
        ⩚(
            ⩜(A→B, B→C, C→D), 
            ∨(ExtSet(A, B, C)→D, w→o), 
            ⩚(A→B, B→C, C→D)
        ), 
        ∧(s1, s2), 
        \(A, ⋄, s3, s5) → /(s1, ⋄, B, s4),
        s2 ⇒ s3,
        ¬(⩀(w, i, d, q, o) → IntSet(s6, ∩(A, B, C)))
    ) → s4) ⇔ (s6 ⇒ s7)
    @show s8

    terms = [w, i, d, q, o, s1, s2, s3, s4, s5, s6, s7, s8]
    @info "terms: " terms

    # 构建
    sentences = [
        narsese"<A-->B>. :|: %1.00;0.90% "
        narsese"<SELF {-] good>! :|: "
        narsese"<<(*, A, B) --> (*, C, D)> ==> (&&, <A --> C>, <B --> D>)>@ %1.00;0.90%"
        narsese"<(*, A, B, C, D) --> R>? "
        nse"「我是墓地」。现在真值=1.0真0.5信"han
        nse"「「他是『爱因斯坦』」得「他似爱因斯坦」」"han
        nse"「（与，「凉白开是水」，「水是有毒的」）得「凉白开是有毒的」」将来真值=0.8真0.3信"han
        nse"「「（积，甲，乙）是（积，丙，丁）」将得（与，「甲是丙」，「乙是丁」）」？"han
        nse"「「（积，『爱因斯坦』，专利局）是坐在」曾得「（外像，『爱因斯坦』，坐在，某）是专利局」」曾经真值=0.5真0.9信"han
        nse"「「『我』是【好】」同（与，「我为【好】」，「『我』有好」，「我具有好」）」；"han
        nse"「（外交，【词项，任一独立变量，其一非独变量】，【所问查询变量，操作操作】）似【词项，任一独立变量，其一非独变量，所问查询变量，操作操作】」"han
        nse"「（内交，【词项，任一独立变量，其一非独变量，所问查询变量】，【所问查询变量，操作操作】）似【所问查询变量】」"han
        nse"「（内差，【词项，任一独立变量，其一非独变量】，【词项】）似【任一独立变量，其一非独变量】」"han
        nse"（与，「『爱因斯坦』是物理学家」，「（外像，某，研发出，相对论）是『爱因斯坦』」）。"han
        nse"「（与，「任一人是【会死的】」，「『苏格拉底』是人」）得「『苏格拉底』是【会死的】」」。"han
        nse"「（接连，「时间是黑夜」，「程序员有写代码」，「（外像，程序员，撞上，某）是bug」）将得「程序员是【熬夜的】」」。"han
        nse"「（同时，「系统有开放性」，「系统有自主性」，「系统有实时性」）将得「系统是AGI」」？"han
        SentenceJudgement(s8)
    ]
    @info "sentences: " sentences
    # 下面这些注释是利用系统报错精确获得堆栈信息/调试支持的
    # ASTParser.(ASTParser.(ASTParser.(sentences)))
    # XMLParser_optimized.(XMLParser_optimized.(XMLParser_optimized.(sentences)))
    # @info "sentences@AST: " ASTParser.(ASTParser.(ASTParser.(sentences)))
    # @info "sentences@XML: " XMLParser.(XMLParser.(XMLParser.(sentences)))
    # @info "sentences@JSON: " JSONParser{Dict}.(JSONParser{Dict}.(JSONParser{Dict}.(sentences)))
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

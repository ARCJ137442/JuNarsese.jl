if !isdefined(Main, :JuNarsese)
    push!(LOAD_PATH, "../src") # 用于直接打开（..上一级目录）
    push!(LOAD_PATH, "src") # 用于VSCode调试（项目根目录起）

    # 自动导入JuNarsese模块
    using JuNarsese
    using JuNarsese.Util # 【20230821 22:20:42】现在不用特别using其中的「Util」

    # 启用「严格模式」
    JuNarsese.Narsese.use_strict!()
end
begin "报错debug专用"
    # @show CommonCompound{CompoundTypeTermLogicalSet{Intension, Or}}()
    # @show nse"$0.5;0.5;0.5$ <A-->B>."
    # @show nse"<$A-->$B>." # 预算值不能匹配到独立变量的「$」
    # @show nse"预0.5、0.8、0.1算「我是墓地」。"han
    # @show nse"「我是墓地」。"han
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
    A,B,C,D,E,R = "A B C D E R" |> split .|> Word
    # 词项集
    @show t1 = ⩀(w, i, d, q, n, o) - ⊍(w, i, d, q, n, o)
    # 词项逻辑集
    @show t2 = ∩(A, B, C) - ∪(A, B, C)
    # 像
    @show t3 = /(R, A, B, ⋄, \(R, A, B, ⋄, D))
    # 陈述、乘积
    @show s1 = *(A, B, C, D) → R
    # 陈述逻辑集
    @show s2 = ∧(⊍(A, B, C) → D, ⊍(A, B, C) → E) ⇒ ∨((A → D), (B → D), (C → D))
    # 快捷方式解析
    @show s3 = ShortcutParser(
        """ (( q"A" * i"B" ) → o"C" ) ⇔ (d"D" ↔ (w"E" * n"12")) """
    )
    # 时序合取
    @show s4 = ∨(⩜(A→B, B→C, C→D), ⩚(A→B, B→C, C→D)) ⇒ (A→D)
    # 副系词|时序蕴含/等价
    s5 = ParConjunction([
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
    @show s5
    # 极端嵌套情况
    s6 = (*(
        ⩚(
            ⩜(A→B, B→C, C→D), 
            ∨(ExtSet(A, B, C)→D, w→o), 
            ⩚(A→B, B→C, C→D)
        ), 
        ∧(s5, s1), 
        \(A, ⋄, s3, t3) → /(t1, ⋄, B, t2),
        s1 ⇒ s3,
        ¬(⩀(w, i, d, q, o) → IntSet(s4, ∩(A, B, C)))
    ) → t2) ⇔ (s4 ⇒ s2)
    @show s6

    terms::Vector{AbstractTerm} = [w, i, d, q, o, t1, s1, s2, s3, t2, t3, s4, s5, s6]
    @info "terms: " terms

    # 构建
    sentences::Vector{AbstractSentence} = [
        narsese"<A-->B>. :|: %1.00;0.90%"
        narsese"<SELF {-] good>! :|: "
        narsese"<<(*, A, B) --> (*, C, D)> ==> (&&, <A --> C>, <B --> D>)>@ %1.00;0.90%"
        narsese"<(*, A, B, C, D) --> R>? "
        narsese"<BALL {-] left>. :!132:"
        nse"「我是墓地」。现在真值=1.0真0.5信"han
        nse"「「他是『爱因斯坦』」得「他似爱因斯坦」」。"han
        nse"「（与，「凉白开是水」，「水是有毒的」）得「凉白开是有毒的」」将来真值=0.8真0.3信"han
        nse"「「（积，甲，乙）是（积，丙，丁）」将得（与，「甲是丙」，「乙是丁」）」？"han
        nse"「「（积，『爱因斯坦』，专利局）是坐在」曾得「（外像，『爱因斯坦』，坐在，某）是专利局」」曾经真值=0.5真0.9信"han
        nse"「（积，「『我』是【好】」）似（积，「我为【好】」，「『我』有好」，「我具有好」）」；"han
        nse"「（外交，【词项，任一独立变量，其一非独变量】，【所问查询变量，操作操作】）似【词项，任一独立变量，其一非独变量，所问查询变量，操作操作】」？"han
        nse"「（内交，【词项，任一独立变量，其一非独变量，所问查询变量】，【所问查询变量，操作操作】）似【所问查询变量】」。时刻=42"han
        nse"「（内差，【词项，任一独立变量，其一非独变量】，【词项】）似【任一独立变量，其一非独变量】」。"han
        nse"（与，「『爱因斯坦』是物理学家」，「（外像，某，研发出，相对论）是『爱因斯坦』」）。"han
        nse"「（与，「任一人是【会死的】」，「『苏格拉底』是人」）得「『苏格拉底』是【会死的】」」。"han
        nse"「（接连，「时间是黑夜」，「程序员有写代码」，「（外像，程序员，撞上，某）是bug」）将得「程序员是【熬夜的】」」。"han
        nse"「（同时，「系统有开放性」，「系统有自主性」，「系统有实时性」）将得「系统是AGI」」？"han
        SentenceJudgement(s6)
    ]

    # 构建
    tasks::Vector{AbstractTask} = [
        narsese"$1.0;0.5;0.5$ <A-->B>. :|: %1.00;0.90%"
        narsese"$0.5;0.5;0.5$ <SELF {-] good>! :|: "
        narsese"$0.4;0.6;0.5$ <<(*, A, B) --> (*, C, D)> ==> (&&, <A --> C>, <B --> D>)>@ %1.00;0.90%"
        narsese"$0.3;0.7;0.5$ <(*, A, B, C, D) --> R>? "
        narsese"$0.2;0.8;0.5$ <BALL {-] left>. :!132:"
        TaskBasic.(sentences)... # 所有语句转换为一个基本的任务
    ]
    @info "tasks: " tasks
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
    test_set::NamedTuple = (;terms, sentences, tasks) # 具名元组
    # test_set = (;terms=[s7], sentences=[])

    "测试集：\n$test_set" |> println
end

begin "用于「判等失败」后递归查找「不等の元素」的断言函数"

    "兜底断言"
    recursive_assert(t1::Any, t2::Any) = @assert t1 == t2

    "通用复合词项"
    recursive_assert(t1::CommonCompound, t2::CommonCompound) = begin
        @assert typeof(t1) == typeof(t2)
        # 【20230820 12:52:34】因为复合词项现采用「预先排序」的方式，现在只需逐个比对
        @assert length(t1) == length(t2)
        for (tt1, tt2) in zip(t1.terms, t2.terms)
            @assert tt1 == tt2 "$tt1 ≠ $tt2 !"
        end
    end

    "陈述"
    recursive_assert(s1::Statement, s2::Statement) = begin
        recursive_assert(ϕ1(s1), ϕ1(s2))
        recursive_assert(ϕ2(s1), ϕ2(s2))
    end

end

"通用测试の宏"
macro equal_test(
    parser::Union{Symbol,Expr}, 
    test_set::Union{Symbol,Expr},
    )
    # quote里的`($parser)`已经自动把内部对象eval了
    quote
        try
            # 词项 #
            # 二次转换
            local converted_terms = ($parser).(($test_set).terms)
            @info "converted_terms@$($parser):"
            join(converted_terms, "\n") |> println
            local reconverted_terms = ($parser).(converted_terms)
            @info "reconverted_terms@$($parser):"
            join(reconverted_terms, "\n") |> println
            # 比对相等
            for (reconv, origin) in zip(reconverted_terms, ($test_set).terms) # 📝Julia: @simd的循环变量必须是单个标识符，且zip无法参与循环
                if reconv ≠ origin
                    @error "$($parser): Not eq!" reconv origin
                    # if typeof(reconv) == typeof(origin) <: Statement
                    recursive_assert(reconv, origin)
                end
                @test reconv == origin # 📌【20230806 15:24:11】此处引入额外参数会报错……引用上下文复杂
            end
            # 语句 #
            # 二次转换
            local converted_sentences = ($parser).(($test_set).sentences)
            @info "converted_sentences@$($parser):"
            join(converted_sentences, "\n") |> println
            local reconverted_sentences = ($parser).(converted_sentences)
            @info "converted_sentences@$($parser):" 
            join(converted_sentences, "\n") |> println
            # 比对相等
            for (reconv, origin) in zip(reconverted_sentences, ($test_set).sentences)
                if reconv ≠ origin
                    @error "$($parser): Not eq!" reconv origin
                    dump.([reconv, origin]; maxdepth=typemax(Int))
                end
                @assert reconv == origin # 📌【20230806 15:24:11】此处引入额外参数会报错……引用上下文复杂
            end
            # 任务 #
            # 二次转换
            local converted_tasks = ($parser).(($test_set).tasks)
            @info "converted_tasks@$($parser):"
            join(converted_tasks, "\n") |> println
            local reconverted_tasks = ($parser).(converted_tasks)
            @info "converted_tasks@$($parser):" 
            join(converted_tasks, "\n") |> println
            # 比对相等
            for (reconv, origin) in zip(reconverted_tasks, ($test_set).tasks)
                if reconv ≠ origin
                    @error "$($parser): Not eq!" reconv origin
                    dump.([reconv, origin]; maxdepth=typemax(Int))
                end
                @assert reconv == origin # 📌【20230806 15:24:11】此处引入额外参数会报错……引用上下文复杂
            end
        catch e # 打印堆栈
            Base.printstyled("ERROR: "; color=:red, bold=true)
            Base.showerror(stdout, e)
            Base.show_backtrace(stdout, Base.catch_backtrace())
            rethrow(e)
        end
    end |> esc # 在调用的上下文中解析
end

@info "共用测试环境搭建完成！"

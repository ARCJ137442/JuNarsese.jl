include("commons.jl") # 已在此中导入JuNarsese、Test

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
        recursive_assert(s1.ϕ1, s2.ϕ1)
        recursive_assert(s1.ϕ2, s2.ϕ2)
    end

end

"通用测试の宏"
macro equal_test(
    parser::Union{Symbol,Expr}, 
    test_set::Union{Symbol,Expr},
    )
    # quote里的`($parser)`已经自动把内部对象eval了
    quote
        # 词项 #
        # 二次转换
        local converted_terms = ($parser).(($test_set).terms)
        @info "converted_terms@$($parser):"
        join(converted_terms, "\n") |> println
        local reconverted_terms = ($parser).(converted_terms)
        @info "reconverted_terms@$($parser):"
        join(reconverted_terms, "\n") |> println
        # 比对相等
        for (reconv, origin) in zip(reconverted_terms, ($test_set).terms)
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
    end |> esc # 在调用的上下文中解析
end

@testset "Conversion" begin

    @testset "StringParser" begin
        # 原子词项
    
        @test "$w" == "词项"
        @test "$i" == "\$独立变量"
        @test "$d" == "#非独变量"
        @test "$q" == "?查询变量"
        @test "$o" == "^操作"
    
        # 像
        @test /(A, B, ⋄, C) |> StringParser_ascii == "(/, A, B, _, C)"
        @test \(A, w, ⋄, q) |> StringParser_ascii == "(\\, A, 词项, _, ?查询变量)"
        @test \(/(A, B, ⋄, C), w, ⋄, q) |> StringParser_ascii == "(\\, (/, A, B, _, C), 词项, _, ?查询变量)"
        
        # 测试@字符串
        @equal_test StringParser_ascii test_set
        
        # 测试@LaTeX
        @equal_test StringParser_latex test_set
        
        # 测试@漢
        @equal_test StringParser_han test_set

    end

    # @testset "ShortcutParser" begin # 这玩意儿只有解析器没有打包器
    #     @test s3 == (( q"A" * i"B" ) → o"C")
    # end

    @testset "ASTParser" begin
        @equal_test ASTParser test_set
    end
end

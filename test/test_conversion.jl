include("commons.jl") # 已在此中导入JuNarsese、Test

# 通用测试の宏
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
        for (t1, t2) in zip(reconverted_terms, ($test_set).terms)
            if t1 ≠ t2
                dump.(($parser).([t1, t2]); maxdepth=typemax(Int))
                @error "Not eq!" t1 t2
            end
            @test t1 == t2 # 📌【20230806 15:24:11】此处引入额外参数会报错……引用上下文复杂
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
        for (t1, t2) in zip(reconverted_sentences, ($test_set).sentences)
            if t1 ≠ t2
                dump.(($parser).([t1, t2]); maxdepth=typemax(Int))
                @error "Not eq!" t1 t2
            end
            @test t1 == t2 # 📌【20230806 15:24:11】此处引入额外参数会报错……引用上下文复杂
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

        # 陈述 #
    
        # 陈述↔字符串
        @show s0 = *(A,B,C) ⇔ w"op"o
        @test string(s0) == "<(*, A, B, C) <=> ^op>"
    
    end

    # @testset "ShortcutParser" begin # 这玩意儿只有解析器没有打包器
    #     @test s3 == (( w"A"q * w"B"i ) → w"C"o)
    # end

    @testset "ASTParser" begin
        @equal_test ASTParser test_set
    end
end

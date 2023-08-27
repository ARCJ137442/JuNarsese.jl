(@isdefined JuNarsese) || include("commons.jl") # 已在此中导入JuNarsese、Test

# 判等/比大小逻辑 #
@testset "methods/comparation" begin

    "用「词项+语句の词项」构造大测试集"
    all_terms = (
        (fetch_all_terms.(test_set.terms)...)..., 
        (fetch_all_terms.(JuNarsese.get_term.(test_set.sentences))...)...
    )
    @info "抽取到的词项：" all_terms

    # 性能测试：使用大于&小于的方式，是否等效于isequal的效果
    @info "判等性能测试：" (@elapsed [
        (t1 == t2) # 直接使用等号的方法
        for t1 in all_terms, t2 in all_terms
    ]) (@elapsed [
        !(s1<s2 || s2<s1) # 使用「不大于也不小于」的方法
        for s1 in all_terms, s2 in all_terms
    ])

    # 等价性测试：「不（大于或小于）」就是「等于」而非「大于或小于」
    for s1 in all_terms, s2 in all_terms
        @test (s1 == s2) ≠ (s1<s2 || s2<s1)
    end

    # 严格顺序测试：不存在「既大于又小于」的情况
    for s1 in all_terms, s2 in all_terms
        local fail::Bool = s1<s2 && s2<s1
        @test !fail
        if fail
            @info "既大于又小于！" s1 s2
            @assert !fail # 强制中断测试
        end
    end

end

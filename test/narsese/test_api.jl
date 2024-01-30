(@isdefined JuNarsese) || include("../test_commons.jl") # 已在此中导入JuNarsese、Test

# 词项接口：用于后续扩展自定义词项/语句/任务 #
@testset "Narsese/API" begin

    # 定义几个没实现方法的抽象类型，以便测试在「调用未实现方法的报错」 #
    struct TestTerm <: Term end
    struct TestTruth <: Truth end
    struct TestBudget <: Budget end
    struct TestStamp <: Stamp end

    t = TestTerm()
    tt = TestTruth()
    ts = TestStamp()
    tb = TestBudget()

    @test @expectedError get_syntactic_complexity(t)
    
    @test @expectedError get_f(tt) # 未定义
    @test @expectedError get_c(tt) # 未定义

    @test @expectedError get_p(tb)
    @test @expectedError get_d(tb)
    @test @expectedError get_q(tb)

    @test @expectedError get_evidential_base(ts)
    @test @expectedError get_creation_time(ts)
    @test @expectedError get_put_in_time(ts)
    @test @expectedError get_occurrence_time(ts)

    # 测试一些「抽象词项的默认值」 #
    @test !is_commutative(t) # 默认不可交换
    @test is_repeatable(t) # 默认可重复

end

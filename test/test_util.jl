if !(@isdefined JuNarsese)
    push!(LOAD_PATH, "../src") # 用于直接打开（..上一级目录）
    push!(LOAD_PATH, "src") # 用于VSCode调试（项目根目录起）

    # 自动导入JuNarsese模块
    using JuNarsese
end
        
# 测试Util库 #
using JuNarsese.Util
import JuNarsese.Util: @expectedError, check_tuple_equal, number_value_eq

(@isdefined Test) || using Test

@testset "Util" begin

    # 反转字典
    d = Dict{String,Integer}("a" => 1, "b" => 2, "c" => 3)
    @test Dict{Integer,String}(
        @reverse_dict_content d
    ) == Dict(1 => "a", 2 => "b", 3 => "c")

    # Pair的属性：first、second
    @test allproperties(1=>2) == (1, 2)
    @test allproperties_named(1=>2) == (first=1, second=2)

    # 空字符/空字串/空符号
    @test empty_content("string") == empty_content(String) == ""

    # 类名提纯检验
    @test replace("JuNarsese.Narsese.Terms.Word", Util.PURE_TYPE_NAME_REGEX) == get_pure_type_string(Word) == "Word"
    @test get_pure_type_string(w"word") == get_pure_type_string(JuNarsese.Narsese.Terms.Word) == "Word"
    @test get_pure_type_symbol(Word) == :Word
    @test verify_type_expr(:Word)
    @test verify_type_expr(:(TermImage{Extension}))
    @test !verify_type_expr(:(JuNarsese.Narsese.Terms.Word))
    @test assert_type_expr(:Word) == :Word
    @test assert_type_expr(:(TermImage{Extension})) == :(TermImage{Extension})
    @expectedError assert_type_expr(:(JuNarsese.Narsese.Terms.Word))

    # 随机选择宏
    i = @rand [
        1
        2
        3
    ]
    @test i in [1,2,3]

    @test (
        @generate_ifelseif(
            nothing,
            i==1 => 2,
            i==2 => 3,
            i==3 => 4,
        )
    ) == i+1

    # 判等
    @test check_tuple_equal(
        (w"A", 2),
        (w"A", 2);
        is_commutative = false,
    )
    @test check_tuple_equal(
        (w"A", 3.0, 2),
        (2, w"A", 3.0);
        is_commutative = true,
    )

    @test number_value_eq(2.1, 2.1)
    @test number_value_eq(Float16(2.1), Float16(2.1))
    @test !number_value_eq(Float16(2.1), 2.1) # "异类转换精度" 在`Narsese.jl`中实现，单用此方法时无效(转换成「共同默认精度」)
    @test !number_value_eq(2.1, 2.0)
    @test number_value_eq(2, 2.0)

end

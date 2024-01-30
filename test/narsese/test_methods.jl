(@isdefined JuNarsese) || include("../test_commons.jl") # 已在此中导入JuNarsese、Test

@testset "Narsese/methods" begin

    # NAL信息支持
    include("test_methods_nal.jl")
    # 合法性测试 #
    include("test_methods_validity.jl")
    # 词项与数组等可迭代对象的联动方法 #
    include("test_methods_arrays.jl")
    # 判等/比较 方法 #
    include("test_methods_comparation.jl")

end

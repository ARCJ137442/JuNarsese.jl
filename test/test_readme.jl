(@isdefined JuNarsese) || include("commons.jl") # 已在此中导入JuNarsese、Test

# 测试README中的实例
@testset "README" begin

    # 数据结构 #

    water = w"water" # water
    liquid = nse"liquid" # liquid
    water_is_liquid = nse"<water --> liquid>" # <water --> liquid>

    @test length(water_is_liquid) == 2 # true
    @test collect(water_is_liquid) == [water, liquid] # [water, liquid]
    @test water_is_liquid[1] == water # true
    @test ϕ2(water_is_liquid) == liquid # true
    @test Inheritance(water, liquid) == water_is_liquid # true
    @test (water → liquid) == water_is_liquid # true

    # 内置转换器 #

    water_is_liquid = nse"water"ascii → w"liquid" # <water --> liquid>

    # 字符串解析器
    @test water_is_liquid == narsese"\left<water\rightarrow liquid\right>"latex # true
    @test water_is_liquid == nse"「water是liquid」"han # true
    @test water_is_liquid == data2narsese(StringParser_han, Any, "「water是liquid」") # true
    @test water_is_liquid == StringParser_han("「water是liquid」") # true

    # AST解析器
    expr = ASTParser(water_is_liquid) # :($(Expr(:Inheritance, :($(Expr(:Word, :water))), :($(Expr(:Word, :liquid))))))
    @test expr == Expr(:Inheritance, Expr(:Word, :water), Expr(:Word, :liquid))
    @test ASTParser(expr) == water_is_liquid # true

    # 原生对象解析器
    dict = NativeParser_dict(water_is_liquid) # Dict{String, Vector{Dict{String, Vector{String}}}} with 1 entry: ...
    @test dict == Dict("Inheritance" => [Dict("Word"=>["water"]), Dict("Word"=>["liquid"])]) # true
    vector = NativeParser_vector(water_is_liquid) # 3-element Vector{Union{String, Vector}}: ...
    @test vector == ["Inheritance", ["Word", "water"], ["Word", "liquid"]] # true
    @test NativeParser_dict(dict) == NativeParser_vector(vector) # true

    # 快捷方式解析器
    @test water_is_liquid == ShortcutParser(raw""" w"water" → w"liquid" """) # true
    
end

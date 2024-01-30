(@isdefined JuNarsese) || include("test_commons.jl") # 已在此中导入JuNarsese、Test
#=
专注于JuNarsese的性能评估
=#

# 使用可视化的性能评估库`ProfileView`
using ProfileView # 参考：https://www.math.pku.edu.cn/teachers/lidf/docs/Julia/html/_book/perf.html#perf-prof

begin "番外：性能评估"

    @info "性能评估开始"

    # 避免与VSCode冲突
    ProfileView.@profview @equal_test StringParser_ascii test_set # 先前测试已触发编译

    readline() # 在直接执行时，防止异步操作提前退出（不会影响`Pkg.test`）

end

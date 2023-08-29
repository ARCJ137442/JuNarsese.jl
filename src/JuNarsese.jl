"""
JuNarsese 入口模块

更新时间: 20230724 9:56:04

模块层级总览
- JuNarsese
    - Narsese
        - Terms
        - Sentences
    - Conversion

规范：
- 大模块的附属代码，统一存放在其同名文件夹中
    - 细节分类&文件名规范
        - 首字母大写：独立的Module
        - 首字母小写：被include的代码
"""
module JuNarsese

using Reexport

# !测试用 #

@info "当前路径" pwd()

println("ls: ")
print_path(path) = begin
    # 不能进入文件
    isdir(path) || isdir("./$path") || return nothing
    # 尝试在不同平台进入文件夹
    try
        cd("./$path")
    catch _ 
        try
            cd(path)
        catch _
            @error "进入路径$(path)错误！"
            return nothing
        end
    end
    # 查询，打印
    paths = split(`ls` |> read |> String, "\n")
    try
        @info "path@$path"
        join(paths, "\n") |> println
    catch _ return nothing end
    for path in paths
        # 避免空路径
        isempty(path) || print_path(path)
    end
    cd("..")
end
print_path(pwd())

# 导入各个文件 #

# 不导出Util
include("Util/Util.jl")

include("Narsese/Narsese.jl")
include("Conversion/Conversion.jl")

@reexport using .Narsese
@reexport using .Conversion


# 初始化 #

"包初始化：从Project.toml中获取&打印包信息"
function __init__()
    project_file_content = read(
        joinpath(dirname(@__DIR__), "Project.toml"), # 获得文件路径
        String # 目标格式：字符串
    )
    # 使用正则匹配，这样就无需依赖TOML库
    name = match(r"name *= *\"(.*?)\"", project_file_content)[1]
    version = match(r"version *= *\"(.*?)\"", project_file_content)[1]
    # 打印信息（附带颜色）【20230714 22:25:42】现使用`printstyled`而非ANSI控制字符
    printstyled(
        "$name v$version\n", # 例：「JuNarsese v2.3.0」
        bold = true,
        color = :light_green
    )
end

end # module

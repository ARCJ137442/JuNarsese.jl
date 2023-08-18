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

# 配置类参数

DEFAULT_INT_PRECISION::Type{<:Signed} = Int
DEFAULT_UINT_PRECISION::Type{<:Unsigned} = UInt
DEFAULT_FLOAT_PRECISION::Type{<:AbstractFloat} = Float64

"按照「默认浮点精度」解析字符串(📝Julia这样定义函数不会形成闭包)"
parse_default_float(s) = Base.parse(DEFAULT_FLOAT_PRECISION, s)

"按照「默认有符号整型精度」解析字符串"
parse_default_int(s) = Base.parse(DEFAULT_INT_PRECISION, s)

"按照「默认无符号整型精度」解析字符串"
parse_default_uint(s) = Base.parse(DEFAULT_UINT_PRECISION, s)
export DEFAULT_FLOAT_PRECISION, DEFAULT_INT_PRECISION, DEFAULT_UINT_PRECISION
export parse_default_float, parse_default_int, parse_default_uint

# 导入各个文件 #

# 不导出Util
include("Util.jl")

include("Narsese.jl")
@reexport using .Narsese

include("Conversion.jl")
@reexport using .Conversion


# 初始化 #

"包初始化：从Project.toml中获取&打印包信息"
function __init__() # 【20230717 22:23:10】💭很仿Python
    project_file_content = read(
        joinpath(dirname(@__DIR__), "Project.toml"), # 获得文件路径
        String # 目标格式：字符串
    )
    # 使用正则匹配，这样就无需依赖TOML库
    name = match(r"name *= *\"(.*?)\"", project_file_content)[1]
    version = match(r"version *= *\"(.*?)\"", project_file_content)[1]
    # 打印信息（附带颜色）【20230714 22:25:42】现使用`printstyled`而非ANSI控制字符
    printstyled(
        "$name v$version\n", # 例：「JuNEI v0.2.0」
        bold = true,
        color = :light_green
    )
end

end # module

"""
提供基本的词项定义

架构总览
- 词项（抽象）
    - 原子（抽象）
        - 词语
        - 变量{类型}
        - 操作符
    - 复合（抽象）
        - 词项集（抽象）
            - 词项集
            - 词项逻辑集{逻辑操作}
            - 像
            - 乘积
        - 陈述（抽象）
            - 陈述{类型}
            - 陈述集（抽象）
                - 陈述逻辑集{逻辑操作}（抽象）
                    - 陈述逻辑集{逻辑操作}
                    - 陈述时序集{时序关系}

具体在Narsese的文本表示，参见string.jl

参考：
- OpenJunars 词项层级结构

情况：
- 📌现在不使用「deepcopy」对词项进行深拷贝：将「拷贝与否」交给调用者
- 【20230803 11:31:40】暂不将整个文件拆分为「Narsese1-8」的形式，而是以[NAL-X]的格式标注其来源
"""
module Terms

# 引入 #

# 时态 【20230804 14:20:50】因为「时序蕴含/等价」的存在，需要引入「时间参数」（参考自OpenNARS）
include("tense.jl")

# 结构
include("structs.jl")

# 别名
include("aliases.jl")

# 方法
include("methods.jl")

# 快捷构造方式
include("constructor_shortcuts.jl")

# 副系词
include("secondary_copulas.jl")

end # module

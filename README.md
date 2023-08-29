# JuNarsese

**简体中文** | [繁體中文](https://github.com/ARCJ137442/JuNarsese.jl/blob/main/README-zh_tr.md) | [English](https://github.com/ARCJ137442/JuNarsese.jl/blob/main/README-en.md)

[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)
[![Static Badge](https://img.shields.io/badge/julia-package?logo=julia&label=1.8%2B)](https://julialang.org/)

[![CI status](https://github.com/ARCJ137442/JuNarsese.jl/workflows/CI/badge.svg)](https://github.com/ARCJ137442/JuNarsese.jl/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/ARCJ137442/JuNarsese.jl/graph/badge.svg?token=PCQHEU15L0)](https://codecov.io/gh/ARCJ137442/JuNarsese.jl)

该项目使用[语义化版本 2.0.0](https://semver.org/)进行版本号管理。

[Narsese](#narsese)的[Julia](https://github.com/JuliaLang/julia)实现

- 为其它使用Narsese的库提供数据结构表征、存取、转换支持

## 概念

### Narsese

纳思语，NARS + "-ese"

NARS的知识表示语言

### ***CommonNarsese***

- 由[Narsese Grammar (IO Format)](https://github.com/opennars/opennars/wiki/Narsese-Grammar-(Input-Output-Format))定义，
- 在各类NARS(Narsese)实现中，
- 最先产生规范，并最为广泛接受的一种语法

与其它方言、超集的不同点举例：

- 原子词项：
  - 一律使用`$`、`#`、`?`、`^`区分「独立变量」「非独变量」「查询变量」「操作」
  - 一律使用单独的`_`表示「像占位符」
- 复合词项：
  - 一律使用特殊括弧`{词项...}`、`[词项...]`表示「外延集」「内涵集」
  - 一律使用「圆括号+前缀表达式」`(连接符, 词项...)`形式表示「非外延集、内涵集的复合词项」
    - 如`(&, <A --> B>, ^op)`
    - 对「否定」不使用前缀表达式
    - 对其它「二元复合词项」不使用中缀表达式
- 陈述：
  - 一律使用尖括号表示陈述，没有其他选项
    - 如`<A --> B>`
  - 不使用「回顾性等价」`<\>`系词
    - 一律用表义能力等同的「预测性等价」`</>`系词代替
    - 如`<A <\> B>`将表示为`<B </> A>`

## 代码地图

JuNarsese包含两个主要模块：

- Narsese: Narsese的数据结构
  - 词项(NAL-1 ~ NAL-8)
  - 语句(+标点、真值、时间戳)
  - 任务(+预算值)
- Conversion: 用于数据结构间的转换
  - 提供解析器API
    - 抽象解析器类型
    - 「基于类型的解析器」与「基于对象的解析器」
  - [自带解析器](#自带解析器)：实现上述数据结构与以下常用结构的相互转化
    - 字符串
    - AST（抽象语法树，对应Julia的`Expr`类型）
    - 原生（Julia的原生类型，包括`Dict`与`Vector`）

### 词项数据结构

可参见：

- `docs`中的「Narsese导图」
  - ⚠暂时只有简体中文版本
- 或参见源码`structs.jl`

### 自带解析器

JuNarsese自带的解析器有：

- **字符串解析器`StringParser`**
  - 支持类[CommonNarsese](#commonnarsese)语法的解析
  - 均在一定程度上支持Unicode字符
  - 可以使用字符串宏尾缀`narsese"待解析文本"FLAG`指定，以便从某种形式快速构造文本
    - 例：`nse"<A --> B>"ascii`意味着以ASCII解析器解析Narsese文本「<A --> B>」
    - 各类尾缀在下方以「子类型名称（尾缀）列出」
  - 共有三种子类型
    - ASCII（`ascii`）：忠于[CommonNarsese](#commonnarsese)语法，可解析基本ASCII字符串
    - LaTeX（`latex`）：支持LaTeX语法，可解析LaTeX字符串
    - 漢文（`han`）：支持简体中文风格的纯中文[CommonNarsese](#commonnarsese)语法
- **AST解析器`ASTParser`**
  - 使Narsese对象可与Julia原生的`Expr`对象相互转换
  - 其中只会包含：
    - 符号`Symbol`
    - 数值`Number`
    - 其它`Expr`
- **原生对象解析器`NativeParser`**
  - 使Narsese对象可与原生Julia对象相互转换
  - 其中只会包含：
    - 字符串`String`
    - 数组`Vector`
    - 字典`Dict`（在使用子类型「字典解析器」时）
  - 共两种子类型：
    - 字典解析器`NativeParser_dict`：以字典形式封装复合词项、陈述、语句和任务
    - 数组解析器`NativeParser_vector`：以数组形式封装复合词项、陈述、语句和任务
- **快捷构造解析器`ShortcutParser`**
  - 可以直接使用Julia代码构建词项
  - 只有解析，没有构造：暂不能通过`narsese2data`将Narsese对象转化为相应字符串
  - ⚠不推荐使用

## 安裝

作为一个**Julia包**，只需：

1. 在安装`Pkg`包管理器的情况下，
2. 在REPL(`julia.exe`)运行如下代码：

```julia
using Pkg
Pkg.add(url="https://github.com/ARCJ137442/JuNarsese.jl")
```

在REPL，通过按下 `]` 键，同样可以：

```REPL
(v1.8) pkg> add https://github.com/ARCJ137442/JuNarsese.jl
```

## 示例

### 数据结构

使用JuNarsese构建Narsese的数据结构（词项、语句、任务），只需使用`narsese"【CommonNarsese】"`或缩写`nse"【CommonNarsese】"`，此举会自动将字符串形式的[CommonNarsese](#commonnarsese)转换成相应的Narsese数据结构

- 对原子词项而言，亦可使用如下字符串宏：
  - `w"word"`：构造「词语」`word`
  - `i"ind_var"`：构造「独立变量」`$ind_var`
  - `d"i_var"`：构造「非独变量」`#d_var`
  - `q"q_var"`：构造「非独变量」`#q_var`
  - `n"123"`：构造「间隔」`+123`
  - `o"op"`：构造「操作符」`^op`
- 在构造复合词项/陈述时，亦可：
  - 使用JuNarsese导出的Unicode运算符，如用`w"S"→w"P"`生成「继承陈述」`<S --> P>`。
  - 直接调用数据结构的构造函数，例如用`Inheritance(S, P)`生成「继承陈述」`<S --> P>`。

```julia
using JuNarsese

water = w"water" # water
liquid = nse"liquid" # liquid
water_is_liquid = narsese"<water --> liquid>" # <water --> liquid>

length(water_is_liquid) == 2 # true
collect(water_is_liquid) # [water, liquid]
water_is_liquid[1] == water # true
ϕ2(water_is_liquid) == liquid # true
Inheritance(water, liquid) == water_is_liquid # true
(water → liquid) == water_is_liquid # true
```

### 解析器及其API

使用JuNarsese解析以其它形式呈现的Narsese对象，只需使用两个函数：

- `narsese2data`：从Narsese对象转换成其它类型数据
  - 参数：`narsese2data(解析器, Narsese对象)`
- `data2narsese`：从其它类型数据转换成Narsese对象
  - 参数：`data2narsese(解析器, 转换的目标类型, 其它类型数据)`
  - 其中「转换的目标类型」仅在「转换可能发生歧义」时使用
    - 不关注「目标类型」时可填`Any`，意为「兼容模式」（自动将输入识别成Narsese对象）
    - 当填写类型后，转换将只返回是「目标类型」的对象
      - 例如`Term`将只返回词项（非词项对象将报错）

或更简单地，直接调用解析器对象

- 如`解析器对象(待翻译对象/待转换Narsese对象)`

```julia
using JuNarsese
water_is_liquid = nse"water"ascii → w"liquid" # <water --> liquid>

# 字符串解析器
water_is_liquid == narsese"\left<water \rightarrow liquid\right>"latex # true
water_is_liquid == nse"「water是liquid」"han # true
water_is_liquid == data2narsese(StringParser_han, Any, "「water是liquid」") # true
water_is_liquid == StringParser_han("「water是liquid」") # true

# AST解析器
expr = ASTParser(water_is_liquid) # :($(Expr(:Inheritance, :($(Expr(:Word, :water))), :($(Expr(:Word, :liquid))))))
expr == Expr(:Inheritance, Expr(:Word, :water), Expr(:Word, :liquid))
ASTParser(expr) == water_is_liquid # true

# 原生对象解析器
dict = NativeParser_dict(water_is_liquid) # Dict{String, Vector{Dict{String, Vector{String}}}} with 1 entry: ...
dict == Dict("Inheritance" => [Dict("Word"=>["water"]), Dict("Word"=>["liquid"])]) # true
vector = NativeParser_vector(water_is_liquid) # 3-element Vector{Union{String, Vector}}: ...
vector == ["Inheritance", ["Word", "water"], ["Word", "liquid"]] # true
NativeParser_dict(dict) == NativeParser_vector(vector) # true

# 快捷方式解析器
water_is_liquid == ShortcutParser(raw""" w"water" → w"liquid" """) # true
```

有关解析器API的使用，可参见解析器扩展包[**JuNarseseParsers**](https://github.com/ARCJ137442/JuNarseseParsers.jl)的相关源码

## 作者注

1. 项目最初仅作个人学习研究，一些开发规范可能欠缺
2. 项目亦曾作为个人学习Julia的试验项目，代码内含大量注释与笔记
3. 因相关资料缺乏，其中的一些语法解析可能无法达到最好效果（例如LaTeX）
4. 截止至2023年8月，项目尚未应用在任何一个完整实现NARS的项目中（代码未来可能被重构）

## 未来展望

- 项目开发规范接入
- 数据结构性能优化
- 为Narsese模块提供可扩展API

## 参考

- [OpenJunars](https://github.com/AIxer/OpenJunars)
- [OpenNARS](https://github.com/opennars/opennars)
- [PyNARS](https://github.com/bowen-xu/PyNARS)

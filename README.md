# JuNarsese

**中文** | [English](https://github.com/ARCJ137442/JuNarsese.jl/blob/main/README_en.md)

[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)
[![Static Badge](https://img.shields.io/badge/julia-package?logo=julia&label=1.8%2B)](https://julialang.org/)

该项目使用[语义化版本 2.0.0](https://semver.org/)进行版本号管理。

Narsese(纳思语，NARS的知识表示语言)的[Julia](https://github.com/JuliaLang/julia)实现

- 为其它使用Narsese的库提供数据结构表征、存取、互转支持

## 概述

JuNarsese包含两个主要模块：

- Narsese: Narsese的数据结构
  - 词项(NAL-1 ~ NAL-8)
  - 语句(标点、真值、时间戳)
- Conversion: 用于数据结构间的转换
  - 提供解析器API
    - 抽象解析器类型
    - 「基于类型的解析器」与「基于对象的解析器」
  - 实现上述数据结构与以下常用结构的相互转化
    - 字符串
    - AST（抽象语法树，对应Julia的`Expr`类型）
    - 原生（Julia的原生类型，包括`Dict`与`Vector`）

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

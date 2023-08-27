# JuNarsese

[简体中文](https://github.com/ARCJ137442/JuNarsese.jl/blob/main/README.md) | **繁體中文** | [English](https://github.com/ARCJ137442/JuNarsese.jl/blob/main/README-en.md)

[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)
[![Static Badge](https://img.shields.io/badge/julia-package?logo=julia&label=1.8%2B)](https://julialang.org/)

[![CI status](https://github.com/ARCJ137442/JuNarseseParsers.jl/workflows/CI/badge.svg)](https://github.com/ARCJ137442/JuNarsese.jl/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/ARCJ137442/JuNarsese.jl/graph/badge.svg?token=PCQHEU15L0)](https://codecov.io/gh/ARCJ137442/JuNarsese.jl)

該項目使用[語意化版本 2.0.0](https://semver.org/)進行版號管理。

Narsese(納思語，NARS的知識表示語言)的[Julia](https://github.com/JuliaLang/julia)實現

- 為其它使用Narsese的庫提供數據結構表徵、存取、互轉支持

## 概述

JuNarsese包含兩個主要模塊：

- Narsese: Narsese的數據結構
  - 詞項(NAL-1 ~ NAL-8)
  - 語句(標點、真值、時間戳)
- Conversion: 用於數據結構間的轉換
  - 提供解析器API
    - 抽象解析器類型
    - 「基於類型的解析器」與「基於對象的解析器」
  - 實現上述數據結構與以下常用結構的相互轉化
    - 字符串
    - AST（抽象語法樹，對應Julia的`Expr`類型）
    - 原生（Julia的原生類型，包括`Dict`與`Vector`）

## 安裝

作爲一個**Julia包**，衹需：

1. 在安裝`Pkg`包管理器的情況下，
2. 在REPL(`julia.exe`)運行如下程式碼：

```julia
using Pkg
Pkg.add(url="https://github.com/ARCJ137442/JuNarsese.jl")
```

在REPL，通過按下 `]` 鍵，同樣可以：

```REPL
(v1.8) pkg> add https://github.com/ARCJ137442/JuNarsese.jl
```

## 作者注

1. 項目最初僅作個人學習研究，一些開發規範可能欠缺
2. 項目亦曾作爲個人學習Julia的試驗項目，程式碼內含大量注釋與筆記
3. 因相關文檔缺乏，其中的一些語法解析可能無法達到最好效果（例如LaTeX）
4. 截止至2023年8月，項目尚未應用在任何一個完整實現NARS的項目中（程式碼未來可能被重構）

## 未來展望

- 項目開發規範接入
- 數據結構性能優化
- 為Narsese模塊提供可擴展API

## 參考

- [OpenJunars](https://github.com/AIxer/OpenJunars)
- [OpenNARS](https://github.com/opennars/opennars)
- [PyNARS](https://github.com/bowen-xu/PyNARS)

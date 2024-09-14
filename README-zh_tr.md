# JuNarsese

|[简体中文](README.md) | **繁體中文** | [English](README-en.md)|
|:---:|:---:|:---:|

![GitHub License](https://img.shields.io/github/license/ARCJ137442/JuNarsese.jl?style=for-the-badge&color=a270ba)
![Code Size](https://img.shields.io/github/languages/code-size/ARCJ137442/JuNarsese.jl?style=for-the-badge&color=a270ba)
![Lines of Code](https://www.aschey.tech/tokei/github.com/ARCJ137442/JuNarsese.jl?style=for-the-badge&color=a270ba)
[![Language](https://img.shields.io/badge/language-Julia%201.8+-purple?style=for-the-badge&color=a270ba)](https://cn.julialang.org/)

開發狀態：

[![CI status](https://img.shields.io/github/actions/workflow/status/ARCJ137442/JuNarsese.jl/ci.yml?style=for-the-badge)](https://github.com/ARCJ137442/JuNarsese.jl/actions/workflows/ci.yml)
[![Codecov](https://img.shields.io/codecov/c/github/ARCJ137442/JuNarsese.jl?style=for-the-badge)](https://codecov.io/gh/ARCJ137442/JuNarsese.jl)

![Created At](https://img.shields.io/github/created-at/ARCJ137442/JuNarsese.jl?style=for-the-badge)
![Last Commit](https://img.shields.io/github/last-commit/ARCJ137442/JuNarsese.jl?style=for-the-badge)

[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?style=for-the-badge)](https://conventionalcommits.org)
![GitHub commits since latest release](https://img.shields.io/github/commits-since/ARCJ137442/JuNarsese.jl/latest?style=for-the-badge)

## 簡介

[Narsese](#narsese) 的 [Julia](https://github.com/JuliaLang/julia) 實現

- 為其它使用 Narsese 的庫提供數據結構表徵、存取、轉換支持

## 概念

### Narsese

納思語，NARS + "-ese"

NARS 的知識表示語言

### ***CommonNarsese***

- 由[Narsese Grammar (IO Format)](https://github.com/opennars/opennars/wiki/Narsese-Grammar-(Input-Output-Format))定義，
- 在各類NARS(Narsese)實現中，最先產生規範，且最廣爲接受的一種語法
- 基本是各路NARS實現之Narsese語法的**交集**

與其它方言、超集的不同點舉例：

#### Atom 原子詞項

- 一律使用`$`、`#`、`?`、`^`區分「獨立變量」「非獨變量」「查詢變量」「操作」
- 一律使用單獨的`_`表示「像佔位符」
- 一律不在名稱中包含特殊符號
  - 如`^goto`（不允許`^go-to`）

#### Compound 複合詞項

- 一律使用特殊括弧`{詞項...}`、`[詞項...]`表示「外延集」「內涵集」
- 一律使用「圓括號+前綴表達式」`(連接符, 詞項...)`形式表示「非外延集、內涵集的複合詞項」
  - 如`(&, <A --> B>, ^op)`
  - 對「否定」不使用前綴表達式
  - 對其它「二元複合詞項」不使用中綴表達式

#### Statement 陳述

- 一律使用尖括號表示陳述，沒有其他選項
  - 如`<A --> B>`
- 不使用「回顧性等價」`<\>`繫詞
  - 一律用表義能力等同的「預測性等價」`</>`繫詞代替
  - 如`<A <\> B>`將表示爲`<B </> A>`

#### Sentence 語句

- 「真值缺省」：解析語句時，允許不輸入一部分真值
  - 此類真值將在輸入具體NARS實現時被補全
    - 如：OpenNARS的「默認真值」`%1.0; 0.9%`
    - 如：OpenJunars的「默認真值」`%1.0; 0.5%`
  - 具體形式
    - 單缺省（單真值）：f已指定，缺c值
      - 如`A. %1.0%`
    - 全缺省（空真值）：f、c均未指定
      - 如`A.`

## 代碼地圖

JuNarsese 包含兩個主要模塊:

- Narsese: Narsese 的數據結構
  - 詞項(NAL-1 ~ NAL-8)
  - 語句(+標點、真值、時間戳)
  - 任務(+預算值)
- Conversion: 用於數據結構間的轉換
  - 提供解析器 API
    - 抽象解析器類型
    - 「基於類型的解析器」與「基於對象的解析器」
  - [自帶解析器](#自帶解析器):實現上述數據結構與以下常用結構的相互轉化
    - 字符串
    - AST(抽象語法樹，對應 Julia 的 `Expr` 類型)
    - 原生(Julia 的原生類型，包括 `Dict` 與 `Vector`)

### 詞項數據結構

可參見:

- `docs`中的「Narsese導圖」
  - ⚠暫時只有簡體中文版本
- 或參見源碼 `structs.jl`

### 自帶解析器

JuNarsese 自帶的解析器有:

- **字符串解析器 `StringParser`**
  - 支持類 [CommonNarsese](#commonnarsese) 語法的解析
  - 均在一定程度上支持 Unicode 字符
  - 可以使用字符串宏尾缀 `narsese"待解析文本"FLAG` 指定，以便從某種形式快速構造文本
    - 例:`nse"<A --> B>"ascii` 意味著以 ASCII 解析器解析 Narsese 文本「<A --> B>」
    - 各類尾缀在下方以「子類型名稱(尾缀)列出」
  - 共有三種子類型
    - ASCII(`ascii`):忠於 [CommonNarsese](#commonnarsese) 語法，可解析基本 ASCII 字符串
    - LaTeX(`latex`):支持 LaTeX 語法，可解析 LaTeX 字符串
    - 漢文(`han`):支持簡體中文風格的純中文 [CommonNarsese](#commonnarsese) 語法
- **AST 解析器 `ASTParser`**
  - 使 Narsese 對象可與 Julia 原生的 `Expr` 對象相互轉換
  - 其中只會包含:
    - 符號 `Symbol`
    - 數值 `Number`
    - 其它 `Expr`
- **原生對象解析器 `NativeParser`**
  - 使 Narsese 對象可與原生 Julia 對象相互轉換
  - 其中只會包含:
    - 字符串 `String`
    - 數組 `Vector`
    - 字典 `Dict`(在使用子類型「字典解析器」時)
  - 共兩種子類型:
    - 字典解析器 `NativeParser_dict`:以字典形式封裝複合詞項、陳述、語句和任務
    - 數組解析器 `NativeParser_vector`:以數組形式封裝複合詞項、陳述、語句和任務
- **快捷構造解析器 `ShortcutParser`**
  - 可以直接使用 Julia 代碼構建詞項
  - 只有解析，沒有構造:暫不能通過 `narsese2data` 將 Narsese 對象轉化為相應字符串
  - ⚠不推薦使用

## 安裝

作為一個 **Julia 包**，只需:

1. 在安裝 `Pkg` 包管理器的情況下，
2. 在 REPL(`julia.exe`) 運行如下代碼:

```julia
using Pkg
Pkg.add(url="https://github.com/ARCJ137442/JuNarsese.jl")
```

在 REPL，通過按下 `]` 鍵，同樣可以:

```REPL
(v1.8) pkg> add https://github.com/ARCJ137442/JuNarsese.jl
```

## 示例

### 數據結構

使用 JuNarsese 構建 Narsese 的數據結構(詞項、語句、任務)，只需使用 `narsese"【CommonNarsese】"` 或縮寫 `nse"【CommonNarsese】"`，此舉會自動將字符串形式的 [CommonNarsese](#commonnarsese) 轉換成相應的 Narsese 數據結構

- 對原子詞項而言，亦可使用如下字符串宏:
  - `w"word"`:構造「詞語」`word`
  - `i"ind_var"`:構造「獨立變量」`$ind_var`
  - `d"i_var"`:構造「非獨變量」`#d_var`
  - `q"q_var"`:構造「查詢變量」`?q_var`
  - `n"123"`:構造「間隔」`+123`
  - `o"op"`:構造「操作符」`^op`
- 在構造複合詞項/陳述時，亦可:
  - 使用 JuNarsese 導出的 Unicode 運算符，如用 `w"S"→w"P"` 生成「繼承陳述」`<S --> P>`。
  - 直接調用數據結構的構造函數，例如用 `Inheritance(S, P)` 生成「繼承陳述」`<S --> P>`。

```julia
using JuNarsese

water = w"water" # water
liquid = nse"liquid" # liquid
water_is_liquid = narsese"<water --> liquid>" # <water --> liquid>

length(water_is_liquid) == 2 # true
collect(water_is_liquid) # [water, liquid]
water_is_liquid[1] == water # true
φ2(water_is_liquid) == liquid # true
Inheritance(water, liquid) == water_is_liquid # true
(water → liquid) == water_is_liquid # true
```

### 解析器及其 API

使用 JuNarsese 解析以其它形式呈現的 Narsese 對象，只需使用兩個函數:

- `narsese2data`:從 Narsese 對象轉換成其它類型數據
  - 參數:`narsese2data(解析器, Narsese 對象)`
- `data2narsese`:從其它類型數據轉換成 Narsese 對象
  - 參數:`data2narsese(解析器, 轉換的目標類型, 其它類型數據)`
  - 其中「轉換的目標類型」僅在「轉換可能發生歧義」時使用
    - 不關注「目標類型」時可填 `Any`，意為「兼容模式」(自動將輸入識別成 Narsese 對象)
    - 當填寫類型後，轉換將只返回是「目標類型」的對象
      - 例如 `Term` 將只返回詞項(非詞項對象將報錯)

或更簡單地，直接調用解析器對象

- 如 `解析器對象(待翻譯對象/待轉換 Narsese 對象)`

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

# 原生對象解析器
dict = NativeParser_dict(water_is_liquid) # Dict{String, Vector{Dict{String, Vector{String}}}} with 1 entry: ...
dict == Dict("Inheritance" => [Dict("Word"=>["water"]), Dict("Word"=>["liquid"])]) # true
vector = NativeParser_vector(water_is_liquid) # 3-element Vector{Union{String, Vector}}: ...
vector == ["Inheritance", ["Word", "water"], ["Word", "liquid"]] # true
NativeParser_dict(dict) == NativeParser_vector(vector) # true

# 快捷方式解析器
water_is_liquid == ShortcutParser(raw""" w"water" → w"liquid" """) # true
```

有關解析器 API 的使用，可參見解析器擴展包 [**JuNarseseParsers**](https://github.com/ARCJ137442/JuNarseseParsers.jl) 的相關源碼

## 作者註

1. 專案最初僅作個人學習研究，一些開發規範可能欠缺
2. 專案亦曾作為個人學習 Julia 的試驗專案，代碼內含大量註釋與筆記
3. 因相關資料缺乏，其中的一些語法解析可能無法達到最好效果(例如 LaTeX)
4. 截止至 2023 年 8 月，專案尚未應用在任何一個完整實現 NARS 的專案中(代碼未來可能被重構)

## 未來展望

- 專案開發規範接入
- 數據結構性能優化
- 為 Narsese 模塊提供可擴展 API

## 參考

- [OpenJunars](https://github.com/AIxer/OpenJunars)
- [OpenNARS](https://github.com/opennars/opennars)
- [PyNARS](https://github.com/bowen-xu/PyNARS)

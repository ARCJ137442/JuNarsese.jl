# JuNarsese

|[简体中文](README.md) | [繁體中文](README-zh_tr.md) | **English**|
|:---:|:---:|:---:|

![GitHub License](https://img.shields.io/github/license/ARCJ137442/JuNarsese.jl?style=for-the-badge&color=a270ba)
![Code Size](https://img.shields.io/github/languages/code-size/ARCJ137442/JuNarsese.jl?style=for-the-badge&color=a270ba)
![Lines of Code](https://www.aschey.tech/tokei/github.com/ARCJ137442/JuNarsese.jl?style=for-the-badge&color=a270ba)
[![Language](https://img.shields.io/badge/language-Julia%201.8+-purple?style=for-the-badge&color=a270ba)](https://julialang.org/)

Development Status:

[![CI status](https://img.shields.io/github/actions/workflow/status/ARCJ137442/JuNarsese.jl/ci.yml?style=for-the-badge)](https://github.com/ARCJ137442/JuNarsese.jl/actions/workflows/ci.yml)
[![Codecov](https://img.shields.io/codecov/c/github/ARCJ137442/JuNarsese.jl?style=for-the-badge)](https://codecov.io/gh/ARCJ137442/JuNarsese.jl)

![Created At](https://img.shields.io/github/created-at/ARCJ137442/JuNarsese.jl?style=for-the-badge)
![Last Commit](https://img.shields.io/github/last-commit/ARCJ137442/JuNarsese.jl?style=for-the-badge)

[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?style=for-the-badge)](https://conventionalcommits.org)
![GitHub commits since latest release](https://img.shields.io/github/commits-since/ARCJ137442/JuNarsese.jl/latest?style=for-the-badge)

## Introduction

Julia implementation of [Narsese](#narsese).

- Provides data structure representation, access, and conversion support for other libraries using Narsese

## Concepts

### Narsese

Narsese, NARS + "-ese"

Knowledge representation language of NARS

### ***CommonNarsese***

- Defined by [Narsese Grammar (IO Format)](https://github.com/opennars/opennars/wiki/Narsese-Grammar-(Input-Output-Format))
- Among the various NARS(Narsese) implementations, the first to produce specifications and the most widely accepted syntax
- is basically an intersection of the Narsese syntax of the various NARS implementations

Differences from other dialects and supersets:

#### Atomic term

- Consistently use `$`, `#`, `?`, `^` to distinguish "independent variable", "dependent variable", "query variable", "operator"
- Consistently use separate `_` to represent "placeholders"

#### Compound term

- Consistently use special brackets `{terms...}` and `[terms...]` to represent "extension set" and "intension set"
- Consistently use "(connector, term...)" to represent "non-extension and intension compound terms"
  - e.g. `(&, <A --> B>, ^op)`
  - Do not use prefix expression for "negation" (such as `--<A --> B>`)
  - Do not use infix expression for other "binary compound terms" (such as `(A*B)`)

#### Statement

- Consistently use angle brackets to represent propositions, no other options
  - e.g. `<A --> B>`
- Not use retrospective equivalence "<\\>"
  - Consistently use predictive equivalence "</>" with equivalent representational capability instead
  - e.g. `<A <\> B>` will be expressed as `<B </> A>`

#### Sentence

- Truth default: No part of the truth value can be entered during statement parsing
  - Such truth values will be completed when entering a specific NARS implementation
    - e.g. OpenNARS 'Default truth' `%1.0; 0.9%`
      - e.g. OpenJunars 'Default truth' `%1.0; 0.5%`
  - Specific form
    - Single default (single truth value) : f is specified, and c is missing
      - Such as `A. %1.0%`
    - Full default (null true value) : neither f nor c is specified
      - Such as `A`

## Code Map

JuNarsese contains two main modules:

- Narsese: Narsese data structures
  - Terms (NAL-1 ~ NAL-8)
  - Statements (+ punctuation, truth value, timestamp)
  - Tasks (+ budget value)
- Conversion: For data structure interconversion
  - Provide parser APIs
    - Abstract parser types
    - "Type-based parsers" and "object-based parsers"
  - [Built-in parsers](#built-in-parsers): Implement mutual conversion between the above data structures and the following common structures
    - String
    - AST (abstract syntax tree, corresponding to Julia's `Expr` type)
    - Native (Julia's native types, including `Dict` and `Vector`)

### Term Data Structures

See:

- `docs` "Narsese Maps"
  - ⚠ Only Simplified Chinese version is available for now
- Or check `structs.jl` in source code

### Built-in Parsers

JuNarsese's built-in parsers include:

- **String parser `StringParser`**
  - Supports [CommonNarsese](#commonnarsese) syntax parsing
  - Support Unicode characters to some extent
  - Can be specified using string macros to quickly construct texts from some forms
    - e.g. `nse"<A --> B>"ascii` means parsing Narsese text "<A --> B>" with ASCII parser
    - Various suffixes listed below as "subtype name (suffix)"
  - Has three subtypes
    - ASCII (`ascii`): Loyal to [CommonNarsese](#commonnarsese) syntax, can parse basic ASCII strings
    - LaTeX (`latex`): Supports LaTeX syntax, can parse LaTeX strings
    - 漢文 (`han`): Supports pure Chinese [CommonNarsese](#commonnarsese) syntax in Simplified Chinese style
- **AST parser `ASTParser`**
  - Enable mutual conversion between Narsese objects and native Julia `Expr` objects
  - Only contains:
    - `Symbol`
    - `Number`
    - Other `Expr`
- **Native object parser `NativeParser`**
  - Enable mutual conversion between Narsese objects and native Julia objects
  - Only contains:
    - `String`
    - `Vector`
    - `Dict` (when using subtype "dict parser")
  - Has two subtypes:
    - Dict parser `NativeParser_dict`: Encapsulates compound terms, propositions, statements and tasks in dictionary form
    - Vector parser `NativeParser_vector`: Encapsulates compound terms, propositions, statements and tasks in array form
- **Shortcut constructor parser `ShortcutParser`**
  - Can directly construct terms using Julia code
  - Only has parsing, no construction: Cannot convert Narsese objects to corresponding strings via `narsese2data`
  - ⚠ Not recommended

## Installation

As a **Julia package**, simply:

1. When `Pkg` package manager is installed,
2. Run the following code in REPL (`julia.exe`):

```julia
using Pkg
Pkg.add(url="https://github.com/ARCJ137442/JuNarsese.jl") 
```

In REPL, you can also press `]` to:

```REPL
(v1.8) pkg> add https://github.com/ARCJ137442/JuNarsese.jl
```

## Examples

### Data Structures

To construct Narsese data structures (terms, statements, tasks) using JuNarsese, simply use `narsese"【CommonNarsese】"` or abbreviation `nse"【CommonNarsese】"` to automatically convert string [CommonNarsese](#commonnarsese) to corresponding Narsese data structures

- For atomic terms, string macros can also be used:
  - `w"word"`: Construct "word" `word`
  - `i"ind_var"`: Construct "independent variable" `$ind_var`
  - `d"i_var"`: Construct "dependent variable" `#d_var`
  - `q"q_var"`: Construct "query variable" `?q_var`
  - `n"123"`: Construct "interval" `+123`
  - `o"op"`: Construct "operator" `^op`
- When constructing compound terms/propositions, you can also:
  - Use Unicode operators exported by JuNarsese, e.g. use `w"S"→w"P"` to generate inheritance proposition `<S --> P>`
  - Directly call constructor functions of data structures, e.g. use `Inheritance(S, P)` to generate inheritance proposition `<S --> P>`

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

### Parsers and APIs

To parse Narsese objects presented in other forms using JuNarsese, simply use two functions:

- `narsese2data`: Convert Narsese object to other data types
  - Params: `narsese2data(parser, Narsese object)`
- `data2narsese`: Convert other data types to Narsese object
  - Params: `data2narsese(parser, target type, other data type)`
  - Where "target type" is only used when "conversion ambiguity may occur"
    - Can be `Any` when ignoring "target type", meaning "compatibility mode" (automatically identify input as Narsese object)
    - When type is specified, conversion will only return object that is the "target type"
      - e.g. `Term` will only return terms (non-term objects will error)

Or more simply, directly call parser object

- e.g. `parser object(object to translate / Narsese object to convert)`

```julia
using JuNarsese
water_is_liquid = nse"water"ascii → w"liquid" # <water --> liquid>

# String parser
water_is_liquid == narsese"\left<water \rightarrow liquid\right>"latex # true 
water_is_liquid == nse"「water是liquid」"han # true
water_is_liquid == data2narsese(StringParser_han, Any, "「water是liquid」") # true
water_is_liquid == StringParser_han("「water是liquid」") # true

# AST parser 
expr = ASTParser(water_is_liquid) # :($(Expr(:Inheritance, :($(Expr(:Word, :water))), :($(Expr(:Word, :liquid))))))
expr == Expr(:Inheritance, Expr(:Word, :water), Expr(:Word, :liquid))
ASTParser(expr) == water_is_liquid # true

# Native object parser
dict = NativeParser_dict(water_is_liquid) # Dict{String, Vector{Dict{String, Vector{String}}}} with 1 entry: ...
dict == Dict("Inheritance" => [Dict("Word"=>["water"]), Dict("Word"=>["liquid"])]) # true
vector = NativeParser_vector(water_is_liquid) # 3-element Vector{Union{String, Vector}}: ... 
vector == ["Inheritance", ["Word", "water"], ["Word", "liquid"]] # true
NativeParser_dict(dict) == NativeParser_vector(vector) # true

# Shortcut constructor parser
water_is_liquid == ShortcutParser(raw""" w"water" → w"liquid" """) # true
```

For parser API usage, please refer to related source code of parser extension package [**JuNarseseParsers**](https://github.com/ARCJ137442/JuNarseseParsers.jl)

## Author's Note

1. The project was initially for personal research only, some conventions may be lacking
2. The project was also an experiment for learning Julia, code contains lots of comments and notes
3. Due to lack of resources, some syntax parsing may not achieve the best results (e.g. LaTeX)
4. As of Aug 2023, the project has not been applied to any complete NARS implementation projects (code may be refactored in the future)

## Future Plans

- Adopt project development conventions
- Optimize data structure performance
- Provide extensible APIs for Narsese module

## References

- [OpenJunars](https://github.com/AIxer/OpenJunars)
- [OpenNARS](https://github.com/opennars/opennars)
- [PyNARS](https://github.com/bowen-xu/PyNARS)

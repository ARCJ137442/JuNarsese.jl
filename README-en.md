# JuNarsese

[简体中文](https://github.com/ARCJ137442/JuNarsese.jl/blob/main/README.md) | [繁體中文](https://github.com/ARCJ137442/JuNarsese.jl/blob/main/README-zh_tr.md) | **English**

[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)
[![Static Badge](https://img.shields.io/badge/julia-package?logo=julia&label=1.8%2B)](https://julialang.org/)

This project uses [Semantic Versioning 2.0.0](https://semver.org/) for version management.

A [Julia](https://github.com/JuliaLang/julia) implementation of Narsese (the knowledge representation language of NARS)

- Provides data structure representation, access, and conversion support for other libraries that use Narsese

## Overview

JuNarsese contains two main modules:

- **Narsese**: Data structures of Narsese
  - Terms (NAL-1 ~ NAL-8)
  - Statements (punctuation, truth value, timestamp)
- **Conversion**: For converting between data structures
  - Provides parser API
    - Abstract parser type
    - "Type-based parser" and "object-based parser"
  - Implements the conversion between the above data structures and the following common structures
    - String
    - AST (abstract syntax tree, corresponding to Julia type `Expr`)
    - Native (native julia types including `Dict` and `Vector`)

## Installation

As a **Julia package**, you only need to:

1. With the `Pkg` package manager installed,
2. Run the following code in REPL (`julia.exe`):

```julia
using Pkg
Pkg.add(url="https://github.com/ARCJ137442/JuNarsese.jl")
```

In REPL, by press key `]`, you also can:

```REPL
(v1.8) pkg> add https://github.com/ARCJ137442/JuNarsese.jl
```

## Author's note

1. The project was initially for personal learning and research, some development standards may be lacking
2. The project was also used as a personal experiment project for learning Julia, the code contains a lot of comments and notes
3. Due to the lack of relevant information, some of the syntax parsing may not achieve the best results (such as LaTeX)
4. As of August 2023, the project has not been applied to any complete project that implements NARS (the code may be refactored in the future)

## Future outlook

- Project development standards integration
- Data structure performance optimization
- Provide extensible API for Narsese module

## References

- [OpenJunars](https://github.com/AIxer/OpenJunars)
- [OpenNARS](https://github.com/opennars/opennars)
- [PyNARS](https://github.com/bowen-xu/PyNARS)

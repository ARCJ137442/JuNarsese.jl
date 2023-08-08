# JuNarsese

Narsese(纳思语，NARS的知识表示语言)的Julia实现

- 为其它使用Narsese的库提供数据结构表征、存取、互转支持

## 概述

JuNarsese计划包含：

- Narsese: Narsese的数据结构
  - 词项(NAL-1 ~ NAL-8)
- Conversion: 用于数据结构间的转换
  - 提供解析器API
    - 抽象解析器类型
    - 「基于类型的解析器」与「基于对象的解析器」
  - 实现上述数据结构与以下常用结构的相互转化
    - 字符串
    - AST(抽象语法树)

## 作者注

暂仅作个人学习研究

## 参考

- [OpenJunars](https://github.com/AIxer/OpenJunars)
- [OpenNARS](https://github.com/opennars/opennars)

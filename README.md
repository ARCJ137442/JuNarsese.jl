# JuNarsese

Narsese(纳思语，NARS的知识表示语言)的Julia实现

- 为其它使用Narsese的库提供数据结构表征、存取、互转支持

## 概述

JuNarsese包含两个主要模块：

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

1. 项目最初仅作个人学习研究，一些开发规范可能欠缺
2. 项目亦曾作为个人学习Julia的试验项目，代码内含大量注释与笔记
3. 因相关资料缺乏，其中的一些语法解析可能无法达到最好效果（例如LaTeX）
4. 截止至2023年8月，项目尚未应用在任何一个完整实现NARS的项目中（代码未来可能被重构）

## 未来展望

- 基于JuNarsese实现NAL推理规则的表征
- 使用EBNF文法重写解析模块
- 为Narsese模块提供可扩展API
- 应用于其它个人项目

## 参考

- [OpenJunars](https://github.com/AIxer/OpenJunars)
- [OpenNARS](https://github.com/opennars/opennars)

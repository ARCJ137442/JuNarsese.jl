#= 📝Julia: 不存在一个万用的「任意对象⇒Expr」的函数

    <!--反例：构造使用@expr宏，尝试把其中的量转化为AST-->
    代码：
        ```julia
        macro expr(ex)
            :($(Expr(:quote, ex)))
        end
        ```
    期望：
        1. (@expr [1,2,3])::Expr == :([1,2,3])
        2. (@expr (1,2,3))::Expr == :((1,2,3))
        3. s = [1,2,3]; (@expr s)::Expr == :([1,2,3])
                     || (@expr $s)::Expr == :([1,2,3])
    实际：
        1.✅
        2.✅
        3. (@expr s) == :s（不能替换为指定元素）
         | TypeError: in typeassert, expected Expr, got a value of type Vector{Int64}
    结论：
        Expr总是需要针对特定对象转换
=#
# 导出 #

export ASTParser

"""
提供基于抽象语法树(AST)的处理方法
- 一个Expr对应一个词项/语句
- 核心原理：化繁为简
    - 把复杂类型（结构）化作简单类型（原生）
- 📄解析后Expr内只有：
    - 原生类型（下文有提及）
        - Symbol(仅用作头、类名)
            - 保留特征头@保留类型
            - 类名@结构类型|头@保留类型（充当Expr的头）
        - String
        - Number
    - 其它Expr

打包/解析时的三大类：
- 结构类型⇒Expr(:类名, 构造函数の参数...)：
    - ⚠默认值：打包时遇到「自定义类型」，则会作为「结构类型」打包
    - 处理方法：被解析为「类名(构造函数の参数...)」
    - 例：
        - 目标类型：最终提供打包/解析服务的类型
            - 词项 [各自的打包方法]
            - 语句 [各自的打包方法]
        - 其它以构造函数形式打包的类型(用各自的打包方法实现)
            - 字典 :Dict Expr(:Pair, 键值对...)...
            - 集合 :Set Expr(保留特征头, :vect, 集合元素...)...
- 原生类型⇒自身：
    - 处理方法：打包/解析时不经过额外处理
        - 识别@打包：分派「被打包对象」的类型（::原生类型）
        - 识别@解析：分派「被解析对象」的类型（<:原生类型）
    - 例：
        - String 字符串
        - Number 数值
- 保留类型⇒Expr(保留特征头, :表达式头, 表达式参数...)：
    - 概念「保留特征头::Symbol」：用于标记「Expr是否转义了保留类型」
        - Expr(表达式头, 表达式参数...) ==(转义)=> Expr(保留特征头, 表达式头, 表达式参数...)
    - 处理方法：去头得到「原表达式」，递归解析完args后直接eval
    - 例：
        - 数组 :vect
        - 元组 :tuple

打包/解析的核心逻辑：
0. 封装性：`data2narsese`/`narsese2data`只暴露关于「目标类型」的打包/解析功能
    - 在`data2narsese`/`narsese2data`中调用「内部解析函数」
    - ⚠除非是其它类型解析器与之对接，否则不应调用`data2narsese`/`narsese2data`
1. 解析的逻辑尽可能简单：
    - 参数集：解析器，被解析表达式，eval函数，递归回调函数
        - 解析器：用于实现「基于解析器的语法多态」
        - eval函数：指定表达式寻址时的上下文
            - 协议：`(::Expr) -> (::Any)`
            - 默认值：`JuNarsese.Narsese.eval`
                - 用于识别各类Narsese类型
        - 递归回调函数：控制「递归解析」的逻辑
            - 协议：`递归回调(递归回调解析器, 被解析表达式)`
                - 对需要「递归回调函数」作第四参数的函数：采用「默认值」重载
            - 默认值：解析函数自身
            - 控制の例：
                - `pack_identity(_, 对象, _)`：返回对象自身（只解析一层）
                - 解析函数自身：递归解析成Expr
                - 外部解析函数：预先解析成外部格式，可能再交给「外部解析函数」处理
        - 递归回调解析器：用于「递归回调函数」中出现的解析器
            - 默认值：解析器自身
            - 避免回调后「鸠占鹊巢」的情况发生（回调后解析器不再是原来的解析器）
            - 避免额外构造「回调函数」的开销
    - 逻辑@结构类型：`expr.head` ≠ 保留特征头
        1. 头 ⇒ 类型（构造函数表达式）
            - 📌在Julia中，类型⇔构造函数函数名
            - 在「eval函数」中解析
                - `头::String` |> parse_type
        3. 预解析参数：调用「递归回调函数」解析`expr.args`
            - 解析结果作为构造函数的参数
        4. 调用构造函数：`构造函数(参数...)`
    - 逻辑@原生类型：直接返回自身
    - 逻辑@保留类型：`expr.head` == 保留特征头
        1. 去头，还原为Expr
            1. expr.args[1] ⇒ 原Expr头
            2. expr.args[2:end] ⇒ 原Expr参数
        2. 预解析参数：调用「递归回调函数」解析「原Expr参数」
            - 避免`eval`无法解析`Expr(:类名, Vararg{Expr}...)`
        3. 一次性eval（此时args都已为Julia对象）
            - `表达式` |> eval_function
2. 复杂度体现在打包上：
    1. 参数集：解析器，被打包对象，递归回调函数
        - 解析器：用于实现「基于解析器的语法多态」
        - 被打包对象：最终被打包成Expr
        - 递归回调函数：控制「递归打包」的逻辑
            - 协议：`递归回调(递归回调解析器, 被打包对象)`
                - 对需要「递归回调函数」作第三参数的函数：采用「默认值」重载
            - 默认值：打包函数自身
            - 控制の例：
                - `pack_identity(_, 对象, _)`：返回对象自身（只打包一层）
                - 打包函数自身：递归打包成Expr
                - 外部打包函数：预先打包成外部格式，可能再交给「外部打包函数」处理
        - 递归回调解析器：用于「递归回调函数」中出现的解析器
            - 默认值：解析器自身
            - 避免回调后「鸠占鹊巢」的情况发生（回调后解析器不再是原来的解析器）
            - 避免额外构造「回调函数」的开销
    2. 原理：
        - 需要「特殊优化」的对象：特别生成Expr，仅在可能需要「递归解析」时调用「递归回调函数」
            - 例：
                - 陈述@结构类型 => Expr(:类型, 递归回调(解析器, ϕ1), 递归回调(解析器, ϕ2))
                - 数字 => Expr(:类型, 值)（视作「结构类型」）
                - 其它原生类型 => pack_identity(_, 对象, _)
                - 保留类型 => Expr(保留特征头, [自定义内容])
                    - `[1,2,3]` => Expr(保留特征头, :vect, 1, 2, 3)
                    - `(1,2,3)` => Expr(保留特征头, :tuple, 1, 2, 3)
                    - 上两者都依托于「保留类型打包接口」pack_preserved(递归回调函数, 头, 参数...)
                        - 功能：表达式转义
                            - `Expr(表达式头, 表达式参数...)` => Expr(保留特征头, 表达式头, 表达式参数...)
                        - 例：`[元素...]` => `Expr(:vect, 递归回调(解析器, *每个元素*)...)`
                                            => `Expr(保留特征头, *其后同上*...)`
                        - 至于为何不「保留类型⇒打包接口」，见笔记「不存在一个万用的「任意对象⇒Expr」的函数」
        - 默认情况：遍历所有properties，视为「结构类型」返回
            - 例：
                - 时间戳
                - 语句
                - 自定义类型`struct s;a;b;c end`
                    - `s(1,2,3)` => Expr(:s, 1, 2, 3)
                    - `s(属性集...)` => Expr(:s, 递归回调(解析器, *每个属性*)...)

打包の例：
- "<A --> B>" ==(目标)=> `Expr(:Inheriance, Expr(:Word, "A"), Expr(:Word, "B"))`
- "1=>2"      ==(结构)=> `Expr(:Pair, 1, 2)`
- `1.0`       ==(原生)=> `1.0`
- `[1,2,3]`   ==(保留)=> `Expr(:__PRESERVED__, :vect, 1, 2, 3)`
"""
abstract type ASTParser <: AbstractParser end

"类型の短别名"
const TASTParser::Type = Type{<:ASTParser}

"""
声明「原生类型」
- 解析器直接返回自身
"""
const AST_NATIVE_TYPES::Type = Union{
    Symbol, # 用作头、类名
    Real, # 实数：s针对真值Truth
    String # 字符串
}

"""
声明「保留类型」
- 以转义形式打包/解析
"""
const AST_PRESERVED_TYPES::Type = Union{
    Vector,
    Tuple
}

"""
声明「目标类型」
- 能被解析器支持解析
"""
const AST_PARSE_TARGETS::Type = DEFAULT_PARSE_TARGETS

"""
声明用于「保留类型识别」的「保留特征头」
- ⚠限制条件：解析上下文中不能有任何类名与之重合
- 【20230806 14:34:22】现在采用「特殊符号」机制，确保不会有函数名/类名与之重名
"""
const AST_PRESERVED_HEAD::Symbol = Symbol(":preserved:")

"目标类型：词项/语句"
parse_target_types(::TASTParser) = STRING_PARSE_TARGETS

"数据类型：Julia的Expr对象"
Base.eltype(::TASTParser)::Type = Expr

# 【特殊链接】词项↔字符串 #

"重载Expr的构造方法"
Base.Expr(target::AST_PARSE_TARGETS)::Expr = narsese2data(ASTParser, target)

"构造方法支持"
(::Type{T})(expr::Base.Expr) where {T <: AST_PARSE_TARGETS} = data2narsese(ASTParser, Term, expr)


# 正式开始 #

begin "解析の逻辑"

    "恒等函数"
    ast_parse_identity(
        ::TASTParser, 
        v::Any,
        ::Function = Narsese.eval,
        ::Function = ast_parse,
    )::Any = v
    
    "解析@原生类型：即为恒等函数"
    ast_parse(
        parser::TASTParser, 
        v::AST_NATIVE_TYPES,
        eval_function::Function = Narsese.eval,
        recurse_callback::Function = ast_parse,
        recurse_parser::TAbstractParser = parser,
    )::AST_NATIVE_TYPES = ast_parse_identity(
        recurse_parser, 
        v, 
        eval_function, 
        recurse_callback,
        )
    
    """
    解析@结构类型/保留类型
    - 结构类型：(构造函数名::Symbol, 构造函数参数集...)
    - 保留类型类型：(保留特征头, 表达式头::Symbol, 表达式参数集...)
    """
    function ast_parse(
        parser::TASTParser, 
        expr::Expr,
        eval_function = Narsese.eval,
        recurse_callback::Function = ast_parse,
        recurse_parser::TAbstractParser = parser,
        )::Any
        # 保留类型:识别保留特征头
        if expr.head == AST_PRESERVED_HEAD
            reduced_head::Symbol = expr.args[1]
            reduced_args::Vector = [
                # 这里把第四个参数留作默认值
                recurse_callback(recurse_parser, arg, eval_function)
                for arg in expr.args[2:end]
            ]
            reduced::Expr = Expr(
                reduced_head,
                reduced_args,
            )
            return reduced |> eval_function
        else # 结构类型
            # 📌实际上只要可以call的都算「构造器」
            constructor::Union{Type, Function} = parse_type(
                expr.head,
                eval_function
            )
            args = [
                # 这里把第四个参数留作默认值
                recurse_callback(recurse_parser, arg, eval_function)
                for arg in expr.args
            ]
            return constructor(
                args...
            )
        end
    end

end

begin "打包の逻辑"

    "格式化：结构类型"
    ast_form_struct(type::Type, args...)::Expr = Expr(
        pack_type_symbol(type), args...
    )

    # "格式化：原生类型" # 直接用恒等函数，无需再嵌套了
    # ast_form_native(obj::AST_NATIVE_TYPES)::AST_NATIVE_TYPES = obj

    "格式化：保留类型"
    ast_form_preserved(head::Symbol, args...)::Expr = Expr(
        AST_PRESERVED_HEAD, # 增加特征头
        head,
        args...
    )

    "恒等函数"
    ast_pack_identity(
        parser::TASTParser, 
        v::Any,
        ::Function = ast_parse,
        ::TAbstractParser = parser,
    )::Any = v
    
    """
    打包@原生类型：即为恒等函数
    - 数值除外
    """
    ast_pack(
        parser::TASTParser, 
        v::AST_NATIVE_TYPES,
        recurse_callback::Function = ast_parse,
        recurse_parser::TAbstractParser = parser,
        )::AST_NATIVE_TYPES = ast_pack_identity(
        parser, 
        v, 
        recurse_callback,
        recurse_parser,
    )
    
    """
    打包@数值：作为「结构类型」打包
    - 🎯保留精度，解决不同精度的转换问题
        - 例：`i::Int8=127` => `Expr(:Int8, 127)` => `Int8(127)`
    """
    ast_pack(
        ::TASTParser, 
        n::Number,
        recurse_callback::Function = ast_pack,
        recurse_parser::TAbstractParser = parser,
        )::Expr = ast_form_struct(
        typeof(n), # 类型
        n, # 数值
    )

    """
    打包@默认情况
    - 作为「结构类型」
    - 遍历所有属性作为「构造函数参数」
    """
    ast_pack(
        parser::TASTParser, 
        target::Any, 
        recurse_callback::Function = ast_pack,
        recurse_parser::TAbstractParser = parser
        )::Expr = ast_form_struct(
        typeof(target), # 类型
        ( # 遍历所有属性，递归打包
            recurse_callback(recurse_parser, arg) # 第三参数留作默认
            for arg in allproperties_generator(target)
        )...
    )

    begin "特殊打包法@词项"
    
        """
        原子词项：(:类名, :名称)
        """
        ast_pack(
            ::TASTParser, 
            a::Atom, 
            ::Function = ast_pack
            )::Expr = ast_form_struct(
            typeof(a),
            a.name # ::Symbol
        )
    
        """
        陈述的打包方法
        """
        ast_pack(
            parser::TASTParser, 
            s::Statement, 
            recurse_callback::Function = ast_pack,
        recurse_parser::TAbstractParser = parser,
            )::Expr = ast_form_struct(
            typeof(s),
            recurse_callback(recurse_parser, s.ϕ1),
            recurse_callback(recurse_parser, s.ϕ2),
        )
        
        """
        词项集的打包方法：(:类名, 各内容)
        - 适用范围：所有集合类的词项（Image会被特别重载）
        """
        ast_pack(
            parser::TASTParser, 
            ts::TermSetLike, 
            recurse_callback::Function = ast_pack,
            recurse_parser::TAbstractParser = parser
            )::Expr = ast_form_struct(
            typeof(ts),
            (
                recurse_callback(recurse_parser, term)
                for term in ts.terms
            )... # 无论有序还是无序
        )
    
        """
        特殊重载：像
        - 内容
        - 占位符索引
        """
        ast_pack(
            parser::TASTParser, 
            i::TermImage, 
            recurse_callback::Function = ast_pack,
        recurse_parser::TAbstractParser = parser
            )::Expr = ast_form_struct(
            typeof(i),
            i.relation_index, # 占位符索引(直接存储整数)
            (
                recurse_callback(recurse_parser, term)
                for term in i.terms
            )...
        )
    
    end
    
    begin "语句の打包" # 【20230806 14:57:27】此处实际上使用默认的打包方法就足够了
    
        """
        真值的打包方法(:类名, f, c)
        
        协议@真值：
        - 属性「f」
        - 属性「c」
        """
        # ast_pack(
        #     parser::TASTParser, 
        #     t::Truth, 
        #     recurse_callback::Function = ast_pack,
        # recurse_parser::TAbstractParser = parser
        #     )::Expr = ast_form_struct(
        #     typeof(t),
        #     recurse_callback(recurse_parser, t.f),
        #     recurse_callback(recurse_parser, t.c),
        # )

        """
        时间戳&语句：皆采用默认方法(Any)
        """
        # 此处无需再适配
    
    end
    
end

begin "解析器入口"
    
    "打包：表达式→目标对象"
    narsese2data(parser::TASTParser, target::AST_PARSE_TARGETS)::Expr = ast_pack(
        ASTParser, target,
        ast_pack # 自递归
    )

    """
    总「解析」方法：直接调用parse_basical
    - 封装性：只能调用它解析Narsese词项/语句
    """
    function data2narsese(
        parser::TASTParser, ::Type, # 【20230808 10:33:39】因「兼容模式」不限制此处Type 
        ex::Expr
        )::AST_PARSE_TARGETS
        return ast_parse(
            parser, ex,
            Narsese.eval, # 使用Narsese模块作解析の上下文
            ast_parse # 自递归
        )
    end

end

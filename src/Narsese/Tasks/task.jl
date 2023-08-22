#= 📝Julia：泛型类的继承，对应类型参数继承就行
    例：
        1. 使用「子类{参数} <: 父类{参数}」
        2. 使用「子类{参数} <: 父类{常量}」
        3. 使用「子类      <: 父类{常量}」

=#

# 导出 #
export AbstractTask
export TaskBasic

# 代码 #

"""
抽象Narsese任务 <: AbstractItem
- 包含: 
    - sentence 语句：所包含的NAL语句
    - budget   预算：实现AbstractItem的抽象属性
- 以上属性分别定义了相应的get方法
"""
abstract type AbstractTask <: AbstractItem end


# 实现 #

"""
基础Narsese任务
- 实现: 
    - 语句
    - 预算值
"""
struct TaskBasic <: AbstractTask
    sentence::AbstractSentence
    budget::AbstractBudget
end

"""
（API实现@解析器）外部构造方法：提供可选参数
"""
@inline function TaskBasic(
    sentence::ASentence; # 下面无顺序，作为可选参数
    budget::Budget = default_precision_budget(), # 现在无需提供顺序默认值
    )
    TaskBasic(
        sentence, 
        budget,
    )
end


begin "别名(用于在语句转换时简化表达)"

    # 导出
    export ATask

    "不导出Task以免与标准库冲突"
    const ATask = AbstractTask

end

begin "方法集"

    # 导入
    import ..Terms: get_syntactic_complexity, get_syntactic_simplicity # 添加方法
    import ..Sentences: get_term, get_stamp, get_tense, get_punctuation, get_truth # 添加方法

    # 导出
    export get_sentence#=, get_budget=# # 已在`item.jl`中导出
    export get_term, get_stamp, get_tense, get_punctuation, get_truth # 源自sentence
    
    #= 抽象类型 的抽象方法，与语句一脉相承

    【20230822 10:39:55】单行函数Julia编译器会自动内联，无需可以添加
    =#
    for method_name in [:get_term, :get_stamp, :get_tense, :get_punctuation, :get_truth, :get_syntactic_complexity]
        @eval $method_name(t::AbstractTask) = $method_name(get_sentence(t))
    end
    
    # 「语法简单度」需要另外重定向
    get_syntactic_simplicity(t::AbstractTask, r::Number) = get_syntactic_simplicity(get_term(t), r)
    
    #= 抽象类型 的抽象方法，与预算值一脉相承 =#
    for method_name in [:get_p, :get_d, :get_q]
        @eval $method_name(t::AbstractTask) = $method_name(get_budget(t))
    end

    # 基础类型
    """
    获取语句(基础类型)
    """
    get_sentence(s::TaskBasic)::AbstractSentence = s.sentence

    """
    获取预算值(基础类型)
    """
    get_budget(s::TaskBasic)::Budget = s.budget
    

    """
    判等の法：语句⇒预算值
    """
    Base.isequal(t1::AbstractTask, t2::AbstractTask)::Bool = (
        get_sentence(t1) == get_sentence(t2) &&
        get_budget(t1) == get_budget(t2)
    )

    "重定向等号（否则无法引至isequal）"
    Base.:(==)(t1::AbstractTask, t2::AbstractTask)::Bool = isequal(t1, t2)

end

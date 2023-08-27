(@isdefined JuNarsese) || include("commons.jl") # 已在此中导入JuNarsese、Test

@testset "types" begin
    
    # 测试各类「抽象类型」
    @test Intension <: AbstractEI >: Extension
    @test And <: AbstractLogicOperation >: Or
    @test Not <: AbstractLogicOperation
    @test VTIndependent <: AbstractVariableType
    @test Sequential <: AbstractTemporalRelation >: Parallel

    # 测试「原子词项」
    @test Word <: Atom <: Term
    @test IVar <: Variable{VTIndependent} <: Var <: Variable <: Atom <: Term
    
    # 测试「复合词项类型」
    @test CompoundTypeTermProduct <: AbstractCompoundType
    CompoundTypeTermImage{Extension} <: CompoundTypeTermImage
    
    @test TermProduct <: CommonCompound{CompoundTypeTermProduct} <: AbstractCompound{CompoundTypeTermProduct} <: AbstractCompound <: AbstractTerm
    @test TermProduct <: CommonCompound{CompoundTypeTermProduct} <: CommonCompound <: AbstractCompound <: AbstractTerm
    @test ExtImage <: TermImage{Extension} <: AbstractCompound{CompoundTypeTermImage{Extension}} <: AbstractCompound{CompoundTypeTermImage{Extension}} <: AbstractCompound
    @test IntImage <: TermImage{Intension} <: TermImage <: AbstractCompound

    # 测试「陈述类型」
    @test STInheritance <: AbstractStatementType
    @test STImplication <: StatementTypeImplication{Eternal} <: StatementTypeImplication <: AbstractStatementType
    @test STEquivalence <: StatementTypeEquivalence{Eternal} <: StatementTypeEquivalence <: AbstractStatementType

    @test Inheritance <: Statement{STInheritance} <: AbstractStatement{StatementTypeInheritance} <: AbstractStatement <: AbstractTerm
    @test Inheritance <: Statement{STInheritance} <: Statement <: AbstractStatement <: AbstractTerm

end


--Jedi Consular
if true then
    local TAB = {}
    TAB.Name = "Jedi Consular"
    TAB.Color = Vector( 168, 237, 159 )
    lsst:AddTab( "Consular", TAB )
end

if true then
    local SKI = {}
    SKI.Name = "Contemplate"
    SKI.Tab = "Consular"
    SKI.PosX = 325
    SKI.PosY = 16 +96 
    SKI.Powers = "a_replenish"
    SKI.Point = 25
    lsst:AddSkill( "C1_1", SKI )
    lsst:AddPower( "a_replenish", { Name = "Replenish", Ability = "item_force_replenish", Type = 3 } )
end
if true then
    local SKI = {}
    SKI.Name = "Rock Throw"
    SKI.Tab = "Consular"
    SKI.PosX = 325
    SKI.PosY = 16 +96 +96
    SKI.Require = "C1_1" --Changing any of these (C#_#) require a server restart
    SKI.Powers = "a_test"
    SKI.Point = 50
    lsst:AddSkill( "C2_2", SKI ) --Changing any of these (C#_#) require a server restart
    lsst:AddPower( "a_test", { Name = "test", Ability = "item_force_test", Type = 3 } )
end
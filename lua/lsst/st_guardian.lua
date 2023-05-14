
--Jedi Guardian
if true then
    local TAB = {}
    TAB.Name = "Jedi Guardian"
    TAB.Color = Vector( 126, 137, 224 )
    lsst:AddTab( "Guardian", TAB )
end

if true then
    local SKI = {}
    SKI.Name = "Speed"
    SKI.Tab = "Guardian"
    SKI.PosX = 325
    SKI.PosY = 16 +96 
    SKI.Powers = "a_test"
    SKI.Point = 25
    lsst:AddSkill( "G1_1", SKI )
    lsst:AddPower( "a_test", { Name = "test", Ability = "item_force_test", Type = 3 } )
end
if true then
    local SKI = {}
    SKI.Name = "IMU"
    SKI.Tab = "Guardian"
    SKI.PosX = 325
    SKI.PosY = 16 +96 +96
    SKI.Require = "G1_1" --Changing any of these (C#_#) require a server restart
    SKI.Powers = "a_immunity"
    SKI.Point = 50
    lsst:AddSkill( "G2_2", SKI ) --Changing any of these (C#_#) require a server restart
    lsst:AddPower( "a_immunity", { Name = "Immunity", Ability = "item_force_immunity", Type = 3 } )
end
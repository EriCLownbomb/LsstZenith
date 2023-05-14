
--Jedi Sentinel
if true then
    local TAB = {}
    TAB.Name = "Jedi Sentinel"
    TAB.Color = Vector( 216, 224, 126 )
    lsst:AddTab( "Sentinel", TAB )
end

if true then
    local SKI = {}
    SKI.Name = "Valour"
    SKI.Tab = "Sentinel"
    SKI.PosX = 325
    SKI.PosY = 16 +96 
    SKI.Powers = "a_valour"
    SKI.Point = 25
    lsst:AddSkill( "SE1_1", SKI )
    lsst:AddPower( "a_valour", { Name = "Valour", Ability = "item_force_valour", Type = 3 } )
end
if true then
    local SKI = {}
    SKI.Name = "Last Push"
    SKI.Tab = "Sentinel"
    SKI.PosX = 325
    SKI.PosY = 16 +96 +96
    SKI.Require = "SE1_1" --Changing any of these (C#_#) require a server restart
    SKI.Powers = "a_test"
    SKI.Point = 50
    lsst:AddSkill( "SE2_2", SKI ) --Changing any of these (C#_#) require a server restart
    lsst:AddPower( "a_test", { Name = "test", Ability = "item_force_test", Type = 3 } )
end
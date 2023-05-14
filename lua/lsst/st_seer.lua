
--Jedi Seer
if true then
    local TAB = {}
    TAB.Name = "Jedi Seer"
    TAB.Color = Vector( 209, 209, 209 )
    lsst:AddTab( "Seer", TAB )
end

if true then
    local SKI = {}
    SKI.Name = "Blink"
    SKI.Tab = "Seer"
    SKI.PosX = 325
    SKI.PosY = 16 +96 
    SKI.Powers = "a_blink"
    SKI.Point = 25
    lsst:AddSkill( "S1_1", SKI )
    lsst:AddPower( "a_blink", { Name = "blink", Ability = "item_force_blink", Type = 3 } )
end
if true then
    local SKI = {}
    SKI.Name = "SurgSt"
    SKI.Tab = "Seer"
    SKI.PosX = 325
    SKI.PosY = 16 +96 +96
    SKI.Require = "S1_1" --Changing any of these (C#_#) require a server restart
    SKI.Powers = "a_test"
    SKI.Point = 50
    lsst:AddSkill( "S2_2", SKI ) --Changing any of these (C#_#) require a server restart
    lsst:AddPower( "a_test", { Name = "Surgical Strike", Ability = "item_force_test", Type = 3 } )
end
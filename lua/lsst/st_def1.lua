if true then
    local TAB = {}
    TAB.Name = "Jedi Learner"
    TAB.Color = Vector( 55, 255, 255 )
    lsst:AddTab( "Default1", TAB )
end
--Jedi Learner
if true then
    local SKI = {}
    SKI.Name = "Jump"
    SKI.Tab = "Default1"
    SKI.PosX = 325
    SKI.PosY = 16 +96
    SKI.Powers = "a_jump"
    SKI.Point = 25
    lsst:AddSkill( "l1_1", SKI )
    lsst:AddPower( "a_jump", { Name = "Jump", Ability = "item_force_jump", Type = 3 } )
end
if true then
    local SKI = {}
    SKI.Name = "THR"
    SKI.Tab = "Default1"
    SKI.PosX = 325 -96
    SKI.PosY = 16 +96 +96
    SKI.Require = "l1_1"
    SKI.Powers = "a_throw"
    SKI.Point = 50
    lsst:AddSkill( "l2_1", SKI )
    lsst:AddPower( "a_throw", { Name = "Throw", Ability = "item_force_throw", Type = 3 } )
end
if true then
    local SKI = {}
    SKI.Name = "Heal"
    SKI.Tab = "Default1"
    SKI.PosX = 325
    SKI.PosY = 16 +96 +96
    SKI.Require = "l1_1"
    SKI.Powers = "a_heal"
    SKI.Point = 50
    lsst:AddSkill( "l2_2", SKI )
    lsst:AddPower( "a_heal", { Name = "heal", Ability = "item_force_heal", Type = 3 } )
end
if true then
    local SKI = {}
    SKI.Name = "Push"
    SKI.Tab = "Default1"
    SKI.PosX = 325 +96
    SKI.PosY = 16 +96 +96
    SKI.Require = "l1_1"
    SKI.Powers = "a_push"
    SKI.Point = 50
    lsst:AddSkill( "l2_3", SKI )
    lsst:AddPower( "a_push", { Name = "Force Push", Ability = "item_force_push", Type = 3 } )
end
if true then
    local SKI = {}
    SKI.Name = "Cure"
    SKI.Tab = "Default1"
    SKI.PosX = 325
    SKI.PosY = 16 +96*2 +96
    SKI.Require = "l2_2"
    SKI.Powers = "a_Cure"
    SKI.Point = 75
    lsst:AddSkill( "l3_2", SKI )
    lsst:AddPower( "a_Cure", { Name = "Force Cure", Ability = "item_force_Cure", Type = 3 } )
end
if true then
    local SKI = {}
    SKI.Name = "Pull"
    SKI.Tab = "Default1"
    SKI.PosX = 325 +96
    SKI.PosY = 16 +96*2 +96
    SKI.Require = "l2_3"
    SKI.Powers = "a_pull"
    SKI.Point = 75
    lsst:AddSkill( "l3_3", SKI )
    lsst:AddPower( "a_pull", { Name = "Force Pull", Ability = "item_force_pull", Type = 3 } )
end




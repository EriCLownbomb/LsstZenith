
--[[
	v v v Hilt v v v
]]
local hilt = {}
hilt.PrintName = "Spear"
hilt.Author = "BadJay707"
hilt.id = "spear"
hilt.mdl = "models/plo/cwa/melee/spear.mdl"
hilt.info = {
    ParentData = {
        ["RH"] = {
            bone = "ValveBiped.Bip01_R_Hand",
            pos = Vector(3.2, -2.5, -0.1),
            ang = Angle(90,180,0),
        },
        ["LH"] = {
            bone = "ValveBiped.Bip01_L_Hand",
            pos = Vector(3.75, -2.5, 14.7),
            ang = Angle(-90,0,0),
        },
    },
    GetBladePos = function( ent ) 
               local blades = {
            [1] = {
                pos = ent:LocalToWorld( Vector(44,-0.5,0) ),
                dir = ent:LocalToWorldAngles( Angle(-90,180,0) ):Up(),
            },
        }

        return blades
    end,
}
LSCS:RegisterHilt( hilt )
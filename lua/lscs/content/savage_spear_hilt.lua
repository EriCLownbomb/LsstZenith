
--[[
	v v v Hilt v v v
]]
local hilt = {}
hilt.PrintName = "Savage Spear"
hilt.Author = "BadJay707"
hilt.id = "savagespear"
hilt.mdl = "models/plo/cwa/melee/savage_spear.mdl"
hilt.info = {
    ParentData = {
        ["RH"] = {
            bone = "ValveBiped.Bip01_R_Hand",
            pos = Vector(3.2, -2.5, -14.7),
            ang = Angle(-90,180,0),
        },
        ["LH"] = {
            bone = "ValveBiped.Bip01_L_Hand",
            pos = Vector(3.75, -2.5, 14.7),
            ang = Angle(90,0,0),
        },
    },
    GetBladePos = function( ent ) 
               local blades = {
            [1] = {
                pos = ent:LocalToWorld( Vector(-10,-0.9,1) ),
                dir = ent:LocalToWorldAngles( Angle(90,180,0) ):Up(),
            },
        }

        return blades
    end,
}
LSCS:RegisterHilt( hilt )
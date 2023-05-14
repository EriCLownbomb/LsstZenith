
--[[
	v v v Hilt v v v
]]
local hilt = {}
hilt.PrintName = "Sycthe"
hilt.Author = "BadJay707"
hilt.id = "sycthe"
hilt.mdl = "models/plo/cwa/melee/sycthe.mdl"
hilt.info = {
    ParentData = {
        ["RH"] = {
            bone = "ValveBiped.Bip01_R_Hand",
            pos = Vector(3.2, -2.5, -4),
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
                pos = ent:LocalToWorld( Vector(-36,-0.5,-5) ),
                dir = ent:LocalToWorldAngles( Angle(360,180,0) ):Up(),
            },
        }

        return blades
    end,
}
LSCS:RegisterHilt( hilt )

--[[
	v v v Hilt v v v
]]
local hilt = {}
hilt.PrintName = "Electrostaff"
hilt.Author = "BadJay707"
hilt.id = "electrostaff"
hilt.mdl = "models/plo/cwa/melee/electro_staff.mdl"
hilt.info = {
    ParentData = {
        ["RH"] = {
            bone = "ValveBiped.Bip01_R_Hand",
            pos = Vector(3.65, -1.05, -10),
            ang = Angle(-90,0,0),
        },
        ["LH"] = {
            bone = "ValveBiped.Bip01_L_Hand",
            pos = Vector(3.75, -1.5, 10),
            ang = Angle(90,0,0),
        },
    },
    GetBladePos = function( ent ) 
               local blades = {
            [1] = {
                pos = ent:LocalToWorld( Vector(-20,-0.9,0) ),
                dir = ent:LocalToWorldAngles( Angle(90,180,0) ):Up(),
            },
        }

        return blades
    end,
}
LSCS:RegisterHilt( hilt )

--[[
	v v v Hilt v v v
]]
local hilt = {}
hilt.PrintName = "Bandit Hilt3"
hilt.Author = "BadJay707"
hilt.id = "bandit3"
hilt.mdl = "models/plo/cwa/sabers/bandit_saber3.mdl"
hilt.info = {
    ParentData = {
        ["RH"] = {
			bone = "ValveBiped.Bip01_R_Hand",
			pos = Vector(3, -1.3, -7),
			ang = Angle(-90, 7, 10),
		},
		["LH"] = {
			bone = "ValveBiped.Bip01_L_Hand",
            pos = Vector(3, -1.3, -7),
            ang = Angle(-90,0,0),
		},
    },
    GetBladePos = function( ent ) 
        local blades = {
            [1] = {
                pos = ent:LocalToWorld( Vector(1.8, -0.5, -0.1) ),
                dir = ent:LocalToWorldAngles( Angle(-90, -7, 10) ):Up(),
            },
            [2] = {
                pos = ent:LocalToWorld( Vector(1,-0.5,1.1) ),
                dir = ent:LocalToWorldAngles( Angle(-50,0,0) ):Up(),
		length_multiplier = 0.15,
		width_multiplier = 0.3,
            },
            [3] = {
                pos = ent:LocalToWorld( Vector(1,-0.5,-1.35) ),
                dir = ent:LocalToWorldAngles( Angle(-130,0,0) ):Up(),
		length_multiplier = 0.15,
		width_multiplier = 0.3,
            },
        }

        return blades
    end,
}
LSCS:RegisterHilt( hilt )
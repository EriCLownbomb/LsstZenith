
--[[
	v v v Hilt v v v
]]
local hilt = {}
hilt.PrintName = "Bandit Hilt2"
hilt.Author = "BadJay707"
hilt.id = "bandit2"
hilt.mdl = "models/plo/cwa/sabers/bandit_saber2.mdl"
hilt.info = {
	ParentData = {
		["RH"] = {
			bone = "ValveBiped.Bip01_R_Hand",
			pos = Vector(3, -1.3, -7),
			ang = Angle(-90, 100, 0),
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
                pos = ent:LocalToWorld( Vector(1.8, -0.4, -0.1) ),
                dir = ent:LocalToWorldAngles( Angle(-90, -7, 10) ):Up(),
            },
        }

        return blades
    end,
}
LSCS:RegisterHilt( hilt )
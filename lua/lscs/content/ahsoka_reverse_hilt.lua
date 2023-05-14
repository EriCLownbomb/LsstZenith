
--[[
	v v v Hilt v v v
]]
local hilt = {}
hilt.PrintName = "Ahsoka Reverse"
hilt.Author = "Ink"
hilt.id = "ahsokareverse"
hilt.mdl = "models/plo/cwa/sabers/reverseahsoka.mdl"
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
			ang = Angle(-90, 0, -10),
		},
	},
GetBladePos = function( ent ) 
        local blades = {
            [1] = {
                pos = ent:LocalToWorld( Vector(1.8, 0, -0.37) ),
                dir = ent:LocalToWorldAngles( Angle(-90, -7, 10) ):Up(),
            },
            [2] = {
                pos = ent:LocalToWorld( Vector(1.8, 0, -0.37) ),
                dir = ent:LocalToWorldAngles( Angle(-90, -7, 10) ):Up(),
				}
        }

        return blades
    end,
}
LSCS:RegisterHilt( hilt )
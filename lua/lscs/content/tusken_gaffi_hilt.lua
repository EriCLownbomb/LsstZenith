
--[[
	v v v Hilt v v v
]]
local hilt = {}
hilt.PrintName = "Tusken Gaffi"
hilt.Author = "BadJay707"
hilt.id = "tuskengaffi"
hilt.mdl = "models/plo/cwa/melee/tusken_gaffi.mdl"
hilt.info = {
    ParentData = {
        ["RH"] = {
            bone = "ValveBiped.Bip01_R_Hand",
            pos = Vector(3.2, -1.3, -6),
            ang = Angle(-90,180,0),
        },
        ["LH"] = {
            bone = "ValveBiped.Bip01_L_Hand",
            pos = Vector(3.75, -1.3, 14.7),
            ang = Angle(90,0,0),
        },
    },
    GetBladePos = function( ent ) 
               local blades = {
            [1] = {
                pos = ent:LocalToWorld( Vector(-13,-0.9,2.5) ),
                dir = ent:LocalToWorldAngles( Angle(370,180,0) ):Up(),
            },
            [2] = {
                pos = ent:LocalToWorld( Vector(25.5,-0.9,0) ),
                dir = ent:LocalToWorldAngles( Angle(-90,-180,0) ):Up(),
            },           
        }

        return blades
    end,
}
LSCS:RegisterHilt( hilt )
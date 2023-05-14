AddCSLuaFile()

SWEP.Base = "weapon_lscs"
DEFINE_BASECLASS( "weapon_lscs" )

SWEP.Category		= "[LSCS]"
SWEP.PrintName	= "Magnaguard Electrostaff"
SWEP.Author		= "BadJay707"
SWEP.Slot		= 0
SWEP.SlotPos 	= 3
SWEP.HoldType 	= "melee2"
SWEP.Spawnable	= true
SWEP.AdminOnly	= false

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables( self )
	
	if SERVER then
		self:SetHiltR("magnastaff") 
		self:SetBladeR("purpstaff")
		//self:SetStance("yongli")
	end
end
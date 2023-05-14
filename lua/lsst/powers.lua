lsst:AddPower( "damage", {
    Name = "Damage",
    Type = 1,
} )
lsst:AddPower( "crit", {
    Name = "Critical Chance",
    Type = 1,
} )
lsst:AddPower( "reduce", {
    Name = "Damage Reduction",
    Type = 1,
} )
lsst:AddPower( "vampire", {
    Name = "Life Steal",
    Type = 1,
} )
lsst:AddPower( "avoid", {
    Name = "avoidance",
    Type = 1,
} )
lsst:AddPower( "regen", {
    Name = "Regeneration",
    Type = 0,
} )
lsst:AddPower( "recharge", {
    Name = "Recharge",
    Type = 0,
} )
lsst:AddPower( "damage2", {
    Name = "Absolute Damage",
    Type = 0,
} )

sound.Add( {
    name = "lsst.Crit",
    channel = CHAN_AUTO,
    volume = 0.5,
    level = 80,
    pitch = { 95, 105 },
    sound = {
        "player/crit_hit_mini.wav",
        "player/crit_hit_mini2.wav",
        "player/crit_hit_mini3.wav",
        "player/crit_hit_mini4.wav",
        "player/crit_hit_mini5.wav",
    }
} )
sound.Add( {
    name = "lsst.Avoid",
    channel = CHAN_AUTO,
    volume = 0.5,
    level = 75,
    pitch = { 100, 125 },
    sound = "Weapon_Crowbar.Single",
} )

hook.Add( "StartCommand", "Hook_lsst_Power", function( ply, cmd )
    if SERVER and ply:Alive() and IsValid( ply:GetActiveWeapon() ) and LSST_ValidClass[ ply:GetActiveWeapon():GetClass() ] then
        local reg, rec = lsst:HasPower( ply, "regen" ), lsst:HasPower( ply, "recharge" )
        local tnam1, tname2 = "["..ply:EntIndex().."]lsst_regen", "["..ply:EntIndex().."]lsst_recharge"
        if isnumber( reg ) and reg != 0 and ( reg < 0 or ply:GetMaxHealth() > ply:Health() ) and !timer.Exists( tnam1 ) then
            timer.Create( tnam1, 3, 0, function()
                if !IsValid( ply ) or !ply:Alive() then timer.Remove( tnam1 ) return end
                local reg = lsst:HasPower( ply, "regen" )
                if !isnumber( reg ) or reg == 0 then timer.Remove( tnam1 ) return end
                if !IsValid( ply:GetActiveWeapon() ) or !LSST_ValidClass[ ply:GetActiveWeapon():GetClass() ] then
                    timer.Remove( tnam1 )
                    return
                end
                if reg > 0 then
                    ply:SetHealth( math.min( ply:GetMaxHealth(), ply:Health() +reg ) )
                else
                    ply:SetHealth( math.max( 1, ply:Health() +reg ) )
                end
            end )
        end
        if isnumber( rec ) and rec != 0 and ( rec < 0 or ply:GetMaxArmor() > ply:Armor() ) and !timer.Exists( tnam2 ) then
            timer.Create( tnam2, 3, 0, function()
                if !IsValid( ply ) or !ply:Alive() then timer.Remove( tnam2 ) return end
                local rec = lsst:HasPower( ply, "recharge" )
                if !isnumber( rec ) or rec == 0 then timer.Remove( tnam2 ) return end
                if !IsValid( ply:GetActiveWeapon() ) or !LSST_ValidClass[ ply:GetActiveWeapon():GetClass() ] then
                    timer.Remove( tnam2 )
                    return
                end
                if rec > 0 then
                    ply:SetArmor( math.min( ply:GetMaxArmor(), ply:Armor() +rec ) )
                else
                    ply:SetArmor( math.max( 0, ply:Armor() +rec ) )
                end
            end )
        end
    end
end )
hook.Add( "EntityTakeDamage", "Hook_lsst_Power", function( tar, dmg )
    local atk, inf = dmg:GetAttacker(), dmg:GetInflictor()
    if IsValid( atk ) and atk:IsPlayer() and istable( atk.lsst_Profile ) and IsValid( atk:GetActiveWeapon() ) and LSST_ValidClass[ atk:GetActiveWeapon():GetClass() ] then
        local dam, crt, lsl, abd = lsst:HasPower( atk, "damage" ), lsst:HasPower( atk, "crit" ), lsst:HasPower( atk, "vampire" ), lsst:HasPower( atk, "damage2" )
        local pro = atk.lsst_Profile  local s1, s4 = pro.Stat1, pro.Stat4
        if s1 > 0 then
            dam = ( isnumber( dam ) and dam +2*s1 or 2*s1 )
        end
        if s4 > 0 then
            crt = ( isnumber( crt ) and crt +2*s1 or 2*s1 )
        end
        if dmg:GetDamage() != 0 and isnumber( abd ) and abd != 0 then
            dmg:SetDamage( math.max( 0, dmg:GetDamage() +abd ) )
        end
        if isnumber( dam ) then
            dmg:ScaleDamage( 1 +dam/100 )
        end
        if isnumber( crt ) and crt > 0 then
            if math.random( 1, 10000 ) <= crt*100 then
                atk:EmitSound( "lsst.Crit" )
                dmg:ScaleDamage( 2 )
            end
        end
        if isnumber( lsl ) and lsl > 0 then
            local hp = math.max( 0, dmg:GetDamage()*lsl/100 )
            if !isnumber( atk.lsst_Steal ) then atk.lsst_Steal = 0 end
            atk.lsst_Steal = atk.lsst_Steal +hp
            if atk.lsst_Steal > 1 then
                atk:SetHealth( math.min( atk:GetMaxHealth(), atk:Health() +math.floor( atk.lsst_Steal ) ) )
                atk.lsst_Steal = 0
            end
        end
    end
    if IsValid( tar ) and tar:IsPlayer() and IsValid( tar:GetActiveWeapon() ) and LSST_ValidClass[ tar:GetActiveWeapon():GetClass() ] and istable( tar.lsst_Profile ) then
        local pro = tar.lsst_Profile
        local red, avo = lsst:HasPower( tar, "reduce" ), lsst:HasPower( tar, "avoid" )  local s2, s3 = pro.Stat2, pro.Stat3
        if s3 > 0 then
            red = ( isnumber( red ) and red +3*s3 or 3*s3 )
        end
        if s2 > 0 then
            avo = ( isnumber( avo ) and avo +2*s2 or 2*s2 )
        end
        if isnumber( red ) then
            dmg:ScaleDamage( 1 -red/100 )
        end
        if isnumber( avo ) and avo > 0 then
            if math.random( 1, 10000 ) <= avo*100 then
                atk:EmitSound( "lsst.Avoid" )
                dmg:ScaleDamage( 0 )
                dmg:SetAttacker( Entity( 0 ) )
                dmg:SetDamageType( DMG_GENERIC )
                return true
            end
        end
    end
end )
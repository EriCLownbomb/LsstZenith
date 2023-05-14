hook.Add( "OnNPCKilled", "Hook_lsst_KillNPC", function( npc, atk, inf )
    if !IsValid( inf ) or !inf:IsWeapon() or !IsValid( atk ) or !atk:IsPlayer() then return end
    local cls = inf:GetClass()
    if !LSST_ValidClass[ cls ] or npc:GetMaxHealth() <= 0 then return end
    lsst:PointGive( atk, lsst.Config.NPCEarn )
end )
hook.Add( "PlayerDeath", "Hook_lsst_KillPlayer", function( vic, inf, atk )
    if !IsValid( atk ) or !atk:IsPlayer() or !atk:Alive() then return end
    local wep = atk:GetActiveWeapon()
    if !IsValid( wep ) or !LSST_ValidClass[ wep:GetClass() ] then return end
    lsst:PointGive( atk, lsst.Config.PlayerEarn )
end )
hook.Add( "KeyPress", "Hook_lsst_CheckAFK", function( ply, key )
    if CLIENT or !istable( ply.lsst_Profile ) or !ply:Alive() then return end
    ply.lsst_AFKTimer = os.time()
end )
hook.Add( "StartCommand", "Hook_lsst_TimerEarn", function( ply, cmd )
    if CLIENT or !IsValid( ply ) or !ply:Alive() or !istable( ply.lsst_Profile ) then return end
    local tname = "["..ply:EntIndex().."]lsst_Timer"
    if !timer.Exists( tname ) then
        timer.Create( tname, 1, 0, function()
            if !IsValid( ply ) or !istable( ply.lsst_Profile ) or ( isnumber( ply.lsst_AFKTimer ) and ply.lsst_AFKTimer +lsst.Config.Timer < os.time() and !lsst.Config.TimerAFK ) then
                if IsValid( ply ) then ply.lsst_Timer = nil end
                timer.Remove( tname )
                return
            end
            if !isnumber( ply.lsst_Timer ) then ply.lsst_Timer = 0 else
                ply.lsst_Timer = ply.lsst_Timer +1
                if ply.lsst_Timer >= lsst.Config.Timer then
                    ply.lsst_Timer = nil
                    lsst:PointGive( ply, lsst.Config.TimerEarn )
                end
            end
        end )
    end
end )
if istable( lsst ) and IsValid( lsst.Menu ) then lsst.Menu:Remove() end
if SERVER then MsgC( Color( 155, 155, 255, 255 ), "Lightsaber Skill Tree System Loaded!\n" ) end
local txt_col, bck_col, tab_col, par_col, men_col = Color( 155, 155, 155 ), Color( 40, 45, 75 ), Color( 15, 25, 50 ), Color( 30, 35, 60 ), Color(0,127,255,255)
local GradMat, ClickMat, ZoomMat, TabMat = Material( "vgui/gradient-l" ), Material( "sun/overlay" ), Material( "vgui/zoom" ), Material( "lscs/ui/icon64.png" )
local StatCol = { Color( 255, 0, 0 ), Color( 255, 255, 0 ), Color( 0, 255, 0 ), Color( 0, 255, 255 ) }
local LearTxt = { "lsst.Unavailable", "lsst.Insufficient", "lsst.Available", "lsst.Learnt" }
timer.Remove( "lsst_UpdateProfile" )
LSST_ValidClass = {
    [ "weapon_lscs" ] = true,
    [ "weapon_nanosword" ] = true,
    [ "weapon_vibrosword" ] = true,
    [ "weapon_lscs_electrostaff" ] = true,
    [ "weapon_lscs_forcepike" ] = true,
    [ "weapon_lscs_magnastaff" ] = true,
    [ "weapon_lscs_mandostaff" ] = true,
    [ "weapon_lscs_savagespear" ] = true,
    [ "weapon_lscs_shockstaff" ] = true,
    [ "weapon_lscs_skreejipike" ] = true,
    [ "weapon_lscs_spear" ] = true,
    [ "weapon_lscs_sycthe" ] = true,
    [ "weapon_lscs_tusken" ] = true,
}
lsst = {}

if SERVER or CLIENT then
    lsst.Powers = {}
    lsst.Tabs = {}
    lsst.Skills = {}

    function lsst:AddPower( cls, dat )
        if !isstring( cls ) or cls == "" or cls == "_" or !istable( dat ) then return end
        cls = string.lower( cls )

        local inp = {}
        inp.Name        = ( isstring( dat.Name ) and dat.Name or "" )
        inp.Ability     = ( isstring( dat.Ability ) and dat.Ability or nil )
        inp.Bad         = ( isbool( dat.Bad ) and dat.Bad or nil )
        inp.Type        = ( isnumber( dat.Type ) and math.Clamp( math.Round( dat.Type ), 0, 3 ) or 0 )
        inp.Class       = cls

        if SERVER and isstring( inp.Ability ) and !isnumber( lsst.Restricted[ inp.Ability ] ) then
            lsst.Restricted[ inp.Ability ] = 0
        end
        lsst.Powers[ cls ] = inp
    end
    function lsst:AddTab( cls, dat )
        if !isstring( cls ) or cls == "" or cls == "_" or !istable( dat ) then return end

        local inp = {}
        inp.Name        = ( isstring( dat.Name ) and dat.Name or "" )
        inp.Color       = ( isvector( dat.Color ) and dat.Color or "" )
        inp.Icon        = ( isstring( dat.Icon ) and dat.Icon or nil )
        if isstring( dat.Groups ) then dat.Groups = { [ dat.Groups ] = 0 } end
        inp.Groups      = ( istable( dat.Groups ) and dat.Groups or nil )
        if isstring( dat.Teams ) then dat.Teams = { [ dat.Teams ] = 0 } end
        if isnumber( dat.Teams ) then dat.Teams = { [ tostring( dat.Teams ) ] = 0 } end
        inp.Teams       = ( istable( dat.Teams ) and dat.Teams or nil )
        inp.StartX      = ( isnumber( dat.StartX ) and math.Clamp( dat.StartX, -4096, 4096 ) or nil )
        inp.StartY      = ( isnumber( dat.StartY ) and math.Clamp( dat.StartY, -4096, 4096 ) or nil )
        inp.Class       = cls

        lsst.Tabs[ cls ] = inp
    end
    function lsst:AddSkill( cls, dat )
        if !isstring( cls ) or cls == "" or cls == "_" or !istable( dat ) then return end

        local inp = {}
        inp.Name        = ( isstring( dat.Name ) and dat.Name or "" )
        inp.Info        = ( isstring( dat.Info ) and dat.Info or nil )
        inp.Tab         = ( isstring( dat.Tab ) and dat.Tab or "" )
        inp.Point       = ( isnumber( dat.Point ) and math.max( 0, dat.Point ) or 0 )
        if isstring( dat.Require ) then dat.Require = { dat.Require } end
        inp.Require     = ( istable( dat.Require ) and dat.Require or nil )
        inp.PosX        = ( isnumber( dat.PosX ) and math.Clamp( dat.PosX, -4096, 4096 ) or 0 )
        inp.PosY        = ( isnumber( dat.PosY ) and math.Clamp( dat.PosY, -4096, 4096 ) or 0 )
        inp.Icon        = ( isstring( dat.Icon ) and dat.Icon or nil )
        if isstring( dat.Powers ) then dat.Powers = { [ dat.Powers ] = 0 } end
        inp.Powers      = ( istable( dat.Powers ) and dat.Powers or nil )
        inp.Class       = cls

        lsst.Skills[ cls ] = inp
    end
    function lsst:HasPower( ply, str )
        if !ply:IsPlayer() or !isstring( ply:SteamID() ) or !istable( ply.lsst_Power ) then return nil end
        return ply.lsst_Power[ str ]
    end
    function lsst:SendHint( txt, snd, typ, ply )
        if !isnumber( typ ) then typ = 1 end
        if !isstring( txt ) or txt == "" then txt = "!V" end
        if !isstring( snd ) or snd == "" then snd = "!V" end
        if CLIENT then
            if isstring( txt ) and txt != "" and txt != "!V" then
                local exp = string.Explode( "&", txt )
                if istable( exp ) then
                    for k, v in pairs( exp ) do
                        exp[ k ] = language.GetPhrase( v )
                    end
                    txt = table.concat( exp, "" )
                end
                notification.AddLegacy( language.GetPhrase( txt ), typ, 3 )
            end
            if isstring( snd ) and snd != "" and snd != "!V" then
                surface.PlaySound( snd )
            end
        else
            if !IsValid( ply ) or !ply:IsPlayer() or ply:IsBot() then return end
            net.Start( "NET_lsst_SendHint" )
            net.WriteString( txt )
            net.WriteString( snd )
            net.WriteFloat( typ )
            net.Send( ply )
        end
    end
    function lsst:SendCommand( str, ply, dat )
        if !isstring( str ) or str == "" then return end
        if CLIENT then
            net.Start( "NET_lsst_Command" )
            net.WriteString( str )
            net.WriteString( isstring( dat ) and dat or "!V" )
            net.SendToServer()
            return
        end
        if !istable( ply.lsst_Profile ) then return end
        local pro = ply.lsst_Profile
        if str == "PointReset" then
            local pot = 0
            for k, v in pairs( pro.Skill ) do
                if !isstring( k ) or !istable( lsst.Skills[ k ] ) then continue end
                pot = pot +lsst.Skills[ k ].Point
            end
            ply.lsst_Profile.Point = ply.lsst_Profile.Point +pot
            ply.lsst_Profile.Skill = {}
            lsst:PowerGain( ply )
            lsst:ProfileUpdate( ply )
            lsst:SendHint( "lsst.Success2", "npc/roller/remote_yes.wav", 2, ply )
            return
        end
        if str == "PowerReset" then
            lsst:PowerGain( ply )
            lsst:SendHint( "lsst.Success3", "npc/roller/remote_yes.wav", 2, ply )
            return
        end
        if str == "LearnStat" and dat != "!V" then
            dat, poi = string.Explode( "|", dat ), lsst.Config.StatCost
            if !istable( dat ) or #dat != 2 or !isnumber( poi ) or poi < 0 then return end
            if ( dat[ 2 ] != "0" and dat[ 2 ] != "1" ) or ( dat[ 1 ] != "1" and dat[ 1 ] != "2" and dat[ 1 ] != "3" and dat[ 1 ] != "4" ) then return end
            local plu, lvl = ( dat[ 2 ] == "1" ), pro[ "Stat"..dat[ 1 ] ]
            
            if !isnumber( lvl ) or ( plu and lvl >= 5 ) or ( !plu and lvl <= 0 ) then return end
            if plu and ply.lsst_Profile.Point < poi then return end
            lsst:SendHint( "!V", "ui/beep_synthtone01.wav", 0, ply )
            ply.lsst_Profile.Point = ply.lsst_Profile.Point -lsst.Config.StatCost*( plu and 1 or -1 )
            ply.lsst_Profile[ "Stat"..dat[ 1 ] ] = lvl +( plu and 1 or -1 )
            lsst:PowerGain( ply, true )
            lsst:ProfileUpdate( ply, nil, false )
            return
        end
        if str == "GiveAbility" and istable( ply.lsst_Power ) and dat != "!V" and istable( lsst.Powers[ dat ] ) and isstring( lsst.Powers[ dat ].Ability ) then
            if !isnumber( ply.lsst_Power[ dat ] ) then return end
            lsst:SendHint( "lsst.Success4&: &"..lsst.Powers[ dat ].Name, "garrysmod/content_downloaded.wav", 0, ply )
            ply:lscsAddInventory( lsst.Powers[ dat ].Ability, nil )
            return
        end
    end
    function lsst:ProfileUpdate( ply, pro, ume )
        if !ply:IsPlayer() or !isstring( ply:SteamID() ) then return end
        if !istable( pro ) and istable( ply.lsst_Profile ) then
            pro = ply.lsst_Profile
        end
        if !istable( pro ) or !istable( pro.Skill ) or !isnumber( pro.Point ) then
            pro = { Point = 0, Stat1 = 0, Stat2 = 0, Stat3 = 0, Stat4 = 0, Skill = {} }
        end
        if !isnumber( pro.Stat1 ) then pro.Stat1 = 0 else pro.Stat1 = math.Clamp( math.Round( pro.Stat1 ), 0, 5 ) end
        if !isnumber( pro.Stat2 ) then pro.Stat2 = 0 else pro.Stat2 = math.Clamp( math.Round( pro.Stat2 ), 0, 5 ) end
        if !isnumber( pro.Stat3 ) then pro.Stat3 = 0 else pro.Stat3 = math.Clamp( math.Round( pro.Stat3 ), 0, 5 ) end
        if !isnumber( pro.Stat4 ) then pro.Stat4 = 0 else pro.Stat4 = math.Clamp( math.Round( pro.Stat4 ), 0, 5 ) end
        if SERVER then
            net.Start( "NET_lsst_SendProfile" )
            net.WriteString( util.TableToJSON( pro ) )
            net.WriteString( ume and "NO" or "YES" )
            net.Send( ply )
            pro.Name = ply:Nick()
            local txt = string.lower( string.Replace( ply:SteamID(), ":", "_" ) )
			if !file.IsDir( "lsstdata", "DATA" ) then
                file.CreateDir( "lsstdata" )
            end
            file.Write( "lsstdata/"..txt..".txt", util.TableToJSON( pro, true ) )
        end
        pro.Name = ply:Nick()
        ply.lsst_Profile = pro
    end
    function lsst:ProfileGet( ply )
        if !ply:IsPlayer() or !isstring( ply:SteamID() ) then return nil end
        if !istable( ply.lsst_Profile ) then
            lsst:ProfileUpdate( ply )
        end
        return ply.lsst_Profile
    end
    function lsst:LearnSkill( cls, ply )
        if !isstring( cls ) or !istable( lsst.Skills[ cls ] ) then return end
        if CLIENT then
            net.Start( "NET_lsst_Learn" )
            net.WriteString( cls )
            net.SendToServer()
            return
        end
        local pro, dat = ply.lsst_Profile, lsst.Skills[ cls ]
        if !istable( pro ) then return end
        if !isnumber( pro.Point ) or pro.Point < dat.Point then
            lsst:SendHint( "lsst.NotEnough", "resource/warning.wav", 1, ply )
            return
        end
        if !istable( pro.Skill ) then return end
        if istable( dat.Require ) then
            for k, v in pairs( dat.Require ) do
                if !isstring( v ) then continue end
                if !isnumber( pro.Skill[ v ] ) then
                    lsst:SendHint( "lsst.CantLearn", "resource/warning.wav", 1, ply )
                    return
                end
            end
        end
        lsst:SendHint( "lsst.Success&: &"..dat.Name, "ui/achievement_earned.wav", 0, ply )
        ply.lsst_Profile.Point = pro.Point -dat.Point
        ply.lsst_Profile.Skill[ cls ] = 0
        lsst:ProfileUpdate( ply )
        lsst:PowerGain( ply, cls )
    end
    function lsst:PointGet( ply )
        if !ply:IsPlayer() or !isstring( ply:SteamID() ) then return nil end
        if !istable( ply.lsst_Profile ) then
            lsst:ProfileUpdate( ply )
        end
        return ply.lsst_Profile.Point
    end
    function lsst:OpenMenu( ply )
        if SERVER then
            if ply:IsPlayer() then net.Start( "NET_lsst_OpenMenu" ) net.Send( ply ) end
            return
        end
        if IsValid( lsst.Menu ) then lsst.Menu:Remove() end
        lsst.Menu = vgui.Create( "DFrame" )  local pan = lsst.Menu
        pan.P_DMenu = nil
        pan:SetVisible( true )
        pan:SetScreenLock( true )
        pan:SetDraggable( true )
        pan:ShowCloseButton( false )
        pan:SetAnimationEnabled( false )
        pan:SetSize( 35, 35 )
        pan:SizeTo( 800, 35, 0.25 )
        pan:SizeTo( 800, 624, 0.25, 0.25 )
        pan:SetPos( ScrW()/2, ScrH()/2 -35/2 )
        pan:MoveTo( ScrW()/2 -800/2, ScrH()/2 -35/2, 0.25 )
        pan:MoveTo( ScrW()/2 -800/2, ScrH()/2 -624/2, 0.25, 0.25 )
        pan:SetAlpha( 1 )
        pan:AlphaTo( 255, 0.25 )
        pan:SetTitle( "" )
        pan:MakePopup()
        pan.B_Closed = false
        pan.N_TabCount = 0
        pan.N_Cool = 0
        pan.S_Class = "_"
        pan.T_Buts = {}
        pan.T_Skis = {}
        pan.T_Tabs = {}
        pan.N_Buts = 0
        local function BaseButtonClickSB( id, snd )
            if snd != "!V" then
                surface.PlaySound( isstring( snd ) and snd or "ui/buttonclick.wav" )
            end
            pan.T_Buts[ id ] = 1
        end
        local function DrawButtonClickSB( self, w, h )
            if !isnumber( pan.T_Buts[ self.N_ID ] ) or pan.T_Buts[ self.N_ID ] <= 0 then return end
            local col = Color( 150, 200, 255 )
            if isvector( self.V_Color ) then
                col = Color( self.V_Color.x, self.V_Color.y, self.V_Color.z )
            end
            pan.T_Buts[ self.N_ID ] = pan.T_Buts[ self.N_ID ] or 0
            pan.T_Buts[ self.N_ID ] = pan.T_Buts[ self.N_ID ] -math.min( pan.T_Buts[ self.N_ID ], RealFrameTime()*3 )
            local Size = pan.T_Buts[ self.N_ID ]
            if Size > 0.05 then
                surface.DrawCircle( w*0.5, h*0.5, ( 1 -Size )*( w -25 ), col.r, col.g, col.b, 255*Size )
                surface.DrawCircle( w*0.5, h*0.5, ( 1 -Size )*( w -15 ), col.r, col.g, col.b, 255*0.5*Size )
                surface.DrawCircle( w*0.5, h*0.5, ( 1 -Size )*( w -10 ), col.r, col.g, col.b, 255*0.2*Size )
                surface.SetMaterial( ClickMat )
                surface.SetDrawColor( col.r*Size, col.g*Size, col.b*Size, 255*Size )
                surface.DrawTexturedRect( w*0.5 -w*0.5*Size*2, h*0.5 -h*0.5*Size*2, w*Size*2, h*Size*2 )
            end
        end
        function pan:Paint( w, h )
            draw.RoundedBox( 0, 0, 35, w, h -35, bck_col )
            if !pan.B_Closed then
                surface.SetMaterial( ClickMat )
                surface.SetDrawColor( txt_col )
                local xx, yy = pan:CursorPos()
                surface.DrawTexturedRectRotated( xx, yy, 256, 256, 0 )
            end
            draw.RoundedBox( 0, 0, 0, w, 35, tab_col )
            draw.TextShadow( {
                text = language.GetPhrase( "lsst.Menu" ),
                pos = { 12, 16 },
                font = "lsst_Font1",
                xalign = TEXT_ALIGN_LEFT,
                yalign = TEXT_ALIGN_CENTER,
                color = txt_col
            }, 1, 255 )
        end

        for k, v in pairs( lsst.Skills ) do
            if !istable( v ) or !isstring( v.Tab ) then continue end
            if !istable( pan.T_Skis[ v.Tab ] ) then
                pan.T_Skis[ v.Tab ] = {}
            end
            v.Class = k
            table.insert( pan.T_Skis[ v.Tab ], v )
        end

	    if true then
            pan.P_Close = pan:Add( "DButton" )  local pax = pan.P_Close --X button
            pax:SetText( "" )
            pax:SetPos( 760, 0 )
            pax:SetSize( 28, 28 )
            pax.B_Hover = false
            function pax:Paint( w, h )
                draw.TextShadow( {
                    text = "×",
                    pos = { w/2, h/2 },
                    font = "lsst_Font2",
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_CENTER,
                    color = ( pax.B_Hover and Color( 255, 0, 0 ) or txt_col )
                }, 2, 255 )
            end
            function pax:DoClick()
                pan.B_Closed = true
                pan:SetMouseInputEnabled( false ) pan:AlphaTo( 1, 0.25 )
                timer.Simple( 0.26, function()
                    if IsValid( pan ) then pan:Close() end
                end )
                if IsValid( pan.P_DMenu ) then pan.P_DMenu:Remove() end
                if IsValid( pan.P_Mdl ) then pan.P_Mdl:Remove() end
            end
            function pax:OnCursorEntered() pax.B_Hover = true end
            function pax:OnCursorExited() pax.B_Hover = false end
        end

        if true then
            pan.P_Right = pan:Add( "DPanel" )  local pax = pan.P_Right --status
            pax:SetPos( 74, 41 )
            pax:SetSize( 718, 575 )
            pax.N_Lerp1 = 0
            pax.N_Lerp2 = 0
            pax.V_Color = Vector( 255, 255, 255 )
            function pax:Paint( w, h )
                pax.N_Lerp1 = Lerp( 0.05, pax.N_Lerp1, 1 )
                draw.RoundedBox( 0, 0, 0, w, h, par_col )
                surface.SetDrawColor( tab_col )
                surface.DrawOutlinedRect( 0, 0, w, h, 2 )
                surface.DrawRect( 0, 0, w, 40 )
                local str, col = "lsst.Status", Vector( 255, 255, 255 )
                if pan.S_Class != "_" and istable( lsst.Tabs[ pan.S_Class ] ) then
                    local dat = lsst.Tabs[ pan.S_Class ]
                    str = dat.Name
                    col = dat.Color
                end
                if pan.S_Class != "_" and istable( lsst.Tabs[ pan.S_Class ] ) then
                    local dat = lsst.Tabs[ pan.S_Class ]
                    col = dat.Color
                end
                pax.V_Color = LerpVector( 0.02, pax.V_Color, col )
                draw.RoundedBox( 0, 2, 41, 714, 532, Color( pax.V_Color.r/4, pax.V_Color.g/4, pax.V_Color.b/4, 100 ) )
                draw.TextShadow( {
                    text = language.GetPhrase( str ),
                    pos = { w/2, 20 },
                    font = "lsst_Font2",
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_CENTER,
                    color = Color( pax.V_Color.x, pax.V_Color.y, pax.V_Color.z )
                }, 1, 255 )
            end
        end

        if true then
            pan.P_Tree = pan.P_Right:Add( "DPanel" )  local pax = pan.P_Tree --draw anything below status
            pax:SetPos( 2, 41 )
            pax:SetSize( 714, 532 )
            pax.T_Pans = {}
            function pax:Paint( w, h )
                local col = pan.P_Right.V_Color
                if !pan.B_Closed then
                    surface.SetMaterial( ClickMat )
                    surface.SetDrawColor( col.r/4, col.g/4, col.b/4 )
                    local xx, yy = self:CursorPos()
                    if pan.P_Drag and pan.P_Drag.B_Drag then
                        xx, yy = pan.P_Drag.N_DragX, pan.P_Drag.N_DragY
                        local x2, y2 = pan:GetPos()
                        local x3, y3 = pan.P_Right:GetPos()
                        local x4, y4 = pan.P_Tree:GetPos()
                        xx, yy = xx-x2-x3-x4, yy-y2-y3-y4
                    end
                    surface.DrawTexturedRectRotated( xx, yy, 256, 256, 0 )
                    for k, v in pairs( pax.T_Pans ) do
                        if !IsValid( v ) then continue end
                        if istable( v.T_Require ) then
                            for m, n in pairs( v.T_Require ) do
                                local ppp = pan.P_Tree.T_Pans[ n ]
                                if !IsValid( ppp ) then continue end
                                local col = StatCol[ v.N_Type ]
                                surface.SetDrawColor( col.r -v.N_Lerp*100, col.g -v.N_Lerp*100, col.b -v.N_Lerp*100 )
                                local x1, y1 = v:GetPos()
                                local x2, y2 = ppp:GetPos()
                                local x3, y3 = pan.P_Drag:GetPos()
                                surface.DrawLine( x1 +x3 +32, y1 +y3 +32, x2 +x3 +32, y2 +y3 +32 )
                            end
                        end
                    end
                end
            end
        end

        if true then
            pan.P_Note = pan.P_Right:Add( "DPanel" )  local pax = pan.P_Note-- red - button?
            pax:SetPos( 595, 465 )
            pax:SetSize( 150, 92 )
            pax:SetMouseInputEnabled( false )
            function pax:Paint( w, h )
                if pan.S_Class == "_" then return end
                for i=0, 3 do
                    surface.SetDrawColor( StatCol[ i+1 ] )
                    surface.DrawRect( 8, 24*i, 20, 20 )
                    surface.SetDrawColor( 0, 0, 0 )
                    surface.DrawOutlinedRect( 8, 0 +24*i, 20, 20, 2 )
                    surface.SetDrawColor( 255, 255, 255 )
                    surface.DrawOutlinedRect( 8, 0 +24*i, 20, 20, 1 )
                    draw.TextShadow( {
                        text = language.GetPhrase( LearTxt[ i+1 ] ),
                        pos = { 36, 10 +24*i },
                        font = "lsst_Font4",
                        xalign = TEXT_ALIGN_LEFT,
                        yalign = TEXT_ALIGN_CENTER,
                        color = StatCol[ i+1 ]
                    }, 1, 255 )
                end
            end
        end

        if true then
            pan.P_Left = pan:Add( "DScrollPanel" )  local pax = pan.P_Left
            pax:SetPos( 0, 35 )
            pax:SetSize( 68, 589 )
            local vba = pax:GetVBar()
            vba:SetHideButtons( true )
            vba:SetSize( 0, 0 )
            pax.N_Update = 0
            pax.N_Hover = 0
            pax.S_Select = "_"
			function vba.btnGrip:Paint( w, h ) end
            function vba:Paint( w, h ) end
            function pax:Paint( w, h )
                draw.RoundedBox( 0, 0, 0, w, h, tab_col )
            end
            function pax:OnCursorEntered()
                pan:HoverOnce()
            end
            function pax:OnCursorExited()
                pan:ExitOnce()
            end
            function pax:Think()
                if pax.N_Update > 0 and pax.N_Update <= CurTime() then
                    pax.N_Update = 0
                    if pax.N_Hover > 0 then
                        pan.P_Left:SizeTo( 68 +200, 589, 0.25 )
                    else
                        pan.P_Left:SizeTo( 68, 589, 0.25 )
                    end
                end
            end
            function pax:AddATab( cls )
                local tab = pax:Add( "DButton" ) --moving tab to the left
                pan.N_Buts = pan.N_Buts +1
                tab.N_ID = pan.N_Buts
                pan.T_Buts[ tab.N_ID ] = tab
                tab:SetSize( 272, 68 )
                tab:Dock( TOP )
                tab:SetText( "" )
                tab.N_Lerp = 0
                tab.N_Perc = 0
                tab.B_Hover = false
                tab.V_Color = Vector( 255, 255, 255 )
                tab.S_Class = "_"
                table.insert( pan.T_Tabs, tab )
                function tab:OnCursorEntered()
                    pan:HoverOnce()
                    tab.B_Hover = true
                end
                function tab:OnCursorExited()
                    pan:ExitOnce()
                    tab.B_Hover = false
                end
                function tab:DoClick()
                    if !pan:UpdateTree( tab.S_Class ) then return end
                    BaseButtonClickSB( tab.N_ID )
                    pan.S_Class = tab.S_Class
                    pan.P_Right.N_Lerp1 = 0
                end
                function tab:Paint2( w, h ) end
                function tab:Paint( w, h )
                    tab.N_Lerp = Lerp( 0.1, tab.N_Lerp, ( tab.S_Class == pan.S_Class or tab.B_Hover ) and 1 or 0 )
                    local col = Color( tab.V_Color.x, tab.V_Color.y, tab.V_Color.z )
                    surface.SetMaterial( GradMat )
                    surface.SetDrawColor( Color( col.r, col.g, col.b, tab.N_Lerp*55 ) )
                    surface.DrawTexturedRect( 0, 0, w*tab.N_Lerp, h )
                    if pan.S_Class == tab.S_Class then
                        surface.SetDrawColor( Color( 255, 255, 255, 55 ) )
                        surface.DrawOutlinedRect( 0, 0, w, h, 1 )
                        surface.SetDrawColor( Color( col.r, col.g, col.b, 55 ) )
                        surface.DrawOutlinedRect( 0, 0, w, h, 2 )
                    end
                    tab:Paint2( w, h )
                    DrawButtonClickSB( tab, w, h )
                end
                if isstring( cls ) and istable( lsst.Tabs[ cls ] ) then local dat = lsst.Tabs[ cls ]
                    tab.S_Class = cls
                    if isvector( dat.Color ) then
                        tab.V_Color = dat.Color
                    end
                    function tab:Paint2( w, h )
                        local col, alp = Color( tab.V_Color.x, tab.V_Color.y, tab.V_Color.z ), ( 100 +tab.N_Lerp*155 )
                        if tab.S_Class == pan.S_Class then alp = 255 end
                        surface.SetMaterial( dat.Icon and dat.Icon or TabMat )
                        surface.SetDrawColor( Color( col.r, col.g, col.b, alp ) )
                        surface.DrawTexturedRect( 2, 2, 64, 64 )
                        draw.TextShadow( {
                            text = dat.Name,
                            pos = { 72, h/2 -15 },
                            font = "lsst_Font1",
                            xalign = TEXT_ALIGN_LEFT,
                            yalign = TEXT_ALIGN_CENTER,
                            color = Color( col.r, col.g, col.b, alp ),
                        }, 1, alp )
                        draw.TextShadow( {
                            text = tab.N_Perc.."%",
                            pos = { 72, h/2 +15 },
                            font = "lsst_Font3",
                            xalign = TEXT_ALIGN_LEFT,
                            yalign = TEXT_ALIGN_CENTER,
                            color = Color( col.r, col.g, col.b, alp ),
                        }, 1, alp )
                    end
                else
                    pan.P_Profile = tab
                    tab.N_Points = 0
                    tab.N_Learnt = 0
                    tab.V_Color = Vector( 255, 255, 255 )
                    local avt = tab:Add( "AvatarImage" )
                    avt:SetPos( 4, 4 )
                    avt:SetSize( 60, 60 )
                    avt:SetSteamID( LocalPlayer():SteamID64(), 184 )
                    avt:SetMouseInputEnabled( false )
                    function tab:Paint2( w, h )
                        draw.TextShadow( {
                            text = language.GetPhrase( "lsst.Menu1" )..": "..tab.N_Learnt,
                            pos = { 72, h/2 -12 },
                            font = "lsst_Font3",
                            xalign = TEXT_ALIGN_LEFT,
                            yalign = TEXT_ALIGN_CENTER,
                            color = Color( 255, 255, 255 )
                        }, 1, 255 )
                        draw.TextShadow( {
                            text = language.GetPhrase( "lsst.Menu2" )..": "..tab.N_Points,
                            pos = { 72, h/2 +12 },
                            font = "lsst_Font3",
                            xalign = TEXT_ALIGN_LEFT,
                            yalign = TEXT_ALIGN_CENTER,
                            color = Color( 255, 255, 255 )
                        }, 1, 255 )
                    end
                end
                return tab
            end
            pax:AddATab()
            for k, v in pairs( lsst.Tabs ) do
                if !istable( v ) then continue end
                if v.Groups != nil and !isnumber( v.Groups[ LocalPlayer():GetUserGroup() ] ) then continue end
                if v.Teams != nil and !isnumber( v.Teams[ tostring( LocalPlayer():Team() ) ] ) then continue end
                if isstring( v.Icon ) then v.Icon = Material( v.Icon ) end
                pax:AddATab( k )
            end
        end

        function pan:UpdateTree( ski, no )
            if pan.N_Cool > CurTime() then return false end
            pan.N_Cool = CurTime() +0.5
            pan.S_Tab = ski
            pan.P_Tree.T_Pans = {}
            pan.P_Tree:Clear()
            if !no then
                pan.P_Tree:SetAlpha( 1 )
                pan.P_Tree:AlphaTo( 255, 0.5 )
                pan.P_Note:SetAlpha( 1 )
                pan.P_Note:AlphaTo( 255, 0.25 )
                pan.P_Note:SetPos( 610, 480 )
                pan.P_Note:MoveTo( 595, 465, 0.25 )
            end
            if !isstring( ski ) or ski == "_" then
            
            pan.P_Part1 = pan.P_Tree:Add( "DPanel" )  local pax = pan.P_Part1 --playermodel
            pax:SetSize( 250, 400 )
            pax:SetPos( 457, 8 )
            local mdl = pax:Add( "DModelPanel" )  pan.P_Mdl = mdl
            mdl:Dock( FILL )
	        mdl:SetModel( LocalPlayer():GetModel() )
	        local mins, maxs = mdl.Entity:GetRenderBounds()
	        mdl:SetFOV( 40 )
	        mdl:SetLookAt( ( mins + maxs ) / 2 +Vector( 0, 0, 2 ) )
            mdl:SetMouseInputEnabled( false )
            mdl.Entity:ResetSequence( "pose_standing_02" )
            mdl.Entity:SetAngles( Angle( 0, 45, 0 ) )
            mdl:SetDirectionalLight( BOX_TOP, Color( 0, 0, 0 ) )
            mdl:SetAmbientLight( Color( 255, 255, 255, 255 ) )
            function mdl.Entity:GetPlayerColor()
                return LocalPlayer():GetPlayerColor()
            end
            function mdl:LayoutEntity() return end
            function pax:Paint( w, h )
                draw.RoundedBox( 0, 0, 0, w, h, par_col )
                surface.SetDrawColor( bck_col )
                surface.DrawOutlinedRect( 0, 0, w, h, 2 )
                surface.SetDrawColor( 0, 0, 0 )
                surface.DrawOutlinedRect( 0, 0, w, h, 1 )
                if !IsValid( mdl ) then return end
                mdl.Entity:DrawModel()
            end

            pan.P_Part2 = pan.P_Tree:Add( "DButton" )  local pax = pan.P_Part2 --refresh power + playermodel box
            pax:SetSize( 250, 45 )
            pax:SetPos( 457, 420 )
            pax:SetText( "" )
            pax.B_Hover = false
            pax.N_Lerp = 0
            pan.N_Buts = pan.N_Buts +1
            pax.N_ID = pan.N_Buts
            pan.T_Buts[ pax.N_ID ] = pax
            function pax:Paint( w, h )
                local act = ( IsValid( pan.P_DMenu ) and pan.P_DMenu.P_On == pax )
                pax.N_Lerp = Lerp( 0.1, pax.N_Lerp, ( pax.B_Hover or act ) and 1 or 0 )
                draw.RoundedBox( 0, 0, 0, w, h, par_col )
                surface.SetDrawColor( bck_col )
                surface.DrawOutlinedRect( 0, 0, w, h, 2 )
                surface.SetDrawColor( 0, 0, 0 )
                surface.DrawOutlinedRect( 0, 0, w, h, 1 )
                surface.SetDrawColor( 255, 255, 255, pax.N_Lerp*255 )
                surface.DrawOutlinedRect( 0, 0, w, h, 4*pax.N_Lerp )
                surface.SetDrawColor( 155, 155, 155, pax.N_Lerp*255 )
                surface.DrawOutlinedRect( 0, 0, w, h, 2*pax.N_Lerp )
                draw.TextShadow( {
                    text = language.GetPhrase( "lsst.Refresh" ),
                    pos = { w/2, h/2 },
                    font = "lsst_Font1",
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_CENTER,
                    color = Color( 155 +pax.N_Lerp*100, 155 +pax.N_Lerp*100, 155 +pax.N_Lerp*100 )
                }, 1, 255 )
                DrawButtonClickSB( self, w, h )
            end
            function pax:OnCursorEntered() pax.B_Hover = true end
            function pax:OnCursorExited() pax.B_Hover = false end
            function pax:DoClick()
                BaseButtonClickSB( pax.N_ID )
                pan.P_DMenu = DermaMenu()
                pan.P_DMenu.P_On = pax
                local opt = pan.P_DMenu:AddOption( "Confirm", function()
                    lsst:SendCommand( "PowerReset" )
                end )
                opt:SetIcon( "icon16/tick.png" )
                pan.P_DMenu:Open()
            end

            pan.P_Part3 = pan.P_Tree:Add( "DButton" )  local pax = pan.P_Part3
            pax:SetSize( 250, 45 )
            pax:SetPos( 457, 475 )
            pax:SetText( "" )
            pax.B_Hover = false
            pax.N_Lerp = 0
            pan.N_Buts = pan.N_Buts +1
            pax.N_ID = pan.N_Buts
            pan.T_Buts[ pax.N_ID ] = pax
            function pax:Paint( w, h )
                local act = ( IsValid( pan.P_DMenu ) and pan.P_DMenu.P_On == pax )
                pax.N_Lerp = Lerp( 0.1, pax.N_Lerp, ( pax.B_Hover or act ) and 1 or 0 )
                draw.RoundedBox( 0, 0, 0, w, h, par_col )
                surface.SetDrawColor( bck_col )
                surface.DrawOutlinedRect( 0, 0, w, h, 2 )
                surface.SetDrawColor( 0, 0, 0 )
                surface.DrawOutlinedRect( 0, 0, w, h, 1 )
                surface.SetDrawColor( 255, 255, 255, pax.N_Lerp*255 )
                surface.DrawOutlinedRect( 0, 0, w, h, 4*pax.N_Lerp )
                surface.SetDrawColor( 155, 155, 155, pax.N_Lerp*255 )
                surface.DrawOutlinedRect( 0, 0, w, h, 2*pax.N_Lerp )
                draw.TextShadow( {
                    text = language.GetPhrase( "lsst.Reset" ),
                    pos = { w/2, h/2 },
                    font = "lsst_Font1",
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_CENTER,
                    color = Color( 155 +pax.N_Lerp*100, 155 +pax.N_Lerp*100, 155 +pax.N_Lerp*100 )
                }, 1, 255 )
                DrawButtonClickSB( self, w, h )
            end
            function pax:OnCursorEntered() pax.B_Hover = true end
            function pax:OnCursorExited() pax.B_Hover = false end
            function pax:DoClick()
                BaseButtonClickSB( pax.N_ID )
                pan.P_DMenu = DermaMenu()
                pan.P_DMenu.P_On = pax
                local opt = pan.P_DMenu:AddOption( "Confirm", function()
                    lsst:SendCommand( "PointReset" )
                end )
                opt:SetIcon( "icon16/tick.png" )
                pan.P_DMenu:Open()
            end

            pan.P_Part4 = pan.P_Tree:Add( "DPanel" )  local pax = pan.P_Part4
            pax:SetSize( 442, 40 )
            pax:SetPos( 6, 268 )
            pax.N_Nums = 0
            function pax:Paint( w, h )
                draw.RoundedBox( 0, 0, 0, w, h, par_col )
                draw.TextShadow( {
                    text = language.GetPhrase( "lsst.Abilities" ).." ("..pax.N_Nums..")",
                    pos = { w/2, h/2 },
                    font = "lsst_Font5",
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_CENTER,
                    color = men_col
                }, 1, 255 )
                surface.SetDrawColor( bck_col )
                surface.DrawOutlinedRect( 0, 0, w, h, 2 )
                surface.SetDrawColor( 0, 0, 0 )
                surface.DrawOutlinedRect( 0, 0, w, h, 1 )
            end

            pan.P_Part5 = pan.P_Tree:Add( "DScrollPanel" )  local pax = pan.P_Part5
            pax:SetSize( 442, 200 )
            pax:SetPos( 6, 320 )
            local vba = pax:GetVBar()
			vba:SetHideButtons( true )
            vba:SetSize( 0, 0 )
			function vba.btnGrip:Paint( w, h ) end
			function vba:Paint( w, h ) end
            pax.T_Conts = {}
            function pax:Paint( w, h )
                draw.RoundedBox( 0, 0, 0, w, h, par_col )
                surface.SetDrawColor( bck_col )
                surface.DrawOutlinedRect( 0, 0, w, h, 2 )
                surface.SetDrawColor( 0, 0, 0 )
                surface.DrawOutlinedRect( 0, 0, w, h, 1 )
            end

            pan.P_Part6 = pan.P_Tree:Add( "DPanel" )  local pax = pan.P_Part6 --Character Stats
            pax:SetSize( 442, 40 )
            pax:SetPos( 6, 8 )
            pax.N_Nums = 0
            function pax:Paint( w, h )
                draw.RoundedBox( 0, 0, 0, w, h, par_col )
                draw.TextShadow( {
                    text = language.GetPhrase( "lsst.CharacterStats" ),
                    pos = { w/2, h/2 },
                    font = "lsst_Font5",
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_CENTER,
                    color = men_col
                }, 1, 255 )
                surface.SetDrawColor( bck_col )
                surface.DrawOutlinedRect( 0, 0, w, h, 2 )
                surface.SetDrawColor( 0, 0, 0 )
                surface.DrawOutlinedRect( 0, 0, w, h, 1 )
            end

            pan.P_Part7 = pan.P_Tree:Add( "DScrollPanel" )  local pax = pan.P_Part7
            pax:SetSize( 442, 200 )
            pax:SetPos( 6, 58 )
            pan.P_Part7.T_Pars = {}
            local vba = pax:GetVBar()
			vba:SetHideButtons( true )
            vba:SetSize( 0, 0 )
			function vba.btnGrip:Paint( w, h ) end
			function vba:Paint( w, h ) end
            function pax:Paint( w, h )
                draw.RoundedBox( 0, 0, 0, w, h, par_col )
                surface.SetDrawColor( bck_col )
                surface.DrawOutlinedRect( 0, 0, w, h, 2 )
                surface.SetDrawColor( 0, 0, 0 )
                surface.DrawOutlinedRect( 0, 0, w, h, 1 )
            end
            local function FullCircle( x, y, radius, seg, col, alp )
                local cir = {}
                table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
                for i = 0, seg do
                    local a = math.rad( ( i/seg )*-360 )
                    table.insert( cir, { x = x +math.sin( a )*radius, y = y +math.cos( a )*radius, u = math.sin( a )/2 +0.5, v = math.cos( a )/2 +0.5 } )
                end
                local a = math.rad( 0 )
                table.insert( cir, { x = x +math.sin( a )*radius, y = y +math.cos( a )*radius, u = math.sin( a )/2 +0.5, v = math.cos( a )/2 +0.5 } )
	            draw.NoTexture()
                surface.SetDrawColor( Color( col.r, col.g, col.b, alp ) )
                surface.DrawPoly( cir )
            end
            local pro = LocalPlayer().lsst_Profile
            for i=1, 4 do
                local p1 = pax:Add( "DPanel" )
                table.insert( pan.P_Part7.T_Pars, p1 )
                p1:Dock( TOP )
                p1:SetSize( 0, 50 )
                p1.T_Buts = {}
                p1.N_Type = 0
                p1.N_Lerp = 0
                p1.N_Level = pro[ "Stat"..i ]
                if !isnumber( p1.N_Level ) then continue end
                function p1:Paint( w, h )
                    draw.TextShadow( {
                        text = language.GetPhrase( "lsst.Stat"..i ),
                        pos = { 16, h/2 },
                        font = "lsst_Font1",
                        xalign = TEXT_ALIGN_LEFT,
                        yalign = TEXT_ALIGN_CENTER,
                        color = Color( 255, 255, 255 )
                    }, 1, 255 )
                    for x=1, 5 do
                        FullCircle( 240 +(x-1)*38, 25, 17, 6, Color( 0, 0, 0 ) )
                        FullCircle( 240 +(x-1)*38, 25, 16, 6, Color( 0, 155, 255 ) )
                        FullCircle( 240 +(x-1)*38, 25, 14, 6, par_col )
                        if p1.N_Level +( p1.N_Type == 1 and 1 or 0 ) < x then continue end
                        local ler, le2 = 1, 1
                        if p1.N_Type > 0 and p1.N_Level +( p1.N_Type == 1 and 1 or 0 ) == x then
                            p1.N_Lerp = Lerp( 0.05, p1.N_Lerp, 1 )
                            ler, le2 = p1.N_Lerp, ( p1.N_Type == 1 and 1-ler or ler )
                        end
                        FullCircle( 240 +(x-1)*38, 25, 12*le2, 6, Color( 0, 155, 255, 255 ), 255*ler )
                        FullCircle( 240 +(x-1)*38, 25, 24*ler, 6, Color( 150, 200, 255, 255 ), 255*(1-ler) )
                    end
                end
                for x=1, 2 do
                    local p2 = p1:Add( "DButton" )
                    table.insert( p1.T_Buts, p2 )
                    p2:SetSize( 32, 32 )
                    p2:SetPos( 140 +40*(x-1), 9 )
                    p2:SetText( "" )
                    p2.B_Hover = false
                    p2.N_Lerp = 0
                    pan.N_Buts = pan.N_Buts +1
                    p2.N_ID = pan.N_Buts
                    pan.T_Buts[ p2.N_ID ] = p2
                    p2.B_Allow = ( x == 1 and p1.N_Level > 0 ) or ( x == 2 and p1.N_Level < 5 and pro.Point >= lsst.Config.StatCost )
                    p2.V_Color = ( p2.B_Allow and Vector( 0, 255, 255 ) or Vector( 255, 0, 0 ) )
                    p2.S_Class = "Stat"..i
                    p2.N_PType = 1
                    function p2:Paint( w, h )
                        p2.N_Lerp = Lerp( 0.1, p2.N_Lerp, p2.B_Hover and 1 or 0 )
                        local col = Color( p2.V_Color.x, p2.V_Color.y, p2.V_Color.z )
                        draw.RoundedBox( 0, 0, 0, w, h, par_col )
                        surface.SetDrawColor( bck_col )
                        surface.DrawOutlinedRect( 0, 0, w, h, 2 )
                        surface.SetDrawColor( 0, 0, 0 )
                        surface.DrawOutlinedRect( 0, 0, w, h, 1 )
                        surface.SetDrawColor( col )
                        surface.DrawOutlinedRect( 0, 0, w, h, p2.N_Lerp*3 )
                        draw.Text( {
                            text = ( x == 1 and "-" or "+" ),
                            pos = { w/2, h/2 },
                            font = "lsst_Font6",
                            xalign = TEXT_ALIGN_CENTER,
                            yalign = TEXT_ALIGN_CENTER,
                            color = col
                        } )
                        DrawButtonClickSB( p2, w, h )
                    end
                    function p2:OnCursorEntered()
                        p2.B_Hover = true
                        lsst.Preview = p2
                    end
                    function p2:OnCursorExited()
                        if lsst.Preview != p2 then return end
                        p2.B_Hover = false
                        lsst.Preview = nil
                    end
                    function p2:DoClick()
                        if !p2.B_Allow then
                            BaseButtonClickSB( p2.N_ID, "ui/beep_error01.wav" )
                            return
                        end
                        BaseButtonClickSB( p2.N_ID, "!V" )
                        lsst:SendCommand( "LearnStat", LocalPlayer(), i.."|"..(x-1) )
                    end
                end
            end

            local pro = LocalPlayer().lsst_Profile
            if istable( pro ) then
                for k, v in pairs( pro.Skill ) do
                    if !isstring( k ) or !isnumber( v ) or !istable( lsst.Skills[ k ] ) or !istable( lsst.Skills[ k ].Powers ) then continue end
                    for n, m in pairs( lsst.Skills[ k ].Powers ) do
                        if !isstring( n ) or !istable( lsst.Powers[ n ] ) or !isnumber( m ) then continue end
                        local det = lsst.Powers[ n ]
                        if det.Type == 3 or det.Type == 2 then
                            if !isnumber( pan.P_Part5.T_Conts[ n ] ) then pan.P_Part5.T_Conts[ n ] = 0 end
                        else
                            if !isnumber( pan.P_Part5.T_Conts[ n ] ) then pan.P_Part5.T_Conts[ n ] = 0 end
                            pan.P_Part5.T_Conts[ n ] = pan.P_Part5.T_Conts[ n ] +m
                        end
                    end
                end
            end
            local Mat = Material( "gui/center_gradient" )
            local function AddABar( cls, n )
                local tab = lsst.Powers[ cls ]
                if !istable( tab ) then return end
                local bar = pan.P_Part5:Add( "DButton" )
                pan.N_Buts = pan.N_Buts +1
                bar.N_ID = pan.N_Buts
                pan.T_Buts[ bar.N_ID ] = bar
                bar:SetText( "" )
                bar:SetSize( 0, 30 )
                bar:Dock( TOP )
                bar:DockMargin( 0, 1, 0, 1 )
                bar.S_Name = tab.Name
                bar.N_Type = tab.Type
                bar.B_Bad = tab.Bad
                bar.N_Lerp = 1
                bar.B_Hover = false
                function bar:Paint( w, h )
                    local col, sss, num = Color( 0, 255, 0 ), ( n == 0 and "" or ( n > 0 and "+" or "" ) ), ""
                    if ( bar.B_Bad and n > 0 ) or n < 0 then col = Color( 255, 0, 0 ) end
                    if bar.N_Type == 3 then sss, num, col = "", "", Color( 0, 155, 255 )
                    elseif bar.N_Type == 2 then sss, num = "", ""
                    elseif bar.N_Type == 1 then num = n.."%" else num = tostring( n ) end
                    if !isvector( bar.V_Color ) then
                        bar.V_Color = Vector( col.r, col.g, col.b )
                    end
                    surface.SetMaterial( Mat )
                    surface.SetDrawColor( col.r, col.g, col.b, 55 +50*bar.N_Lerp/2 )
                    surface.DrawTexturedRect( 0, 0, w, h )
                    draw.TextShadow( {
                        text = language.GetPhrase( bar.S_Name ).." "..sss..num,
                        pos = { w/2, h/2 },
                        font = "lsst_Font3",
                        xalign = TEXT_ALIGN_CENTER,
                        yalign = TEXT_ALIGN_CENTER,
                        color = col
                    }, 1, 255 )
                    surface.SetDrawColor( col.r, col.g, col.b, 155 )
                    surface.DrawOutlinedRect( 2, 1, w -4, h -2, bar.N_Lerp )
                    surface.SetDrawColor( col.r/4, col.g/4, col.b/4, 155 )
                    surface.DrawOutlinedRect( 2, 1, w -4, h -2, bar.N_Lerp/2 )
                    if bar.N_Type != 3 or !isstring( tab.Ability ) then return end
                    bar.N_Lerp = Lerp( 0.1, bar.N_Lerp, bar.B_Hover and 4 or 1 )
                    DrawButtonClickSB( self, w, h )
                end
                if bar.N_Type != 3 or !isstring( tab.Ability ) then return end
                function bar:OnCursorEntered() bar.B_Hover = true end
                function bar:OnCursorExited() bar.B_Hover = false end
                function bar:DoClick()
                    lsst:SendCommand( "GiveAbility", LocalPlayer(), cls )
                    BaseButtonClickSB( bar.N_ID, "!V" )
                end
            end

            for k, v in pairs( pan.P_Part5.T_Conts ) do
                pan.P_Part4.N_Nums = pan.P_Part4.N_Nums +1
                AddABar( k, v )
            end

            return true end

            if !istable( pan.T_Skis[ ski ] ) then return true end

            local tab, dat = lsst.Tabs[ ski ], pan.T_Skis[ ski ]
            pan.P_Drag = pan.P_Tree:Add( "DPanel" )  local pax = pan.P_Drag
            pax:SetSize( 8192, 8192 )
            pax:SetPos( -4096, -4096 )
            pax.N_Count = 0
            pax.N_DragX = 0
            pax.N_DragY = 0
            pax.N_MoveX = tab.StartX and tab.StartX or 0
            pax.N_MoveY = tab.StartY and tab.StartY or ( no and 0 or -64 )
            pax.N_ToX = 0
            pax.N_ToY = 0
            pax.N_MinX = -4096
            pax.N_MaxX = 4096
            pax.N_MinY = -4096
            pax.N_MaxY = 4096
            pax.B_Drag = false
            function pax:Paint( w, h ) end
            function pax:OnMousePressed()
                if !isbool( pax.B_Drag ) then return end
                pax:SetCursor( "blank" )
                pax.B_Drag = true
                pax.N_DragX, pax.N_DragY = input.GetCursorPos()
                for k, v in pairs( pan.P_Tree.T_Pans ) do
                    v:SetMouseInputEnabled( false )
                end
            end
            function pax:OnMouseReleased()
                if !isbool( pax.B_Drag ) then return end
                pax:SetCursor( "sizeall" )
                pax.B_Drag = false
                for k, v in pairs( pan.P_Tree.T_Pans ) do
                    v:SetMouseInputEnabled( true )
                end
            end
            function pax:OnCursorExited()
                if !isbool( pax.B_Drag ) then return end
                pax:SetCursor( "sizeall" )
                pax.B_Drag = false
                for k, v in pairs( pan.P_Tree.T_Pans ) do
                    v:SetMouseInputEnabled( true )
                end
            end
            function pax:Think()
                pax.N_MoveX = math.Round( Lerp( 0.1, pax.N_MoveX, pax.N_ToX ), 3 )
                pax.N_MoveY = math.Round( Lerp( 0.1, pax.N_MoveY, pax.N_ToY ), 3 )
                pax:SetPos( math.Clamp( -4096 -pax.N_MoveX, -8192, 0 ), math.Clamp( -4096 -pax.N_MoveY, -8192, 0 ) )
            end
            for k, v in pairs( dat ) do pax.N_Count = pax.N_Count +1
                if isstring( v.Icon ) then v.Icon = Material( v.Icon ) end
                local but = pan.P_Drag:Add( "DButton" )
                but:SetSize( 64, 64 )
                but:SetPos( 4096 +v.PosX, 4096 +v.PosY )
                but:SetText( "" )
                but:SetCursor( "crosshair" )
                but.S_Class = v.Class
                but.B_Hover = false
                but.N_Lerp = 1
                but.N_Type = 1
                pan.N_Buts = pan.N_Buts +1
                but.N_ID = pan.N_Buts
                but.N_PType = 0
                pan.T_Buts[ but.N_ID ] = but
                pax.N_MaxX = math.min( pax.N_MaxX, v.PosX )
                pax.N_MinX = math.max( pax.N_MinX, v.PosX )
                pax.N_MaxY = math.min( pax.N_MaxY, v.PosY )
                pax.N_MinY = math.max( pax.N_MinY, v.PosY )
                pan.P_Tree.T_Pans[ v.Class ] = but
                function but:UpdateStat()
                    but.N_Type = 1
                    but.T_Require = nil
                    local pro, dat = LocalPlayer().lsst_Profile, lsst.Skills[ but.S_Class ]
                    if !istable( pro ) or !istable( dat ) then return end
                    if istable( dat.Require ) then
                        but.T_Require = dat.Require
                        for k, v in pairs( dat.Require ) do
                            if isstring( v ) and !isnumber( pro.Skill[ v ] ) then return end
                        end
                    end
                    if isnumber( pro.Skill[ but.S_Class ] ) then
                        but.N_Type = 4
                        return
                    end
                    but.N_Type = 2
                    if pro.Point >= dat.Point then
                        but.N_Type = 3
                    end
                end
                but:UpdateStat()
                function but:Paint( w, h )
                    local act = ( IsValid( pan.P_DMenu ) and pan.P_DMenu.P_On == but )
                    but.N_Lerp = Lerp( 0.1, but.N_Lerp, ( but.B_Hover or act ) and 0 or 1 )
                    local col = StatCol[ but.N_Type ]
                    if v.Icon and !isstring( v.Icon ) then
                        surface.SetDrawColor( 255, 255, 255 )
                        surface.SetMaterial( v.Icon )
                        surface.DrawTexturedRect( 0, 0, w, h )
                    else
                        local col = StatCol[ but.N_Type ]
                        surface.SetDrawColor( Color( col.r/2, col.g/2, col.b/2 ) )
                        surface.DrawRect( 0, 0, w, h )
                        local mark = markup.Parse( language.GetPhrase( v.Name ) )
                        mark:Draw( w/2, h/2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 255, TEXT_ALIGN_CENTER )
                    end
                    surface.SetDrawColor( 255, 255, 255, 255 -but.N_Lerp*100 )
                    surface.SetMaterial( ZoomMat )
                    surface.DrawTexturedRectRotated( w/2, h/2, w, h, 0 )
                    surface.DrawTexturedRectRotated( w/2, h/2, w, h, 180 )
                    surface.SetDrawColor( col.r -but.N_Lerp*100, col.g -but.N_Lerp*100, col.b -but.N_Lerp*100 )
                    surface.DrawOutlinedRect( 0, 0, w, h, 2 )
                    surface.SetDrawColor( 0, 0, 0 )
                    surface.DrawOutlinedRect( 0, 0, w, h, 1 )
                    DrawButtonClickSB( but, w, h )
                end
                function but:OnCursorEntered()
                    but.B_Hover = true
                    lsst.Preview = but
                    lsst.PStatus = but.N_Type
                end
                function but:OnCursorExited()
                    if lsst.Preview != but then return end
                    lsst.Preview = nil
                    but.B_Hover = false
                end
                function but:DoClick()
                    but.V_Color = StatCol[ but.N_Type ]
                    but.V_Color = Vector( but.V_Color.r, but.V_Color.g, but.V_Color.b )
                    if but.N_Type == 2 then
                        BaseButtonClickSB( but.N_ID, "resource/warning.wav" )
                        lsst:SendHint( "lsst.NotEnough", "!V", 1 )
                        return
                    end
                    if but.N_Type == 1 then
                        BaseButtonClickSB( but.N_ID, "resource/warning.wav" )
                        lsst:SendHint( "lsst.CantLearn", "!V", 1 )
                        return
                    end
                    if but.N_Type != 3 then
                        BaseButtonClickSB( but.N_ID, "buttons/lightswitch2.wav" )
                        return
                    end
                    BaseButtonClickSB( but.N_ID )
                    if IsValid( pan.P_DMenu ) then pan.P_DMenu:Remove() end
                    local cls = but.S_Class
                    pan.P_DMenu = DermaMenu()
                    pan.P_DMenu.P_On = but
                    local lea = pan.P_DMenu:AddOption( "Learn", function()
                        lsst:LearnSkill( cls, LocalPlayer() )
                    end )
                    lea:SetIcon( "icon16/book.png" )
                    pan.P_DMenu:Open()
                end
            end
            if ( ( pax.N_MaxX < 0 or pax.N_MinX > 714 ) and pax.N_Count > 1 ) or ( ( pax.N_MaxY < 0 or pax.N_MinY > 532 ) and pax.N_Count > 1 ) then
                pax:SetCursor( "sizeall" )
            else pax.B_Drag = nil end
            return true
        end
        function pan:HoverOnce()
            pan.P_Left.N_Update = 1
            pan.P_Left.N_Hover = pan.P_Left.N_Hover +1
        end
        function pan:ExitOnce()
            pan.P_Left.N_Update = CurTime() +0.25
            pan.P_Left.N_Hover = pan.P_Left.N_Hover -1
        end
        function pan:UpdateMenu()
            pan:UpdateTree( pan.S_Class, true )
            pan:UpdateStat()
            if !istable( pan.T_Tabs ) or #pan.T_Tabs <= 0 then return end
            for k, v in pairs( pan.T_Tabs ) do
                local pro = LocalPlayer().lsst_Profile  if !istable( pro ) then break end
                if !IsValid( v ) or !isstring( v.S_Class ) or v.S_Class == "_" then continue end
                local dat = pan.T_Skis[ v.S_Class ]  if !istable( dat ) or #dat <= 0 then continue end
                local n1, n2 = 0, 0
                for m, n in pairs( dat ) do
                    n1 = n1 +1
                    if isnumber( pro.Skill[ n.Class ] ) then
                        n2 = n2 +1
                    end
                end
                v.N_Perc = math.Round( math.Clamp( n2/n1, 0, 1 )*100, 1 )
            end
            if IsValid( pan.P_Profile ) then
                local pro = LocalPlayer().lsst_Profile
                pan.P_Profile.N_Points = pro.Point
                local num = 0
                for k, v in pairs( pro.Skill ) do num = num +1 end
                pan.P_Profile.N_Learnt = num
            end
        end
        function pan:UpdateStat()
            if !IsValid( pan.P_Part7 or !istable( pan.P_Part7.T_Pars ) ) then return end
            local pro = LocalPlayer().lsst_Profile
            for k, v in pairs( pan.P_Part7.T_Pars ) do
                v.N_Lerp = 0
                if v.N_Level != pro[ "Stat"..k ] then
                    v.N_Type = ( v.N_Level > pro[ "Stat"..k ] and 1 or 2 )
                else
                    v.N_Type = 0
                end
                v.N_Level = pro[ "Stat"..k ]
                for i=1, 2 do
                    v.T_Buts[ i ].B_Allow = ( i == 1 and v.N_Level > 0 ) or ( i == 2 and v.N_Level < 5 and pro.Point >= lsst.Config.StatCost )
                    v.T_Buts[ i ].V_Color = ( v.T_Buts[ i ].B_Allow and Vector( 0, 255, 255 ) or Vector( 255, 0, 0 ) )
                end
            end
        end
        pan:UpdateMenu()
    end
end

if CLIENT then
    lsst.Menu = nil
    lsst.PStatus = 0
    lsst.Preview = nil
    lsst.PType = 0
    lsst.APreview = nil
    lsst.APType = 0
    lsst.ALerp = 0
    lsst.APosX = 0
    lsst.APosY = 0
    lsst.Langs = {}
    lsst.Langs[ "en" ] = {
        [ "Menu" ] = "[LSCS] - Skill Tree",
        [ "Menu1" ] = "Skills Learnt",
        [ "Menu2" ] = "Skill Points",
        [ "Status" ] = "Status",
        [ "Unavailable" ] = "Unavailable",
        [ "Insufficient" ] = "Insufficient",
        [ "Available" ] = "Available",
        [ "Learnt" ] = "Learnt",
        [ "Points" ] = "Points",
        [ "Learn" ] = "Learn",
        [ "NotEnough" ] = "Not enough skill points!",
        [ "CantLearn" ] = "You cant learn this skill now!",
        [ "Success" ] = "Skill Learnt",
        [ "Abilities" ] = "Abilities",
        [ "Ability" ] = "Ability",
        [ "Refresh" ] = "Refresh Power",
        [ "Reset" ] = "Reset Skills",
        [ "Confirm" ] = "Confirm",
        [ "Success2" ] = "Your Skills have been reset.",
        [ "Success3" ] = "Powerup Refreshed.",
        [ "Success4" ] = "Ability Given",
        [ "CharacterStats" ] = "Character Stats",
        [ "Stat1" ] = "Fortitude",
        [ "Stat2" ] = "Stamina",
        [ "Stat3" ] = "Endurance",
        [ "Stat4" ] = "Intelligence",
        [ "DStat1" ] = "Increases the users max health by 80 and damage by 2% with each point.",
        [ "DStat2" ] = "Increases the users speed by 10% and avoid chance by 2% with each point.",
        [ "DStat3" ] = "Increases the users damage resistance by 3% and health regeneration with each point.",
        [ "DStat4" ] = "Increases the users crit chance by 2% and max force point by 20% with each point.",
        [ "Require" ] = "Requires",
    }
    timer.Simple( 0.1, function()
	    local ln, lg = GetConVar( "gmod_language" ):GetString(), "en"
	    if ln != nil and istable( lsst.Langs[ ln ] ) then
            lg = GetConVar( "gmod_language" ):GetString()
        end
        if !istable( lsst.Langs[ lg ] ) then return end
	    for hld, txt in pairs( lsst.Langs[ lg ] ) do
            language.Add( "lsst."..hld, txt )
        end
    end )
    surface.CreateFont( "lsst_Font1", { font = "obsidian", size = 25, weight = 100, antialias = true, bold = true } )
    surface.CreateFont( "lsst_Font2", { font = "obsidian", size = 40, weight = 100, antialias = true, bold = true } )
    surface.CreateFont( "lsst_Font3", { font = "obsidian", size = 20, weight = 100, antialias = true, bold = true } )
    surface.CreateFont( "lsst_Font4", { font = "obsidian", size = 15, weight = 100, antialias = true, bold = true } )
    surface.CreateFont( "lsst_Font5", { font = "obsidian", size = 30, weight = 100, antialias = true, bold = true } )
    surface.CreateFont( "lsst_Font6", { font = "tahoma", size = 30, weight = 100, antialias = true, bold = true } )

    hook.Add( "InitPostEntity", "Hook_lsst_NeedProfile", function()
        net.Start( "NET_lsst_NeedProfile" )
        net.SendToServer()
    end )
    hook.Add( "Think", "Hook_lsst_StupidMouseLock", function()
        if IsValid( lsst.Menu ) and IsValid( lsst.Menu.P_Drag ) then
            local pax = lsst.Menu.P_Drag
            if pax.B_Drag and isnumber( pax.N_DragX ) and isnumber( pax.N_DragY ) then
                local xx, yy = input.GetCursorPos()
                xx, yy = xx-pax.N_DragX, yy-pax.N_DragY
                pax.N_ToX = math.Clamp( pax.N_ToX -xx, pax.N_MaxX -64, pax.N_MinX -714/2 -224 )
                pax.N_ToY = math.Clamp( pax.N_ToY -yy, pax.N_MaxY -56, pax.N_MinY -532/2 -144 )
                input.SetCursorPos( pax.N_DragX, pax.N_DragY )
            end
        end
    end )
    hook.Add( "DrawOverlay", "Hook_lsst_Info", function()
        local pan, ply, pro, ani = lsst.Preview, LocalPlayer(), LocalPlayer().lsst_Profile, false
        local dat, typ = "_", -1
		if IsValid( pan ) then
            dat, typ = pan.S_Class, pan.N_PType
            lsst.APreview, lsst.APType = dat, typ
            if lsst.ALerp >= 0.998 then
                lsst.ALerp = 1
            else
                lsst.ALerp = Lerp( 0.1, lsst.ALerp, 1 )
            end
		elseif lsst.APreview != "_" and lsst.ALerp != 0 then
            dat, typ = lsst.APreview, lsst.APType
            if lsst.ALerp <= 0.002 then
                lsst.ALerp = 0
                lsst.PStatus = 0
            else
                lsst.ALerp = Lerp( 0.1, lsst.ALerp, 0 )
            end
            ani = true
        end
        if dat != "_" and typ != -1 and ( typ != 0 or istable( lsst.Skills[ dat ] ) ) then
            local xx, yy = input.GetCursorPos()
            local str = ""
            if ani then
                xx, yy = lsst.APosX, lsst.APosY
            else
                lsst.APosX, lsst.APosY = xx, yy
            end
            if typ == 0 then
                local tab = lsst.Skills[ dat ]
                str = "<font=TargetID>"..string.Replace( language.GetPhrase( tab.Name ), "\n", " " ).."</font>\n"
                if isstring( tab.Info ) then
                    str = str.."<font=TargetIDSmall><color=155,155,155,255>'"..language.GetPhrase( tab.Info ).."'</color></font>\n"
                end
                if istable( tab.Powers ) then
                    for k, v in SortedPairs( tab.Powers ) do
                        if !istable( lsst.Powers[ k ] ) then continue end
                        local det, col, num = lsst.Powers[ k ], Color( 0, 255, 0 ), ( v == 0 and "" or ( v > 0 and "+" or "" ) ), ""
                        if ( det.Bad and v > 0 ) or v < 0 then col = Color( 255, 0, 0 ) end
                        if det.Type == 3 then num, col = language.GetPhrase( "lsst.Ability" ), Color( 255, 255, 0 )
                        elseif det.Type == 2 then num = ""
                        elseif det.Type == 1 then num = v.."%" else num = tostring( v ) end
                        str = str.."<font=TargetIDSmall><color="..col.r..","..col.g..","..col.b..",255>"..language.GetPhrase( det.Name ).." "..num.."</color></font>\n"
                    end
                end
                if istable( pro ) and lsst.PStatus > 0 then
                    local txt, col = LearTxt[ lsst.PStatus ], StatCol[ lsst.PStatus ]
                    if lsst.PStatus != 1 and lsst.PStatus < 4 then
                        str = str.."<font=TargetIDSmall><color=255,255,255,255>"..language.GetPhrase( "lsst.Points" )..": </color><color="..col.r..","..col.g..","..col.b..",255>"..tab.Point.."</color></font>\n"
                    elseif lsst.PStatus == 1 and istable( tab.Require ) then
                        local ext = ""
                        for k, v in pairs( tab.Require ) do
                            if !istable( lsst.Skills[ v ] ) then continue end
                            ext = ext..( isnumber( pro.Skill[ v ] ) and "<color=0,255,255,255>" or "<color=255,0,0,255>" ).." "..lsst.Skills[ v ].Name.."</color>"
                        end
                        str = str.."<font=TargetIDSmall><color=255,255,255,255>"..language.GetPhrase( "lsst.Require" )..": </color>"..ext.."</font>\n"
                    else
                        str = str.."<font=TargetIDSmall><color="..col.r..","..col.g..","..col.b..",255>"..language.GetPhrase( txt ).."</color></font>\n"
                    end
                end
            elseif typ == 1 then
                str = "<font=TargetID>"..language.GetPhrase( "lsst."..dat ).."</font>\n"
                str = str.."<font=TargetIDSmall><color=155,155,155,255>"..language.GetPhrase( "lsst.D"..dat ).."</color></font>\n"
                if istable( pro ) then
                    local pot, col = lsst.Config.StatCost, Color( 255, 255, 0 )
                    str = str.."<font=TargetIDSmall><color=255,255,255,255>"..language.GetPhrase( "lsst.Points" )..": </color><color="..col.r..","..col.g..","..col.b..",255>±"..pot.."</color></font>\n"
                end
            end
			local mark = markup.Parse( str, 300 )
            local ww, hh = mark:GetWidth(), mark:GetHeight()
			local per = lsst.ALerp
            local aaa = per*255
            local col = bck_col
            yy = yy +30
			render.SetScissorRect( xx -ww/2 -10, yy -10, xx +( ww/2 +10 )*per, yy +( hh +10 )*per, true )
            if !ani then surface.SetDrawColor( 255, 255, 255, 255-aaa )
            surface.DrawRect( xx -ww/2 -10, yy -10, ww +20, hh +20 ) end
			draw.RoundedBox( 0, xx -ww/2 -10, yy -10, ww +20, hh +20, Color( col.r, col.g, col.b, aaa ) )
			surface.SetDrawColor( col.r*2, col.g*2, col.b*2, aaa )
            surface.DrawOutlinedRect( xx -ww/2 -10, yy -10, ww +20, hh +20, 2 )
			surface.SetDrawColor( 0, 0, 0, aaa )
            surface.DrawOutlinedRect( xx -ww/2 -10, yy -10, ww +20, hh +20, 1 )
            mark:Draw( xx, yy, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, aaa )
			render.SetScissorRect( 0, 0, 0, 0, false )
        end
    end )
    net.Receive( "NET_lsst_OpenMenu", function()
        lsst:OpenMenu()
    end )
    net.Receive( "NET_lsst_SendProfile", function()
        local pro, men = util.JSONToTable( net.ReadString() ), net.ReadString()
        if IsValid( LocalPlayer() ) and istable( pro ) then
            LocalPlayer().lsst_Profile = pro
            timer.Create( "lsst_UpdateProfile", 0.1, 1, function()
                if !IsValid( lsst.Menu ) then return end
                if men == "YES" then
                    lsst.Menu:UpdateMenu()
                else
                    lsst.Menu:UpdateStat()
                end
            end )
        end
    end )
    net.Receive( "NET_lsst_SendHint", function()
        local txt = net.ReadString()
        local snd = net.ReadString()
        local typ = net.ReadFloat()
        lsst:SendHint( txt, snd, typ, nil )
    end )
end

if SERVER then
    lsst.Restricted = {}
    util.AddNetworkString( "NET_lsst_OpenMenu" )
    util.AddNetworkString( "NET_lsst_NeedProfile" )
    util.AddNetworkString( "NET_lsst_Learn" )
    util.AddNetworkString( "NET_lsst_SendHint" )
    util.AddNetworkString( "NET_lsst_Command" )
    util.AddNetworkString( "NET_lsst_SendProfile" )

	function lsst:ProfileLoad( ply )
        if !ply:IsPlayer() or !isstring( ply:SteamID() ) then return end
		local txt = string.lower( string.Replace( ply:SteamID(), ":", "_" ) )
        if !file.IsDir( "lsstdata", "DATA" ) then file.CreateDir( "lsstdata" ) end
		local pat = ( "lsstdata/"..txt..".txt" )
        local pro = ( file.Exists( pat, "DATA" ) and util.JSONToTable( file.Read( pat, "DATA" ) ) or { Point = 0, Stat1 = 0, Stat2 = 0, Stat3 = 0, Stat4 = 0, Skill = {} } )
        for k, v in pairs( pro.Skill ) do
            if !isstring( k ) or !isnumber( v ) then continue end
            local det = lsst.Skills[ k ]  if !istable( det ) then continue end
            local tab = lsst.Tabs[ det.Tab ] if !istable( tab ) then continue end
            if istable( tab.Groups ) and !isnumber( tab.Groups[ ply:GetUserGroup() ] ) then pro.Skill[ k ] = nil continue end
            if istable( tab.Teams ) and !isnumber( tab.Teams[ tostring( ply:Team() ) ] ) then pro.Skill[ k ] = nil continue end
        end
		lsst:ProfileUpdate( ply, pro )
    end
    function lsst:PointGive( ply, amo )
        if !ply:IsPlayer() or !isstring( ply:SteamID() ) or !isnumber( amo ) or amo == 0 then return end
        local pot = self:PointGet( ply )
        ply.lsst_Profile.Point = math.Clamp( pot +amo, 0, 2147483647 )
        lsst:ProfileUpdate( ply )
    end
    function lsst:PowerGet( ply, ext )
        if !ply:IsPlayer() or !isstring( ply:SteamID() ) or !istable( ply.lsst_Profile ) then return nil end
        local dat = ply.lsst_Profile.Skill
        if !istable( dat ) then return nil end
        if ext == nil or !istable( ply.lsst_Power ) then
            ply.lsst_Power, ply.lsst_Ability = nil, {}
            local tab = {}
            for k, v in pairs( dat ) do
                local ski = lsst.Skills[ k ]
                if !istable( ski ) or !istable( ski.Powers ) then continue end
                for m, n in pairs( ski.Powers ) do
                    if !isstring( m ) or !istable( lsst.Powers[ m ] ) or !isnumber( n ) then continue end
                    local inn = lsst.Powers[ m ]
                    if inn.Type == 3 or inn.Type == 2 then
                        tab[ m ] = 0
                        if inn.Type == 3 and isstring( inn.Ability ) then
                            ply.lsst_Ability[ inn.Ability ] = 0
                        end
                    else
                        if !istable( tab[ m ] ) then tab[ m ] = 0 end
                        tab[ m ] = tab[ m ] +n
                    end
                end
            end
            ply.lsst_Power = tab
            return tab
        else
            local tab, ta2, ta3 = ply.lsst_Power, ( isstring( ext ) and lsst.Skills[ ext ] or nil ), {}
            if !istable( ta2 ) or !istable( ta2.Powers ) then
                return tab
            end
            for m, n in pairs( ta2.Powers ) do
                if !isstring( m ) or !istable( lsst.Powers[ m ] ) or !isnumber( n ) then continue end
                local inn = lsst.Powers[ m ]
                if inn.Type == 3 or inn.Type == 2 then
                    tab[ m ] = 0
                    if inn.Type == 3 and isstring( inn.Ability ) then
                        ply.lsst_Ability[ inn.Ability ] = 0
                    end
                else
                    if !istable( tab[ m ] ) then tab[ m ] = 0 end
                    tab[ m ] = tab[ m ] +n
                end
            end
            ply.lsst_Power = tab
            return tab
        end
    end
    function lsst:PowerGain( ply, ext )
        if !ply:IsPlayer() or !isstring( ply:SteamID() ) or !istable( ply.lsst_Profile ) then return end
        local pow, pro = lsst:PowerGet( ply, ext ), ply.lsst_Profile
        if !istable( pow ) then return end
        if ext then
            ply:SetMaxHealth( math.max( ply:GetMaxHealth(), 100 +80*pro.Stat1 ) )
            ply:SetWalkSpeed( math.max( ply:GetWalkSpeed(), 200 +20*pro.Stat2 ) )
            ply:SetRunSpeed( math.max( ply:GetRunSpeed(), 400 +20*pro.Stat2 ) )
            local ti1 = "["..ply:EntIndex().."]lsst_regenhp"
            timer.Remove( ti1 )
            if pro.Stat3 > 0 then
                timer.Create( ti1, 2 -pro.Stat3*0.2, 0, function()
                    if !IsValid( ply ) or !ply:Alive() then timer.Remove( ti1 ) return end
                    if ply:GetMaxHealth() <= ply:Health() then return end
                    ply:SetHealth( math.min( ply:GetMaxHealth(), ply:Health() +1 ) )
                end )
            end
            if pro.Stat4 > 0 then
                ply:lscsSetMaxForce( 100 +pro.Stat4*20 )
                ply:lscsBuildPlayerInfo()
            end
        end
        local equ = table.Inherit( {}, ply.lsst_Ability )
        local inv, slo = ply:lscsGetInventory(), 0
        if istable( inv ) and lsst.Config.Restrict then
            slo = #inv
            for k, v in pairs( inv ) do
                if isstring( v ) and !isnumber( equ ) and isnumber( lsst.Restricted[ v ] ) then
                    slo = slo -1
                    ply:lscsRemoveItem( k )
                elseif isstring( v ) and isnumber( equ[ v ] ) then
                    abi = abi -1
                    abn[ v ] = nil
                end
            end
        end
		ply:lscsSyncInventory()
		ply:lscsBuildPlayerInfo()
    end
    function lsst:HasAbility( ply, str )
        if !IsValid( ply ) or !istable( ply.lsst_Ability ) or !isstring( str ) or str == "" or str == "_" then return end
        return isnumber( ply.lsst_Ability[ str ] )
    end

    hook.Add( "LSCS:PlayerInventory", "Hook_lsst_Restricted", function( ply, ite, id )
        if lsst.Config.Restrict and isnumber( lsst.Restricted[ ite ] ) then
            if istable( ply.lsst_Ability ) and isnumber( ply.lsst_Ability[ ite ] ) then return end
            return true
        end
    end )
    hook.Add( "LSCS:OnPlayerDroppedItem", "Hook_lsst_RestrictItem", function( ply, ite )
        if lsst.Config.Restrict and isnumber( lsst.Restricted[ ite:GetClass() ] ) then
            ite:Remove()
        end
    end )
    hook.Add( "PlayerSpawn", "Hook_lsst_GivePower", function( ply )
        timer.Simple( 0, function()
            if !IsValid( ply ) or !ply:Alive() then return end
            lsst:PowerGain( ply, true )
        end )
    end )
    net.Receive( "NET_lsst_NeedProfile", function( len, ply )
        if len > 0 or !ply:IsPlayer() or istable( ply.lsst_Profile ) then return end
        lsst:ProfileLoad( ply )
    end )
    net.Receive( "NET_lsst_Learn", function( len, ply )
        if len <= 0 or len > 512 or !ply:IsPlayer() then return end
        if isnumber( ply.lsst_Cool ) and ply.lsst_Cool > CurTime() then return end
        ply.lsst_Cool = CurTime() +0.25
        local cls = net.ReadString()
        lsst:LearnSkill( cls, ply )
    end )
    net.Receive( "NET_lsst_Command", function( len, ply )
        if len <= 0 or len > 512 or !ply:IsPlayer() then return end
        if isnumber( ply.lsst_Cool ) and ply.lsst_Cool > CurTime() then return end
        local cmd, dat = net.ReadString(), net.ReadString()
        ply.lsst_Cool = CurTime() +( cmd == "LearnStat" and 0.25 or 1 )
        lsst:SendCommand( cmd, ply, dat )
    end )
end

list.Set( "DesktopWindows", "LSCSSkillTree", {
	title = "[LSCS] Skill Tree",
	icon = "lscs/ui/icon64.png",
	init = function( icon, window ) lsst:OpenMenu() end
} )
concommand.Add( "lscs_openskilltree", function( ply, cmd, args ) lsst:OpenMenu() end )
local fil, dir = file.Find( "lsst/*.lua", "LUA" ) if !fil or !dir then return end
for _, out in pairs( fil ) do if SERVER then AddCSLuaFile( "lsst/"..out ) end include( "lsst/"..out ) end
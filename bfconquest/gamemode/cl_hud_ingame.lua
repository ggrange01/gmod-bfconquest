--Scoreboard, round end, warnings, points

newPoints = { }
lastPointsDraw = 0
alpha = 0
currenText = ""

function DrawPoints()
	if alpha <= 0 then
		if table.IsEmpty( newPoints ) then return end
		local text = table.remove( newPoints, 1 )
		if text == "" then return end
		currenText = text
		alpha = 255
	end
	if currenText == "" then return end
	draw.Text( {
		text = currenText,
		font = "BF4_Ammo_Main",
		pos = { ScrW() * 0.5, ScrH() * 0.7},
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_CENTER,
		color = Color( 240, 240, 240, alpha )
	} )
	alpha = alpha - 2
end
hook.Add( "DrawOverlay", "PointsHUD", DrawPoints )

function DrawTags()
	if !GameStarted then return end
	if !LocalPlayer().GetBFCTeam then return end
	local ply = LocalPlayer():GetEyeTrace().Entity
	if ply.GetBFCTeam then
		if IsValid( ply ) and ply:IsPlayer() then
			if LocalPlayer():GetPos():Distance( ply:GetPos() ) < 3000 or ply:GetBFCTeam() == LocalPlayer():GetBFCTeam() then
				local pos = ( ply:GetPos() + Vector( 0, 0, 85 ) ):ToScreen()
				local color = GetTeamColor( ply:GetBFCTeam() )
				local wx, wy = draw.Text( {
					text = ply:GetName(),
					font = "BF4_Small+",
					pos = { pos.x, pos.y },
					xalign = TEXT_ALIGN_CENTER,
					yalign = TEXT_ALIGN_CENTER,
					color = color
				} )
				surface.SetDrawColor( Color( 75, 75, 75, 150 ) )
				surface.DrawRect( pos.x - wx / 2 - 5, pos.y - wy / 2 - 3, wx + 10, wy + 6 )
				draw.Text( {
					text = ply:GetName(),
					font = "BF4_Small+",
					pos = { pos.x, pos.y },
					xalign = TEXT_ALIGN_CENTER,
					yalign = TEXT_ALIGN_CENTER,
					color = color
				} )
			end
		end
	end
	for k, v in pairs( GetPlayersByTeam( LocalPlayer():GetBFCTeam() ) ) do
		if v != LocalPlayer() then
			local trpos = util.TraceLine( {
				start = LocalPlayer():EyePos(),
				endpos = v:GetPos(),
				filter = { LocalPlayer(), v }
			} )
			local treyes = util.TraceLine( {
				start = LocalPlayer():EyePos(),
				endpos = v:EyePos(),
				filter = { LocalPlayer(), v }
			} )
			if ( !trpos.Hit or !treyes.Hit ) and v:Alive() and !v:GetNoDraw() then
				local pos = ( v:GetPos() + Vector( 0, 0, 85 ) ):ToScreen()
				local color = GetTeamColor( v:GetBFCTeam() )
				local wx, wy = draw.Text( {
					text = v:GetName(),
					font = "BF4_Small+",
					pos = { pos.x, pos.y },
					xalign = TEXT_ALIGN_CENTER,
					yalign = TEXT_ALIGN_CENTER,
					color = Color( 0, 0, 0, 0 )
				} )
				surface.SetDrawColor( Color( 75, 75, 75, 100 ) )
				surface.DrawRect( pos.x - wx / 2 - 5, pos.y - wy / 2 - 3, wx + 10, wy + 6 )
				draw.Text( {
					text = v:GetName(),
					font = "BF4_Small+",
					pos = { pos.x, pos.y },
					xalign = TEXT_ALIGN_CENTER,
					yalign = TEXT_ALIGN_CENTER,
					color = Color( color.r, color.g, color.b, 100 )
				} )
			end
		end
	end
end
hook.Add( "HUDPaint", "DrawTags", DrawTags )

function DrawPlayersWaiting()
	if !GameStarted and #player.GetAll() < 2 then
		draw.Text( {
			text = GetLangMessage( "waiting" ),
			font = "BF4_Big",
			pos = { ScrW() * 0.5, ScrH() * 0.3},
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
			color = Color( 240, 240, 240, 240 )
		} )
	end
end
hook.Add( "DrawOverlay", "WaitingForPlayers", DrawPlayersWaiting )

function DrawBaseRapeWarn()
	if LocalPlayer().BaseRape then
		local time = LocalPlayer().BRTime
		if !time or time == 0 or time - CurTime() < 0 then
		 	time = ""
		 else
		 	time = string.format( "%.1f", time - CurTime() )
		end
		draw.Text( {
			text = GetLangMessage( "goback" ).." "..time,
			font = "BF4_Ammo_Main",
			pos = { ScrW() * 0.5, ScrH() * 0.5},
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
			color = Color( 240, 10, 50, 240 )
		} )
	end
end
hook.Add( "DrawOverlay", "BaseRapeWarn", DrawBaseRapeWarn )

function DrawDetect()
	if !GameStarted or #player.GetAll() < 2 then return end
	if !LocalPlayer():Alive() or LocalPlayer():GetNoDraw() then return end
	surface.SetMaterial( Material( "danx91/hud/detect.png" ) )
	surface.SetDrawColor( GetTeamColor( GetEnemyTeam( LocalPlayer():GetBFCTeam() ) ) )
	for k, v in pairs( DetectedPlayers ) do
		local ply = v.ent
		if IsValid( ply ) then
			local trpos = util.TraceLine( {
				start = LocalPlayer():EyePos(),
				endpos = ply:GetPos(),
				filter = { LocalPlayer(), ply }
			} )
			local treyes = util.TraceLine( {
				start = LocalPlayer():EyePos(),
				endpos = ply:EyePos(),
				filter = { LocalPlayer(), ply }
			} )
			if !trpos.Hit or !treyes.Hit then
				local pos = ( v.ent:GetPos() + Vector( 0, 0, 85 ) ):ToScreen()
				if pos.x > 0 and pos.x < ScrW() and pos.y > 0 and pos.y < ScrH() then
					--print( v.ent )
					local addy = math.Clamp( v.ent:GetPos():Distance( LocalPlayer():GetPos() ) / 50, 0, 32 )
					surface.DrawTexturedRect( pos.x - 16, pos.y - addy, 32, 32 )
				end
			end
		end
	end

end
hook.Add( "DrawOverlay", "Detect", DrawDetect )

net.Receive( "SendMessage", function( len )
	local msg = net.ReadString()
	if IsValid( LocalPlayer() ) then
		LocalPlayer():PrintMessage( HUD_PRINTTALK, msg )
	else
		print( msg )
	end
end )

function GM:HUDWeaponPickedUp( weapon )
	--
end

function GM:HUDItemPickedUp( name )
	--
end

function GM:HUDAmmoPickedUp( name, amount )
	--
end

function GM:HUDDrawTargetID()
	--
end

function GM:PreDrawHalos()
	halo.Add( DrawHalos, Color( 255, 0, 0, 255), 1, 1, 2, true, false )
end
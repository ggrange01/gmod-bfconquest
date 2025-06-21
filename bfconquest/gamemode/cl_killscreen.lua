local player = LocalPlayer()
local killer, weapon, damage, shots

function DrawKillScreen()
	if !KillScreen then return end
	w, h = ScrW(), ScrH()
	surface.SetDrawColor( Color(30, 50, 70, 235) )
	surface.DrawRect( w * 0.1, h * 0.1, w * 0.8, h * 0.8 )
	if !IsValid( avatar ) then
		CreateAvatar( killer, 128 )
	end
	local text = GetLangMessage( "killedby" ).." "..killer:GetName()
	if killer == player then
		text = GetLangMessage( "died" )
	end
	local lenx, leny = draw.Text( {
		text = text,
		font = "BF4_Ammo_Secondary",
		pos = { w * 0.3, h * 0.2 },
		xalign = TEXT_ALIGN_LEFT,
		yalign = TEXT_ALIGN_CENTER,
		color = Color( 0, 0, 0, 0 )
	} )
	surface.SetDrawColor( Color( 150, 150, 150, 100 ) )
	surface.DrawRect( w * 0.28, h * 0.18, lenx + w * 0.04, leny + h * 0.01 )
	draw.Text( {
		text = text,
		font = "BF4_Ammo_Secondary",
		pos = { w * 0.3, h * 0.2 },
		xalign = TEXT_ALIGN_LEFT,
		yalign = TEXT_ALIGN_CENTER,
		color = Color( 255, 255, 255, 255 )
	} )
	local texttoshow = { killer:GetName(), GetLangMessage( "kills" ).." "..killer:Frags(), GetLangMessage( "deaths" ).." "..killer:Deaths(), GetLangMessage( "level" ).." "..killer:GetLevel(), GetLangMessage( "experience" ).." "..killer:GetExp() }
	for i, v in ipairs( texttoshow ) do
		draw.Text( {
			text = v,
			font = "BF4_Small",
			pos = { w * 0.1 + h * 0.15, h * 0.36 + i * w * 0.014 },
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
			color = Color( 255, 255, 255, 255 )
		} )
	end
	surface.SetDrawColor( Color( 125, 125, 125, 100 ) )
	surface.DrawRect( w * 0.28, h * 0.3, w * 0.5, h * 0.4 )
	texttoshow = { 
		GetLangMessage( "killedbywep" ).." "..FastFormat( weapon, GetLangMessage( "unknownwep" ) ),
		string.format( GetLangMessage( "dmginshots" ), damage, shots ),
		"",
		GetLangMessage( "lvl" ).." "..player:GetLevel(),
		GetLangMessage( "exp" ).." "..player:GetExp(),
		"",
		GetLangMessage( "scr" ).." "..player:GetScore()
	}
	for i, v in ipairs( texttoshow ) do
		draw.Text( {
			text = v,
			font = "BF4_Ammo_Secondary",
			pos = { w * 0.31, h * 0.28 + i * w * 0.03 },
			xalign = TEXT_ALIGN_LEFT,
			yalign = TEXT_ALIGN_CENTER,
			color = Color( 255, 255, 255, 255 )
		} )
	end
end

hook.Add( "HUDPaint", "KillScreen", DrawKillScreen )

function ShowKillScreen()
	if avatar then RemoveAvatar() end
	KillScreen = true
	player = LocalPlayer()
	killer = DeathInfo.killer or LocalPlayer()
	weapon, damage, shots = DeathInfo.weapon, math.Round( DeathInfo.damage ), DeathInfo.shots
	DeathInfo = {
		killer = nil,
		weapon = nil,
		damage = 0,
		shots = 0
	}
	if !DeathInfo.weapon_name then
		local wep = weapons.Get( weapon )
		if wep then
			weapon = wep.PrintName
		end
	end
	wep = wep or ""
	gui.EnableScreenClicker( true ) 
end

function HideKillScreen()
	KillScreen = false
	gui.EnableScreenClicker( false )
	RemoveAvatar()
end

function CreateAvatar( ply, size )
	avatar = vgui.Create( "AvatarImage" )
	avatar:SetName( "Avatar" )
	avatar:SetPos( w * 0.1 + h * 0.05, h * 0.15 )
	avatar:SetSize( h * 0.2, h * 0.2 )
	avatar:SetPlayer( ply, size )
end

function RemoveAvatar()
	if IsValid( avatar ) then
		avatar:Remove()
		avatar = nil
	end
end

function FastFormat( text1, text2 )
	if text1 == "" then return text2 end
	return text1 or text2
end
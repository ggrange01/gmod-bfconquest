showTree = 0
nextChangeRequest = 0

function DrawHUD()
	if !RoleSelectHUD then return end
	if !vgui.CursorVisible() then
		gui.EnableScreenClicker( true )
	end
	w, h = ScrW(), ScrH()
	surface.SetDrawColor( Color(30, 110, 155, 235) )
	surface.DrawRect( 0, 0, w, h )
	surface.SetDrawColor( COLOR_US )
	surface.DrawRect( 0, 0, w * 0.5, h * 0.2 )
	surface.SetDrawColor( COLOR_RU )
	surface.DrawRect( w * 0.5, 0, w * 0.5, h * 0.2 )
	draw.Text( {
		text = "US",
		font = "BF4_Big",
		pos = { w * 0.035, h * 0.095 },
		xalign = TEXT_ALIGN_CENTER ,
		yalign = TEXT_ALIGN_CENTER ,
		color = Color( 240, 240, 240, 240 )
	} )
	draw.Text( {
		text = RoundData.UST,
		font = "BF4_Big",
		pos = { w * 0.475, h * 0.095 },
		xalign = TEXT_ALIGN_RIGHT ,
		yalign = TEXT_ALIGN_CENTER ,
		color = Color( 240, 240, 240, 240 )
	} )
	draw.Text( {
		text = "RU",
		font = "BF4_Big",
		pos = { w * 0.955, h * 0.095 },
		xalign = TEXT_ALIGN_CENTER ,
		yalign = TEXT_ALIGN_CENTER ,
		color = Color( 240, 240, 240, 240 )
	} )
	draw.Text( {
		text = RoundData.RUT,
		font = "BF4_Big",
		pos = { w * 0.525, h * 0.095 },
		xalign = TEXT_ALIGN_LEFT ,
		yalign = TEXT_ALIGN_CENTER ,
		color = Color( 240, 240, 240, 240 )
	} )
	draw.Text( {
		text = GetLangMessage( "deploypoints" ),
		font = "BF4_Big",
		pos = { w * 0.25, h * 0.25 },
		xalign = TEXT_ALIGN_CENTER ,
		yalign = TEXT_ALIGN_CENTER ,
		color = Color( 240, 240, 240, 240 )
	} )
	local color = GetTeamColor( LocalPlayer():GetBFCTeam() )
	SpawnSelectButton( w, h, 0, color, function()
		if PlayerSpawnData.POINT == "DE" then return true end
		return false
	end, function()
		PlayerSpawnData.POINT = "DE"
	end, string.format( GetLangMessage( "deployment" ), GetTeamName( LocalPlayer():GetBFCTeam() ) ) ) 
	local i = 1
	for k, v in ipairs( RoundData.OBJS ) do
		local obj = TranslateObject( v )
		if obj.teamID == LocalPlayer():GetBFCTeam() then
			SpawnSelectButton( w, h, i, color, function()
				i = i + 1
				if PlayerSpawnData.POINT == obj.name then return true end
				return false
			end, function()
				PlayerSpawnData.POINT = obj.name
			end, obj.name )
		end
	end
	local info = GetLangMessage( "info" )
	draw.Text( {
		text = info[1].." "..GetTeamName( LocalPlayer():GetBFCTeam() ),
		font = "BF4_Ammo_Main",
		pos = { w * 0.48, h * 0.4},
		xalign = TEXT_ALIGN_LEFT,
		yalign = TEXT_ALIGN_CENTER,
		color = Color( 240, 240, 240, 240 )
	} )
	draw.Text( {
		text = info[2].." "..LocalPlayer():GetLevel(),
		font = "BF4_Ammo_Main",
		pos = { w * 0.48, h * 0.5},
		xalign = TEXT_ALIGN_LEFT,
		yalign = TEXT_ALIGN_CENTER,
		color = Color( 240, 240, 240, 240 )
	} )
	draw.Text( {
		text = info[3].." "..GetTrueExp( LocalPlayer() ),
		font = "BF4_Ammo_Main",
		pos = { w * 0.48, h * 0.6},
		xalign = TEXT_ALIGN_LEFT,
		yalign = TEXT_ALIGN_CENTER,
		color = Color( 240, 240, 240, 240 )
	} )
	/*draw.Text( {
		text = "+ "..LocalPlayer():GetScore(),
		font = "BF4_Ammo_Main",
		pos = { w * 0.71, h * 0.65},
		xalign = TEXT_ALIGN_LEFT,
		yalign = TEXT_ALIGN_CENTER,
		color = Color( 240, 240, 240, 240 )
	} )*/
	DrawWeaponSelectButtons( w, h )
	DrawTree( w, h )
	DrawTeamChangeButton( w, h )
	DrawSpawnButton( w, h )
	surface.SetDrawColor( Color( 255, 255, 255, 125 ) )
	surface.SetMaterial( Material( "danx91/logo.png" ) )
	surface.DrawTexturedRect( w * 0.425, h * -0.03, w * 0.15, h * 0.12 )
	DrawExpBar( w, h )
end
	
hook.Add( "HUDPaint", "SelectHUD", DrawHUD )

function ShowSelectWindow()
	--print( debug.traceback() )
	RoleSelectHUD = true 
end

function HideSelectWindow()
	RoleSelectHUD = false
	gui.EnableScreenClicker( false )
end

function DrawExpBar( w, h )
	draw.Text( {
		text = GetLangMessage( "experience" ),
		font = "BF4_Ammo_Main",
		pos = { w * 0.19, h * 0.943},
		xalign = TEXT_ALIGN_RIGHT,
		yalign = TEXT_ALIGN_CENTER,
		color = Color( 240, 240, 240, 240 )
	} )
	surface.SetDrawColor( Color( 75, 75, 75, 200 ) )
	surface.DrawRect( w * 0.2, h * 0.925, w * 0.7, h * 0.05 )
	surface.SetDrawColor( Color( 150, 150, 150, 200 ) )
	surface.DrawRect( w * 0.2 + 5, h * 0.925 + 5, w * 0.7 - 10, h * 0.05 - 10 )
	surface.SetDrawColor( Color( 75, 75, 175, 200 ) )
	local nextlevel = LocalPlayer():GetLevel() or 1
	local prevlevel = LocalPlayer():GetLevel() - 1 or 0
	if nextlevel > 20 then
		nextlevel = Levels[20] + Levels.over20 * ( nextlevel - 20 )
	else
		nextlevel = Levels[ nextlevel ]
	end
	--print( prevlevel )
	for pplvl = 1, prevlevel do
		if pplvl > 20 then
			prevlevel = prevlevel + Levels[20] + Levels.over20 * ( pplvl - 20 )
		else
			prevlevel = prevlevel + Levels[ pplvl ]
		end
	end
	--print( prevlevel, GetTrueExp( LocalPlayer() ) )
	if !nextlevel or nextlevel == 0 then nextlevel = 1 end
	local cexp = GetTrueExp( LocalPlayer() ) - ( prevlevel or 0 )
	surface.DrawRect( w * 0.2 + 5, h * 0.925 + 5, w * ( cexp / nextlevel ) * 0.7 - 10, h * 0.05 - 10 )
	draw.Text( {
		text = cexp.." / "..nextlevel,
		font = "BF4_Ammo_Secondary",
		pos = { w * 0.55, h * 0.948},
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_CENTER,
		color = Color( 240, 240, 240, 240 )
	} )
end

function DrawSpawnButton( w, h )
	local text = ""
	if PlayerNextSpawn > CurTime() then
		surface.SetDrawColor( Color( 100, 100, 100, 230 ) )
		surface.DrawRect( w * 0.05, h * 0.8, w * 0.4, h * 0.1 )
		text = tostring( math.Round( PlayerNextSpawn - CurTime() ) ) 
	else
		surface.SetDrawColor( Color( 50, 100, 175, 240 ) )
		surface.DrawRect( w * 0.05, h * 0.8, w * 0.4, h * 0.1 )
		text = GetLangMessage( "spawn" )
		if DoButton( w * 0.05, h * 0.8, w * 0.4, h * 0.1 ) then
			PlayerNextSpawn = CurTime() + 3
			net.Start( "PlayerSpawnPort" )
				net.WriteTable( PlayerSpawnData )
			net.SendToServer()
		end
	end
	draw.Text( {
		text = text,
		font = "BF4_Ammo_Main",
		pos = { w * 0.25, h * 0.85},
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_CENTER,
		color = Color( 240, 240, 240, 240 )
	} )
end

function DrawTeamChangeButton( w, h )
	if nextChangeRequest < CurTime() then
		surface.SetDrawColor( Color( 100, 50, 150, 240 ) )
		surface.DrawRect( w * 0.80, h * 0.23, w * 0.18, h * 0.05 )
		draw.Text( {
			text = GetLangMessage( "changeteam" ),
			font = "BF4_Mini",
			pos = { w * 0.89, h * 0.253},
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
			color = Color( 240, 240, 240, 240 )
		} )
		if DoButton( w * 0.80, h * 0.23, w * 0.18, h * 0.05 ) then
			nextChangeRequest = CurTime() + 30
			net.Start("PlayerChangeTeamPort")
			net.SendToServer()
		end
	else
		surface.SetDrawColor( Color( 100, 100, 100, 240 ) )
		surface.DrawRect( w * 0.80, h * 0.23, w * 0.18, h * 0.05 )
		draw.Text( {
			text = math.Round( nextChangeRequest - CurTime() ),
			font = "BF4_Mini",
			pos = { w * 0.89, h * 0.253},
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
			color = Color( 240, 240, 240, 240 )
		} )
	end
end

function DrawTree( w, h )
	if showTree == 0 then return end
	local weps = Weapons[Weapons.TRANSLATE[showTree]]
	local cats = {"PRIM", "SEC", "NADE", "SPEC"}
	local plyweps = {}
	for k, v in ipairs( weps ) do
		local team = WeaponTeamName( v[3], "NONE" )
		if team == "NONE" or GetTeamID( team ) == LocalPlayer():GetBFCTeam() then
			table.insert( plyweps, v )
		end
	end
	local weaponinfo = GetLangMessage( "weaponinfo" )
	surface.SetMaterial( Material( "danx91/hud/hud_lock.png" ) )
	for k, v in ipairs( plyweps ) do
		local can = true
		local x, y = (k - 1) % 5, math.floor( (k - 1) / 5 )
		if LocalPlayer():GetLevel() >= v[5] then
			surface.SetDrawColor( Color( 100, 100, 255, 230 ) )
		else
			surface.SetDrawColor( Color( 100, 100, 100, 230 ) )
			can = false
		end
		surface.DrawRect( w * 0.5 + w * 0.086 * x , h * 0.7 - h * 0.0815 * y, w * 0.084, h * 0.08 )
		draw.Text( {
			text = v[1],
			font = "BF4_Small",
			pos = { w * 0.5 + w * 0.086 * x + w * 0.042, h * 0.715 - h * 0.0815 * y  },
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
			color = Color( 240, 240, 240, 240 )
		} )
		draw.Text( {
			text = weaponinfo[1].." "..v[5],
			font = "BF4_Small+",
			pos = { w * 0.5 + w * 0.086 * x + w * 0.042, h * 0.733 - h * 0.0815 * y  },
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
			color = Color( 240, 240, 240, 240 )
		} )
		draw.Text( {
			text = weaponinfo[2].." "..v[4],
			font = "BF4_Small+",
			pos = { w * 0.5 + w * 0.086 * x + w * 0.042, h * 0.749 - h * 0.0815 * y  },
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
			color = Color( 240, 240, 240, 240 )
		} )
		draw.Text( {
			text = weaponinfo[3].." "..WeaponTeamName( v[3], weaponinfo[4] ),
			font = "BF4_Small+",
			pos = { w * 0.5 + w * 0.086 * x + w * 0.042, h * 0.765 - h * 0.0815 * y  },
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
			color = Color( 240, 240, 240, 240 )
		} )
		local tname, twep = TranslateWeapon( Weapons, PlayerSpawnData[cats[showTree]], showTree, weaponinfo[5] )
		if twep[2] == v[2] then
			surface.SetDrawColor( Color( 150, 20, 20, 120 ) )
			for j=1, 3 do
				surface.DrawOutlinedRect( w * 0.5 + w * 0.086 * x + j, h * 0.7 - h * 0.0815 * y + j, w * 0.084 - 2 * j, h * 0.08 - 2 * j )
			end
		end
		if !can then
			surface.SetDrawColor( Color( 50, 20, 20, 120 ) )
			surface.DrawTexturedRect( w * 0.5 + w * 0.086 * x + w * 0.042 - h * 0.03, h * 0.71 - h * 0.0815 * y, h * 0.06, h * 0.06 )
		else
			if DoButton( w * 0.5 + w * 0.086 * x , h * 0.7 - h * 0.0815 * y, w * 0.084, h * 0.08 ) then
				PlayerSpawnData[cats[showTree]] = v[2]
			end
		end
	end
	if DoOutButton( w * 0.5, h * 0.7 - h * 0.0815 * math.floor( ( #plyweps - 1 ) / 5 ), w * 0.43, h * 0.0815 * math.floor( ( #plyweps - 1 ) / 5 ) + h * 0.2)then
		showTree = 0
	end
end

function DrawWeaponSelectButtons( w, h )
	local disp = GetLangMessage( "displayweapons" )
	local cats = {"PRIM", "SEC", "NADE", "SPEC"}
	for i = 0, 3 do
		surface.SetDrawColor( Color( 100, 100, 255, 230 ) )
		surface.DrawRect( w * 0.5 + w * 0.11 * i , h * 0.8, w * 0.1, h * 0.1 )
		draw.Text( {
			text = disp[i+1],
			font = "BF4_Counters",
			pos = { w * 0.5 + w * 0.11 * i + w * 0.05, h * 0.82  },
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
			color = Color( 240, 240, 240, 240 )
		} )
		surface.SetDrawColor( Color( 0, 0, 0, 255 ) )
		surface.SetMaterial( Material( "danx91/hud/hud_"..i..".png" ) )
		if i == 0 then
			surface.DrawTexturedRect( w * 0.5 + w * 0.11 * i + w * 0.05 - h * 0.03, h * 0.836, h * 0.06, h * 0.03)
		else
			surface.DrawTexturedRect( w * 0.5 + w * 0.11 * i + w * 0.05 - h * 0.015, h * 0.838, h * 0.03, h * 0.03)
		end
		local act = TranslateWeapon( Weapons, PlayerSpawnData[cats[i+1]], i+1, GetLangMessage( "none" ) )
		draw.Text( {
			text = act,
			font = "BF4_Counters",
			pos = { w * 0.5 + w * 0.11 * i + w * 0.05, h * 0.88  },
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
			color = Color( 240, 240, 240, 240 )
		} )
		if DoButton( w * 0.5 + w * 0.11 * i , h * 0.8, w * 0.1, h * 0.1 ) then
			showTree = i + 1
		end
	end
end

function SpawnSelectButton( w, h, i, color, selected, click, text )
	surface.SetDrawColor( Color( 40, 50, 60, 255 ) )
	surface.DrawRect( w * 0.05, h * 0.33 + h * 0.05 * i, w * 0.4, h * 0.04 )
	surface.SetDrawColor( color )
	surface.DrawRect( w * 0.05 + 6, h * 0.33 + h * 0.05 * i + 6, h * 0.04 - 12, h * 0.04 - 12 )
	draw.Text( {
		text = text,
		font = "BF4_Counters",
		pos = { w * 0.08, h * 0.35 + h * 0.05 * i },
		xalign = TEXT_ALIGN_LEFT ,
		yalign = TEXT_ALIGN_CENTER ,
		color = Color( 240, 240, 240, 240 )
	} )
	if selected() then
		for j=1, 2 do
			surface.DrawOutlinedRect( w * 0.05 + j, h * 0.33 + h * 0.05 * i + j, w * 0.4 - 2 * j, h * 0.04 - 2 * j ) 
		end
		return
	end
	if DoButton( w * 0.05, h * 0.33 + h * 0.05 * i, w * 0.4, h * 0.04 ) then
		click()
	end
end

function DoButton( x, y, w, h )
	local mx, my = input.GetCursorPos()
	if mx > x and mx < x + w then
		if my > y and my < y + h then
			if input.IsMouseDown( MOUSE_LEFT ) then
				return true
			end
		end
	end
	return false
end

function DoOutButton( x, y, w, h )
	local mx, my = input.GetCursorPos()
	if mx < x or mx > x + w then
		if input.IsMouseDown( MOUSE_LEFT ) then
			return true
		end
	end
	if my < y or my > y + h then
		if input.IsMouseDown( MOUSE_LEFT ) then
			return true
		end
	end
	return false
end
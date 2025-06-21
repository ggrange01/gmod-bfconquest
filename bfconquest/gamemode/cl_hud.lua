local hideHUD = {
	CHudAmmo = true,
	CHudBattery = true,
	CHudHealth = true,
	CHudSecondaryAmmo = true,
}

hook.Add( "HUDShouldDraw", "HideHUD", function( name )
	if hideHUD[name] then
		return false
	end
end )

surface.CreateFont( "BF4_Big", {
	font = STANDARD_FONT_OVERRIDE or "Purista SemiBold TTF",
	size = 100,
	--size = ScrH() * 0.0925
	weight = 200
} )

surface.CreateFont( "BF4_Targets", {
	font = STANDARD_FONT_OVERRIDE or "Purista SemiBold TTF",
	size = 80,
	weight = 200
} )

surface.CreateFont( "BF4_Ammo_Main",
    {
        font      = NUMBERS_FONT_OVERRIDE or "BF4 Numbers",
        size      = 73,
        weight    = 200,
    }
 )
surface.CreateFont( "BF4_Ammo_Secondary",
    {
        font      = NUMBERS_FONT_OVERRIDE or "BF4 Numbers",
        size      = 41,
        weight    = 200,
    }
 )
surface.CreateFont( "BF4_Mini",
    {
        font      = NUMBERS_FONT_OVERRIDE or "BF4 Numbers",
        size      = 34,
        weight    = 200,
    }
 )
surface.CreateFont( "BF4_Counters",
    {
        font      = STANDARD_FONT_OVERRIDE or "Purista SemiBold TTF",
        size      = 25,
        weight    = 200,
    }
 )
 surface.CreateFont( "BF4_Small",
    {
        font      = NUMBERS_FONT_OVERRIDE or "BF4 Numbers",
        size      = 23,
        weight    = 200,
    }
 )
  surface.CreateFont( "BF4_Small+",
    {
        font      = NUMBERS_FONT_OVERRIDE or "BF4 Numbers",
        size      = 18,
        weight    = 200,
    }
 )
 
txFire = ""
local FBReloadAlpha = 0
local FBReloadBaseAlpha = 0
local FBReloadIconAlpha = 1
local mats = {
	wep_back = Material( "Lavadeeto/Weapon Hud/Weapon_Back.png", "noclamp" ),
	automatic = Material( "Lavadeeto/Weapon Hud/FR_Auto.png", "noclamp" ),
	single = Material( "Lavadeeto/Weapon Hud/FR_Single.png", "noclamp" ),
	reload_back = Material( "Lavadeeto/Weapon Hud/Reload_Back.png", "noclamp" ),
	reload_ico = Material( "Lavadeeto/Weapon Hud/Reload_Icon.png", "noclamp" ),
	mm_back = Material( "Lavadeeto/Minimap/Minimap_Back_v2.png", "noclamp" ),
	mm_front = Material( "Lavadeeto/Minimap/Minimap_Front.png", "noclamp" ),
	player = Material( "Lavadeeto/Minimap/Player Arrow.png", "noclamp" ),
	fov = Material( "Lavadeeto/Minimap/Minimap_FOV.png", "noclamp" ),
	enemy = Material( "Lavadeeto/Minimap/enemy.png", "noclamp" ),
	ally = Material( "Lavadeeto/Minimap/ally.png", "noclamp" ),
}
local FBMagMax = ""
local angDiff = Angle( 0, 0, 0 )

function BF4HUD()
	if !InGameHUD then return end
	local BFply = LocalPlayer()
	local BFwep = BFply:GetActiveWeapon()
	local HudTicketsStart = MaxTickets
	local HudTicketsUS = RoundData.UST
	local HudTicketsRU = RoundData.RUT
	local targets = RoundData.OBJS

	if IsValid( BFply ) and BFply:Alive() then
		--Start Weapon
		if !IsValid( BFwep ) then
			wep = {}
			wep.Primary = {}
			wep.Primary.Automatic = false
			wep.Primary.ClipSize = 0
			wep.GetPrimaryAmmoType  = function() return 0 end
			wep.Clip1 = function() return 0 end
			BFwep = wep
		end
		-- Draw the main part
		surface.SetDrawColor(255,255,255,255)
		surface.SetMaterial( mats.wep_back )
		surface.DrawTexturedRect(ScrW()-240,(ScrH()-130),205,101)
		surface.SetTexture(0)

		--Mag Ammo Values
		if BFwep.Primary and BFwep.Primary.Automatic then
			txFire = mats.automatic
		else 
			txFire = mats.single
		end
			
		local Res=BFply:GetAmmoCount(BFwep:GetPrimaryAmmoType()) 
		-- Primary
		if BFwep:Clip1() < 0 then
			txMag = 0
		elseif BFwep:Clip1() > 999 then
			txMag = 999
		else
			txMag = BFwep:Clip1()
		end
			
		if txMag <= 9 then
			tx = ScrW()-164
			ty = ScrH()-140
		elseif txMag <= 99 then
			tx = ScrW()-200
			ty = ScrH()-140
		elseif txMag <= 999 then
			tx = ScrW()-236
			ty = ScrH()-140
		else
			tx = ScrW()-236
			ty = ScrH()-140
		end
			--Reserve
		if Res < 0 then
			txSecMag = 0
		elseif Res > 999 then
			txSecMag = 999
		else
			txSecMag = Res
		end
			
		if txSecMag <= 9 then
			sectx = ScrW()-64
			secty = ScrH()-131
		elseif txSecMag <= 99 then
			sectx = ScrW()-84
			secty = ScrH()-131
		elseif txSecMag <= 999 then
			sectx = ScrW()-105
			secty = ScrH()-131
		end

		draw.SimpleText(txMag,"BF4_Ammo_Main",tx,ty,Color(158,167,171,330),100,100)--Mag Ammo Counter
		draw.SimpleText(txSecMag,"BF4_Ammo_Secondary",sectx,secty,Color(158,167,171,230),100,100)-- Sec Mag Ammo Counter
		
			
		local Health = BFply:Health( )

		if Health < 39 then 
			HealthR = Color(math.Clamp(255 * math.sin(CurTime() * 7),100,255),0,0,255)
		else
			HealthR = Color(158,167,171,330)
		end

		--local Nade = BFply:GetAmmoCount( 44 ) + BFply:GetAmmoCount( 45 ) + BFply:GetAmmoCount( 46 )
		local Nade = 0
		
		if Nade > 99 then
			txNade = 99
		else
			txNade = Nade
		end

		draw.SimpleText(Health,"BF4_Mini",ScrW()-103,ScrH()-71,HealthR,100,100)
		draw.SimpleText(txNade,"BF4_Mini",ScrW()-202,ScrH()-71,Color(158,167,171,330),100,100)
		surface.SetDrawColor(255,255,255,255)
		surface.SetMaterial(txFire)
		surface.DrawTexturedRect(ScrW()-115,ScrH()-92,60,16)
		surface.SetTexture(0)
		
		if BFwep.Primary then
			FBMagMax = BFwep.Primary.ClipSize
		else
			FBMagMax = 0
		end

		if BFwep:Clip1() <= FBMagMax / 3 and FBMagMax > 0  then
			FBReloadBaseAlpha = math.Clamp(FBReloadBaseAlpha + 40,0,255)
			FBReloadIconAlpha = 255 * math.sin(CurTime() * 5)
		else
			FBReloadBaseAlpha = math.Clamp(FBReloadBaseAlpha - 40,0,255)
			FBReloadIconAlpha = math.Clamp(FBReloadIconAlpha - 40,0,255)
		end

		surface.SetDrawColor(255,255,255,FBReloadBaseAlpha)
		surface.SetMaterial( mats.reload_back )
		surface.DrawTexturedRect(ScrW()-240,ScrH()-158.1,204,29)
		surface.SetTexture(0)

		surface.SetDrawColor(255,255,255,FBReloadIconAlpha)
		surface.SetMaterial( mats.reload_ico )
		surface.DrawTexturedRect(ScrW()-240,ScrH()-159,124,31)
		surface.SetTexture(0)

			
		-- End Weapon
		--Map

	
		surface.SetDrawColor(255,255,255,255)-- Main Map
		surface.SetMaterial( mats.mm_back )
		surface.DrawTexturedRect(19,(ScrH()-290),207,283)
		surface.SetTexture(0)

		surface.SetDrawColor(255,255,255,255)-- BG
		surface.SetMaterial( mats.mm_front )
		surface.DrawTexturedRect(20,(ScrH()-211),205,200)
		surface.SetTexture(0)
		surface.SetDrawColor(255,255,255,255)-- BG
		surface.SetMaterial( mats.mm_front )
		surface.DrawTexturedRect(20,(ScrH()-211),205,200)
		surface.SetTexture(0)

		if MINIMAP and MINIMAP.Enabled and MINIMAP_TX then
			surface.SetMaterial( MINIMAP_TX )

			local worldsize = MINIMAP_WS * 2
			local minimapsize = MINIMAP_SIZE

			local scale = minimapsize / worldsize
			local pos = LocalPlayer():GetPos() * scale - Vector( minimapsize / 2, minimapsize / 2 )

			if MINIMAP.Static then
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.DrawSubTexturedRect( 22, ScrH() - 211, 200, 200, minimapsize - pos.y - 75, minimapsize - pos.x - 75, 150, 150, MINIMAP_TX:Width(), MINIMAP_TX:Height() )
				
				local rot = LocalPlayer():GetAngles().yaw

				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.SetMaterial( mats.player )
				surface.DrawTexturedRectRotated( 122, ScrH() - 111, 32, 32, rot )

				local mx = Matrix()
				mx:Translate( Vector( 122, ScrH() - 110 ) )
				mx:Rotate( Angle( 0, -rot, 0 ) )
				mx:Translate( -Vector( 122, ScrH() - 110 ) )

				render.ClearStencil()
				render.SetStencilEnable( true )

					render.SetStencilTestMask( 255 )
					render.SetStencilWriteMask( 255 )

					render.SetStencilReferenceValue( 1 )

					render.SetStencilCompareFunction( STENCIL_NEVER )
					render.SetStencilPassOperation( STENCIL_KEEP )
					render.SetStencilFailOperation( STENCIL_REPLACE )
					render.SetStencilZFailOperation( STENCIL_KEEP )

					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.DrawRect( 22, ScrH() - 211, 200, 200 )

					render.SetStencilCompareFunction( STENCIL_EQUAL )

					cam.PushModelMatrix( mx )
						surface.SetDrawColor( 255, 255, 255, 255 )
						surface.SetMaterial( mats.fov )
						surface.DrawTexturedRect( 22, ScrH() - 210, 200, 100 )
					cam.PopModelMatrix()

				render.SetStencilEnable( false )
			else
				local ang = LocalPlayer():GetAngles().yaw

				render.ClearStencil()
				render.SetStencilEnable( true )

					render.SetStencilTestMask( 255 )
					render.SetStencilWriteMask( 255 )

					render.SetStencilReferenceValue( 1 )

					render.SetStencilCompareFunction( STENCIL_NEVER )
					render.SetStencilPassOperation( STENCIL_KEEP )
					render.SetStencilFailOperation( STENCIL_REPLACE )
					render.SetStencilZFailOperation( STENCIL_KEEP )

					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.DrawRect( 22, ScrH() - 211, 200, 200 )

					render.SetStencilCompareFunction( STENCIL_EQUAL )

					surface.DisableClipping( true )

					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.DrawRotatedSubTexturedRect( -28, ScrH() - 261, 300, 300, minimapsize - pos.y - 112.5, minimapsize - pos.x - 112.5, 225, 225, MINIMAP_TX:Width(), MINIMAP_TX:Height(), ang )
					
					surface.DisableClipping( false )

				render.SetStencilEnable( false )

				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.SetMaterial( mats.player )
				surface.DrawTexturedRect( 106, ScrH() - 127, 32, 32 )

				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.SetMaterial( mats.fov )
				surface.DrawTexturedRect( 22, ScrH() - 210, 200, 100 )

			end
		end

		-- Start Map functions
		local scale
		if MINIMAP and MINIMAP.Enabled and MINIMAP_WS and MINIMAP_SIZE then
			local worldsize = MINIMAP_WS * 2
			minimapsize = MINIMAP_SIZE

			scale = minimapsize / worldsize
		else
			scale = 0.07
		end

		local maxdist = 140 / scale

		local fent = ents.FindInSphere( LocalPlayer():GetPos(), maxdist )
		local plnormal = LocalPlayer():GetEyeTrace().Normal
		for k, v in pairs( fent ) do
			if v:IsNPC() or v:IsPlayer() and v != BFply and v:Alive() then
				local trpos = util.TraceLine( {
					start = BFply:EyePos(),
					endpos = v:GetPos(),
					filter = { BFply, v }
				} )
				local treyes = util.TraceLine( {
					start = BFply:EyePos(),
					endpos = v:EyePos(),
					filter = { BFply, v }
				} )

				if !v.GetBFCTeam then
					player_manager.RunClass( v, "SetupDataTables" )
				end

				local pos = v:GetPos()
				local localplayer = LocalPlayer()
				local dist = localplayer:GetPos():DistanceIgnoreZ( pos )
				if dist <= maxdist then
					if v:GetBFCTeam() == localplayer:GetBFCTeam() or EntDetected( v ) or !trpos.Hit and plnormal:Dot( trpos.Normal ) > 0.5 or !treyes.Hit and plnormal:Dot( treyes.Normal ) > 0.5 then
						if v:GetBFCTeam() == localplayer:GetBFCTeam() then
							surface.SetMaterial( mats.ally )
						else
							surface.SetMaterial( mats.enemy )
						end

						local x, y

						if !MINIMAP or !MINIMAP.Enabled or !MINIMAP.Static then
							local lineang = ( pos - localplayer:GetPos() ):Angle() - localplayer:GetAngles()
							local ang = math.rad( lineang.yaw - 180 )
							x = math.sin( ang ) * dist * scale
							y = math.cos( ang ) * dist * scale
						else
							local lineang = ( pos - localplayer:GetPos() ):Angle()
							local ang = math.rad( lineang.yaw - 180 )
							x = math.sin( ang ) * dist * scale
							y = math.cos( ang ) * dist * scale
						end

						if x > -95 and x < 95 and y > -95 and y < 95 then
							surface.DrawTexturedRect( 110 + x, ScrH() - 122 + y, 24, 24 )
						end
					end
				end
			end

			/*if v:GetClass() == "cw_frag_grenade" or v:GetClass() == "cw_smoke_grenade" or v:GetClass() == "cw_flash_grenade" then
				surface.SetMaterial( Material( "Lavadeeto/Extras/Frag Icon.png", "noclamp" ) )
				surface.DrawTexturedRectRotated( v:GetPos():ToScreen().x, v:GetPos():ToScreen().y - 15, 38/2, 42/2, 0 )
			end	
			
			if v:GetClass() == "fas2_thrown_ammobox" or v:GetClass() == "activated_ammokit" then
				surface.SetMaterial( Material( "Lavadeeto/Extras/ammopack.png", "noclamp" ) )
				surface.DrawTexturedRectRotated( v:GetPos():ToScreen().x, v:GetPos():ToScreen().y - 15, 50/2, 43/2, 0 )
			end	
			
			if v:GetClass() == "item_healthkit" or v:GetClass() == "item_healthvial" or v:GetClass() == "activated_medkit"  then
				surface.SetMaterial( Material( "Lavadeeto/Extras/medicpack.png", "noclamp" ) )
				surface.DrawTexturedRectRotated( v:GetPos():ToScreen().x, v:GetPos():ToScreen().y - 15, 50/2, 43/2, 0 )
			end*/	
							
		end
		draw.SimpleText( "US "..HudTicketsUS, "BF4_Counters", 25, ScrH() - 263, Color( 125, 211, 254, 330 ), 100, 100 )
		draw.SimpleText( "RU "..HudTicketsRU, "BF4_Counters", 25, ScrH() - 240, Color( 231, 139, 94, 330 ), 100, 100 )
		
		local width = math.Round( HudTicketsUS / HudTicketsStart * 101 )	
		surface.SetDrawColor( Color(125,211,254,330) )
		surface.DrawOutlinedRect( 110, ScrH()-259, 105, 17 ) 
		surface.DrawRect( 112, ScrH()-257, width, 13 )
		
		local width = math.Round( HudTicketsRU / HudTicketsStart * 101 )	
		surface.SetDrawColor( Color(231,139,94,330) )
		surface.DrawOutlinedRect( 110, ScrH()-236, 105, 17 ) 
		surface.DrawRect( 112, ScrH()-234, width, 13 )
		
		local total = #targets
		local totalLen = total * 13 + 15 * ( total - 1 )
		for k, v in ipairs( targets ) do
			local obj = TranslateObject( v )
			local dcol = Color( 150, 150, 150, 255 )
			if obj.teamID == TEAM_RU then
				dcol = Color( 231, 139, 94, 255 )
			elseif obj.teamID == TEAM_US then
				dcol = Color( 125, 211, 254, 255 )
			end
			local x = 19 + 207 / 2 - totalLen / 2 + k * 13 + (k - 1) * 15
			draw.SimpleText(
				obj.name,
				"BF4_Counters",
				x, ScrH() - 277,
				dcol,
				TEXT_ALIGN_RIGHT,
				TEXT_ALIGN_CENTER
			)
		end
	end

	--surface.SetMaterial( MINIMAP_TX )
	--surface.DrawTexturedRect( 0, 0, 1000, 1000 )

end
hook.Add("HUDPaint","BF4HUD",BF4HUD )

function EntDetected( ent )
	for k, v in pairs( DetectedPlayers ) do
		if v.ent == ent then return true end
	end
end

function DrawVehicleInfo()
	if !IsValid( LocalPlayer() ) then return end
	if !LocalPlayer():InVehicle() then return end

	local vehicle = LocalPlayer():GetVehicle():GetParent()
	if !IsValid( vehicle ) then
		vehicle = LocalPlayer():GetVehicle()
	end

	if !IsValid( vehicle ) then return end

	local w, h = ScrW(), ScrH()

	local hp, maxhp = hook.Run( "BFCVehicleHealth", vehicle, LocalPlayer():GetVehicle() )
	if hp and maxhp then
		local text = math.ceil( hp / maxhp * 100 ).."%"

		surface.SetFont( "BF4_Mini" )
		local tw, th = surface.GetTextSize( text )

		surface.SetDrawColor( Color( 75, 75, 75, 125 ) )
		surface.DrawRect( w * 0.98 - h * 0.035 - tw, h * 0.7, w * 0.01 + h * 0.035 + tw, h * 0.01 + th )

		surface.SetDrawColor( 225, 225, 225, 200 )
		surface.SetMaterial( Material( "danx91/hud/wrench.png" ) )
		surface.DrawTexturedRect( w * 0.98 - h * 0.03 - tw, h * 0.690 + th / 2, h * 0.03, h * 0.03 )

		draw.Text( {
			text = text,
			pos = { w * 0.985, h * 0.704 + th / 2 },
			font = "BF4_Mini",
			color = Color( 225, 225, 225, 200 ),
			xalign = TEXT_ALIGN_RIGHT,
			yalign = TEXT_ALIGN_CENTER,
		} )
	end

	if VehicleLocked then
		local key = string.upper( input.LookupBinding( "bfc_flares" ) or "bfc_flares" )
		local text = "Launch Flares ["..key.."]"

		surface.SetFont( "BF4_Mini" )
		local tw, th = surface.GetTextSize( text )

		surface.SetDrawColor( Color( 75, 75, 75, 125 ) )
		surface.DrawRect( w * 0.98 - tw, h * 0.75, w * 0.01 + tw, h * 0.01 + th )

		local alpha = math.TimedSinWave( 1.5, 25, 200 )

		draw.Text( {
			text = text,
			pos = { w * 0.985, h * 0.754 + th / 2 },
			font = "BF4_Mini",
			color = Color( 255, 255, 255, alpha ),
			xalign = TEXT_ALIGN_RIGHT,
			yalign = TEXT_ALIGN_CENTER,
		} )
	end

end
hook.Add( "HUDPaint", "BFCVehicleInfo", DrawVehicleInfo )
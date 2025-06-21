ShouldDrawTargets = ShouldDrawTargets or false

local target = Material( "lavadeeto/minimap/target2_big.png" )
function DrawTargets()
	if !ShouldDrawTargets then return end
	local player = LocalPlayer()
	for k, v in ipairs( RoundData.OBJS ) do
		local trobj = TranslateObject( v )
		local obj = Targets[ trobj.name ]
		if obj then
			local pos = obj.pos
			local drawBig = false
			local dist = player:GetPos():Distance( Vector( pos.x, pos.y, obj.height ) )
			if dist <= obj.area and math.abs( player:GetPos().z - obj.height ) < obj.h then
				drawBig = true
			end
			--local scale = dist < 10000 and dist / 300 or 0	
			draw.NoTexture()
			local shoulddrawbars = ObjectProgress[ trobj.name ][1] != 0 and ObjectProgress[ trobj.name ][1] != 100
			--print( ObjectProgress[ trobj.name ][1] )
			if !drawBig then
				local scr = ( pos + Vector( 0, 0, 750 ) ):ToScreen()
				if scr.x > 0 and scr.x < ScrW() and scr.y > 0 and scr.y < ScrH() then
					local alphamul = 1
					if scr.x > ScrW() * 0.45 and scr.x < ScrW() * 0.55 and scr.y + 32 > ScrH() * 0.45 and scr.y + 32 < ScrH() * 0.55 then
						alphamul = 0.03
					end
					if shoulddrawbars then
						surface.SetDrawColor( Color( 100, 100, 100, 75 * alphamul ) )
						surface.DrawRect( scr.x - 64, scr.y + 64, 128, 24 )
						local col_orig = GetTeamColor( ObjectProgress[ trobj.name ][2] )
						local col = Color( col_orig.r, col_orig.g, col_orig.b, col_orig.a * alphamul )
						surface.SetDrawColor( col )
						surface.DrawRect( scr.x - 62, scr.y + 66, 124, 20 )
						surface.SetDrawColor( Color( 200, 200, 200, 200 * alphamul ) )
						surface.DrawRect( scr.x - 60, scr.y + 68, 120, 16 )
						
						surface.SetDrawColor( col )
						surface.DrawRect( scr.x - 58, scr.y + 70, ( ObjectProgress[ trobj.name ][1] / 100 * 116 ), 12 )
					end
					surface.SetDrawColor( Color( 125, 125, 125, 100 * alphamul ) )
					surface.DrawTexturedRectRotated( scr.x, scr.y + 32, 32, 32, 45 )
					local col_orig = GetTeamColor( trobj.teamID )
					local col = Color( col_orig.r, col_orig.g, col_orig.b, col_orig.a * alphamul )
					surface.SetMaterial( target )
					surface.SetDrawColor( col )
					surface.DrawTexturedRect( scr.x - 32, scr.y, 64, 64 )
					draw.Text( {
						text = trobj.name,
						font = "BF4_Counters",
						pos = { scr.x, scr.y + 30 },
						xalign = TEXT_ALIGN_CENTER,
						yalign = TEXT_ALIGN_CENTER,
						color = col
					} )
				end
			else
				if shoulddrawbars then
					surface.SetDrawColor( Color( 100, 100, 100, 75 ) )
					surface.DrawRect( ScrW() * 0.436, ScrH() * 0.064, ScrW() * 0.128, ScrH() * 0.04 )
					surface.SetDrawColor( GetTeamColor( ObjectProgress[ trobj.name ][2] ) )
					surface.DrawRect( ScrW() * 0.436 + 5, ScrH() * 0.064 + 5, ScrW() * 0.128 - 10, ScrH() * 0.04 - 10 )
					surface.SetDrawColor( Color( 200, 200, 200, 200 ) )
					surface.DrawRect( ScrW() * 0.436 + 7, ScrH() * 0.064 + 7, ScrW() * 0.128 - 14, ScrH() * 0.04 - 14 )
					surface.SetDrawColor( GetTeamColor( ObjectProgress[ trobj.name ][2] ) ) 
					surface.DrawRect( ScrW() * 0.436 + 8, ScrH() * 0.064 + 8, ( ScrW() * 0.128 - 16 ) * ObjectProgress[ trobj.name ][1] / 100, ScrH() * 0.04 - 16 )
				end
				surface.SetDrawColor( Color( 100, 100, 100, 75 ) )
				surface.DrawTexturedRectRotated( w * 0.5, h * 0.125 + 64, 64, 64, 45 )
				surface.SetMaterial( target )
				surface.SetDrawColor( GetTeamColor( trobj.teamID ) )
				surface.DrawTexturedRect( ScrW() * 0.5 - 64 , ScrH() * 0.125, 128, 128 )
				draw.Text( {
					text = trobj.name,
					font = "BF4_Targets",
					pos = { w * 0.5, h * 0.125 + 60 },
					xalign = TEXT_ALIGN_CENTER,
					yalign = TEXT_ALIGN_CENTER,
					color = GetTeamColor( trobj.teamID )
				} )
			end
		end
	end
end
hook.Add( "HUDPaintBackground", "Targets", DrawTargets )
local forced = false

surface.CreateFont( "BFC_Scoreboard",
    {
        font      = "BF4 Numbers",
        size      = 22,
        weight    = 500,
    }
 )

surface.CreateFont( "BFC_Scoreboard_ext",
    {
        font      = "BF4 Numbers",
        size      = 28,
        weight    = 500,
    }
 )
 
local buttonnext = true
 
function ShowScoreboard()
	local width, height = ScrW(), ScrH()
	Frame = vgui.Create( "DFrame" )
	Frame:SetSize( width * 0.9, height * 0.9 )
	Frame:SetTitle( "" )
	Frame:SetVisible( true )
	Frame:SetDeleteOnClose( true )
	Frame:SetDraggable( false )
	Frame:ShowCloseButton( false )
	Frame:Center()
	Frame:MakePopup()
	Frame.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 130, 130, 130, 220 ) ) 
		draw.Text( {
			text = "US",
			font = "BF4_Ammo_Main",
			pos = { w / 4 - 20, h * 0.033 },
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
			color = Color( 255, 255, 255, 255 )
		} )
		draw.Text( {
			text = "RU",
			font = "BF4_Ammo_Main",
			pos = { w / 4 * 3 + 20, h * 0.033 },
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
			color = Color( 255, 255, 255, 255 )
		} )
		if forced then
			ntime = ntime or 0
			DrawText( w * 0.5, h * 0.035, "Next game starts in "..string.ToMinutesSeconds( math.Round( ntime - CurTime() ) ) )
		end
	end
	
	local scrollpaneus = vgui.Create( "DScrollPanel", Frame )
	scrollpaneus:SetSize( width * 0.4, 0 )
	scrollpaneus:Dock( LEFT )
	scrollpaneus:DockMargin( 20, 40, 0, 10 )
	scrollpaneus.Paint = function( self, w, h ) 
		draw.RoundedBox( 0, 0, 0, w, h, Color( 125, 211, 254, 75 ) )
	end
	
	local scrollpaneru = vgui.Create( "DScrollPanel", Frame )
	scrollpaneru:SetSize( width * 0.4, 0 )
	scrollpaneru:Dock( RIGHT )
	scrollpaneru:DockMargin( 0, 40, 20, 10 )
	scrollpaneru.Paint = function( self, w, h ) 
		draw.RoundedBox( 0, 0, 0, w, h, Color( 231, 139, 94, 75 ) ) 
	end
	
	local panels = { scrollpaneus, scrollpaneru }
	
	for pn = 1, 2 do
		local panel = vgui.Create( "DPanel", panels[pn] )	
		panel:SetSize( 0, 30 )
		panel:Dock( TOP )
		panel:DockMargin( 10, 6, 10, 0 )
		panel.Paint = function( self, w, h )
			local scoreboardtext = GetLangMessage( "scoreboard" )
			DrawText( 44 + w * 0.15, h * 0.5, scoreboardtext[1] )
			DrawText( 44 + w * 0.325 + 2, h * 0.5, scoreboardtext[2] )
			DrawText( 44 + w * 0.535 + 2, h * 0.5, scoreboardtext[3] )
			DrawText( 44 + w * 0.625 + 4, h * 0.5, scoreboardtext[4] )
			DrawText( 44 + w * 0.765 + 4, h * 0.5, scoreboardtext[5] )
			DrawText( 44 + w * 0.895 + 4, h * 0.5, scoreboardtext[6] )
		end
	end
	
	for k, v in ipairs( player.GetAll() ) do
		if !v.GetBFCTeam or !v.GetBFCScore or !v.GetBFCLevel then
			player_manager.RunClass( v, "SetupDataTables" )
		end
	end
	
	local allply = table.Copy( player.GetAll() )
	SortPlayers( allply )
	
	for k, v in ipairs( allply ) do
		local parent = v:GetBFCTeam() == TEAM_US and scrollpaneus or scrollpaneru
		local panel = vgui.Create( "DPanel", parent )	
		panel:SetSize( 0, 30 )
		panel:Dock( TOP )
		panel:DockMargin( 10, 6, 10, 0 )
		panel.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 175, 175, 175, 255 ) )
			
			if IsValid( v ) then
				local nextpanelx = 0
				
				nextpanelx = DrawPanel( 44, 0, w, h, 0.3, ValidateName( v:GetName() ), Color( 125, 125, 125, 200 ) )
				local posx, posy = self:LocalToScreen( 44, 0 )
				if DoButton( posx, posy, w * 0.3, h ) and buttonnext then
					buttonnext = false
					timer.Simple( 0.7, function() buttonnext = true end )	
					v:ShowProfile()
				end
				
				nextpanelx = DrawPanel( nextpanelx + 2, 0, w, h, 0.05, math.Clamp( v:GetLevel(), 0, 999 ), Color( 125, 125, 125, 200 ) )
				nextpanelx = CalcNextPanelX( nextpanelx, w, 0.14 ) --DrawPanel( nextpanelx, 0, w, h, 0.14, "", Color( 125, 125, 125, 200 ) )
				
				nextpanelx = DrawPanel( nextpanelx, 0, w, h, 0.09, math.Clamp( v:Frags(), -9999, 9999 ), Color( 125, 125, 125, 200 ) )
				nextpanelx = DrawPanel( nextpanelx + 2, 0, w, h, 0.09, math.Clamp( v:Deaths(), -9999, 9999 ), Color( 125, 125, 125, 200 ) )
				nextpanelx = DrawPanel( nextpanelx + w * 0.02, 0, w, h, 0.15, math.Clamp( v:GetScore(), 0, 99999 ), Color( 125, 125, 125, 200 ) )
				nextpanelx = DrawPanel( nextpanelx + w * 0.02, 0, w, h, 0.07, math.Clamp( v:Ping(), 0, 999 ), Color( 125, 125, 125, 200 ) )
			end
		end
		
		local avatar = vgui.Create( "AvatarImage", panel )
		avatar:SetSize( 24, 24 )
		avatar:Dock( LEFT )
		avatar:DockMargin( 10, 3, 0, 3 )
		avatar:SetPlayer( v, 32 )
	end
	
end

function GM:ScoreboardShow()
	if forced then return end
	showScoreboard = true
	ShowScoreboard()
end

function GM:ScoreboardHide()
	if forced then return end
	showScoreboard = false
	if IsValid( Frame ) then
		Frame:Close()
	end
end

function ForceShowScoreboard()
	ForceHideScoreboard()
	forced = true
	showScoreboard = true
	ShowScoreboard()
end

function ForceHideScoreboard()
	forced = false
	if IsValid( Frame ) then
		Frame:Close()
	end
end


function DrawText( x, y, text, color )
	color = color or Color( 255, 255, 255, 255 )
	draw.Text( {
		text = text,
		font = "BFC_Scoreboard_ext",
		pos = { x, y },
		xalign = TEXT_ALIGN_CENTER ,
		yalign = TEXT_ALIGN_CENTER ,
		color = color
	} )
end

function DrawPanel( x, y, w, h, length, text, color, textcolor )
	color = color or Color( 0, 0, 0, 0 )
	textcolor = textcolor or Color( 255, 255, 255, 255 )
	surface.SetDrawColor( color )
	surface.DrawRect( x, y, w * length, h )
	draw.Text( {
		text = text,
		font = "BFC_Scoreboard",
		pos = { x + w * length / 2, h * 0.5 },
		xalign = TEXT_ALIGN_CENTER ,
		yalign = TEXT_ALIGN_CENTER ,
		color = textcolor
	} )
	return x + w * length
end

function CalcNextPanelX( x, w, l )
	return x + w * l
end

function ValidateName( name )
	if string.len( name ) > 25 then
		return string.sub( name, 0, 25 )
	end
	return name
end
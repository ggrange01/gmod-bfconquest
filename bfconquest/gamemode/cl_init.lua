LANG = {}

--including modules
include( "shared.lua" )
include( "cl_hud.lua" )
include( "cl_targets.lua" )
include( "cl_scoreboard.lua" )
include( "cl_killscreen.lua" )
include( "cl_hud_ingame.lua" )
include( "cl_selectwindow.lua" )
include( "cl_postprocess.lua" )
--include( "config_creator.lua" )

--language
Lang = LANG.english

CreateClientConVar( "bfc_language", "english", true, false, "" )
cvars.AddChangeCallback( "bfc_language", function( name, old, new )
	if LANG[ new ] then
		Lang = LANG[ new ]
	end
end)

local langtouse = GetConVar( "bfc_language" ):GetString()
if LANG[ langtouse ] then
	Lang = LANG[ langtouse ]
end

print( "Setting language to "..Lang.NAME )

--clientside hooks

function GM:PlayerBindPress( ply, bind, pressed )
	if bind == "+menu" then
		ply:ConCommand( "lastinv" )
	elseif bind == "+zoom" then
		ply:ConCommand( "bfc_detect" )
	end
end

--vars init

InGameHUD = InGameHUD or false
RoleSelectHUD = RoleSelectHUD or false
KillScreen = KillScreen or false

GameStarted = GameStarted or false
MaxTickets = GetConVar( "bfc_tickets" ):GetInt()

PlayerSpawnData = {
	PRIM = "DEF",
	SEC = "DEF",
	NADE = "DEF",
	SPEC = "DEF",
	POINT = "DE",
}

DeathInfo = {
	killer = nil,
	weapon = nil,
	damage = 0,
	shots = 0
}

PlayerNextSpawn = 0

Weapons = Weapons or {}
Levels = Levels or {}
DetectedPlayers = DetectedPlayers or {}
DrawHalos = DrawHalos or {}

--concommands

RunConsoleCommand( "cw_blur_customize", 1 )

concommand.Add( "bfc_suicide", function( ply, cmd, args )
	net.Start( "PlayerSuicide" )
	net.SendToServer()
end )

local ndetect = 0
concommand.Add( "bfc_detect" , function( ply, cmd, args )
	if ndetect > CurTime() then return end
	ndetect = CurTime() + 2.5
	net.Start( "DetectPort" )
	net.SendToServer()
end )

local nflares = 0
concommand.Add( "bfc_flares" , function( ply, cmd, args )
	if !VehicleLocked then return end
	if nflares > CurTime() then return end
	nflares = CurTime() + 2.5
	net.Start( "BFCVehicle" )
	net.SendToServer()
end )

concommand.Add( "bfc_rebuild_minimap", function( ply, cmd, args )
	if MINIMAP then
		if args[1] == "true" then
			RebuildMinimap( true )
		else
			RebuildMinimap()
			print( "Minimap has been rebuilded! If you changed resolution then use 'bfc_rebuild_minimap true' instead" )
		end
	else
		print( "Minimap is not supported on this map!" )
	end
end )

concommand.Add( "bfc_minimap", function( ply, cmd, args )
	if MINIMAP then
		if MINIMAP.Enabled then
			MINIMAP.Enabled = false
			print( "Minimap disabled" )
			RunConsoleCommand( "cvar_bfc_minimap_enabled", 0 )
		else
			MINIMAP.Enabled = true
			print( "Minimap enabled" )
			RunConsoleCommand( "cvar_bfc_minimap_enabled", 1 )
		end
	else
		print( "Minimap is not supported on this map!" )
	end
end )

concommand.Add( "bfc_minimap_static", function( ply, cmd, args )
	if MINIMAP then
		if MINIMAP.Enabled then
			if MINIMAP.Static then
				MINIMAP.Static = false
				print( "Minimap static mode disabled" )
				RunConsoleCommand( "cvar_bfc_minimap_static_enbaled", 0 )
			else
				MINIMAP.Static = true
				print( "Minimap static mode enabled" )
				RunConsoleCommand( "cvar_bfc_minimap_static_enbaled", 1 )
			end
		else
			print( "Minimap is disabled! Enable minimap in order to change minimap mode!" )
		end
	else
		print( "Minimap is not supported on this map!" )
	end
end )

CreateClientConVar( "cvar_bfc_minimap_enabled", "1" )
CreateClientConVar( "cvar_bfc_minimap_static_enbaled", "0" )
CreateClientConVar( "cvar_bfc_minimap_quality", "1" )

if MINIMAP then
	MINIMAP.Enabled = GetConVar( "cvar_bfc_minimap_enabled" ):GetBool()
	MINIMAP.Static = GetConVar( "cvar_bfc_minimap_static_enbaled" ):GetBool()
end

/*
concommand.Add( "bfc_t", function( ply, cmd, args )
	InGameHUD = !InGameHUD
	if RoleSelectHUD then
		HideSelectWindow()
	else
		ShowSelectWindow()
	end
end )

concommand.Add( "bfc_n", function( ply, cmd, args )
	if KillScreen then
		HideKillScreen()
		ShowSelectWindow()
	else
		HideSelectWindow()
		ShowKillScreen()
	end
end )

concommand.Add( "bfc_p", function( ply, cmd, args )
	for i = 1, 8 do
		table.insert( newPoints, "test"..i )
	end
end )
--net
*/

-------CREDITS-------

timer.Create( "Credits", 180, 0, function()
	print( "BF Conquest by danx91 [ZGFueDkx] - release v"..BFC_VERSION.." ["..BFC_DATE.."]" )
end)

---------------------

net.Receive( "DetectPort", function( len )
	DetectedPlayers = net.ReadTable()
	local halos = {}
	for k, v in pairs( DetectedPlayers ) do
		if v.halo then
			table.insert( halos, v.ent )
		end
	end
	DrawHalos = halos
end )

net.Receive( "AddPoints", function(len)
	local text = net.ReadString()
	local points = net.ReadString()
	if GetLangMessage( text ) != "" then
		text = GetLangMessage( text )
	end
	table.insert( newPoints, text.." "..points )
end )

net.Receive( "RoundDataPort", function( len )
	RoundData = net.ReadTable()
end )

net.Receive( "GameSetPort", function( len )
	Weapons = net.ReadTable()
	Levels = net.ReadTable()
end )

net.Receive( "PlayerSpawnPort", function( len )
	local command = net.ReadString()
	if command == "nst" then
		DeathInfo = net.ReadTable()
		PlayerNextSpawn = net.ReadFloat()
		ShouldDrawTargets = false
		InGameHUD = false
		ShowKillScreen()
		timer.Simple( 7, function()
			HideKillScreen()
			ShowSelectWindow()
		end )
	elseif command == "frs" then
		PlayerNextSpawn = net.ReadFloat()
		ShouldDrawTargets = false
		InGameHUD = false
		PlayerSpawnData = {
			PRIM = "DEF",
			SEC = "DEF",
			NADE = "DEF",
			SPEC = "DEF",
			POINT = "DE",
		}
		ShowSelectWindow()
		ForceHideScoreboard()
	elseif command == "ok" then
		ShouldDrawTargets = true
		PlayerNextSpawn = 0
		InGameHUD = true
		HideSelectWindow()
	elseif command == "err" then
		local err = net.ReadString()
		print( err )
	end
end )

net.Receive( "PlayerChangeTeamPort", function( len )
	local result = net.ReadInt( 2 )
	local msg = ""
	if result == 1 then
		msg = GetLangMessage( "tcs" )
	else
		msg = GetLangMessage( "tcf" )
	end
	--print( msg )
	table.insert( newPoints, msg )
end )

net.Receive( "UpdateTickets", function( len )
	local tickets = net.ReadTable()
	RoundData.RUT = tickets.ru
	RoundData.UST = tickets.us
end )

net.Receive( "ObjectStatusChanged", function( len )
	ObjectsStatus = net.ReadTable()
end )

net.Receive( "ObjectProgress", function( len )
	ObjectProgress = net.ReadTable()
end )

net.Receive( "GameEnd", function( len )
	local wteam = net.ReadInt( 3 )
	ntime = net.ReadFloat()
	ShouldDrawTargets = false
	InGameHUD = false
	if KillScreen then HideKillScreen() end
	HideSelectWindow()
	ForceShowScoreboard()
end )

net.Receive( "PlayerReady", function( len )
	local initdata = net.ReadTable()
	MaxTickets = initdata.tickets
	if initdata.gamestarted then
		ShowSelectWindow()
		if MINIMAP then
			RebuildMinimap()
		end
		GameStarted = initdata.gamestarted
		ObjectProgress = initdata.progress
		ObjectsStatus = initdata.status
	end
end )

net.Receive( "PlayerBaseRape", function( len ) 
	local br = net.ReadBool()
	LocalPlayer().BaseRape = br
	if br then
		LocalPlayer().BRTime = CurTime() + 5
	else
		LocalPlayer().BRTime = 0
	end
end )

local beepsnd = Sound( "stinger/check1.wav" )

net.Receive( "BFCVehicle", function( len ) 
	local s = net.ReadInt( 2 )
	if s == 1 then
		VehicleLocked = true
		timer.Create( "VehicleLockedBeep", 0.2, 0, function()
			surface.PlaySound( beepsnd )
		end )
	elseif s == 0 then
		VehicleLocked = false
		if timer.Exists( "VehicleLockedBeep" ) then
			timer.Remove( "VehicleLockedBeep" )
		end
	end
end )

timer.Simple( 0.5, function()
	net.Start( "RoundDataPort" )
	net.SendToServer()
	net.Start( "GameSetPort" )
	net.SendToServer()
	net.Start( "PlayerReady" )
	net.SendToServer()
end )

include( "sh_modloader.lua" )

print( "CLIENT OK" )
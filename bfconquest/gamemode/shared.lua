GM.Name = "BFConquest"
GM.Author = "danx91"
GM.Email = ""
GM.Website = ""

BFC_VERSION = "1.0"
BFC_DATE = "27.03.2018"

local files, dirs = file.Find( GM.FolderName.."/gamemode/languages/*.lua", "LUA" )
for k, v in pairs( files ) do
	print( "Loading language "..v )
	if SERVER then
		AddCSLuaFile( "languages/"..v )
	else
		include( "languages/"..v )
	end
end

local path = GM.FolderName.."/gamemode/config/maps/"..game.GetMap()..".lua"
if file.Exists( path, "LUA" ) then
	print( "Loading config for map "..game.GetMap() )
	if SERVER then
		AddCSLuaFile( path )
		include( path )
	else
		include( path )
	end
	hook.Run( "BFCMapLoaded", Config )
else
	print( "Loading config failed for map ", game.GetMap() )
	print( [[If you want to create your own config switch gamemode to sandbox
			and type bfc_config_creator]] )
end

include( "sh_player.lua" )
include( "player_class.lua" )
include( "sh_func.lua" )
include( "ulx.lua" )

function GM:Initialize()
	self.BaseClass.Initialize( self )
	--concommand.Add("cw_customize", CW20_Customize)
	CustomizableWeaponry.canDropWeapon = false
end

function GM:ShutDown()
	if SERVER then
		for k, v in pairs( player.GetAll() ) do
			v:SaveData()
		end
	end
end

-- shared vars
RoundData = RoundData or {
	OBJS = {},
	RUT = 0,
	UST = 0
}

ObjectsStatus = ObjectsStatus or {}
ObjectProgress = ObjectProgress or {}

--shared hooks

/*function GM:EntityEmitSound( data ) -- breaks sound
	local p = data.Pitch
	if ( game.GetTimeScale() != 1 ) then
		data.Pitch = math.Clamp( p * game.GetTimeScale(), 0, 255 )
	end*
	return true
end*/

local lct = 0
function ObjectsCalc()
	if #player.GetAll() < 1 then return end
	if !GameStarted then return end
	if lct > CurTime() then return end
	lct = CurTime() + 0.4
	CalcObjectsStatus()
	if SERVER then
		local changed = false
		for k, v in pairs( ObjectProgress ) do
			local obj = TranslateObjectByName( k )
			if v[1] == 100 and obj.teamID != v[2] then
				ChangeObjectTeam( obj.name, v[2] )
				changed = true
				AddCapturePoints( obj, v[2] )
			elseif obj.teamID != v[2] and obj.teamID != TEAM_NONE then
				ChangeObjectTeam( obj.name, TEAM_NONE )
				changed = true
				AddCapturePoints( obj, GetEnemyTeam( obj.teamID ), true )
			end
		end
		if changed then
			net.Start( "RoundDataPort" )
				net.WriteTable( GetRoundData() )
			net.Broadcast()
			net.Start( "ObjectProgress" )
				net.WriteTable( ObjectProgress )
			net.Broadcast()
		end
	end
end
hook.Add( "Tick", "ObjectsCalc", ObjectsCalc )

function AddCapturePoints( obj, team, n )
	local fent = ents.FindInSphere( Targets[ obj.name ].pos, Targets[ obj.name ].area )
	for _, ent in pairs( fent ) do
		if ent:IsPlayer() and ent:Alive() and !ent.IsDead and ent:GetBFCTeam() == team then
			if math.Distance( 0, ent:GetPos().z, 0, Targets[ obj.name ].height ) < Targets[ obj.name ].h then
				if n then
					ent:AddScoreMsg( 75, "tn" )
				else
					ent:AddScoreMsg( 100, "tc" )
				end
			end
		end
	end
end

--shared convars

if !ConVarExists( "bfc_tickets" ) then CreateConVar( "bfc_tickets", 250, { FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARHCIVE, FCVAR_NOTIFY}, "Starting value of tickets" ) end
if !ConVarExists( "bfc_friendlyfire" ) then CreateConVar( "bfc_friendlyfire", 0, { FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARHCIVE, FCVAR_NOTIFY}, "Is friendlyfire allowed?" ) end
--if !ConVarExists( "bfc_auto_punish_vote" ) then CreateConVar( "bfc_auto_punish_vote", 0, { FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARHCIVE, FCVAR_NOTIFY}, "Works only when bfc_friendlyfire value is 1" ) end
if !ConVarExists( "bfc_scale_damage" ) then CreateConVar( "bfc_scale_damage", 1, { FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARHCIVE, FCVAR_NOTIFY}, "Scales bullets damage" ) end
if !ConVarExists( "bfc_disable_autobalance" ) then CreateConVar( "bfc_disable_autobalance", 0, { FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARHCIVE, FCVAR_NOTIFY}, "Disables autobalance" ) end
--if !ConVarExists( "bfc_hardcore_mode" ) then CreateConVar( "bfc_hardcore_mode", 0, { FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARHCIVE, FCVAR_NOTIFY}, "Works only when bfc_friendlyfire value is 1" ) end
--if !ConVarExists( "bfc_vehicles_teams" ) then CreateConVar( "bfc_vehicles_teams", 0, { FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARHCIVE, FCVAR_NOTIFY}, "Restricts vehicles only for specified teams" ) end
if !ConVarExists( "bfc_allow_vehicles" ) then CreateConVar( "bfc_allow_vehicles", 1, { FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARHCIVE, FCVAR_NOTIFY}, "Is vehicles allowed?" ) end
--shared vars

TEAM_NONE = 0
TEAM_US = 1
TEAM_RU = 2
COLOR_US = Color( 125, 211, 254, 255 )
COLOR_RU = Color( 231, 139, 94, 255 )

--ammo

game.AddAmmoType( {
 	name = "bfc_rocket",
 	npcdmg = 0,
 	plydmg = 0
 } )

game.AddAmmoType( {
 	name = "bfc_fim92",
 	npcdmg = 0,
 	plydmg = 0
 } )
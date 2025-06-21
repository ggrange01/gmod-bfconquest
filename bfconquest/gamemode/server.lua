--network
util.AddNetworkString( "RoundDataPort" )
util.AddNetworkString( "GameSetPort" )
util.AddNetworkString( "PlayerSpawnPort" )
util.AddNetworkString( "PlayerChangeTeamPort" )
util.AddNetworkString( "PlayerReady" )
util.AddNetworkString( "AddPoints" )
util.AddNetworkString( "SendMessage" )
util.AddNetworkString( "UpdateTickets" )
util.AddNetworkString( "ObjectStatusChanged" )
util.AddNetworkString( "ObjectProgress" )
util.AddNetworkString( "GameEnd" )
util.AddNetworkString( "PlayerSuicide" )
util.AddNetworkString( "PlayerBaseRape" )
util.AddNetworkString( "DetectPort" )
util.AddNetworkString( "BFCVehicle" )

DetectedPlayers = {
	{},
	{}
}

net.Receive( "BFCVehicle", function( len, ply )
	if ply:InVehicle() then
		local vehicle = ply:GetVehicle():GetParent()
		if !IsValid( vehicle ) then
			vehicle = ply:GetVehicle()
		end
		if !IsValid( vehicle ) then return end

		if vehicle.LaunchFlares then
			vehicle:LaunchFlares()
		else
			vehicle.Flares = CreateFlare( vehicle )
		end
	end
	/*local flare = ents.Create( "bfc_flare" )
	if IsValid( flare ) then
		flare:SetPos( ply:GetPos() + Vector( 0, 0, 25 ) )
		flare:SetDirection( ply:GetAimVector() )
		flare:Spawn()
	else
		print( "NOT VALID" )
	end*/
end )

net.Receive( "DetectPort", function( len, ply )
	if !ply.ndetect then ply.ndetect = 0 end
	if ply.ndetect > CurTime() then return end
	ply.ndetect = CurTime() + 2.5
	local tab = DetectPlayers( ply )
	for k, v in pairs( GetPlayersByTeam( ply:GetBFCTeam() ) ) do
		net.Start( "DetectPort" )
			net.WriteTable( tab )
		net.Send( v )
	end
end )

net.Receive( "PlayerReady", function( len, ply )
	net.Start( "PlayerReady" )
	net.WriteTable( {
		tickets = GetConVar( "bfc_tickets" ):GetInt() or 250,
		gamestarted = GameStarted,
		progress = ObjectProgress,
		status = ObjectsStatus
	} )
	net.Send( ply )
end )

net.Receive( "PlayerSuicide", function( len, ply )
	if ply:GetBFCTeam() == TEAM_NONE then return end
	if ply.IsDead then return end
	if ply.nsuicide and ply.nsuicide > CurTime() then return end
	ply.nsuicide = CurTime() + 180
	ply:Kill()
end )

net.Receive( "RoundDataPort", function( len, ply )
	net.Start( "RoundDataPort" )
		net.WriteTable( GetRoundData() )
	net.Send( ply )
end )

net.Receive( "GameSetPort", function( len, ply )
	net.Start( "GameSetPort" )
		net.WriteTable( WEAPONS )
		net.WriteTable( LEVELS )
	net.Send( ply )
end )

net.Receive( "PlayerSpawnPort", function( len, ply )
	local data = net.ReadTable()
	--print( ply:GetName() )
	--PrintTable( data )
	SpawnPlayer( ply, data )
end )

net.Receive( "PlayerChangeTeamPort", function( len, ply )
	net.Start( "PlayerChangeTeamPort" )
		if ChangeTeam( ply ) then
			net.WriteInt( 1, 2 )
		else
			net.WriteInt( 0, 2 )
		end			
	net.Send( ply )
end )

function SendRoundData()
	net.Start( "RoundDataPort" )
		net.WriteTable( GetRoundData() )
	net.Broadcast()
end

function SpawnPlayer( ply, data )
	--if !ply.IsDead then return end --TODO
	if ply.NextSpawn and ply.NextSpawn != 0 and ply.NextSpawn > CurTime() then return end
	if !CanPlayerUseSpawn( ply, data.POINT ) then return end
	local wep, cat
	local z
	for k, v in pairs( data ) do
		if k != "POINT" then
			cat = k == "PRIM" and 1 or k == "SEC" and 2 or k == "NADE" and 3 or k == "SPEC" and 4 or 0
			z, wep = TranslateWeapon( WEAPONS, v, WEAPONS.TRANSLATE[cat] )
			if !CanPlayerUseWeapon( ply, wep ) then return end
			data[k] = wep
		end
	end
	net.Start( "PlayerSpawnPort" )
		net.WriteString( "ok" )
	net.Send( ply )
	if timer.Exists( "BaseRape_"..ply:SteamID64() ) then
		timer.Remove( "BaseRape_"..ply:SteamID64() )
	end
	ply.BaseRape = false
	net.Start( "PlayerBaseRape" )
		net.WriteBool( false )
	net.Send( ply )
	ply:SpawnData( data )
	TakeTeamTickets( ply:GetBFCTeam(), 1 )
end

function ChangeTeam( ply )
	if RoundData.UST < RoundMaxT * 0.08 or RoundData.RUT < RoundMaxT * 0.08 then return false end
	local us, ru = 0, 0
	for k, v in pairs( player.GetAll() ) do
		if v:GetBFCTeam() == TEAM_US then
			us = us + 1
		elseif v:GetBFCTeam() == TEAM_RU then
			ru = ru + 1
		end
	end
	if ply:GetBFCTeam() == TEAM_US and us - 1 > ru then
		ply:SetBFCTeam( TEAM_RU )
		return true
	elseif ply:GetBFCTeam() == TEAM_RU and ru - 1 > us then
		ply:SetBFCTeam( TEAM_US )
		return true
	end
	return false
end
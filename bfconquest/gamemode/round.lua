GameStarted = GameStarted or false
Flags = Flags or {}

FlagsCFG = {
	model_white = "models/gmodflags/otherflagpole.mdl",
	model = {
		US = "models/gmodflags/flagpole01.mdl",
		RU = "models/gmodflags/flagpole01.mdl",
		NONE = "models/gmodflags/otherflagpole.mdl"
	},
	white_skin = 7,
	skin = {
		US = 0,
		RU = 3,
		NONE = 7
	}
}

UpgradeAreaVec = UpgradeAreaVec or {}
BaseAreaVec = BaseAreaVec or {}

function LoadMapConfig()
	if Config then
		print( "Configuring map with config "..Config )

		local objects = {}
		local i = 1
		for k, v in pairs( Targets ) do
			ObjectsStatus[k] = { 0, 0 }
			ObjectProgress[k] = { 0, 0 }
			objects[i] = k.."0"
			i = i +1
		end
		table.sort( objects )
		RoundData.OBJS = objects

		UpgradeAreaVec = table.Copy( UpgradeAreas )
		for k, v in pairs( UpgradeAreaVec ) do
			OrderVectors( v[1], v[2] )
		end

		BaseAreaVec = table.Copy( BaseAreas )
		for k, v in pairs( BaseAreaVec ) do
			OrderVectors( v[1], v[2] )
		end

		if REGISTER_VEHICLES and isfunction( REGISTER_VEHICLES ) then
			REGISTER_VEHICLES()
		end
		
		return true
	end
	return false
end

function StartRound()
	CleanUpGame()
	CleanUpPlayers()
	print( "CleanUp: Done" )
	--
	SetupPlayers()
	print( "Players Setup: Done" )
	--
	RoundData.RUT = GetConVar( "bfc_tickets" ):GetInt() or 250
	RoundData.UST = GetConVar( "bfc_tickets" ):GetInt() or 250
	RoundMaxT = GetConVar( "bfc_tickets" ):GetInt() or 250
	LoadMapConfig()
	net.Start( "RoundDataPort" )
		net.WriteTable( GetRoundData() )
	net.Broadcast()
	net.Start( "ObjectStatusChanged" )
		net.WriteTable( ObjectsStatus )
	net.Broadcast()
	net.Start( "ObjectProgress" )
		net.WriteTable( ObjectProgress )
	net.Broadcast()
	net.Start( "PlayerReady" )
		net.WriteTable( { tickets = GetConVar( "bfc_tickets" ):GetInt() or 250 } )
	net.Broadcast()
	print( "Initial Data: Done" )
	--
	
	--
	CreateFlags()
	CreateTimers()
	if GetConVar( "bfc_allow_vehicles" ):GetInt() != 0 then
		BFCVehicles.SpawnAll()
	end
	--
	GameStarted = true
	BroadcastLua( "GameStarted = true" )
	print( "Round Ready" )
	--prep
	PreRound()
	timer.Create( "RoundStarted", 15, 1, function()
		RoundStarted()
		print( "Round Started" )
	end )
end

function StopRound()
	DestroyTimers()
	BFCVehicles.DestroyAll()
	RoundData = {
		OBJS = {},
		RUT = 0,
		UST = 0
	}
	net.Start( "RoundDataPort" )
		net.WriteTable( GetRoundData() )
	net.Broadcast()
	--
	GameStarted = false
	BroadcastLua( "GameStarted = false" )
end

function CleanUpGame()
	game.CleanUpMap()
	hook.Run( "BFCCleanup" )
end

function CleanUpPlayers()
	for k, v in pairs( player.GetAll() ) do
		v:SetBFCTeam( TEAM_NONE )
		if !v:IsBot() then
			v:SpawnAsSpectator()
		else
			v:Spawn()
		end
	end
end

function SetupPlayers()
	local players = player.GetAll()
	local nextteam = TEAM_US
	for i = 1, #players do
		local ply = table.remove( players, math.random( 1, #players ) )
		ply:SetBFCTeam( nextteam )
		if nextteam == TEAM_US then
			nextteam = TEAM_RU
		else
			nextteam = TEAM_US
		end
	end
end

function CreateTimers()
	timer.Create( "CheckBalance", 10, 0, function()
		if GetConVar( "bfc_disable_autobalance" ):GetInt() == 0 then
			BalanceTeams()
		end
	end )
	timer.Create( "TakeTickets", 1, 0, function()
		local allobjs = math.floor( #RoundData.OBJS / 2 )
		local usobjs, ruobjs = 0, 0
		for k, v in pairs( RoundData.OBJS ) do
			local trobj = TranslateObject( v )
			if trobj.teamID == TEAM_US then
				usobjs = usobjs + 1
			elseif trobj.teamID == TEAM_RU then
				ruobjs = ruobjs + 1
			end
		end
		if ruobjs > allobjs then
			TakeTeamTickets( TEAM_US, 1 )
		elseif	usobjs > allobjs then
			TakeTeamTickets( TEAM_RU, 1 )
		end
	end )
end

function DestroyTimers()
	timer.Remove( "RoundStarted" )
	timer.Remove( "RestartRound" )
	timer.Remove( "BalanceTimer" )
	timer.Remove( "CheckBalance" )
	timer.Remove( "TakeTickets" )
end

function GetRoundData()
	return RoundData
end

function TakeTeamTickets( team, i )
	if team == TEAM_RU then
		if RoundData.RUT - i >= 0 then
			RoundData.RUT = RoundData.RUT - i
			UpdateTickets()
			CheckWin()
		end
	elseif team == TEAM_US then
		if RoundData.UST - i >= 0 then
			RoundData.UST = RoundData.UST - i
			UpdateTickets()
			CheckWin()
		end
	end
end

AboutToStart = false
function CheckStart()
	local players = #player.GetAll()
	if players >= 2 and !GameStarted and !AboutToStart then
		AboutToStart = true
		net.Start( "SendMessage" )
			net.WriteString( "Game will start in 5 seconds!" )
		net.Broadcast()
		timer.Simple( 5, function()
			if players >= 2 then
				StartRound()
				AboutToStart = false
			end
		end )
	end
end

function CheckWin()
	local roundend = false
	local winteam = TEAM_NONE
	if RoundData.UST <= 0 then
		roundend = true
		winteam = TEAM_RU
	elseif RoundData.RUT <= 0 then
		roundend = true
		winteam = TEAM_US
	end
	if roundend then
		StopRound()
		PostRound( winteam )
		timer.Create( "RestartRound", 30, 1, function()
			PreRestart()
			StartRound()
		end )
	end
end

function UpdateTickets()
	local tickets = {
		us = RoundData.UST,
		ru = RoundData.RUT
	}
	net.Start( "UpdateTickets" )
		net.WriteTable( tickets )
	net.Broadcast()
end

function PreRound()
	net.Start( "PlayerSpawnPort" )
		net.WriteString( "frs" )
		net.WriteFloat( CurTime() + 15 )
	net.Broadcast()
	for k, v in pairs( player.GetAll() ) do
		v.NextSpawn = CurTime() + 15
	end
	hook.Run( "BFCPreRound" )
end

function RoundStarted()
	hook.Run( "BFCRoundStarted" )
end

function PostRound( team )
	if team then
		for k, v in pairs( player.GetAll() ) do
			if v:GetBFCTeam() == team then
				v:AddScoreMsg( 1000, "gwin" )
			end
		end
	end
	for k, v in pairs( player.GetAll() ) do
		v:AddScoreMsg( 250, "gfinish" )
		net.Start( "GameEnd" )
			net.WriteInt( team, 3 )
			net.WriteFloat( CurTime() + 30 )
		net.Send( v )
		v:SpawnAsSpectator()
	end
	hook.Run( "BFCPostRound", team )
end

function PreRestart()
	for k, v in pairs( player.GetAll() ) do
		v:PushScoreToExp()
	end
	ClearStats()
end

function CreateFlags()
	DestroyFlags()
	for k, v in pairs( Targets ) do
		local flag = ents.Create( "prop_physics" )
		if IsValid( flag ) then
			flag:SetModel( FlagsCFG.model_white )
			flag:SetSkin( FlagsCFG.white_skin )
			flag:SetPos( v.pos )
			flag:Spawn()
			local phys = flag:GetPhysicsObject()
			phys:EnableMotion( false )
			Flags[k] = flag
		end
	end
end

function DestroyFlags()
	for k, v in pairs( Flags ) do
		if IsValid( v ) then
			v:Remove()
		end
	end
end

--tick hooks

local ltime = 0
function CaptureCheck()
	if #player.GetAll() < 1 then return end
	if !Config or !GameStarted then return end
	if ltime > CurTime() then return end
	ltime = CurTime() + 0.1
	for k, v in pairs( Targets ) do
		local postf = Vector( v.pos.x, v.pos.y, v.height )
		local fent = ents.FindInSphere( postf, v.area )
		local us, ru = 0, 0
		for _, ent in pairs( fent ) do
			if ( ent:IsPlayer() or ent:IsNPC() ) and ent:Alive() and !ent.IsDead then
				if math.abs( ent:GetPos().z - v.height ) < v.h then
					if ent:GetBFCTeam() == TEAM_US then us = us + 1 end
					if ent:GetBFCTeam() == TEAM_RU then ru = ru + 1 end
				end
			end
		end
		if ObjectsStatus[k][1] != us or ObjectsStatus[k][2] != ru then
			ObjectsStatus[k] = { us, ru }
			net.Start( "ObjectStatusChanged" )
				net.WriteTable( ObjectsStatus )
			net.Broadcast()
		end
	end
end
hook.Add( "Tick", "CaptureCheck", CaptureCheck )

local brlt = 0
function BaseRapeCheck()
	if #player.GetAll() < 1 then return end
	if !Config or !GameStarted then return end
	if brlt > CurTime() then return end
	brlt = CurTime() + 0.5

	for _, ply in pairs( player.GetAll() ) do
		if ply:Alive() and !ply.IsDead then
			local inany = false
			for k, area in pairs( BaseAreaVec ) do
				local t = GetEnemyTeam( GetTeamID( string.sub( k, 1, 2 ) ) )
				if ply:GetBFCTeam() == t and ply:GetPos():WithinAABox( area[1], area[2] ) then
					inany = true
					break
				end
			end
			if inany and GameStarted then
				if !ply.BaseRape then
					ply.BaseRape = true
					net.Start( "PlayerBaseRape" )
						net.WriteBool( true )
					net.Send( ply )
					timer.Create( "BaseRape_"..ply:SteamID64(), 5, 1, function()
						if ply:Alive() and !ply.IsDead and ply.BaseRape then
							local inany = false
							for k, area in pairs( BaseAreaVec ) do
								local t = GetEnemyTeam( GetTeamID( string.sub( k, 1, 2 ) ) )
								if ply:GetBFCTeam() == t and ply:GetPos():WithinAABox( area[1], area[2] ) then
									inany = true
									break
								end
							end
							if inany then
								ply:Kill()
							end
						end
						ply.BaseRape = false
						net.Start( "PlayerBaseRape" )
							net.WriteBool( false )
						net.Send( ply )
					end )
				end
			else
				ply.BaseRape = false
				timer.Remove( "BaseRape_"..ply:SteamID64() )
				net.Start( "PlayerBaseRape" )
					net.WriteBool( false )
				net.Send( ply )
			end
		end
	end

	/*for k, v in pairs( BaseAreaVec ) do
		local t = string.sub( k, 1, 2 )
		local plys = GetPlayersByTeam( GetEnemyTeam( GetTeamID( t ) ) )
		for _, ply in pairs( plys ) do
			if ply:Alive() and !ply.IsDead and ply:GetPos():WithinAABox( v[1], v[2] ) and !ply.BaseRape and GameStarted then
				ply.BaseRape = true
				net.Start( "PlayerBaseRape" )
					net.WriteBool( true )
				net.Send( ply )
				timer.Create( "BaseRape_"..ply:SteamID64(), 5, 1, function()
					if ply:Alive() and !ply.IsDead and ply.BaseRape then
						if ply:GetPos():WithinAABox( v[1], v[2] ) then
							ply:Kill()
						end
					end
					ply.BaseRape = false
					net.Start( "PlayerBaseRape" )
						net.WriteBool( false )
					net.Send( ply )
				end )
				--print( "baserape started", ply )
			elseif ( !ply:Alive() or ply.IsDead or !ply:GetPos():WithinAABox( v[1], v[2] ) or ply:GetBFCTeam() == GetTeamID( t ) or !GameStarted ) and ply.BaseRape then

			elseif	
				ply.BaseRape = false
				net.Start( "PlayerBaseRape" )
					net.WriteBool( false )
				net.Send( ply )
				timer.Remove( "BaseRape_"..ply:SteamID64() )
				--print( "baserape stopped", ply )
			end
		end
	end*/
end
hook.Add( "Tick", "BaseRapeCheck", BaseRapeCheck )

local lcde= 0
function CheckDetectEnd()
	if #player.GetAll() < 1 then return end
	if !GameStarted then return end
	if lcde > CurTime() then return end
	lcde = CurTime() + 1
	for i = 1, 2 do
		local changed = false
		for index, v in ipairs( DetectedPlayers[i] ) do
			if v.time <= CurTime() then
				local islooking = false
				for k, pl in pairs( GetPlayersByTeam( GetEnemyTeam( v.ent:GetBFCTeam() ) ) ) do
					if MaxDetectDistance and MaxDetectDistance > 0 then
						if v.ent:GetPos():DistToSqr( pl:GetPos() ) > MaxDetectDistance * MaxDetectDistance then
							continue
						end
					end
					local trpos = util.TraceLine( {
						start = pl:EyePos(),
						endpos = v.ent:GetPos(),
						filter = { pl, v.ent }
					} )
					local treyes = util.TraceLine( {
						start = pl:EyePos(),
						endpos = v.ent:EyePos(),
						filter = { pl, v.ent }
					} )
					if !trpos.Hit and pl:GetEyeTrace().Normal:Dot( trpos.Normal ) > 0.97 or !treyes.Hit and pl:GetEyeTrace().Normal:Dot( treyes.Normal ) > 0.97 then
						islooking = true
						break
					end
				end
				if !islooking then
					table.remove( DetectedPlayers[i], index )
					changed = true
				else
					v.time = CurTime() + 3
					changed = true
				end
			end
		end
		if changed then
			for k, v in pairs( GetPlayersByTeam( i ) ) do
				net.Start( "DetectPort" )
					net.WriteTable( DetectedPlayers[i] )
				net.Send( v )
			end
		end
	end
end
hook.Add( "Tick", "DetectEnd", CheckDetectEnd )
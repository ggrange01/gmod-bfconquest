function CanPlayerUseSpawn( ply, spawn )
	if spawn == "DE" then return true end
	local objs = RoundData.OBJS
	local obj
	for k, v in pairs( objs ) do
		local tmpobj = TranslateObject( v )
		if tmpobj.name == spawn then
			obj = tmpobj
			break
		end
	end
	if !obj then return false end
	if GetTeamID( obj.team ) != ply:GetBFCTeam() then return false end
	return true
end

function AssignToTeam( ply )
	local us, ru = 0, 0
	for k, v in pairs( player.GetAll() ) do
		if v != ply then
			if v:GetBFCTeam() == TEAM_US then
				us = us + 1
			elseif v:GetBFCTeam() == TEAM_RU then
				ru = ru + 1
			end
		end
	end
	--print( us, ru )
	if us > ru then
		return TEAM_RU
	else
		return TEAM_US
	end
end

function BalanceTeams()
	local us, ru = 0, 0
	for k, v in pairs( player.GetAll() ) do
		if v != ply then
			if v:GetBFCTeam() == TEAM_US then
				us = us + 1
			elseif v:GetBFCTeam() == TEAM_RU then
				ru = ru + 1
			end
		end
	end
	local players = {}
	if ru - 1 > us then
		players = SortPlayers( GetPlayersByTeam( TEAM_RU ) )
	elseif us - 1 > ru then
		players = SortPlayers( GetPlayersByTeam( TEAM_US ) )
	end
	local vplayers = {}
	for i, v in ipairs( players ) do
		if i > math.floor( #players / 2 ) then
			table.insert( vplayers, v )
		end
	end
	local playertoswap = table.Random( vplayers )
	if playertoswap then
		net.Start( "SendMessage" )
			net.WriteString( "Teams will be balanced in 5 seconds!" )
		net.Broadcast()
		timer.Create( "BalanceTimer", 5, 1, function()
			ChangeTeam( playertoswap )
			playertoswap:Kill()
		end )
	end
end

function ChangeObjectTeam( obj, team )
	for k, v in pairs( RoundData.OBJS ) do
		local trobjn = TranslateObject( v ).name
		if obj == trobjn then
			RoundData.OBJS[k] = trobjn..team
			Flags[trobjn]:SetModel( FlagsCFG.model[ GetTeamName( team ) ] )
			Flags[trobjn]:SetSkin( FlagsCFG.skin[ GetTeamName( team ) ] )
		end
	end
end

function ClearStats()
	for k, v in pairs( player.GetAll() ) do
		v:SetFrags( 0 )
		v:SetDeaths( 0 )
	end
end

function CanUpgradeWeapon( ply )
	local pos = ply:GetPos()
	for k, v in pairs( UpgradeAreaVec ) do
		if pos:WithinAABox( v[1], v[2] ) then
			return true
		end
	end
	for k, v in pairs( Targets ) do
		local target = TranslateObjectByName( k )
		if target.teamID == ply:GetBFCTeam() then
			local postf = Vector( v.pos.x, v.pos.y, v.height )
			if ply:GetPos():Distance( postf ) < v.area then
				if math.abs( ply:GetPos().z - v.height ) < v.h then
					return true
				end
			end
		end
	end
end

function DetectPlayers( ply )
	local plnormal = ply:GetEyeTrace().Normal
	local plys = GetPlayersByTeam( GetEnemyTeam( ply:GetBFCTeam() ) )
	local tab = DetectedPlayers[ ply:GetBFCTeam() ]
	for k, v in pairs( plys ) do
		if MaxDetectDistance and MaxDetectDistance > 0 then
			if ply:GetPos():DistToSqr( v:GetPos() ) > MaxDetectDistance * MaxDetectDistance then
				continue
			end
		end
		local trpos = util.TraceLine( {
			start = ply:EyePos(),
			endpos = v:GetPos(),
			filter = { ply, v }
		} )
		local treyes = util.TraceLine( {
			start = ply:EyePos(),
			endpos = v:GetPos(),
			filter = { ply, v }
		} )
		if !trpos.Hit or !treyes.Hit then
			if plnormal:Dot( trpos.Normal ) > 0.97 or plnormal:Dot( treyes.Normal ) > 0.97 then
				local found = false
				for _, pl in pairs( tab ) do
					if v == pl.ent then
						pl.time = CurTime() + 5
						found = true
						break
					end
				end
				if !found then
					local totab = {
						ent = v,
						time = CurTime() + 5,
						halo = IsSniper( v )
					}
					table.insert( tab, totab )
				end
			end
		end
	end
	return tab
end

function IsSniper( ply )
	local weps = ply:GetWeapons()
	for k, v in pairs( weps ) do
		if v:GetClass() == "cw_l115" or v:GetClass() == "gdcw_m98b" then
			return true
		end
	end
end
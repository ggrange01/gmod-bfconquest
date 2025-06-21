function TranslateObject( obj )
	if !obj then return end
	local robj = { }
	robj.name = string.sub( obj, 0, 1 )
	robj.teamID = tonumber( string.sub( obj, 2, 3 ) )
	robj.team = GetTeamName( robj.teamID )
	return robj
end

function GetObjectByName( name )
	if !name then return end
	for k, v in pairs( RoundData.OBJS ) do
		if TranslateObject( v ).name == name then
			return v
		end
	end
end

function TranslateObjectByName( name )
	if !name then return end
	for k, v in pairs( RoundData.OBJS ) do
		local trobj = TranslateObject( v )
		if trobj.name == name then
			return trobj
		end
	end
end

function TranslateWeapon( weaponsTab, weapon, cat, def )
	cat = cat or "#ALL"
	local tab = weaponsTab[cat]
	if !tab and ( isnumber( cat ) or tonumber( cat ) ) then
		cat = tonumber( cat )
		for k, v in pairs( weaponsTab ) do
			if v.NUM == cat then
				tab = v
				break
			end
		end
	end
	if !tab and cat == "#ALL" then
		for k, v in pairs( weaponsTab ) do
			for i, wep in ipairs( v ) do
				if weapon == wep[1] or weapon == wep[2] then
					tab = v
					break
				end
			end
			if tab then break end
		end
		if !tab then return def end
	end
	if !tab then
		print( "Category "..cat.." not found in wepons list!" )
		return def
	end
	if weapon == "DEF" and tab.DEF then
		return tab[tab.DEF][1], tab[tab.DEF]
	end
	for k, v in pairs( tab ) do
		if k != "DEF" and k != "NUM" then
			if weapon == v[1] or weapon == v[2] then
				return v[1], v
			end
		end
	end
	if tab.DEF then
		return tab[tab.DEF][1], tab[tab.DEF]
	end
	return def
end

function table.IsEmpty( tab )
	for k, v in pairs( tab ) do
		return false
	end
	return true
end

function GetTeamColor( id )
	if id == TEAM_RU then
		return COLOR_RU
	elseif id == TEAM_US then
		return COLOR_US
	elseif id == TEAM_NONE then
		return Color( 255, 255, 255, 255 )
	end
	return Color( 0, 0, 0, 255 )
end

function GetTeamName( id )
	if id == TEAM_RU then
		return "RU"
	elseif id == TEAM_US then
		return "US"
	elseif id == TEAM_NONE then
		return "NONE"
	end
end

function GetTeamID( teamName )
	if teamName == "RU" then
		return TEAM_RU
	elseif teamName == "US" then
		return TEAM_US
	elseif teamName == "NONE" then
		return TEAM_NONE
	end
end

function GetEnemyTeam( teamID )
	if teamID == TEAM_RU then
		return TEAM_US
	elseif teamID == TEAM_US then
		return TEAM_RU
	elseif teamID == TEAM_NONE then
		return TEAM_NONE
	end
end

function WeaponTeamName( team, both )
	if team == "R" then return "RU" end
	if team == "U" then return "US" end
	if team == "N" then return both end
end

function VehicleTeamName( team )
	if team == "R" then return TEAM_RU end
	if team == "U" then return TEAM_US end
	if team == "N" then return TEAM_NONE end
end

function findWeapon( wep )
	if istable( wep ) then return wep end
	for k, v in pairs( WEAPONS ) do
		if k != "TRANSLATE" then
			for _, w in ipairs( v ) do
				if wep == w[1] or wep == w[2] then
					return w
				end
			end
		end
	end
end

function CanPlayerUseWeapon( ply, weapon )
	local wep = findWeapon( weapon )
	if !wep then return false end
	if GetTeamID( WeaponTeamName( wep[3], "NONE" ) ) != ply:GetBFCTeam() and GetTeamID( WeaponTeamName( wep[3], "NONE" ) ) != TEAM_NONE then return false end
	if wep[5] > ply:GetLevel() then return false end
	return true
end

function GetTrueExp( ply )
	return ply:GetExp() + ply:GetScore()
end

function SortPlayers( plytab )
	table.sort( plytab, sorter )
	return plytab
end

function sorter( ply1, ply2 )
	if ply1:GetScore() > ply2:GetScore() then
		return true
	end
	return false
end

function GetPlayersByTeam( teamid )
	local plytab = {}
	for k, v in pairs( player.GetAll() ) do
		if v.GetBFCTeam then
			if v:GetBFCTeam() == teamid then
				table.insert( plytab, v )
			end
		end
	end
	return plytab
end

function CalcObjectsStatus()
	for k, v in pairs( ObjectsStatus ) do
		--ObjectProgress[k][2] = 0
		--ObjectProgress[k][1] = 0
		local uss, rss = v[1], v[2]
		local wteam = uss > rss and TEAM_US or rss > uss and TEAM_RU
		local wam = math.abs( uss - rss )
		--print( k, v[1], v[2], wteam, wam, ObjectProgress[k][1], ObjectProgress[k][2] )
		if !wteam then 
			if TranslateObjectByName( k ).teamID != TEAM_NONE and TranslateObjectByName( k ).teamID == ObjectProgress[k][2] and ObjectProgress[k][1] < 100 and uss == 0 and rss == 0 then
				ObjectProgress[k][1] = ObjectProgress[k][1] + 2
			elseif ObjectProgress[k][2] != TEAM_NONE and ObjectProgress[k][1] > 0 and ObjectProgress[k][1] < 100 and uss == 0 and rss == 0 then
				ObjectProgress[k][1] = ObjectProgress[k][1] - 1
			end
			if ObjectProgress[k][1] > 100 then
				ObjectProgress[k][1] = 100
			elseif ObjectProgress[k][1] < 0 then
				ObjectProgress[k][1] = 0
			end
			continue
		end
		if ObjectProgress[k][2] == TEAM_NONE then
			ObjectProgress[k][2] = wteam
			ObjectProgress[k][1] = ObjectProgress[k][1] + wam		
		elseif ObjectProgress[k][2] == wteam then
			if ObjectProgress[k][1] >= 100 then continue end
			ObjectProgress[k][1] = ObjectProgress[k][1] + wam
		else
			ObjectProgress[k][1] = ObjectProgress[k][1] - wam
		end
		if ObjectProgress[k][1] <= 0 then
			ObjectProgress[k][2] = TEAM_NONE
		elseif ObjectProgress[k][1] >= 100 then 
			ObjectProgress[k][1] = 100
			ObjectProgress[k][2] = wteam
		end
	end
end

function GetMapPointPosition( point, team )
	team = team == TEAM_US and "US" or team == TEAM_RU and "RU"
	local correction = Correction and Vector( 0, 0, Correction ) or Vector( 0, 0, 5 )
	local var
	if SPAWNS[team.."_"..point] then
		var = SPAWNS[team.."_"..point]
	elseif SPAWNS[point] then
		var = SPAWNS[point]
	else
		return nil
	end
	if !istable( var ) then
		if isvector( var ) then
			return var + Vector( 0, 0, 5 )
		end
	else
		local pos = table.Random( var )
		if isvector( pos ) then
			return pos + Vector( 0, 0, 5 )
		end
	end
end

if CLIENT then
	function GetLangMessage( msg )
		if Lang[msg] then
			return Lang[msg]
		elseif LANG.english[msg] then
			return LANG.english[msg]
		else
			return ""
		end
	end
end
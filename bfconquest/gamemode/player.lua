-- player server vars
US_MODELS = {
	"models/steinman/bf4/us_01.mdl",
	"models/steinman/bf4/us_02.mdl",
	"models/steinman/bf4/us_03.mdl",
	"models/steinman/bf4/us_04.mdl",
}
RU_MODELS = {
	"models/steinman/bf4/ru_01.mdl",
	"models/steinman/bf4/ru_02.mdl",
	"models/steinman/bf4/ru_03.mdl",
	"models/steinman/bf4/ru_04.mdl",
}

DEATH_SOUNDS = {}

for i = 1, 21 do
	sound.Add( {
		name = "death_"..i,
		channel = CHAN_STATIC,
		volume = 1.0,
		level = 511,
		pitch = 100,
		sound = "death_sound/death"..i..".wav"
	} )
	DEATH_SOUNDS[i] = "death_"..i
end
-- player server hooks

function GM:PlayerConnect( name, ip )
	--
end

function GM:PlayerAuthed( ply, steamid, uniqueid )
	player_manager.SetPlayerClass( ply, "player_class" )
	player_manager.RunClass( ply, "SetupDataTables" )
end

function GM:PlayerDisconnected( ply )
	ply:PushScoreToExp()
	ply:SaveData()
end

function GM:PlayerInitialSpawn( ply ) 
	player_manager.SetPlayerClass( ply, "player_class" )
	player_manager.RunClass( ply, "SetupDataTables" )
	ply:SetModel( "models/player/kleiner.mdl" )
	--concommand.Add( "cw_customize", CW20_Customize ) --?
	ply:SetCanZoom( false )
	CheckStart()
end

function GM:PlayerSpawn( ply )
	if !ply.FirstSpawn then
		ply.FirstSpawn = true
		ply.IsDead = true
		ply:SpawnAsSpectator()
	end
	ply:SetTeam( 1 )
	ply:SetNoCollideWithTeammates(true)
	if ply.GetBFCTeam then
		if ply:GetBFCTeam() == TEAM_US then
			ply:SetModel( table.Random( US_MODELS ) )
		elseif ply:GetBFCTeam() == TEAM_RU then
			ply:SetModel( table.Random( RU_MODELS ) )
		end
	end
end

function GM:DoPlayerDeath( ply, attacker, dmg )
	--sound.Play( table.Random( DEATH_SOUNDS ), ply:GetPos(), 100 )
end

function GM:PlayerDeath( victim, inflictor, attacker )
	local timeo = 10
	victim:CreateRagdoll( timeo ) 
	local info = {
		killer = nil,
		weapon = nil,
		weapon_name = false,
		damage = 0,
		shots = 0
	}
	if IsValid( attacker ) and attacker:IsPlayer() then
		info.killer = attacker
		if attacker:GetBFCTeam() != victim:GetBFCTeam() then
			attacker:AddFrags( 1 )
			attacker:AddScoreMsg( 100, "pkill" )
		end
	end
	/*if IsValid( inflictor ) and inflictor.PrintName then
		info.weapon = inflictor.PrintName
		info.weapon_name = true
	elseif IsValid( inflictor ) then
		info.weapon = inflictor:GetClass()
	else*/if IsValid( attacker ) and attacker:IsPlayer() then
		local wep = attacker:GetActiveWeapon()
		if IsValid( wep ) then
			info.weapon = wep:GetClass()
		end
	end
	if IsValid( victim ) then
		victim:AddDeaths( 1 )
		sound.Play( table.Random( DEATH_SOUNDS ), victim:GetPos(), 180 )
		if victim:IsBot() then
			timer.Simple( 5, function() if !IsValid( victim ) then return end victim:Spawn() TakeTeamTickets( victim:GetBFCTeam(), 1 ) end )
			victim.rShots = 0
			victim.rDamage = 0
			return
		end
		info.shots = victim.rShots or 0
		info.damage = victim.rDamage or 0
		victim.rShots = 0
		victim.rDamage = 0
		victim.NextSpawn = CurTime() + timeo
		victim.IsDead = true
		victim:SpawnAsSpectator( info.killer )
		net.Start( "PlayerSpawnPort" )
			net.WriteString( "nst" )
			net.WriteTable( info )
			net.WriteFloat( victim.NextSpawn )
		net.Send( victim )
	end
end

function GM:PlayerDeathThink( ply ) 

end

function GM:PlayerDeathSound()
	return true
end

function GM:PlayerCanHearPlayersVoice( listener, talker )
	if  listener:GetBFCTeam() == talker:GetBFCTeam() then
		return true
	end
	if listener:GetPos():Distance( talker:GetPos() ) < 1000 and !listener.IsDead and !talker.IsDead then
		return true, true
	end
	return false
end

function GM:PlayerCanSeePlayersChat( text, teamOnly, listener, speaker ) 
	if teamOnly then
		if listener:GetBFCTeam() != speaker:GetBFCTeam() then
			return false
		end
	end
	return true
end

function GM:AllowPlayerPickup( ply, ent )
	return false
end

function GM:PlayerCanPickupWeapon( ply, wep )
	return #ply:GetWeapons() < ply.Weapons
end

function GM:PlayerCanPickupItem( ply, item )
	return false
end

function GM:PlayerShouldTakeDamage( ply, attacker )
	if GetConVar( "bfc_friendlyfire" ):GetInt() == 0 then
		if attacker:IsPlayer() and ply:GetBFCTeam() == attacker:GetBFCTeam() and ply != attacker then
			return false
		end
	end
	return true
end

function GM:PlayerUse( ply, ent )
	if !ply:InVehicle() and ( ent:IsVehicle() or ent.bfc_id ) and ent.bfc_team and ply.GetBFCTeam then
		local t = ply:GetBFCTeam()
		if isfunction( ent.bfc_team ) then
			return ent.bfc_team( t ) or false
		elseif ent.bfc_team == t then
			return true
		elseif ent.bfc_team == TEAM_NONE then
			local driver = ent:GetDriver()
			return !IsValid( driver ) or driver.GetBFCTeam and driver:GetBFCTeam() == t
		else
			return false
		end
	end
	return true
end

function GM:CanPlayerSuicide( player )
	--
end

function GM:PlayerSpray( ply ) 
	return true
end

--Drowning :D
local ndtime = 0
function PlayerDrowning()
	if ndtime > CurTime() then return end
	ndtime = CurTime() + 1
	for k, v in pairs( player.GetAll() ) do
		if !v.OxygenLevel then v.OxygenLevel = 6 end
		if v.OxygenLevel < 1 and v:WaterLevel() == 3 then
			local damage = DamageInfo()
			damage:SetDamage( 10 )
			damage:SetDamageType( DMG_DROWN )
			v:TakeDamageInfo( damage )
		elseif v:WaterLevel() == 3 then
			v.OxygenLevel = v.OxygenLevel - 1
			return
		end
		if v:WaterLevel() != 3 then
			v.OxygenLevel = 6
		end
	end
end
hook.Add( "Tick", "PlayerDrowning", PlayerDrowning )
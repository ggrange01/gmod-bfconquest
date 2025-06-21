BFC_VEHICLE_UNITS_REG = {}
BFC_VEHICLES_UNITS = {}
VEHICLES_SPAWN_HANDLER = {}

VEHICLE_UNIQUE_ID = 0

BFCVehicles = {}

function BFCVehicles.AddHandler( name, handler, override )
	if VEHICLES_SPAWN_HANDLER[name] and !override then return end
	if !isfunction( handler ) then return end

	VEHICLES_SPAWN_HANDLER[name] = handler
end

--[[
	data = {
		pos = ,
		ang = ,
		class = ,
		allow_respawn = ,
		respawn_time = ,
		team = ,
	}
]]

function BFCVehicles.AddUnits( data, handler )
	if !VEHICLES_SPAWN_HANDLER[handler] then
		print( "WARNING! Something has tried to register vehicle using invalid handler!" )
		return
	end

	for k, v in pairs( data ) do
		if !v.class or !v.pos then
			continue
		end

		local veh = {
			class = v.class,
			handler = handler,
			pos = v.pos + Vector( 0, 0, 10 ),
			ang = v.ang or Angle( 0, 0, 0 ),
			team = v.team or TEAM_NONE,
			a_r = v.allow_respawn,
			r_t = v.respawn_time,
		}

		table.insert( BFC_VEHICLE_UNITS_REG, veh )
	end
end

function BFCVehicles.SpawnAll()
	for i, v in ipairs( BFC_VEHICLE_UNITS_REG ) do
		local handler = VEHICLES_SPAWN_HANDLER[v.handler]

		local veh = handler( v.class, v.pos, v.ang )

		if veh then
			veh.BFCVehicle = true
			veh:SetNWBool( "BFCVehicle", true )
			veh.bfc_team = v.team
			veh.bfc_id = VEHICLE_UNIQUE_ID
			local unit = {
				ent = veh,
				regid = i,
				id = VEHICLE_UNIQUE_ID,
				resp = v.a_r
			}
			table.insert( BFC_VEHICLES_UNITS, unit )
			VEHICLE_UNIQUE_ID = VEHICLE_UNIQUE_ID + 1
		end
	end
end

function BFCVehicles.VehicleDestroyed( id, ply )
	local unit, index

	for i, v in ipairs( BFC_VEHICLES_UNITS ) do
		if v.id == id then
			unit = v
			index = i
			break
		end
	end

	if !unit then
		return
	end

	if unit.ent.bfc_team and IsValid( ply ) then
		if isfunction( unit.ent.bfc_team ) and unit.ent.bfc_team( GetEnemyTeam( ply:GetBFCTeam() ) ) or unit.ent.bfc_team == GetEnemyTeam( ply:GetBFCTeam() ) then
			ply:AddScoreMsg( 250, "veh_destroyed" )
		end
	end

	if !unit.resp then
		if IsValid( unit.ent ) then
			unit.ent:Remove()
		end
		table.remove( BFC_VEHICLES_UNITS, index )

		return
	end

	local reg = BFC_VEHICLE_UNITS_REG[unit.regid]

	timer.Create( "BFC_VEHICLE_RESPAWN_"..unit.id, reg.r_t, 1, function()
		if IsValid( unit.ent ) then
			unit.ent:Remove()
		end

		unit.ent = VEHICLES_SPAWN_HANDLER[reg.handler]( reg.class, reg.pos, reg.ang )
		unit.ent.bfc_team = reg.team
		unit.ent.bfc_id = unit.id
		unit.ent.BFCVehicle = true
		unit.ent:SetNWBool( "BFCVehicle", true )
	end )

end

function BFCVehicles.PlayerKilled( victim, attacker )
	if IsValid( victim ) and IsValid( attacker ) then
		if victim:GetBFCTeam() != attacker:GetBFCTeam() then
			attacker:AddFrags( 1 )
			attacker:AddScoreMsg( 100, "pkill" )
		end
	end
end

function BFCVehicles.DestroyAll()
	print( "destro" )
	for i, v in ipairs( BFC_VEHICLES_UNITS ) do
		if IsValid( v.ent ) then
			v.ent:Remove()
		end
		if timer.Exists( "BFC_VEHICLE_RESPAWN_"..v.id ) then
			timer.Remove( "BFC_VEHICLE_RESPAWN_"..v.id )
		end
	end

	BFC_VEHICLES_UNITS = {}
	BFC_VEHICLE_UNITS_REG = {}
end

--Simfphys Functions

function SpawnSimfphysVehicle( class, pos, ang )
	if !pos then return end
	ang = ang or Angle( 0, 0, 0 )

	local vehicle = list.Get( "simfphys_vehicles" )[ class ]
	if !vehicle then
		print( "WARNING! Something has tried to spawn unknown vehicle '"..class.."'!" )
		return
	end
	
	local v = simfphys.SpawnVehicle( nil, pos, ang, vehicle.Model, vehicle.Class, class, vehicle, true )

	if !IsValid( v ) then
		print( "ERROR! An error has occured while spawning vehicle '"..class.."'!" )
		return
	end
	
	return v
end

BFCVehicles.AddHandler( "SIMFPHYS_HANDLER", SpawnSimfphysVehicle )

--WAC Functions

function SpawnWACVehicle( class, pos, ang )
	if !pos then return end
	ang = ang or Angle( 0, 0, 0 )

	local v = ents.Create( class )

	if !IsValid( v ) then
		print( "ERROR! An error has occured while spawning vehicle '"..class.."'!" )
		return
	end
	
	v:SetPos( pos )
	v:SetAngles( ang )

	v:Spawn()

	return v
end

BFCVehicles.AddHandler( "WAC_HANDLER", SpawnWACVehicle )

--Numpad controller

hook.Add( "PlayerButtonUp", "numpad_controller", function( ply, btn )
	numpad.Deactivate( ply, btn )
end )

hook.Add( "PlayerButtonDown", "numpad_controller", function( ply, btn )
	numpad.Activate( ply, btn )
end )

--Hooks

hook.Add( "PlayerLeaveVehicle", "PlayerExitVehicle", function( ply, vehicle )
	if IsValid( ply ) then
		net.Start( "BFCVehicle" )
			net.WriteInt( 0, 2 )
		net.Send( ply )
	end
end )

--Functions

function OnVehicleLocked( ent, rocket )
	if !ent.LockedRockets then ent.LockedRockets = {} end
	ent.LockedRockets[rocket:EntIndex()] = rocket

	if !timer.Exists( "simfphys_locked_"..ent:EntIndex() ) then
		timer.Create( "simfphys_locked_"..ent:EntIndex(), 0.5, 0, function()
			if !IsValid( ent ) then
				timer.Remove( "simfphys_locked_"..ent:EntIndex() )
				return
			end
			local driver = ent:GetDriver()
			if IsValid( driver ) then
				net.Start( "BFCVehicle" )
					net.WriteInt( 1, 2 )
				net.Send( driver )
			end
		end )
	end
end

function OnRocketDestroyed( ent, rocket )
	if !ent.LockedRockets then ent.LockedRockets = {} end
	ent.LockedRockets[rocket:EntIndex()] = nil

	if table.Count( ent.LockedRockets ) < 1 then
		local driver = ent:GetDriver()
		if IsValid( driver ) then
			net.Start( "BFCVehicle" )
				net.WriteInt( 0, 2 )
			net.Send( driver )
		end
		if timer.Exists( "simfphys_locked_"..ent:EntIndex() ) then
			timer.Remove( "simfphys_locked_"..ent:EntIndex() )
			local driver = ent:GetDriver()
			if IsValid( driver ) then
				net.Start( "BFCVehicle" )
					net.WriteInt( 0, 2 )
				net.Send( driver )
			end
		end
	end
end

local flaresnd = Sound( "stinger/rocketfire1.wav" )

function CreateFlare( vehicle )
	if !vehicle.LockedRockets or table.Count( vehicle.LockedRockets ) < 1 then return end

	local nearest_rocket
	local dist = -1

	for k, v in pairs( vehicle.LockedRockets ) do
		local d = vehicle:GetPos():DistToSqr( v:GetPos() )
		if dist == -1 or d < dist then
			dist = d
			nearest_rocket = v
		end
	end

	if !IsValid( nearest_rocket ) or dist == -1 then return end

	if !vehicle.NFlare then	
		vehicle.NFlare = 0
	end
	if vehicle.NFlare > CurTime() then return end

	local dir = ( nearest_rocket:GetPos() - vehicle:GetPos() ):GetNormalized()

	local flare = ents.Create( "bfc_flare" )
	if IsValid( flare ) then
		vehicle.NFlare = CurTime() + 10
		flare:SetPos( vehicle:GetPos() + Vector( 0, 0, 75 ) + dir * 100 )
		flare:SetDirection( dir )
		flare:Spawn()
		flare:EmitSound( flaresnd, 75, 100, 0.5 )
	end

end
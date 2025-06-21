local function Spark( pos , normal , snd )
	local effectdata = EffectData()
	effectdata:SetOrigin( pos - normal )
	effectdata:SetNormal( -normal )
	util.Effect( "stunstickimpact", effectdata, true, true )
	
	if snd then
		sound.Play(Sound( snd ), pos, 75)
	end
end

local function BloodEffect( pos )
	local effectdata = EffectData()
	effectdata:SetOrigin( pos )
	util.Effect( "BloodImpact", effectdata, true, true )
end

local function DestroyVehicle( ent, attacker )
	if not IsValid( ent ) then return end
	if ent.destroyed then return end
	
	ent:OnDestroyed()
	
	ent.destroyed = true
	
	local ply = ent.EntityOwner
	local skin = ent:GetSkin()
	local Col = ent:GetColor()
	Col.r = Col.r * 0.8
	Col.g = Col.g * 0.8
	Col.b = Col.b * 0.8
	
	local bprop = ents.Create( "gmod_sent_vehicle_fphysics_gib" )
	bprop:SetModel( ent:GetModel() )			
	bprop:SetPos( ent:GetPos() )
	bprop:SetAngles( ent:GetAngles() )
	bprop:Spawn()
	bprop:Activate()
	bprop:GetPhysicsObject():SetVelocity( ent:GetVelocity() + Vector(math.random(-5,5),math.random(-5,5),math.random(150,250)) ) 
	bprop:GetPhysicsObject():SetMass( ent.Mass * 0.75 )
	bprop.DoNotDuplicate = true
	bprop.MakeSound = true
	bprop:SetColor( Col )
	bprop:SetSkin( skin )
	
	simfphys.SetOwner( ply , bprop )
	
	if IsValid( ply ) then
		undo.Create( "Gib" )
		undo.SetPlayer( ply )
		undo.AddEntity( bprop )
		undo.SetCustomUndoText( "Undone Gib" )
		undo.Finish( "Gib" )
		ply:AddCleanup( "Gibs", bprop )
	end
	
	if ent.CustomWheels == true and not ent.NoWheelGibs then
		for i = 1, table.Count( ent.GhostWheels ) do
			local Wheel = ent.GhostWheels[i]
			if IsValid(Wheel) then
				local prop = ents.Create( "gmod_sent_vehicle_fphysics_gib" )
				prop:SetModel( Wheel:GetModel() )			
				prop:SetPos( Wheel:LocalToWorld( Vector(0,0,0) ) )
				prop:SetAngles( Wheel:LocalToWorldAngles( Angle(0,0,0) ) )
				prop:SetOwner( bprop )
				prop:Spawn()
				prop:Activate()
				prop:GetPhysicsObject():SetVelocity( ent:GetVelocity() + Vector(math.random(-5,5),math.random(-5,5),math.random(0,25)) )
				prop:GetPhysicsObject():SetMass( 20 )
				prop.DoNotDuplicate = true
				bprop:DeleteOnRemove( prop )
				
				simfphys.SetOwner( ply , prop )
			end
		end
	end
	
	local Driver = ent:GetDriver()
	if IsValid( Driver ) then
		if ent.RemoteDriver ~= Driver then
			Driver:Kill()
			if IsValid( attacker ) then
				BFCVehicles.PlayerKilled( Driver, attacker )
			end
		end
	end
	
	if ent.PassengerSeats then
		for i = 1, table.Count( ent.PassengerSeats ) do
			local Passenger = ent.pSeat[i]:GetDriver()
			if IsValid( Passenger ) then
				Passenger:Kill()
				if IsValid( attacker ) then
					BFCVehicles.PlayerKilled( Passenger, attacker )
				end	
			end
		end
	end
	
	ent:Extinguish() 
	ent:Remove()
end

local function DamageVehicle( ent , damage, type, attacker )
	if not simfphys.DamageEnabled then return end
	
	local MaxHealth = ent:GetMaxHealth()
	local CurHealth = ent:GetCurHealth()
	
	local NewHealth = math.max( math.Round(CurHealth - damage,0) , 0 )
	
	if NewHealth <= (MaxHealth * 0.6) then
		if NewHealth <= (MaxHealth * 0.3) then
			ent:SetOnFire( true )
			ent:SetOnSmoke( false )
		else
			ent:SetOnSmoke( true )
		end
	end
	
	if MaxHealth > 30 and NewHealth <= 31 then
		if ent:EngineActive() then
			ent:DamagedStall()
		end
	end
	
	if NewHealth <= 0 then
		if ent.bfc_id then
			BFCVehicles.VehicleDestroyed( ent.bfc_id, attacker )
		end

		if type ~= DMG_GENERIC and type ~= DMG_CRUSH or damage > 400 then
			
			DestroyVehicle( ent, attacker )
			
			return
		end
		
		if ent:EngineActive() then
			ent:DamagedStall()
		end

		return
	end
	
	ent:SetCurHealth( NewHealth )
end

local function HurtPlayers( ent, damage )
	if not simfphys.pDamageEnabled then return end
	
	local Driver = ent:GetDriver()
	
	if IsValid( Driver ) then
		if ent.RemoteDriver ~= Driver then
			Driver:TakeDamage(damage, Entity(0), ent )
		end
	end
	
	if ent.PassengerSeats then
		for i = 1, table.Count( ent.PassengerSeats ) do
			local Passenger = ent.pSeat[i]:GetDriver()
			
			if IsValid(Passenger) then
				Passenger:TakeDamage(damage, Entity(0), ent )
			end
		end
	end
end

local function bcDamage( vehicle , position , cdamage )
	if not simfphys.DamageEnabled then return end
	
	cdamage = cdamage or false
	net.Start( "simfphys_spritedamage" )
		net.WriteEntity( vehicle )
		net.WriteVector( position ) 
		net.WriteBool( cdamage ) 
	net.Broadcast()
end

local function onCollide( ent, data )
	if IsValid( data.HitEntity ) then
		if data.HitEntity:GetClass():StartWith( "npc_" ) then
			Spark( data.HitPos , data.HitNormal , "MetalVehicle.ImpactSoft" )
			return
		end
	end
	
	if ( data.Speed > 60 && data.DeltaTime > 0.2 ) then
		
		local pos = data.HitPos

		if (data.Speed > 1000) then
			Spark( pos , data.HitNormal , "MetalVehicle.ImpactHard" )

			HurtPlayers( ent , data.Speed / 20 )
			
			ent:TakeDamage( ( data.Speed ) * simfphys.DamageMul, Entity(0), Entity(0) )
			
			bcDamage( ent, ent:WorldToLocal( pos ), true )
		else
			Spark( pos, data.HitNormal, "MetalVehicle.ImpactSoft" )
			
			if data.Speed > 300 then
				local hitent = data.HitEntity:IsPlayer()
				if not hitent then
					bcDamage( ent , ent:WorldToLocal( pos ) , true )
					
					ent:TakeDamage( (data.Speed / 10) * simfphys.DamageMul, Entity(0), Entity(0) )
				end
			end
			
			if data.Speed > 600 then
				HurtPlayers( ent, data.Speed / 75 )
				ent:TakeDamage( (data.Speed / 2) * simfphys.DamageMul, Entity(0), Entity(0) )
			end
		end
	end
end

local function OnDamage( ent, dmginfo )
	ent:TakePhysicsDamage( dmginfo )
	
	if not ent:IsInitialized() then return end
	
	local Damage = dmginfo:GetDamage() 
	local DamagePos = dmginfo:GetDamagePosition() 
	local Attacker = dmginfo:GetAttacker()
	local Type = dmginfo:GetDamageType()
	local Driver = ent:GetDriver()
	bcDamage( ent , ent:WorldToLocal( DamagePos ) )
	
	local Mul = 1
	if Type == DMG_BLAST then
		Mul = 10
	end
	
	if Type == DMG_BULLET then
		Mul = 0.1
	end

	DamageVehicle( ent , Damage * Mul, Type, Attacker )
	
	if ent.IsArmored then return end
	
	if IsValid(Driver) then
		local Distance = (DamagePos - Driver:GetPos()):Length() 
		if (Distance < 70) then
			local Damage = (70 - Distance) / 22
			dmginfo:ScaleDamage( Damage )
			Driver:TakeDamageInfo( dmginfo )
			BloodEffect( DamagePos )
		end
	end
	
	if ent.PassengerSeats then
		for i = 1, table.Count( ent.PassengerSeats ) do
			local Passenger = ent.pSeat[i]:GetDriver()
			
			if IsValid(Passenger) then
				local Distance = (DamagePos - Passenger:GetPos()):Length()
				local Damage = (70 - Distance) / 22
				if (Distance < 70) then
					dmginfo:ScaleDamage( Damage )
					Passenger:TakeDamageInfo( dmginfo )
					BloodEffect( DamagePos )
				end
			end
		end
	end
end

/*local function OnLocked( ent, rocket )
	if !ent.LockedRockets then ent.LockedRockets = {} end
	ent.LockedRockets[rocket:EntIndex()] = ent

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

local function OnRocketDestroyed( ent, rocket )
	if !ent.LockedRockets then ent.LockedRockets = {} end
	ent.LockedRockets[rocket:EntIndex()] = nil

	if table.Count( ent.LockedRockets ) < 1 then
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
end*/

timer.Simple( 0.5, function()
	hook.Add( "OnEntityCreated", "simfphys_damagestuff", function( ent )
		if simfphys.IsCar( ent ) then
			timer.Simple( 0.2, function()
				if not IsValid( ent ) then return end
				
				local Health = math.floor(ent.MaxHealth and ent.MaxHealth or (1000 + ent:GetPhysicsObject():GetMass() / 3))
				
				ent:SetMaxHealth( Health )
				ent:SetCurHealth( Health )
				
				ent.PhysicsCollide = onCollide
				ent.OnTakeDamage = OnDamage
				--ent.OnLocked = OnLocked
				--ent.OnRocketDestroyed = OnRocketDestroyed
			end )
		end
	end )
end )
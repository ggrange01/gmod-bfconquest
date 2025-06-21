AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "IR Rocket"

ENT.Spawnable			= false
ENT.AdminSpawnable		= false

ENT.Speed = 20
--ENT.RotateSpeed = 2

function ENT:SetupDataTables()
	self:NetworkVar( "Entity", 0, "Target" )
end

function ENT:Initialize()
	self.DelTime = CurTime() + 20
	self.CreationTime = CurTime()

	self:SetModel( "models/missiles/fim_92.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	--self:SetColor( 255, 255, 255, 0 )

	if SERVER then
		self.Glow = ents.Create( "env_sprite" )
		self.Glow:SetPos( self:GetPos() - self:GetForward() * 35 )
		self.Glow:SetKeyValue( "renderfx", "0" )
		self.Glow:SetKeyValue( "rendermode", "5" )
		self.Glow:SetKeyValue( "renderamt", "255" )
		self.Glow:SetKeyValue( "rendercolor", "250 200 150" )
		self.Glow:SetKeyValue( "framerate12", "20" )
		self.Glow:SetKeyValue( "model", "light_glow03.spr" )
		self.Glow:SetKeyValue( "scale", "1" )
		self.Glow:SetKeyValue( "GlowProxySize", "10" )
		self.Glow:SetParent( self )
		self.Glow:Spawn()
		self.Glow:Activate()
	end

	if CLIENT then
		self.Emitter = ParticleEmitter( self:GetPos() )
	end
 end

function ENT:Think()
	if SERVER then
		if self.DelTime < CurTime() or !IsValid( self:GetTarget() ) then
			self:Explode( self:GetPos() + self:GetForward() * 30, -self:GetForward() )
		end

		local tr = util.TraceLine( {
			start = self:GetPos() + self:GetForward() * ( 30 - self.Speed ),
			endpos = self:GetPos() + self:GetForward() * 30,
			filter = { self, self.Owner }
		} )
		
		if tr.HitSky then
			if IsValid( self:GetTarget() ) then
				if self:GetTarget().OnRocketDestroyed then
					self:GetTarget():OnRocketDestroyed( self )
				end
			end
			self:Remove()
		end
		
		if tr.Hit then
			self:Explode( tr.HitPos, tr.HitNormal )
		end
	end
	
	if CLIENT then
		local vec = self:GetForward()
		local pos = self:GetPos() - vec * 35

		for i = 1, 5 do
			local particle = self.Emitter:Add( "particle/smokesprites_000"..math.random( 1, 9 ), pos - vec * 5 * ( i - 1 ) )
			if particle then
				particle:SetColor( 175, 175, 175 )
				particle:SetDieTime( math.random( 5, 7 ) )
				particle:SetStartAlpha( math.random( 50, 200 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.random( 10, 20 ) )
				particle:SetEndSize( math.random( 50, 75 ) )
				particle:SetRoll( math.random( 0, 180 ) )
				particle:SetRollDelta( math.random( -1, 1 ) / 5 )
				particle:SetVelocity( -vec * 75 )
				particle:SetGravity( Vector( 0, 0, -2.5 ) )
				particle:SetAirResistance( 25 )
			end
		end
	end

	if IsValid( self:GetTarget() ) then
		local target_pos = self:GetTarget():GetPos() + ( self:GetTarget().GetLockPos and self:GetTarget():GetLockPos() or Vector( 0, 0, 50 ) )
		local target_ang = ( target_pos - self:GetPos() ):GetNormalized():Angle()
		local ang = self:GetAngles()

		local tab = { "pitch", "yaw", "roll" }

		for k, v in pairs( tab ) do
			if ang[v] != target_ang[v] then
				local diff = target_ang[v] - ang[v]
				if diff > 0 then
					ang[v] = math.Clamp( ang[v] + diff, ang[v], target_ang[v] )
				else
					ang[v] = math.Clamp( ang[v] + diff, target_ang[v], ang[v] )
				end
			end
		end

		self:SetAngles( ang )
	end

	self:SetPos( self:GetPos() + self:GetForward() * self.Speed )

	self:NextThink( CurTime() )
	return true
end

function ENT:Explode( pos, normal )
	util.BlastDamage( self, self.Owner, pos, 500, 500 )

	local effectdata = EffectData()
	effectdata:SetOrigin( self:GetPos() )
	effectdata:SetNormal( normal )
	effectdata:SetEntity( self )
	effectdata:SetScale( 3 )
	effectdata:SetMagnitude( 16 )
	util.Effect( "bfc_explosion", effectdata, true, true )

	util.Decal( "Scorch", pos - normal, pos + normal )
	util.ScreenShake( pos, 10, 5, 1, 3000 )

	if IsValid( self:GetTarget() ) then
		if self:GetTarget().OnRocketDestroyed then
			self:GetTarget():OnRocketDestroyed( self )
		else
			OnRocketDestroyed( self:GetTarget(), self )
		end
	end

	if SERVER then
		self:Remove()
	end
end

function ENT:Draw()
	self:DrawModel()
end
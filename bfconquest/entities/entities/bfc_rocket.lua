AddCSLuaFile()

ENT.Type 			= "anim"  
ENT.Base 			= "base_anim"
ENT.PrintName		= "Rocket"
 
ENT.Spawnable			= false
ENT.AdminSpawnable		= false

ENT.Speed = 30

 function ENT:Draw()           
 	self:DrawModel()
 end
 
function ENT:Initialize()
	self.flight_vec = self:GetUp() * self.Speed
	self.deltime = CurTime() + 25

	self:SetModel( "models/led.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetColor( 255, 255, 255, 0 )

	if SERVER then
		self.SmokeTrail = ents.Create( "env_spritetrail" )
		self.SmokeTrail:SetKeyValue( "lifetime", "5" )
		self.SmokeTrail:SetKeyValue( "startwidth", "10" )
		self.SmokeTrail:SetKeyValue( "endwidth", "30" )
		self.SmokeTrail:SetKeyValue( "spritename", "trails/smoke.vmt" )
		self.SmokeTrail:SetKeyValue( "rendermode", "5" )
		self.SmokeTrail:SetKeyValue( "rendercolor", "200 200 200" )
		self.SmokeTrail:SetPos( self:GetPos() )
		self.SmokeTrail:SetParent( self )
		self.SmokeTrail:Spawn()
		self.SmokeTrail:Activate()

		self.Glow = ents.Create( "env_sprite" )
		self.Glow:SetPos( self:GetPos() )
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
		pos = self:GetPos()
		self.emitter = ParticleEmitter( pos )
	end
 end
 
function ENT:Think()	
	if SERVER and self.deltime < CurTime() then
		self:Remove()
	end

	local tr = util.TraceLine( {
		start = self:GetPos(),
		endpos = self:GetPos() + self.flight_vec,
		filter = { self, self.Owner }
	} )
	
	if SERVER and tr.HitSky then
		self:Remove()
	end
	
	if tr.Hit then
		util.BlastDamage( self, self.Owner, tr.HitPos, 600, 125 )

		local ent = tr.Entity
		if !IsValid( ent ) or ent:GetClass() != "gmod_sent_vehicle_fphysics_base" then
			local effectdata = EffectData()
			effectdata:SetOrigin( tr.HitPos )
			effectdata:SetNormal( tr.HitNormal )
			effectdata:SetEntity( self )
			effectdata:SetScale( 3 )
			effectdata:SetMagnitude( 16 )
			util.Effect( "bfc_explosion", effectdata )

			util.Decal( "Scorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal )
			util.ScreenShake( tr.HitPos, 10, 5, 1, 3500 )
		end

		if SERVER then
			self:Remove()
		end
	end
	
	if CLIENT then
		local pos = self:GetPos()
		local vec = self.flight_vec:GetNormalized()
		for i = 0, 5 do
			local particle = self.emitter:Add( "particle/smokesprites_000"..math.random( 1, 9 ), pos + vec * -50 * i )
			if particle then
				particle:SetDieTime( math.Rand( 4, 6 ) )
				particle:SetStartAlpha( math.Rand( 40, 60 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.Rand( 10, 30 ) )
				particle:SetEndSize( math.Rand( 150, 200 ) )
				particle:SetRoll( math.Rand( 0, 360 ) )
				particle:SetRollDelta( math.Rand( -1, 1 ) )
				particle:SetColor( 200, 200, 200 ) 
				particle:SetAirResistance( 100 ) 
				particle:SetGravity( Vector( 0, 0, 25 ) ) 	
			end

			for i = 0, 2 do
				local particle = self.emitter:Add( "effects/fire_cloud1", pos + vec * -75 * i )
				if particle then
					particle:SetVelocity( vec * -500 )
					particle:SetDieTime( 0.2 )
					particle:SetStartAlpha( 255 )
					particle:SetEndAlpha( 0 )
					particle:SetStartSize( 5 )
					particle:SetEndSize( 15 )
					particle:SetRoll( math.Rand( -5, 5 ) )
					particle:SetRollDelta( 0 )
					particle:SetAirResistance( 10 )
					particle:SetColor( 255, 255, 255 )
				end
			end
		end
	end

	self:SetPos( self:GetPos() + self.flight_vec )
	self.flight_vec = self.flight_vec - Vector( math.random( -8, 8 ) * 0.001, math.random( -8, 8 ) * 0.001, 0.006 )

	self:NextThink( CurTime() )
	return true
end
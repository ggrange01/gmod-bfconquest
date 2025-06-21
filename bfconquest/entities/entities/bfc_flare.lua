AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "Flares"

ENT.Spawnable			= false
ENT.AdminSpawnable		= false

ENT.Speed = 75
ENT.LifeTime = 5

function ENT:Initialize()
	self.DelTime = CurTime() + self.LifeTime
	self.CreationTime = CurTime()

	self:SetModel( "models/led.mdl" )
	self:PhysicsInit( SOLID_NONE )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )
	self:SetColor( 255, 255, 255, 0 )

	print( "init" )

	if CLIENT then
		local pos = self:GetPos()
		local dir = self:GetDirection()

		self.Emitter = ParticleEmitter( pos )

		for i = 1, 30 do
			local particle = self.Emitter:Add( "particle/particle_glow_0"..math.random( 2, 5 ), pos )
			if particle then
				particle:SetColor( math.random( 235, 255 ), math.random( 210, 230 ), math.random( 0, 20 ) )
				particle:SetDieTime( math.random( self.LifeTime, self.LifeTime + 3 ) )
				particle:SetStartAlpha( math.random( 100, 150 ) )
				particle:SetEndAlpha( 30 )
				particle:SetStartSize( math.random( 5, 7 ) )
				particle:SetEndSize( math.random( 0, 1 ) )
				particle:SetVelocity( dir * self.Speed * math.random( 75, 150 ) / 100 + VectorRand() * math.random( 20, 50 ) )
				particle:SetGravity( Vector( 0, 0, -15 ) )
			end
		end
	end
 end

ENT.nscan = 0
function ENT:Think()
	if SERVER then
		if self.DelTime < CurTime() then
			self:Remove()
		end

		if self.nscan > CurTime() then return end
		self.nscan = CurTime() + 0.25

		local fents = ents.FindInSphere( self:GetPos(), 300 )
		for k, v in pairs( fents ) do
			if v:GetClass() == "bfc_ir_rocket" then
				v:Explode( v:GetPos() + v:GetForward() * 30, -v:GetForward() )
			end
		end
	end
end

function ENT:SetDirection( vec )
	self:SetAngles( vec:GetNormalized():Angle() )
end

function ENT:GetDirection()
	return self:GetForward()
end

function ENT:SetLifeTime( time )
	self.LifeTime = time
end

function ENT:Draw()
	
end
AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.Author = "danx91"

ENT.HP = 50
ENT.LastHeal = 0

function ENT:SetupDataTables()
	self:NetworkVar( "Entity", 0, "NOwner" )
end

function ENT:Initialize()
	self:SetModel( "models/danx91/medkit/medkit.mdl" )

	if SERVER then
		self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
		self:CollisionRulesChanged()

		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )

		self:PhysicsInit( SOLID_VPHYSICS )
		self:GetPhysicsObject():Wake()
	end

	if IsValid( self:GetNOwner() ) then
		self:SetPhysVelocity( Angle( 0, self:GetNOwner():GetAngles().yaw, 0 ):Forward() * 150 )
	end
end

function ENT:Think()
	if self.LastHeal > CurTime() then return end
	self.LastHeal = CurTime() + 0.3
	local team = self:GetNOwner().GetBFCTeam and self:GetNOwner():GetBFCTeam()
	if CLIENT then return end
	local fent = ents.FindInSphere( self:GetPos(), 150 )
	for k, v in pairs( fent ) do
		if v.GetBFCTeam and v:GetBFCTeam() == team and v:Health() < v:GetMaxHealth() then
			local nhealth = v:Health() + 1
			nhealth = math.Clamp( nhealth, 0, v:GetMaxHealth() )
			v:SetHealth( nhealth )
		end
	end
end

function ENT:OnTakeDamage( dmg )
	self.HP = self.HP - dmg:GetDamage()
	if self.HP <= 0 then
		local attacker = dmg:GetAttacker()
		if attacker:GetBFCTeam() != self:GetNOwner():GetBFCTeam() then
			attacker:AddScoreMsg( 25, "destroy" )
		end
		self:Remove()
	end
end

function ENT:SetPhysVelocity( vel )
	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		phys:SetVelocity( vel )
	end
end

function ENT:SetEntityOwner( ply )
	self:SetNOwner( ply )
end

function ENT:GetEntityOwner()
	return self:GetNOwner()
end
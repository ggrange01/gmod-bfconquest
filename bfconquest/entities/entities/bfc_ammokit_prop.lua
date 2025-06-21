AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.Author = "danx91"

ENT.HP = 50
ENT.LastAmmo = 0

function ENT:SetupDataTables()
	self:NetworkVar( "Entity", 0, "NOwner" )
end

function ENT:Initialize()
	self:SetModel( "models/Items/BoxMRounds.mdl" )

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
	if self.LastAmmo > CurTime() then return end
	self.LastAmmo = CurTime() + 0.5
	if CLIENT then return end
	local team = self:GetNOwner().GetBFCTeam and self:GetNOwner():GetBFCTeam()
	local fent = ents.FindInSphere( self:GetPos(), 100 )
	for k, v in pairs( fent ) do
		if IsValid( v )and v:IsPlayer() and v.GetBFCTeam and v:GetBFCTeam() == team then
			local actwep = v:GetActiveWeapon()
			if IsValid( actwep ) then
				local _, wep = TranslateWeapon( WEAPONS, actwep:GetClass() )
				if wep then
					if actwep.AmmokitCallback then
						actwep:AmmokitCallback( wep )
					else
						local ammomax = wep[4]
						local atype = actwep:GetPrimaryAmmoType()
						if atype then
							local cammo = v:GetAmmoCount( atype ) + 1
							cammo = math.Clamp( cammo, 0, ammomax )
							v:SetAmmo( cammo, atype )
						end
					end
				end
			end
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
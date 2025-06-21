AddCSLuaFile()

SWEP.Base = "weapon_base"

SWEP.Spawnable = false
SWEP.AdminOnly = false
SWEP.Category = "BFC Knife"
SWEP.BounceWeaponIcon = false
SWEP.DrawWeaponInfoBox = false

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID( "danx91/entities/huntstk" )
end

SWEP.PrintName = "Knife"
SWEP.Author = "danx91, model by Cloot"

SWEP.ViewModel = "models/weapons/v_huntpln.mdl"
SWEP.WorldModel = "models/weapons/w_huntpln.mdl"
SWEP.ShowWorldModel = true

SWEP.Primary.Ammo = ""
SWEP.Primary.ClipSize = 0
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false

SWEP.Secondary.Ammo = ""
SWEP.Secondary.ClipSize = 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false

SWEP.HoldType = "knife"

SWEP.Slash = "Weapon_Knife.Slash"
SWEP.Shink = "Weapon_Knife.HitWall"
SWEP.Hit = "Weapon_Knife.Hit"

--function SWEP:Initialize()
--end
SWEP.NextIdle = 0
function SWEP:Think()
	if self.NextIdle > CurTime() then return end
	self.NextIdle = CurTime() + self:SequenceDuration( ACT_VM_IDLE ) * 5
	self:SendWeaponAnim( ACT_VM_IDLE )
end

function SWEP:Deploy()
	self:SetHoldType( self.HoldType )
	self.NextIdle = CurTime() + self:SequenceDuration( ACT_VM_DRAW ) * 15
	self:SendWeaponAnim( ACT_VM_DRAW )
	self:EmitSound("weapons/knife/knife_deploy1.wav", 50, 100)
	self.NextPrimary = CurTime() + 0.5
	return true
end

SWEP.NextPrimary = 0
function SWEP:PrimaryAttack()
	if self.NextPrimary > CurTime() then return end
	self.NextPrimary = CurTime() + 1.5
	self:SendWeaponAnim( ACT_VM_MISSCENTER )
	self.NextIdle = CurTime() + self:SequenceDuration( ACT_VM_MISSCENTER ) * 10
	--local vm = self.Owner:GetViewModel()
	--vm:SetSequence( vm:LookupSequence( "stab" ) )
	self:EmitSound( self.Slash )

	self.Owner:LagCompensation( true )

	local pos = self.Owner:GetShootPos()
	local aim = self.Owner:GetAimVector()
	local dmg = 150
	local dist = 35

	local damage = DamageInfo()
	damage:SetDamage( dmg )
	damage:SetDamageType( DMG_SLASH )
	damage:SetAttacker( self.Owner )
	damage:SetInflictor( self )
	damage:SetDamageForce( aim * 300 )

	local tr = util.TraceHull( {
		start = pos,
		endpos = pos + aim * dist,
		filter = self.Owner,
		mask = MASK_SHOT_HULL,
		mins = Vector( -10, -5, -5 ),
		maxs = Vector( 10, 5, 5 )
	} )
	if tr.Hit then
		local ent = tr.Entity
		if ent:IsPlayer() then
			self:EmitSound( self.Hit )
			if SERVER then
				ent.RagVelocity = damage:GetDamageForce()
				ent:TakeDamageInfo( damage )
			end
		elseif ent:GetClass() != "worldspawn" then
			if SERVER then
				ent:TakeDamageInfo( damage )
			end
		else
			local look = self.Owner:GetEyeTrace()
			self:EmitSound( self.Shink )
			util.Decal("ManhackCut", look.HitPos + look.HitNormal, look.HitPos - look.HitNormal )
		end
	end

	self.Owner:LagCompensation( false )

	self.Owner:SetAnimation( PLAYER_ATTACK1 )
end

function SWEP:SecondaryAttack()
	--
	--self:SendWeaponAnim( ACT_VM_MISSCENTER )
	--local vm = self.Owner:GetViewModel()
	--vm:SetSequence( vm:LookupSequence( "stab" ) )
end
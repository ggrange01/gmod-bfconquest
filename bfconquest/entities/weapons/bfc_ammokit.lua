AddCSLuaFile()

SWEP.Base = "weapon_base"

SWEP.Spawnable = false
SWEP.AdminOnly = false
SWEP.Category = "BFC Special Items"
SWEP.BounceWeaponIcon = false
SWEP.DrawWeaponInfoBox = false

SWEP.PrintName = "AmmoKit"
SWEP.Author = "danx91"

SWEP.WorldModel = ""
SWEP.ViewModel = ""

SWEP.Primary.Ammo = ""
SWEP.Primary.ClipSize = 0
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false

SWEP.Secondary.Ammo = ""
SWEP.Secondary.ClipSize = 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false

function SWEP:Initialize()
	--self.Owner:DrawWorldModel( false )
	--self.Owner:DrawViewModel( false )
end

SWEP.LastDeploy = 0
SWEP.ActiveAmmokit = nil
function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then return end
	if self.LastDeploy > CurTime() then return end
	self.LastDeploy = CurTime() + 30
	if SERVER then
		if IsValid( self.ActiveAmmokit ) then
			self.ActiveAmmokit:Remove()
			self.ActiveAmmokit = nil
		else
			self.ActiveAmmokit = nil
		end
		local ammokit = ents.Create( "bfc_ammokit_prop" )
		if IsValid( ammokit ) then
			ammokit:SetPos( self.Owner:GetPos() + Angle( 0, self.Owner:GetAngles().yaw, 0 ):Forward() * 30 + Vector( 0, 0, 45 ) )
			ammokit:SetEntityOwner( self.Owner )
			ammokit:Spawn()
			ammokit:Activate()
			self.ActiveAmmokit = ammokit
		end
	end
end

function SWEP:SecondaryAttack()
	--
end

function SWEP:DrawWorldModel() 
	--
end

function SWEP:OnRemove()
	if IsValid( self.ActiveAmmokit ) then
		self.ActiveAmmokit:Remove()
		self.ActiveAmmokit = nil
	end
end
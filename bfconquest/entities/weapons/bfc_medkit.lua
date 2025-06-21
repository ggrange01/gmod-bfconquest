AddCSLuaFile()

SWEP.Base = "weapon_base"

SWEP.Spawnable = false
SWEP.AdminOnly = false
SWEP.Category = "BFC Special Items"
SWEP.BounceWeaponIcon = false
SWEP.DrawWeaponInfoBox = false

SWEP.PrintName = "MedKit"
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
SWEP.ActiveMedkit = nil
function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then return end
	if self.LastDeploy > CurTime() then return end
	self.LastDeploy = CurTime() + 30
	if SERVER then
		if IsValid( self.ActiveMedkit ) then
			self.ActiveMedkit:Remove()
			self.ActiveMedkit = nil
		else
			self.ActiveMedkit = nil
		end
		local medkit = ents.Create( "bfc_medkit_prop" )
		if IsValid( medkit ) then
			medkit:SetPos( self.Owner:GetPos() + Angle( 0, self.Owner:GetAngles().yaw, 0 ):Forward() * 50 + Vector( 0, 0, 50 ) )
			medkit:SetAngles( Angle( 0, self.Owner:EyeAngles().y + 90, 0 ) )
			medkit:SetEntityOwner( self.Owner )
			medkit:Spawn()
			medkit:Activate()
			self.ActiveMedkit = medkit
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
	if IsValid( self.ActiveMedkit ) then
		self.ActiveMedkit:Remove()
		self.ActiveMedkit = nil
	end
end
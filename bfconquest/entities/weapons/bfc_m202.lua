SWEP.Category				= "BFC Special Items"
SWEP.Author					= "Raven, edited by danx91"
SWEP.PrintName				= "M202"
SWEP.DrawAmmo				= true
SWEP.DrawWeaponInfoBox		= false
SWEP.BounceWeaponIcon   	= false
SWEP.DrawCrosshair			= true
SWEP.HoldType 				= "rpg"

SWEP.ViewModelFOV			= 70
SWEP.ViewModelFlip			= false
SWEP.ViewModel				= "models/weapons/M202/v_grimreaper.mdl"
SWEP.WorldModel				= "models/weapons/M202/w_grimreaper.mdl"
SWEP.Spawnable				= false
SWEP.AdminSpawnable			= false
SWEP.FiresUnderwater 		= false

SWEP.Primary.Damage			= 100
SWEP.Primary.Spread			= 0.025
SWEP.Primary.SpreadSight	= 0.015

SWEP.Primary.Sound			= Sound( "weapons/m202_shot.wav" )
SWEP.Primary.RPM			= 30
SWEP.Primary.ClipSize		= 4
SWEP.Primary.DefaultClip	= 4
SWEP.Primary.KickUp			= 0.3
SWEP.Primary.KickDown		= 0.3
SWEP.Primary.KickHorizontal	= 0.3
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "bfc_rocket"

SWEP.Secondary.IronFOV		= 55

SWEP.IronSightsPos = Vector( -4.361, 0, -2.8 )
SWEP.IronSightsAng = Vector( 0, 0, 0 )

SWEP.WorldModelPositionOffset = Vector( 17, -2, -4 )
SWEP.WorldModelAngleOffset = Angle( 7, 0, 180 )

SWEP.BoneAttachment = "ValveBiped.Bip01_R_Hand"

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID( "danx91/entities/m202.vmt" )
end

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
	self.OrigCrossHair = self.DrawCrosshair

	if CLIENT then
		self.WM = ClientsideModel( self.WorldModel, RENDERGROUP_OPAQUE )
		self.WM:SetNoDraw( true )
	end
end

SWEP.DeployTime = 0
SWEP.PlayerSpeed = { 200, 320 }
function SWEP:Deploy()
	self:SetHoldType( self.HoldType )

	--self:SendWeaponAnim( ACT_VM_DRAW )
	local vm = self.Owner:GetViewModel()
	if IsValid( vm ) then
		vm:SetPlaybackRate( 0.5 )
	end

	local duration = self.Owner:GetViewModel():SequenceDuration() / 0.5
	timer.Simple( duration, function()
		if IsValid( vm ) then
			vm:SetPlaybackRate( 1 )
		end
	end )

	self.DeployTime = CurTime() + duration + 0.5
	self:SetNextPrimaryFire( CurTime() + duration + 0.5 )
	self:SetNextSecondaryFire( CurTime() + duration + 0.5 )

	self.Weapon:SetNWBool( "Reloading", false )
	   
	self.ResetSights = CurTime() + duration

	if SERVER then
		self.PlayerSpeed = { self.Owner:GetWalkSpeed(), self.Owner:GetRunSpeed() }
		self.Owner:SetWalkSpeed( 75 )
		self.Owner:SetRunSpeed( 75 )
	end

	return true
end

function SWEP:Equip()
	self:SetHoldType( self.HoldType )
end
 
function SWEP:Holster()
	if SERVER then
		self.Owner:SetWalkSpeed( self.PlayerSpeed[1] )
		self.Owner:SetRunSpeed( self.PlayerSpeed[2] )
	end
	return true
end

function SWEP:OnRemove()
	if IsValid( self.WM ) then
		self.WM:Remove()
	end
end

function SWEP:Think()
	self:IronSight()
end

function SWEP:PrimaryAttack()
	if !IsValid( self ) then return end
	if !IsValid( self.Owner ) then return end

	if self:CanPrimaryAttack() then
		if !self.Owner:KeyDown( IN_RELOAD ) then
			self:FireRocket()
			self:TakePrimaryAmmo( 1 )
			self:EmitSound( self.Primary.Sound )
			self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
			self.Owner:SetAnimation( PLAYER_ATTACK1 )
			self.Owner:MuzzleFlash()
			self:SetNextPrimaryFire( CurTime() + 1 / ( self.Primary.RPM / 60 ) )
		end
	end
end

function SWEP:SecondaryAttack()
	return false
end

function SWEP:FireRocket()
	local aim = self.Owner:GetAimVector()
	local pos = self.Owner:GetShootPos()

	if SERVER then
		local rocket = ents.Create( "bfc_rocket" )
		if IsValid( rocket ) then
			rocket:SetAngles( aim:Angle() + Angle( 90, 0, 0 ) )
			rocket:SetPos( pos )
			rocket:SetOwner( self.Owner )
			rocket:Spawn()
			rocket:Activate()
			util.ScreenShake( pos, 1000, 5, 0.5, 500 )
		end
	end
end

function SWEP:Reload()
	if not IsValid( self ) then return end
	if not IsValid( self.Owner ) then return end   
	if self.Owner:KeyDown( IN_USE ) then return end
	if self.DeployTime > CurTime() then return end

	self:DefaultReload( ACT_VM_RELOAD )

   	local wait = self.Owner:GetViewModel():SequenceDuration()
	self.ResetSights = CurTime() + wait
   
	if SERVER then
		if self:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) > 0 then
			self.Owner:SetFOV( 0, 0.3 )
			self:SetIronsights( false )
			self:SetNWBool( "Reloading", true )
			timer.Simple(wait + .1, function()
				if !IsValid( self ) or !IsValid( self.Owner ) then return end
				self:SetNWBool( "Reloading", false )
			end)
		end
	end
end

function SWEP:IronSight()
	if not IsValid( self ) then return end
	if not IsValid( self.Owner ) then return end

	if self.ResetSights and CurTime() >= self.ResetSights then
		self.ResetSights = nil
		self:SendWeaponAnim( ACT_VM_IDLE )
	end

	if self.Owner:KeyPressed( IN_SPEED ) then
		self:SetIronsights( false )
		self.Owner:SetFOV( 0, 0.3 )
		self.DrawCrosshair = false
	elseif self.Owner:KeyReleased( IN_SPEED ) then
		self:SetIronsights( false )
		self.Owner:SetFOV( 0, 0.3 )
		self.DrawCrosshair = self.OrigCrossHair
	end
 
	if !self.Owner:KeyDown( IN_USE ) and !self.Owner:KeyDown( IN_SPEED ) then
		if self.Owner:KeyPressed(IN_ATTACK2) and !self:GetNWBool( "Reloading" ) then
			self.Owner:SetFOV( self.Secondary.IronFOV, 0.3 )
			self.DrawCrosshair = false
			self:SetIronsights( true )
		elseif self.Owner:KeyReleased(IN_ATTACK2) then
			self.Owner:SetFOV( 0, 0.3 )
			self.DrawCrosshair = self.OrigCrossHair
			self:SetIronsights( false )
		end
	end
end

local IRONSIGHT_TIME = 0.3
function SWEP:GetViewModelPosition(pos, ang)
		if !self.IronSightsPos then
			return pos, ang
		end
 
		local bIron = self:GetNWBool( "Ironsights" )
 
		if bIron != self.bLastIron then
			self.bLastIron = bIron
			self.fIronTime = CurTime()
		end
 
		local fIronTime = self.fIronTime or 0
 
		if !bIron and fIronTime < CurTime() - IRONSIGHT_TIME then
			return pos, ang
		end
 
		local Mul = 1.0
 
		if fIronTime > CurTime() - IRONSIGHT_TIME then
			Mul = math.Clamp( ( CurTime() - fIronTime ) / IRONSIGHT_TIME, 0, 1 )
			if !bIron then
				Mul = 1 - Mul
			end
		end
 
		if self.IronSightsAng then
			ang = ang * 1
			ang:RotateAroundAxis( ang:Right(), self.IronSightsAng.x * Mul )
			ang:RotateAroundAxis( ang:Up(), self.IronSightsAng.y * Mul )
			ang:RotateAroundAxis( ang:Forward(), self.IronSightsAng.z * Mul )
		end
 
		local Right = ang:Right()
		local Up = ang:Up()
		local Forward = ang:Forward()

		local Offset = self.IronSightsPos

		pos = pos + Offset.x * Right * Mul
		pos = pos + Offset.y * Forward * Mul
		pos = pos + Offset.z * Up * Mul
 
		return pos, ang
end

function SWEP:DrawWorldModel()
	if IsValid( self.Owner ) then
		if !IsValid( self.WM ) then
			self.WM = ClientsideModel( self.WorldModel, RENDERGROUP_OPAQUE )
			self.WM:SetNoDraw( true )
			print( "creating" )
		end

		/*for i=0, self.Owner:GetBoneCount()-1 do
			print( i, self.Owner:GetBoneName( i ) )
		end*/

		local boneid = self.Owner:LookupBone( self.BoneAttachment )
		if not boneid then
			return
		end

		local matrix = self.Owner:GetBoneMatrix( boneid )
		if not matrix then
			return
		end

		local newpos, newang = LocalToWorld( self.WorldModelPositionOffset, self.WorldModelAngleOffset, matrix:GetTranslation(), matrix:GetAngles() )

		self.WM:SetPos( newpos )
		self.WM:SetAngles( newang )
		self.WM:SetupBones()
		self.WM:DrawModel()
	else
		self:DrawModel()
	end
end

function SWEP:AmmokitCallback( wep )
	if !self.NRefill then
		self.NRefill = CurTime() + 10
	end
	if self.NRefill < CurTime() then
		self.NRefill = CurTime() + 30
		local ammomax = wep[4]
		local atype = self:GetPrimaryAmmoType()
		if atype then
			local cammo = self.Owner:GetAmmoCount( atype ) + 1
			cammo = math.Clamp( cammo, 0, ammomax )
			self.Owner:SetAmmo( cammo, atype )
		end
	end
end

function SWEP:SetIronsights(b)
	self:SetNWBool( "Ironsights", b )
end
 
function SWEP:GetIronsights()
	return self:GetNWBool( "Ironsights" )
end
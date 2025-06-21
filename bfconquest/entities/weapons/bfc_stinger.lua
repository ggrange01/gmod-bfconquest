SWEP.Category				= "BFC Special Items"
SWEP.Author					= "danx91"
SWEP.PrintName				= "FIM-92 Stinger"
SWEP.DrawAmmo				= true
SWEP.DrawWeaponInfoBox		= false
SWEP.BounceWeaponIcon   	= false
SWEP.DrawCrosshair			= false
SWEP.HoldType 				= "rpg"

SWEP.ViewModelFOV			= 80
SWEP.ViewModelFlip			= false
SWEP.ViewModel				= "models/jessev92/weapons/hl2/hevmk4/stinger_v.mdl"
SWEP.WorldModel				= "models/jessev92/weapons/hl2/stinger_w.mdl"
SWEP.Spawnable				= false
SWEP.AdminSpawnable			= false
SWEP.FiresUnderwater 		= false

SWEP.Primary.Damage			= 100
SWEP.Primary.Spread			= 0.025
SWEP.Primary.SpreadSight	= 0.015

SWEP.Primary.Sound			= Sound( "stinger/ignite.wav" )
SWEP.Primary.RPM			= 10
SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.KickUp			= 0.3
SWEP.Primary.KickDown		= 0.3
SWEP.Primary.KickHorizontal	= 0.3
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "bfc_fim92"

SWEP.LockTime				= 2.5
SWEP.Beep 					= Sound( "stinger/check.wav" )

SWEP.Secondary.IronFOV		= 40

SWEP.IronSightsPos = Vector( -0.17, -6, -1.36 )
SWEP.IronSightsAng = Vector( -13.2, -7.5, 53.7 )

SWEP.HoldPos = Vector( -2, 2.5, 1 )
SWEP.HoldAng = Angle( -30, -25, 40 )

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID( "hud/swepicons/weapon_mw2_stinger" )
end

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
	self.OrigCrossHair = self.DrawCrosshair

	if CLIENT then
		sound.Add( {
			name = "bfc_stinger_locked",
			channel = CHAN_WEAPON,
			volume = 1.0,
			level = 80,
			pitch = 100,
			sound = "stinger/locked3.wav"
		} )
	end
end

SWEP.DeployTime = 0
function SWEP:Deploy()
	self:SetHoldType( self.HoldType )

	local duration = self.Owner:GetViewModel():SequenceDuration()
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

	return true
end

function SWEP:Equip()
	self:SetHoldType( self.HoldType )
end
 
function SWEP:Holster()
	return true
end

function SWEP:OnRemove()
end

--SWEP.LockedTarget = false
SWEP.NSound = 0
SWEP.NUse = 0

function SWEP:Think()
	self:IronSight()

	if self.Target and self.Target[3] and self.Target[3] < CurTime() then
		self.LockedTarget = nil
		self.Target = nil
		self:StopSound( "bfc_stinger_locked" )
		self.NSound = 0
	end

	if self.NUse > CurTime() then return end

	if IsValid( self.Owner ) and self:GetIronsights() and !self:GetNWBool( "Reloading" ) then
		local ent = self.Owner:GetEyeTrace().Entity
		if !ent:IsVehicle() and !ent.BFCVehicle and !ent:GetNWBool( "BFCVehicle", false ) then return end
		--if !ent.bfc_id then return end

		if !self.Target then
			self.Target = { ent, CurTime() + self.LockTime, CurTime() + 0.3 }
			return
		end

		if ent != self.Target[1] then return end

		if CLIENT and self.NSound != -1 and self.NSound < CurTime() then
			if self.LockedTarget then
				self:EmitSound( "bfc_stinger_locked" )
				self.NSound = -1
			else
				self:EmitSound( self.Beep )
				self.NSound = CurTime() + 0.5
			end
		end

		self.Target[3] = CurTime() + 0.2

		if !self.LockedTarget and self.Target[2] < CurTime() then
			self.LockedTarget = ent
		end

	end
end

function SWEP:PrimaryAttack()
	if !IsValid( self ) then return end
	if !IsValid( self.Owner ) then return end
	if !self.LockedTarget then return end
	self.NUse = CurTime() + 1 / ( self.Primary.RPM / 60 )

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

	if SERVER and self.LockedTarget then
		local rocket = ents.Create( "bfc_ir_rocket" )
		if IsValid( rocket ) then
			rocket:SetAngles( aim:Angle() )
			rocket:SetPos( pos )
			rocket:SetOwner( self.Owner )
			rocket:SetTarget( self.LockedTarget )
			rocket:Spawn()
			rocket:Activate()
			util.ScreenShake( pos, 1000, 5, 0.5, 500 )
			if self.LockedTarget.OnLocked then
				self.LockedTarget:OnLocked( rocket )
			else
				OnVehicleLocked( self.LockedTarget, rocket )
			end
		end
	end
end

function SWEP:Reload()
	if not IsValid( self ) then return end
	if not IsValid( self.Owner ) then return end   
	if self.Owner:KeyDown( IN_USE ) then return end
	if self.DeployTime > CurTime() then return end

	self:DefaultReload( ACT_VM_RELOAD )

   	local wait = self.Owner:GetViewModel():SequenceDuration() + 3
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

	if self:GetIronsights() and ( !self:CanAim() or self:Clip1() < 1 ) then
		self:SetIronsights( false )
		self.Owner:SetFOV( 0, 0.3 )
		self.DrawCrosshair = self.OrigCrossHair
	end

	if !self.Owner:KeyDown( IN_USE ) and !self.Owner:KeyDown( IN_SPEED ) and self:CanAim() then
		if self.Owner:KeyPressed( IN_ATTACK2 ) and !self:GetNWBool( "Reloading" ) and self:Clip1() > 0 then
			self.Owner:SetFOV( self.Secondary.IronFOV, 0.3 )
			self.DrawCrosshair = false
			self:SetIronsights( true )
		elseif self.Owner:KeyReleased( IN_ATTACK2 ) and self:GetIronsights() then
			self.Owner:SetFOV( 0, 0.3 )
			self.DrawCrosshair = self.OrigCrossHair
			self:SetIronsights( false )
		end
	end
end

local IRONSIGHT_TIME = 0.3
function SWEP:GetViewModelPosition( pos, ang )
		local orig_ang = Angle( ang.pith, ang.yaw, ang.roll )
		if self.HoldPos then
			pos = pos + ang:Right() * self.HoldPos.x
			pos = pos + ang:Up() * self.HoldPos.y
			pos = pos + ang:Forward() * self.HoldPos.z
		end

		if self.HoldAng then
			ang:RotateAroundAxis( ang:Right(), self.HoldAng.x )
			ang:RotateAroundAxis( ang:Up(), self.HoldAng.y )
			ang:RotateAroundAxis( ang:Forward(), self.HoldAng.z )
		end

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
			ang:RotateAroundAxis( ang:Forward(), ( self.IronSightsAng.z - self.HoldAng.z ) * Mul )
			ang:RotateAroundAxis( ang:Up(), ( self.IronSightsAng.y - self.HoldAng.y ) * Mul )
			ang:RotateAroundAxis( ang:Right(), ( self.IronSightsAng.x - self.HoldAng.x ) * Mul )
		end

		local Right = orig_ang:Right()
		local Up = orig_ang:Up()
		local Forward = orig_ang:Forward()

		local Offset = self.IronSightsPos

		pos = pos + Offset.x * Right * Mul
		pos = pos + Offset.y * Forward * Mul
		pos = pos + Offset.z * Up * Mul
 
		return pos, ang
end

function SWEP:CanAim()
	if !IsValid( self.Owner ) then return end
	return !self.Owner:KeyDown( IN_FORWARD ) and !self.Owner:KeyDown( IN_BACK ) and !self.Owner:KeyDown( IN_MOVELEFT ) and !self.Owner:KeyDown( IN_MOVERIGHT )
end

function SWEP:DrawWorldModel()
	self:DrawModel()
end

function SWEP:AmmokitCallback( wep )
end

function SWEP:SetIronsights( b )
	self:SetNWBool( "Ironsights", b )
end
 
function SWEP:GetIronsights()
	return self:GetNWBool( "Ironsights" )
end
--server vars for player

local player = FindMetaTable( "Player" )

function player:CreateRagdoll( timetoremove )
	local rag = ents.Create( "prop_ragdoll" )
	
	local vel = self:GetVelocity()
	if self.RagVelocity then
		vel = self.RagVelocity
		self.RagVelocity = nil
	end

	rag:SetPos( self:GetPos() )
	rag:SetAngles( self:GetAngles() )
	rag:SetModel( self:GetModel() )
	rag:SetColor( self:GetColor() )
	rag:SetVelocity( vel )
	
	rag:Spawn()
	--rag:Activate()
	
	rag:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
	timer.Simple( 1, function()
		--rag:CollisionRulesChanged()
	end )
	rag:CollisionRulesChanged()
	
	timer.Simple( timetoremove, function()
		if IsValid( rag ) then
			rag:Remove()
		end
	end )
	
	local velocity = vel * 0.8
	local bones = rag:GetPhysicsObjectCount()
	for i = 0, bones do
		local physbone = rag:GetPhysicsObjectNum( i )
		if IsValid( physbone ) then
			bonepos, boneang = self:GetBonePosition( rag:TranslatePhysBoneToBone( i ) )
			if bonepos and boneang then
				physbone:SetPos( bonepos )
				physbone:SetAngles( boneang )
			end
			physbone:SetVelocity( velocity )
		end
	end
	
end

function player:SetSpectator()
	self:SetNoDraw( true )
	self:SetNoTarget( true )
	--self:StripWeapons()
	--self:RemoveAllAmmo()
	self:RemoveAllItems()
	self:Flashlight( false )
	self:AllowFlashlight( false )
	self:Freeze( true )
end

function player:SpawnAsSpectator( ply )
	self:Spawn()
	self:SetSpectator()
	if ply and IsValid( ply ) and ply:IsPlayer() and ply:Alive() then
		self:Spectate( OBS_MODE_CHASE  )
		self:SpectateEntity( ply )
		timer.Simple( 7, function()
				if IsValid( self ) then
					self:UnSpectate()
				end
		end )
	end
end

function player:SpawnData( data )
	local point = data.POINT
	local primary, secondary = data.PRIM, data.SEC
	local grenade, special = data.NADE, data.SPEC
	self:AllowFlashlight( true )
	self:SetNoDraw( false )
	self:SetNoTarget( false )
	self:RemoveAllItems()
	self:Spawn()
	self.IsDead = false
	self.Weapons = 0
	local togive = { primary, secondary, grenade, special, "bfc_knife" }
	for i, v in ipairs( togive ) do
		if v[2] != "none" then
			self.Weapons = self.Weapons + 1
			local wep = weapons.GetStored( v[2] )
			if wep then
				self:Give( wep.ClassName )
				self:GiveAmmo( v[4], wep.Primary.Ammo, true )
			end
		end
	end
	self:Give( "bfc_knife" )
	local pos = GetMapPointPosition( point, self:GetBFCTeam() )
	if pos then
		self:SetPos( pos )
	end
	self:Freeze( false )
end

function player:AddLevel( ammount )
	local levels = self:GetLevel() + ammount
	self:AddMsg( "lvlup", self:GetLevel().." ⇒ "..levels )
	self:SetBFCLevel( levels )
end

function player:AddExp( ammount )
	local cexp = self:GetExp() + ammount
	self:SetBFCExp( cexp )
	self:RecalculateLevel()
end

function player:AddScore( ammount )
	local score = self:GetScore() + ammount
	self:SetBFCScore( score )
	self:RecalculateLevel()
end

function player:RecalculateLevel()
	prevlevel = 0
	for pplvl = 1, self:GetLevel() - 1 do
		if pplvl > 20 then
			prevlevel = prevlevel + LEVELS[20] + LEVELS.over20 * ( pplvl - 20 )
		else
			prevlevel = prevlevel + LEVELS[ pplvl ]
		end
	end
	prevlevel = prevlevel or 0
	if prevlevel < 0 then prevlevel = 0 end
	local nexp = GetTrueExp( self ) - prevlevel
	--print( "Player "..self:GetName().." nexp is "..nexp )
	repeat
		local nextexp = 0
		if self:GetLevel() > 20 then
			nextexp = LEVELS[20] + LEVELS.over20 * ( self:GetLevel() - 20 )
		else
			nextexp = LEVELS[self:GetLevel()]
		end
		if nextexp <= nexp then
			nexp = nexp - nextexp
			self:AddLevel( 1 )
		end
	until nextexp > nexp
end

function player:AddScoreMsg( ammount, msg )
	self:AddScore( ammount )
	self:AddMsg( msg, ammount )
end

function player:AddMsg( msg, points )
	net.Start( "AddPoints" )
		net.WriteString( msg )
		net.WriteString( points )
	net.Send( self )
end

function player:PushScoreToExp()
	local nexp = self:GetExp() + self:GetScore()
	self:SetBFCScore( 0 )
	self:SetBFCExp( nexp )
	self:RecalculateLevel()
end

function player:SaveData()
	self:PushScoreToExp()
	self:SetPData( "bfc_level", self:GetLevel() ) 
	self:SetPData( "bfc_exp", self:GetExp() )
end
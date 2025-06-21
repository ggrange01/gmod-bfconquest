--player shared hooks and vars

local player = FindMetaTable( "Player" )

--function GM:PlayerConnect( name, ip )
	--
--end

function GM:PlayerButtonDown( ply, button )
	--
end

function GM:PlayerButtonUp( ply, button )
	--
end

function GM:KeyPress( ply, key )
	--
end

function GM:KeyRelease( ply, key )
	--
end

function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )
	local attacker = dmginfo:GetAttacker()
	if GetConVar( "bfc_friendlyfire" ):GetInt() == 1 then
		if ply:GetBFCTeam() == attacker:GetBFCTeam() then
			dmginfo:ScaleDamage( 0.5 )
		end
	end
	if hitgroup == HITGROUP_HEAD then
		dmginfo:ScaleDamage( 1.5 )
	elseif hitgroup == HITGROUP_CHEST then
		dmginfo:ScaleDamage( 1.0 )
	elseif hitgroup == HITGROUP_STOMACH then
		dmginfo:ScaleDamage( 0.9 )
	elseif hitgroup == HITGROUP_LEFTARM or hitgroup == HITGROUP_RIGHTARM then
		dmginfo:ScaleDamage( 0.75 )
	elseif hitgroup == HITGROUP_LEFTLEG or hitgroup == HITGROUP_RIGHTLEG then
		dmginfo:ScaleDamage( 0.75 )
	elseif hitgroup == HITGROUP_GEAR then
		dmginfo:ScaleDamage( 0 )
	end	
	local scale = GetConVar( "bfc_scale_damage" ):GetFloat()
	scale = math.Clamp( scale, 0.1, 2 )
	if scale then
		dmginfo:ScaleDamage( scale )
	end	
	if dmginfo:IsDamageType( DMG_BULLET ) then
		ply.rShots = ( ply.rShots or 0 ) + 1
	end
	local dmg = dmginfo:GetDamage()
	if SERVER and hitgroup == HITGROUP_HEAD and dmg >= ply:Health() and ply:GetBFCTeam() != attacker:GetBFCTeam() then
		attacker:AddScoreMsg( 50, "hs" )
	end
	ply.rDamage = ( ply.rDamage or 0 ) + dmg
end

--shared vars for player

function player:GetLevel()
	if !self.GetBFCLevel then
		player_manager.RunClass( self, "SetupDataTables" ) 
	end
	return self:GetBFCLevel()
end

function player:GetExp()
	if !self.GetBFCExp then
		player_manager.RunClass( self, "SetupDataTables" ) 
	end
	return self:GetBFCExp()
end

function player:GetScore()
	if !self.GetBFCScore then
		player_manager.RunClass( self, "SetupDataTables" ) 
	end
	return self:GetBFCScore()
end
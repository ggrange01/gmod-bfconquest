if !ulx or !ULib then
	
	print( "ULX or ULib not found! ULX module will not be loaded!" )

else

	print( "Loading ULX module" )

	function ulx.level( ply, plys, lvl )
		lvl = math.Round( lvl )
		for k, v in pairs( plys ) do
			v:AddLevel( lvl )
		end
		ulx.fancyLogAdmin( ply, "#A gave "..lvl.." level(s) to #T", plys )
	end
	local level = ulx.command( "BF Conquest Admin", "ulx bfc_level", ulx.level, "!bfclevel" )
	level:addParam{ type = ULib.cmds.PlayersArg }
	level:addParam{ type = ULib.cmds.NumArg, hint = "ammount" }
	level:defaultAccess( ULib.ACCESS_SUPERADMIN )
	level:help( "Adds player(s) specified ammount of level" )

	function ulx.exp( ply, plys, exp )
		exp = math.Round( exp )
		for k, v in pairs( plys ) do
			v:AddExp( exp )
			v:RecalculateLevel()
		end
		ulx.fancyLogAdmin( ply, "#A gave "..exp.." experience to #T", plys )
	end
	local exp = ulx.command( "BF Conquest Admin", "ulx bfc_exp", ulx.exp, "!bfcexp" )
	exp:addParam{ type = ULib.cmds.PlayersArg }
	exp:addParam{ type = ULib.cmds.NumArg, hint = "ammount" }
	exp:defaultAccess( ULib.ACCESS_SUPERADMIN )
	exp:help( "Adds player(s) specified ammount of experience" )

	function ulx.restartround( ply )
		StopRound()
		PreRestart()
		StartRound()
		ulx.fancyLogAdmin( ply, "#A restarted round" )
	end
	local restartround = ulx.command( "BF Conquest Admin", "ulx bfc_restart_round", ulx.restartround, "!restartround" )
	restartround:defaultAccess( ULib.ACCESS_SUPERADMIN )
	restartround:help( "Restarts round" )

	function ulx.swap( plyc, plyt1, plyt2 )
		if plyt1 == plyt2 then
			ULib.tsayError( plyc, "You have to select at least 2 different players!" )
			return
		end
		if !plyt1.GetBFCTeam or !plyt2.GetBFCTeam then
			ULib.tsayError( plyc, "An error has occurred while swapping players! [ Player team is not specified or data is damaged! ]" )
			return
		end
		if plyt1:GetBFCTeam() == 0 or plyt2:GetBFCTeam() == 0 then
			ULib.tsayError( plyc, "An error has occurred while swapping players! [ Player is not assigned to any team! ]" )
			return
		end
			if plyt1:GetBFCTeam() == plyt2:GetBFCTeam() then
			ULib.tsayError( plyc, "An error has occurred while swapping players! [ Both players are in the same team! ]" )
			return
		end
		local t1 = plyt1:GetBFCTeam()
		local t2 = plyt2:GetBFCTeam()
		plyt1:SetBFCTeam( t2 )
		plyt2:SetBFCTeam( t1 )
		plyt1:Kill()
		plyt2:Kill()
		ulx.fancyLogAdmin( plyc, "#A swapped #T with #T", plyt1, plyt2 )
	end
	local swap = ulx.command( "BF Conquest Admin", "ulx bfc_swap", ulx.swap, "!bfcswap" )
	swap:addParam{ type = ULib.cmds.PlayerArg }
	swap:addParam{ type = ULib.cmds.PlayerArg }
	swap:defaultAccess( ULib.ACCESS_SUPERADMIN )
	swap:help( "Swaps 2 players" )

end
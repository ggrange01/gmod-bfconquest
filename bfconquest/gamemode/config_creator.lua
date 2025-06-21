local MapName = ""

concommand.Add( "bfcmc" , function( ply, cmd, args, str )
	if #args < 1 or str[1] == "?" or str[1] == "help" then
		PrintHelp()
	elseif str[1] == "start" then
		StartConfig()
	elseif str[1] == "add" then
		AddConfig( cmd, str )
	elseif str[1] == "remove" then
		RemoveConfig( cmd, str )
	elseif str[1] == "save" then
		SaveConfig()
	else
		print( "[ERROR] bfcmc is unable to perform "..str[1].."operation! Type 'bfcmc help' to see help" )
	end
end )

local function PrintHelp()
	local help = [[
		bfcmc help
		usage < bfcmc [command] [args] >
		commands:
			start - starts new config for current map ( If you have unsaved config this function will delete it! )
			save - saves config file in '[garrys mod folder]/data/bfc/mapconfigs' ( If config fo current map already exists this function will overwrite it! )
			add [name] [args] - adds new spawn to spawns list with given name. Returns spawn index.
			remove [name] [index] - removes spawn from spawns list with given name and index.
		args:
			[name] - Targets
	]]
	print( help )
end

local function StartConfig()

end
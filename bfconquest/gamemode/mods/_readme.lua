/*
	This is readme file, before modding it's recomended to read this file.

	All files with _ prefix will be ignored by modloader.
	All files with sv_ prefix will be loaded serverside.
	All files with cl_ prefix will be loaded clientside.
	Other files will be loaded on both sides(shared).

	Mods are loaded after whole gamemode is set up.
	It's great place to put every changes which are too small to reupload whole gamemode.
	
	---------------------------
	Content:
		A - Hooks
		B - Making map config
		C - Making language file
	---------------------------

	A. Hooks:
		1. BFCMapLoaded
			Info:
				Called right after map file and almost nothing is set up. Map name is passed as string argument. Good place for doing map related things

			Example:
				hook.Add( "BFCMapLoaded", "UniqueName", function( map )
					if map == "gm_fork" then
						print( "GM_FORK is currently used map!" )
					else
						print( "GM_FORK is not currently used map!" )
					end
				end )
	

		2. BFCCleanup
			Info:
				Called right after map clean up. Nothing is passed as argument. Good place for deleting map props

			Example: (Remove every breakable props)
				hook.Add( "BFCCleanup", "UniqueName", function()
					local EntsToDelete = ents.FindByClass( "func_breakable" )
					for k, v in pairs( EntsToDelete ) do
						v:Remove()
					end
				end )


		3. BFCPreRound
			Info:
				Called after map cleanup and after setting up basig map elements(flags, vehicles etc.). Nothing is passed as argument. Good place for spawning your entities

			Example:
				hook.Add( "BFCPreRound", "UniqueName", function()
					--do sth
				end )


		4. BFCRoundStarted
			Info:
				Called just after preround end(15 seconds after BFCPreRound hook). Nothing is passed as argument. Good place for idk what...

			Example:
				hook.Add( "BFCRoundStarted", "UniqueName", function()
					
				end )


		5. BFCPostRound
			Info:
				Called when one of teams wins game. Victorious team is passed as int argument. Good place for doing things with victorious players

			Example: (print nick of every player from victorious team in console)
				hook.Add( "BFCPostRound", "UniqueName", function( team )
					local plys = GetPlayersByTeam( team )
					for k, v in pairs( plys ) do
						print( v:GetName() )
					end
				end )


		6. BFCVehicleHealth
			Info:
				Called only clientside to obtain vehicle health. Do NOT touch this function unless you know what are you doing! Vehicle and player's seat are passed
					as entity arguments. Return current health of vehicle and Max health of vehicle, return nothing to call next hooks.

			Example: (taken from 'sh_humvee.lua')
				hook.Add( "BFCVehicleHealth", "SimfphysHealth", function( vehicle, cl_vehicle ) --Important: 'vehicle' is actual vehicle and 'cl_vehicle' is player's seat
					if vehicle.GetCurHealth and vehicle.GetMaxHealth then
						return vehicle:GetCurHealth(), vehicle:GetMaxHealth()
					end
				end )


	B. Making map config
		Coming soon...


	C. Making language file
		1. Go to 'languages' directory
		2. Copy 'english.lua' and rename it to 'yourlanguage.lua' Important: Use only ASCII characters (Example: Russian is written in their language 'русский',
			but you can't use it. Instead name file 'russian.lua' or 'pyccknn.lua'. It's your choice)
		3. If your language uses special characters then on top of the file you have to specify 'STANDARD_FONT_OVERRIDE' and 'NUMBERS_FONT_OVERRIDE' by default these
			values are set to 'Purista SemiBold TTF' and 'BF4 Numbers'. To do it simply place variable name and assign string to it. (Example: STANDARD_FONT_OVERRIDE = "font_name")
		4. Translate only strings, do not modify variables' name.
		5. Test your language by writing in console 'bfc_language name' --Note that the 'name' is not file name, but a varible 'LANGUAGE.NAME'
		6. You don't have to reupload whole gamemode simply create new addon and put this file into 'gamemodes/bfconquest/gamemode/languages' directory. Also you
			can ask me to put this language into gamemode.

		Important:
			If you used custom font, you have to put this font file to 'resource/fonts' directory.
*/
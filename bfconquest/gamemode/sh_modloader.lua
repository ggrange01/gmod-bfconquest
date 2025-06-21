print( "---# BFC Mod Loader #---" )
print( "------------------------" )

local path = GM.FolderName.."/gamemode/mods/"

local files, dirs = file.Find( path.."*.lua", "LUA" )
local ignored = 0
for i, f in pairs( files ) do
	if string.sub( f, 1, 1 ) == "_" then
		ignored = ignored + 1
		continue
	end
	local ext = string.sub( f, 1, 3 )
	if ext == "sv_" then
		if SERVER then
			print( "# Loading mod: "..f )
			include( path..f )
		end
	elseif ext == "cl_" then
		if SERVER then
			AddCSLuaFile( path..f )
		end
		if CLIENT then
			print( "# Loading mod: "..f )
			include( path..f )
		end
	else
		if SERVER then
			AddCSLuaFile( path..f )
		end
		print( "# Loading mod: "..f )
		include( path..f )
	end
end

if SERVER and ignored > 0 then
	print( "------------------------" )
	print( "# Some files("..ignored..") have been ignored!" )
	print( "# Look into '_readme.lua' for more info" )
end

print( "------------------------" )
print( "------------------------" )
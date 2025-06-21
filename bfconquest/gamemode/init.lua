AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "sh_modloader.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "cl_selectwindow.lua" )
AddCSLuaFile( "cl_hud_ingame.lua" )
AddCSLuaFile( "cl_scoreboard.lua" )
AddCSLuaFile( "cl_targets.lua" )
AddCSLuaFile( "cl_killscreen.lua" )
AddCSLuaFile( "sh_player.lua" )
AddCSLuaFile( "player_class.lua" )
AddCSLuaFile( "sh_func.lua" )
AddCSLuaFile( "ulx.lua" )
AddCSLuaFile( "cl_postprocess.lua" )
--AddCSLuaFile( "config_creator.lua" )

include( "shared.lua" )
include( "entity.lua" )
include( "player.lua" )
include( "sv_player.lua" )
include( "round.lua" )
include( "server.lua" )
include( "sv_func.lua" )
include( "sv_vehicles.lua" )
include( "config/weapons.lua" )
include( "config/levels.lua" )

resource.AddWorkshop( '1121506304' ) -- BFConquest_content
resource.AddWorkshop( '242055891' ) -- BF4 Player Models
resource.AddWorkshop( '293485644' ) -- World Flags
resource.AddWorkshop( '349050451' ) -- Customizable Weaponry 2.0
resource.AddWorkshop( '358608166' ) -- Extra Customizable Weaponry 2.0
resource.AddWorkshop( '519666908' ) -- World Flags -Add Pole
resource.AddWorkshop( '318551641' ) -- Battlefield 4 M98B
resource.AddWorkshop( '443385748' ) -- Battlefield Hardline: AKM CW2.0
resource.AddWorkshop( '440793968' ) -- Battlefield Hardline: M16A3 CW2.0
resource.AddWorkshop( '315369257' ) -- GDCW Models & Materials
resource.AddWorkshop( '756601186' ) -- Grim Reaper

--CW 2.0 function override
function CW20_Customize( ply, com, args )
	if not CustomizableWeaponry.canOpenInteractionMenu or not CustomizableWeaponry.customizationEnabled then
		return
	end
	
	if not ply:Alive() then
		return
	end
	if ply.IsDead or ply:GetNoDraw() then return end

	local wep = ply:GetActiveWeapon()
	
	if not IsValid(wep) or not wep.CW20Weapon then
		return
	end
	
	if !CanUpgradeWeapon( ply ) then return end
	
	if wep:canCustomize() then
		wep:toggleCustomization()
	end
end

timer.Simple( 1, function()
	concommand.Add( "cw_customize", CW20_Customize )
end )

include( "sh_modloader.lua" )

print( "SERVER OK" )
--clientside hook

local LOW_HP_COLOR_MOD = {
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 0.8,
	["$pp_colour_colour"] = 0.75,
	["$pp_colour_addr"] = 0.04,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0.02,
	["$pp_colour_mulr"] = 0.6,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0.3
}

local BASE_RAPE_COLOR_MOD = {
	["$pp_colour_brightness"] = -0.3,
	["$pp_colour_contrast"] = 0.5,
	["$pp_colour_colour"] = 0,
	["$pp_colour_addr"] = 0.2,
	["$pp_colour_addg"] = 0.2,
	["$pp_colour_addb"] = 0.2,
	["$pp_colour_mulr"] = 1,
	["$pp_colour_mulg"] = 1,
	["$pp_colour_mulb"] = 1
}

function GM:RenderScreenspaceEffects()
	local health = LocalPlayer():Health()

	if health <= 20 then
		DrawSharpen( 1, 1 )
		DrawMotionBlur( 0.4, 0.4, 0.04 )
		DrawSobel( 0.8 )
		DrawColorModify( LOW_HP_COLOR_MOD )
	end

	if LocalPlayer().BaseRape then
		DrawColorModify( BASE_RAPE_COLOR_MOD )
	end

end
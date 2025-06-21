WEAPONS = {}

WEAPONS.TRANSLATE = { "PRIMARY", "SECONDARY", "GRENADE", "SPECIAL" }

WEAPONS.PRIMARY = {
	NUM = 1,
	DEF = 1,
	{"UMP .45", "cw_ump45", "N", 120, 1},
	{"MAC-11", "cw_mac11", "R", 150, 2}, --disp name, class, team(R, U, N), ammo, level
	{"MP5", "cw_mp5", "U", 120, 2},
	--pistol
	{"G36C", "cw_g36c", "N", 115, 4},
	{"VSS Vintorez", "cw_vss", "N", 100, 5},
	{"Serbu Shorty", "cw_shorty", "N", 30, 6},
	--pistol
	{"L85A2", "cw_l85a2", "N", 125, 8},
	{"SCAR-H", "cw_scarh", "N", 100, 9},
	{"G3A3", "cw_g3a3", "N", 100, 10},
	{"L115", "cw_l115", "N", 30, 11},
	--pistol
	{"AK-74", "cw_ak74", "R", 130, 13},
	{"AR-15", "cw_ar15", "U", 130, 13},
	{"M249", "cw_m249_official", "N", 350, 14},
	{"M3 Super 90", "cw_m3super90", "N", 40, 15},
	{"M98B", "gdcw_m98b", "N", 30, 16},
	{"M14 EBR", "cw_m14", "N", 110, 17},
	--pistol
	{"M16A3", "cw_bfh_m16a3", "U", 150, 20},
	{"AKM", "cw_bfh_akm", "R", 150, 20},
	
	
}

WEAPONS.SECONDARY = {
	NUM = 2,
	DEF = 1,
	{"Five-seveN", "cw_fiveseven", "N", 75, 1},
	{"P99", "cw_p99", "U", 60, 3},
	{"PM", "cw_makarov", "R", 60, 3},
	{"M1911", "cw_m1911", "N", 50, 7},
	{"MR96", "cw_mr96", "N", 40, 12},
	{"Desert Eagle", "cw_deagle", "N", 30, 19},
}

WEAPONS.GRENADE = {
	NUM = 3,
	DEF = 1,
	{"none", "none", "N", 0, 0},
	{"Frag", "cw_frag_grenade", "N", 2, 5},
	{"Smoke", "cw_smoke_grenade", "N", 1, 7},
	{"Flash", "cw_flash_grenade", "N", 1, 10},
}

WEAPONS.SPECIAL = {
	NUM = 4,
	DEF = 1,
	{"none", "none", "N", 0, 0},
	{"MedKit", "bfc_medkit", "N", 1, 4},
	{"Ammo", "bfc_ammokit", "N", 1, 6},
	{"M202", "bfc_m202", "N", 4, 15 },
	{"FIM-92 Stinger", "bfc_stinger", "N", 2, 15 }
}
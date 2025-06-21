local light_table = {
	ModernLights = true,
	L_HeadLampPos = Vector(105, 20, 4),
	L_HeadLampAng = Angle(10, 0, 0),
	R_HeadLampPos = Vector(105, -20, 4),
	R_HeadLampAng = Angle(10, 0, 0),
	
	L_RearLampPos = Vector(-96, 34, 7.5),
	L_RearLampAng = Angle(25,90,0),
	R_RearLampPos = Vector(-96, -34, 7.5),
	R_RearLampAng = Angle(25,90,0),
	
	Headlight_sprites = { 
		{
			pos = Vector(22, 102, 43),
			color = Color(255, 240, 220, 200),
			size = 45,
		},
		{
			pos = Vector(-22, 102, 43),
			color = Color(255, 240, 220, 200),
			size = 45,
		},
		
	},

	Headlamp_sprites = {
		{
			pos = Vector(22, 102, 43),
			color = Color(255, 240, 220, 255),
			size = 60,
		},
		{
			pos = Vector(-22, 102, 43),
			color = Color(255, 240, 220, 255),
			size = 60,
		},
	},
	
	Rearlight_sprites = {
		{
			pos = Vector(38, -99, 44),
			color = Color(127, 0, 0, 255),
			size = 30,
		},
		{
			pos = Vector(-38, -99, 44),
			color = Color(127, 0, 0, 255),
			size = 30,
		},
	},

	Brakelight_sprites = {
	{
			pos = Vector(38, -99, 44),
			color = Color(127, 0, 0, 255),
			size = 45,
		},
		{
			pos = Vector(-38, -99, 44),
			color = Color(127, 0, 0, 255),
			size = 45,
		},
	},

	Reverselight_sprites = {
	},
}
list.Set( "simfphys_lights", "humvii", light_table)

local V = {
	Name = "BFC Humvee",
	Model = "models/sentry/humvee.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "BFC Vehicles",
	SpawnOffset = Vector( 0, 0, 25 ),
	SpawnAngleOffset = 90,

	Members = {
		
		ModelInfo = {
			Color = Color( 255, 255, 255, 255 ),
		},
		
		LightsTable = "humvii",
		
		Mass = 2300,
		IsArmored = true,
		MaxHealth = 2500,
		EnginePos = Vector( 0, 85, 50 ),
		
		FrontWheelRadius = 19,
		RearWheelRadius = 19,
		
		CustomMassCenter = Vector( 0, 5, 0 ),
		
		FirstPersonViewPos = Vector( 3, -7, 7 ),
		
		SeatOffset = Vector( -2, -2, -4 ),
		SeatPitch = 0,
		SeatYaw = 0,
		
		SpeedoMax = 100,
		
		PassengerSeats = {
			{pos = Vector( 30, 13, 27 ), ang = Angle( 0, 0, 9 )},
			{pos = Vector( -32,-22,27 ), ang = Angle( 0, 0, 9 )},
			{pos = Vector( 32, -22, 27 ), ang = Angle( 0, 0, 9 )},
		},
		
		ExhaustPositions = {
			{
				pos = Vector( -49, -39, 22 ),
				ang = Angle( 180, 0, 0 )
			},
		
		},
		
		StrengthenSuspension = false,
		
		FrontHeight = 17,
		FrontConstant = 55000,
		FrontDamping = 3200,
		FrontRelativeDamping = 3200,
		
		RearHeight = 17,
		RearConstant = 50000,
		RearDamping = 3000,
		RearRelativeDamping = 3000,
		
		FastSteeringAngle = 18,
		SteeringFadeFastSpeed = 535,
		
		TurnSpeed = 2,
		
		MaxGrip = 75,
		Efficiency = 1,
		GripOffset = -3,
		BrakePower = 55,
		AirFriction = -3000,
		
		IdleRPM = 750,
		LimitRPM = 4000,
		PeakTorque = 200,
		PowerbandStart = 1300,
		PowerbandEnd = 4000,
		Turbocharged = false,
		Supercharged = false,
		
		FuelType = FUELTYPE_NONE,
		--FuelTankSize = 95,
		--FuelFillPos = Vector( 34, -87, 65 ),
		
		
		PowerBias = 0,
		
		EngineSoundPreset = 1,
		
		
		DifferentialGear = 0.55,
		Gears = { -0.15, 0, 0.12, 0.17, 0.24, 0.32, 0.38, 0.45 }
	}
}
list.Set( "simfphys_vehicles", "bfc_humvee", V )

if CLIENT then
	hook.Add( "BFCVehicleHealth", "SimfphysHealth", function( vehicle, cl_vehicle )
		if vehicle.GetCurHealth and vehicle.GetMaxHealth then
			return vehicle:GetCurHealth(), vehicle:GetMaxHealth()
		end
	end )
end
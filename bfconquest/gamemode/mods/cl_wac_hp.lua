hook.Add( "BFCVehicleHealth", "WACHealth", function( vehicle, cl_vehicle )
	if vehicle.GetHP and vehicle.GetMaxHP then
		return vehicle:GetHP(), vehicle:GetMaxHP()
	end
end )
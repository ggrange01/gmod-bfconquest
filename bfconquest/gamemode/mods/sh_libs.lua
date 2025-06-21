surface = surface or {}

function surface.DrawRing( x, y, radius, thick, angle, segments, fill, rotation )
	angle = math.Clamp( angle or 360, 1, 360 )
	fill = math.Clamp( fill or 1, 0, 1 )
	rotation = rotation or 0

	local segmentstodraw = {}
	local segang = angle / segments
	local bigradius = radius + thick

	for i = 1, math.Round( segments * fill ) do
		local ang1 = math.rad( rotation + ( i - 1 ) * segang )
		local ang2 = math.rad( rotation + i * segang )

		local sin1 = math.sin( ang1 )
		local cos1 = -math.cos( ang1 )

		local sin2 = math.sin( ang2 )
		local cos2 = -math.cos( ang2 )

		surface.DrawPoly( {
			{ x = x + sin1 * radius, y = y + cos1 * radius },
			{ x = x + sin1 * bigradius, y = y + cos1 * bigradius },
			{ x = x + sin2 * bigradius, y = y + cos2 * bigradius },
			{ x = x + sin2 * radius, y = y + cos2 * radius }
		} )

	end
end

function surface.DrawRingDC( x, y, radius, thick, angle, segments, fill, rotation, dist, func )
	angle = math.Clamp( angle or 360, 1, 360 )
	fill = math.Clamp( fill or 1, 0, 1 )
	rotation = rotation or 0
	dist = dist or 0

	local segmentstodraw = {}
	local segang = ( angle / segments )
	local bigradius = radius + thick

	for i = 1, math.Round( segments * fill ) do
		local ang1 = math.rad( rotation + ( i - 1 ) * segang )
		local ang2 = math.rad( rotation + i * segang - dist )

		local sin1 = math.sin( ang1 )
		local cos1 = -math.cos( ang1 )

		local sin2 = math.sin( ang2 )
		local cos2 = -math.cos( ang2 )

		if func and isfunction( func ) then
			func( i )
		end

		surface.DrawPoly( {
			{ x = x + sin1 * radius, y = y + cos1 * radius },
			{ x = x + sin1 * bigradius, y = y + cos1 * bigradius },
			{ x = x + sin2 * bigradius, y = y + cos2 * bigradius },
			{ x = x + sin2 * radius, y = y + cos2 * radius }
		} )

	end
end

function surface.DrawSubTexturedRect( x, y, w, h, subx, suby, subw, subh, txw, txh )
	local ustart = subx / txw
	local vstart = suby / txh
	local uwidth = subw / txw
	local vwidth = subh / txh

	surface.DrawPoly( {
		{
			x = x,
			y = y,
			u = ustart,
			v = vstart
		},
		{
			x = x + w,
			y = y,
			u = ustart + uwidth,
			v = vstart
		},
		{
			x = x + w,
			y = y + h,
			u = ustart + uwidth,
			v = vstart + vwidth
		},
		{
			x = x,
			y = y + h,
			u = ustart,
			v = vstart + vwidth
		},				
	} )
end

function surface.DrawRotatedSubTexturedRect( x, y, w, h, subx, suby, subw, subh, txw, txh, rot )
	local mx = Matrix()

	mx:Translate( Vector( x + w / 2, y + h / 2 ) )
	mx:Rotate( Angle( 0, rot, 0 ) )
	mx:Translate( -Vector( x + w / 2, y + h / 2 ) )

	cam.PushModelMatrix( mx )

		surface.DrawSubTexturedRect( x, y, w, h, subx, suby, subw, subh, txw, txh )

	cam.PopModelMatrix()

end

function surface.DrawFilledCircle( x, y, radius, seg )
	seg = math.Round( seg )
	local verts = {}
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( verts, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius } )
	end
	surface.DrawPoly( verts )
end

---------------------------------------------------------------------------

math = math or {}

function math.TimedSinWave( freq, min, max )
	min = ( min + max ) / 2
	local wave = math.SinWave( RealTime(), freq, min - max, min )
	return wave
end

--based on wikipedia: f(x) = sin( angular frequency(in Hz) * x ) * amplitude + offset
function math.SinWave( x, freq, amp, offset )
	local wave = math.sin( 2 * math.pi * freq * x ) * amp + offset
	return wave
end


---------------------------------------------------------------------------

local vector = FindMetaTable( "Vector" )

function vector:Copy()
	return Vector( self.x, self.y, self.z )
end

function vector:DistanceIgnoreZ( vec )
	local vec1 = Vector( self.x, self.y, 0 )
	local vec2 = Vector( vec.x, vec.y, 0 )

	return vec1:Distance( vec2 )
end

local angle = FindMetaTable( "Angle" )

function angle:Copy()
	return Angle( self.pitch, self.yaw, self.roll )
end

---------------------------------------------------------------------------

function CopyTable( to, from )
	to = to or {}
	for k, v in pairs( from ) do
		if type( v ) == "table" then
			CopyTable( to[k], v[k] )
		else
			to[k] = v
		end
	end
end
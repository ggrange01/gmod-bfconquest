function EFFECT:Init(data)

	self.position = data:GetOrigin()
	self.scale = data:GetScale()
	self.direction 	= data:GetNormal()
	self.particles = data:GetMagnitude()

	self.Emitter = ParticleEmitter( self.position )

	sound.Play( "weapons/boom.wav", self.position, 120, 100 )

	for i = 1, 5 do 
		local flash = self.Emitter:Add( "effects/muzzleflash"..math.random( 1, 4 ), self.position )
		if flash then
			flash:SetVelocity( self.direction * 100 )
			flash:SetAirResistance( 20 )
			flash:SetDieTime( 0.3 )
			flash:SetStartAlpha( 255 )
			flash:SetEndAlpha( 0 )
			flash:SetStartSize( self.scale * 250 )
			flash:SetEndSize( 0 )
			flash:SetRoll( math.Rand( 180, 360 ) )
			flash:SetRollDelta( math.Rand( -1, 1 ) )
			flash:SetColor( 255, 255, 255 )	
		end
	end

	for i=1, 20 * self.scale do
		local dust = self.Emitter:Add( "particle/particle_composite", self.position )	
		if dust then
			dust:SetVelocity( ( self.direction * math.random( 100, 300 ) + VectorRand() * 250 ) * self.scale )
			dust:SetDieTime( math.Rand( 2, 3 ) )
			dust:SetStartAlpha( 200 )
			dust:SetEndAlpha( 0 )
			dust:SetStartSize( 50 * self.scale )
			dust:SetEndSize( 125 * self.scale )
			dust:SetRoll( math.Rand( 180, 360 ) )
			dust:SetRollDelta( math.Rand( -1, 1 ) )
			dust:SetAirResistance( 150 )
			dust:SetGravity( Vector( 0, 0, math.Rand( -100, -300 ) ) )
			dust:SetColor( 80, 80, 80 )
		end
	end

	for i = 1, 5 * self.scale do
		local dust = self.Emitter:Add( "particle/smokesprites_000"..math.random( 1, 9 ), self.position )
		if dust then
			dust:SetVelocity( ( self.direction * math.random( 100, 300 ) + VectorRand() * 250 ) * self.scale )
			dust:SetDieTime( math.Rand( 1, 5 ) )
			dust:SetStartAlpha( 150 )
			dust:SetEndAlpha( 0 )
			dust:SetStartSize( 75 * self.scale )
			dust:SetEndSize( 250 * self.scale )
			dust:SetRoll( math.Rand( 180, 360 ) )
			dust:SetRollDelta( math.Rand( -1, 1 ) )			
			dust:SetAirResistance( 250 ) 			 
			dust:SetGravity( Vector( math.Rand( -250 , 250 ), math.Rand( -250 , 250 ), math.Rand( 75 , 250 ) ) )		
			dust:SetColor( 90, 85, 75 )
		end
	end

	for i = 1, 5 * self.scale do
		local cement = self.Emitter:Add( "effects/fleck_cement"..math.random( 1, 2 ), self.position )
		if cement then
			cement:SetVelocity( ( self.direction * math.random( 250, 400 ) + VectorRand() * math.random( 100, 250 ) ) * self.scale )
			cement:SetDieTime( math.random( 1, 2 ) * self.scale )
			cement:SetStartAlpha( 255 )
			cement:SetEndAlpha( 0 )
			cement:SetStartSize( math.random( 5, 10 ) * self.scale )
			cement:SetRoll( math.Rand( 0, 360 ) )
			cement:SetRollDelta( math.Rand( -3, 3 ) )			
			cement:SetAirResistance( 50 ) 			 			
			cement:SetColor( 60, 60, 60 )
			cement:SetGravity( Vector( 0, 0, -500 ) ) 	
		end
	end

	local angle = self.direction:Angle()
	local size = self.scale * 5

	for i = 1, 8 do
		angle:RotateAroundAxis( angle:Forward(), 360 / 8 )
		local dir = self.direction * math.random( 1, 5 ) + angle:Up() * math.random( 3, 5 )
		for j = 1, self.particles do
			local particle = self.Emitter:Add( "particle/smokesprites_000"..math.random( 1, 9 ), self.position )
			particle:SetVelocity( ( VectorRand() * math.random( 1, 2 ) + dir * j * 1.25 ) * size )
			particle:SetDieTime( 2.5 )

			particle:SetStartAlpha( 150 )
			particle:SetEndAlpha( 0 )

			particle:SetStartSize( ( 5 * size - j / self.particles * size ) )
			particle:SetEndSize( ( 20 * size - j / self.particles * size ) )

			particle:SetRoll( math.random( -50, 50 ) )
			particle:SetRollDelta( math.random( -1, 1 ) )

			particle:SetAirResistance( size * 4 )
			particle:SetGravity( VectorRand() * math.random( 2, 5 ) * size + Vector( 0, 0, -75 ) )

			particle:SetColor( math.random( 90, 93 ), math.random( 91, 94 ), math.random( 92, 95 ) )
		end
	end


























	/*for i = 1, 3 do
		angle:RotateAroundAxis( angle:Forward(), 360 / 3 )
		local vec = self.direction * math.Rand( 1, 5 ) + angle:Up() * math.Rand( 2, 5 )
		for j = 3, self.particles do
			local c = math.random( -20, 20 )

			local particle1 = self.Emitter:Add( "particle/smokesprites_000"..math.random( 1, 9 ), self.position )
			particle1:SetVelocity( ( VectorRand():GetNormalized() * math.Rand( 1, 2 ) * size ) + ( vec * size * j * 3.5 ) )
			particle1:SetDieTime( math.Rand( 0.5, 4 )*self.scale )

			particle1:SetStartAlpha( math.Rand( 90, 100 ) )
			particle1:SetEndAlpha( 0 )

			particle1:SetGravity( VectorRand():GetNormalized() * math.Rand( 5, 10 ) * size + Vector( 0, 0, -50 ) )
			particle1:SetAirResistance( 200 + self.scale * 20 )

			particle1:SetStartSize( ( 5 * size ) - ( ( j / self.particles ) * size * 3 ) )
			particle1:SetEndSize( ( 20 * size ) - ( ( j / self.particles ) * size ) )

			particle1:SetRoll( math.random( -500, 500 ) / 100 )
			particle1:SetRollDelta( math.random( -0.5, 0.5 ) )

			particle1:SetColor( 90 + c, 87 + c, 80 + c )
		end
	end*/

 end

function EFFECT:Think( )
	return false
end

function EFFECT:Render()

end
function RebuildMinimap()
	if !MINIMAP then return end

	local w, h = ScrW(), ScrH()
	local size = h * math.Clamp( MINIMAP.Quality or 1, 0.1, 1 )
	local oldRT = render.GetRenderTarget()
	local newRT = GetRenderTarget( "minimap_render_target", size, size )

	render.SetRenderTarget( newRT )
	render.SetViewPort( 0, 0, size, size )

		render.Clear( 0, 0, 0, 255, true, true )

		local mins, maxs = Entity( 0 ):GetModelBounds()
		local orig = ( mins + maxs ) / 2
		orig.z = MINIMAP.RenderHeight or orig.z

		local rendersize = math.max( maxs.x - mins.x, maxs.y - mins.y ) / 2

		local view = {
			origin = orig,
			angles = Angle( 90, MINIMAP.RenderYaw or 0, 0 ),
			x = 0,
			y = 0,
			w = size,
			h = size,
			ortho = {
				/*left = mins.x,
				right = maxs.x,
				top = mins.y,
				bottom = maxs.y*/
				left = -rendersize,
				right = rendersize,
				top = -rendersize,
				bottom = rendersize,
			}
		}

		render.RenderView( view )

	render.SetRenderTarget( oldRT )
	render.SetViewPort( 0, 0, w, h )

	local tx = MINIMAP_TX or CreateMaterial( "minimap_mat", "UnlitGeneric" )
	tx:SetTexture( "$basetexture", newRT )

	MINIMAP_TX = tx
	MINIMAP_WS = rendersize
	MINIMAP_SIZE = size
	--return tx, rendersize, size
end
--MINIMAP_TX, MINIMAP_WS, MINIMAP_SIZE = RebuildMinimap()
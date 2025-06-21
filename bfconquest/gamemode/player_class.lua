DEFINE_BASECLASS( "player_default" )

--call
--	player_manager.SetPlayerClass( player, "player_class" ) 
--	player_manager.RunClass( player, "SetupDataTables" ) 

local PLAYER = { }

function PLAYER:SetupDataTables()
	print( "Seting up data tables for "..self.Player:GetName() )
	--network vars etc.
	self.Player:NetworkVar( "Int", 0, "BFCTeam" )
	self.Player:NetworkVar( "Int", 1, "BFCLevel" )
	self.Player:NetworkVar( "Int", 2, "BFCExp" )
	self.Player:NetworkVar( "Int", 3, "BFCScore" )
	
	if SERVER then
		CheckForDataIssue( self.Player, "bfc_level", 1 )
		CheckForDataIssue( self.Player, "bfc_exp", 0 )
		if self.Player:GetBFCTeam() == TEAM_NONE then
			self.Player:SetBFCTeam( AssignToTeam( self.Player ) )
			print( "Setting player initial team to "..self.Player:GetBFCTeam() )
		end
		self.Player:SetBFCLevel( self.Player:GetPData( "bfc_level", 1 ) )
		self.Player:SetBFCExp( self.Player:GetPData( "bfc_exp", 0 ) )
	end
end

player_manager.RegisterClass( "player_class", PLAYER, "player_default" )

function CheckForDataIssue( ply, name, def )
	local data = ply:GetPData( name, nil )
	if data and !tonumber( data ) then
		print( ply:GetName().."'s data is damaged! Repairing..." )
		ply:RemovePData( name )
		ply:SetPData( name, def )
	end
end
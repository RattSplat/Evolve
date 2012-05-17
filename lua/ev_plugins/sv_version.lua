/*-------------------------------------------------------------------------------------------------------------------------
	Evolve version
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Version"
PLUGIN.Description = "Returns the version of Evolve."
PLUGIN.Author = "Overv,MadDog"
PLUGIN.ChatCommand = { "version", "about" }

function PLUGIN:Call( ply, args )
	evolve:Notify( ply, evolve.colors.white, "This server is running ", evolve.colors.red, "revision " .. evolve.version, evolve.colors.white, " of Evolve." )
end

function PLUGIN:PlayerInitialSpawn( ply )
	if ( ply:EV_IsOwner() ) then
		if ( !self.LatestVersion ) then
			--im using my personal website to pull the version number off the GitHub website. My site also trims the content down so the server doesnt have to download a huge file. ~MadDog
			http.Get( "http://www.aspinvision.com/evolve.asp", "", function( src ) 
				self.LatestVersion = tonumber( src ) --:match( "version = ([1-9]+)" ) )
				self:PlayerInitialSpawn( ply )
			end )
			return
		end
		
		if ( evolve.version < self.LatestVersion ) then
			evolve:Notify( ply, evolve.colors.red, "WARNING: Your Evolve needs to be updated to " .. self.LatestVersion .. "!" )
		end
	end
end

evolve:RegisterPlugin( PLUGIN )
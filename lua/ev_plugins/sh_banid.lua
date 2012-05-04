local PLUGIN = {}
PLUGIN.Title = "BanID"
PLUGIN.Description = "Ban a player."
PLUGIN.Author = "centran - based on Overv's Ban"
PLUGIN.ChatCommand = "banid"
PLUGIN.Usage = "<player> [time=5] [reason]"
PLUGIN.Privileges = { "Ban", "Permaban" }

function PLUGIN:Call( ply, args )
        local time = math.Clamp( tonumber( args[2] ) or 5, 0, 10080 )

        if ( ( time > 0 and ply:EV_HasPrivilege( "Ban" ) ) or ( time == 0 and ply:EV_HasPrivilege( "Permaban" ) ) ) then
                /*-------------------------------------------------------------------------------------------------------------------------
                        Get the unique ID to ban
                -------------------------------------------------------------------------------------------------------------------------*/

                local sid

                //Is this a steam ID
                if not (  string.find( args[1], "STEAM_%d:%d:%d+" ) )
                then
                        evolve:Notify( ply, evolve.colors.white, "Not a ", evolve.colors.red, "SteamID" )
                        return
                end

                sid = args[1]

                local length = tonumber( args[2] ) or 0

                if ( length < 0 )
                then
                        evolve:Notify( ply, evolve.colors.white, "INVALID:", evolve.colors.red, "Ban Time" )
                        return
                end

                local reason = table.concat( args, " ", 3 )
                        if ( #reason == 0 ) then reason = "No reason specified"
                end

                //perform ban
                sourcebans.BanPlayerBySteamID( sid, length*60, reason, ply )

                if ( length == 0 ) then
                        evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " banned ", evolve.colors.red, "SteamID", evolve.colors.white, " permanently (" .. reason .. ")." )
                else
                        evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " banned ", evolve.colors.red, "SteamID", evolve.colors.white, " for " .. length / 60 .. " minutes (" .. reason .. ")." )
                end
        else
                evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
        end
end

if ( SERVER ) then
        function PLUGIN:InitPostEntity()
                for uid, data in pairs( evolve.PlayerInfo ) do
                        if ( evolve:IsBanned( uid ) ) then
                                game.ConsoleCommand( "banid " .. ( data.BanEnd - os.time() ) / 60 .. " " .. data.SteamID .. "\n" )
                        end
                end
        end
end

evolve:RegisterPlugin( PLUGIN )
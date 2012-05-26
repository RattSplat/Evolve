

local PLUGIN = {}
PLUGIN.Title = "MOTD"
PLUGIN.Description = "Message of the Day."
PLUGIN.Author = "Wrex"
PLUGIN.ChatCommand = "motd"
PLUGIN.Usage = nil
PLUGIN.Privileges = nil

if (SERVER) then 
	if (file.Exists("ev_motd.txt","DATA")) then
		resource.AddFile("data/ev_motd.txt")
		print("Sending MOTD file To Clients.")
	end
end



function PLUGIN:OpenMotd( ply )
	if (SERVER) then
		ply:ConCommand("evolve_motd")
	end
end

function PLUGIN:ReadMOTD(txt)
	if CLIENT then
	
		if file.Exists("ev_motd.txt","DATA") then
			txt = file.Read( "ev_motd.txt","DATA")
		else
			txt = "Welcome to the server, Enjoy your stay!"
		end
	end
	
	return txt
end


function PLUGIN:Call( ply, args )
	self:OpenMotd( ply )

end



if (CLIENT) then
	function PLUGIN:CreateMenu()

		self.MotdPanel = vgui.Create("DFrame")
		local w,h = ScrW() - 200,ScrH() - 200
		self.MotdPanel:SetPos( 100,100 )
		self.MotdPanel:SetSize( w,h )
		self.MotdPanel:SetTitle( "MOTD" )
		self.MotdPanel:SetVisible( false )
		self.MotdPanel:SetDraggable( false )
		self.MotdPanel:ShowCloseButton( true )
		self.MotdPanel:SetDeleteOnClose( false )
		self.MotdPanel:SetScreenLock( true )
		self.MotdPanel:MakePopup()
		
		self.MotdBox = vgui.Create("HTML",self.MotdPanel)
		self.MotdBox:StretchToParent( 4,25,4,4 )
		self.MotdBox:SetHTML(self:ReadMOTD())
	end
	timer.Simple( 0.1, function() PLUGIN:CreateMenu() end)
	
	concommand.Add("evolve_motd",function(ply,cmd,args)
		PLUGIN.MotdPanel:SetVisible( true )
	end)
	
	concommand.Add("evolve_startmotd",function(ply,cmd,args)
		PLUGIN.StartPanel:SetVisible( true )
	end)
	
end

function ShowMOTDOnSpawn( ply )
	timer.Simple( 3, function() ply:ConCommand("evolve_motd") end)
end
	
hook.Add( "PlayerInitialSpawn", "playerInitialSpawn", ShowMOTDOnSpawn)


evolve:RegisterPlugin( PLUGIN )
local PLUGIN = {}
PLUGIN.Title = "MOTD"
PLUGIN.Description = "Message of the Day."
PLUGIN.Author = "Wrex,MadDog"
PLUGIN.ChatCommand = "motd"
PLUGIN.Usage = nil
PLUGIN.Privileges = nil
PLUGIN.AcceptCloseDelay = 6 --seconds



CreateConVar("ev_motd", "http://dl.dropbox.com/u/45247280/ev_motd.htm", _, FCVAR_REPLICATED | FCVAR_ARCHIVE ) --off by default. 1 = enable, or enter a url to load a page (example: ev_motd "http://www.yourwebsite.com")
if (SERVER) then 	

	if (file.Exists("ev_motd.txt","DATA")) then
		resource.AddFile("data/ev_motd.txt")
	end

	function PLUGIN:OpenMotd( ply )
		ply:ConCommand("evolve_motd")
	end

end

function PLUGIN:Call( ply, args )
	if (SERVER) then
		self:OpenMotd( ply )
	end
end

function PLUGIN:ReadMOTD()
	if CLIENT then
		if file.Exists("ev_motd.txt","DATA") then
			return file.Read( "ev_motd.txt","DATA")
		end
	end
end

function PLUGIN:PlayerInitialSpawn( ply )
	if (SERVER) then
		timer.Simple(4, self.OpenMotd, self, ply )
	end
end



function PLUGIN:CreateMenu()
	
	if (CLIENT) then
		local w,h = ScrW() - 100,ScrH() - 100
		

		--the frame
		self.MotdPanel = vgui.Create( "DFrame" )
		self.MotdPanel:SetSize( w, h )
		self.MotdPanel:Center()
		self.MotdPanel:SetTitle( self.Title )
		self.MotdPanel:SetDraggable( false )
		self.MotdPanel:SetScreenLock( true )
		self.MotdPanel:SetDeleteOnClose( false )
		self.MotdPanel:SetVisible( true )
		self.MotdPanel:MakePopup()

		--ShowCloseButton is useless in the beta so these are needed for now
		self.MotdPanel.btnClose:SetVisible(false)
		self.MotdPanel.btnMaxim:SetVisible(false)
		self.MotdPanel.btnMinim:SetVisible(false)

		--the Accept button
		--must agree to close, and the button is disabled for a few seconds to start with!
		self.AcceptButton = vgui.Create( "DButton", self.MotdPanel )
		self.AcceptButton:SetText( "I Agree to the Rules" )
		self.AcceptButton.DoClick = function()
			if !(LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin()) then RunConsoleCommand("say", "I agree to the rules.") end --dont make admins say they agree
			self.MotdPanel:Close()
			gui.EnableScreenClicker( false )
		end
		self.AcceptButton:SetSize( 150, 40 )
		self.AcceptButton:SetDisabled( true )
		self.AcceptButton:SetPos( (self.MotdPanel:GetWide() - self.AcceptButton:GetWide()) / 2, self.MotdPanel:GetTall() - self.AcceptButton:GetTall() - 10 )

		--the MOTD
		self.MotdBox = vgui.Create( "DHTML", self.MotdPanel )
		self.MotdBox:SetSize( self.MotdPanel:GetWide() - 10, self.MotdPanel:GetTall() - self.AcceptButton:GetTall() - 50 )
		self.MotdBox:SetPos( 5, 30 )

		if (!GetConVarString("ev_motd"):find("://")) then
			self.MotdBox:SetHTML( self:ReadMOTD() )
		else
			self.MotdBox:OpenURL( GetConVarString("ev_motd") .. "?" .. os.time() ) --appending time insures the file is never cached by the client
		end

		timer.Simple( self.AcceptCloseDelay, function()
			PLUGIN.AcceptButton:SetDisabled( false )
		end)
	end
end




concommand.Add("evolve_motd",function( ply, cmd, args )
	if CLIENT then
		if PLUGIN.MotdPanel then
			PLUGIN.MotdPanel:SetVisible( true )			
		else	
			PLUGIN:CreateMenu() 
		end
	end
end)



	
	
evolve:RegisterPlugin( PLUGIN )
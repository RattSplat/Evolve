
local PLUGIN = {}
PLUGIN.Title = "MOTD"
PLUGIN.Description = "Message of the Day."
PLUGIN.Author = "Wrex,MadDog"
PLUGIN.ChatCommand = "motd"
PLUGIN.Usage = nil
PLUGIN.Privileges = nil
PLUGIN.AcceptCloseDelay = 6 --seconds

if (SERVER) then 
	if (file.Exists("ev_motd.txt","DATA")) then
		resource.AddFile("data/ev_motd.txt")
	end

	CreateConVar("ev_motd", "", _, FCVAR_REPLICATED | FCVAR_ARCHIVE ) --off by default. 1 = enable, or enter a url to load a page (example: ev_motd "http://www.yourwebsite.com")
end

function PLUGIN:Call( ply, args )
	self:OpenMotd( ply )
end

function PLUGIN:OpenMotd( ply )
	if (SERVER) then
		ply:ConCommand("evolve_motd")
	end
end

function PLUGIN:ReadMOTD(txt)
	if CLIENT then
		if file.Exists("ev_motd.txt","DATA") then
			return file.Read( "ev_motd.txt","DATA")
		end
	end
end

function PLUGIN:PlayerInitialSpawn( ply )
	if (SERVER and GetConVar("ev_motd"):GetString() ~= "") then
		timer.Simple(4, self.OpenMotd, self, ply )
	end
end

if (CLIENT) then
	function PLUGIN:CreateMenu()
		if (GetConVar("ev_motd"):GetString() == "") then return end --motd disabled by server
		if (!GetConVar("ev_motd"):GetString():find("://") and !self:ReadMOTD()) then return end --no motd file

		local w,h = ScrW() - 100,ScrH() - 100

		--the frame
		self.MotdPanel = vgui.Create( "DFrame" )
		self.MotdPanel:SetSize( w, h )
		self.MotdPanel:Center()
		self.MotdPanel:SetTitle( self.Title )
		self.MotdPanel:SetDraggable( false )
		self.MotdPanel:SetScreenLock( true )
		self.MotdPanel:SetDeleteOnClose( false )
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

		if (!GetConVar("ev_motd"):GetString():find("://")) then
			self.MotdBox:SetHTML( self:ReadMOTD() )
		else
			self.MotdBox:OpenURL( GetConVar("ev_motd"):GetString() .. "?" .. os.time() ) --appending time insures the file is never cached by the client
		end

		timer.Simple( self.AcceptCloseDelay, function()
			PLUGIN.AcceptButton:SetDisabled( false )
		end)
	end
	timer.Simple( 0.1, function() PLUGIN:CreateMenu() end)

	concommand.Add("evolve_motd",function( ply, cmd, args )
		PLUGIN.MotdPanel:SetVisible( true )
	end)
end

evolve:RegisterPlugin( PLUGIN )
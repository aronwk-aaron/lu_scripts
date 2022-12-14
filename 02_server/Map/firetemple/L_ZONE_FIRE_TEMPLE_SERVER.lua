----------------------------------------
-- FIRE TEMPLE SERVER ZONE SCRIPT
--
-- created by mrb... 9/29/11 
---------------------------------------------
local tPlayers = {}

function onZoneLoadedInfo(self, msg)
	-- store out players
	self:SetVar("initialPlayerCount", msg.maxPlayersSoft)
	math.randomseed(os.time())
end

function onPlayerLoaded(self, msg)
	-- open the activity close button
	msg.playerID:UIMessageServerToSingleClient{strMessageName = "ToggleActivityCloseButton", args = {{"bShow", true}}}
	
	table.insert(tPlayers, msg.playerID)
end 

function onMessageBoxRespond(self, msg)	
	-- button hit came from the x and it's not open for this user, so display the exit question
	if msg.identifier == "ActivityButton" and not self:GetVar("|"..msg.sender:GetID()) then      
		self:SetVar("|"..msg.sender:GetID(), true)
		
		msg.sender:DisplayMessageBox{	bShow = true, 
										imageID = 1, 
										callbackClient = self, 
										text = "UI_EULA_CONFIRM_EXIT_LINE2", 
										identifier = "Exit"}		  
	-- exit button was hit
	elseif msg.identifier == "Exit" then	
		-- clear the player var
		self:SetVar("|"..msg.sender:GetID(), nil)
		
		if msg.iButton == 1 then
			-- open the activity close button
			msg.sender:UIMessageServerToSingleClient{strMessageName = "ToggleActivityCloseButton", args = {{"bShow", false}}}
			-- player hit the check so exit			
			msg.sender:TransferToLastNonInstance()
		end
	end
end 

function onPlayerExit(self, msg)
	local tempTable = {}
	
	-- remove the player from the player table
	for k, player in ipairs(tPlayers) do
		if player:GetID() ~= msg.playerID:GetID() then
			table.insert(tempTable, player)
		end
	end
	
	tPlayers = tempTable
end 
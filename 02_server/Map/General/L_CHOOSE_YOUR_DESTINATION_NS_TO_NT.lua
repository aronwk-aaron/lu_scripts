--------------------------------------------------------------
-- LEGO Club door Script to transfer the player
--
-- updated mrb... 4/18/11 - updated to use base script and new functionality
--------------------------------------------------------------

----------------------------------------------
-- sets up variables and returns if this needs a choice box or not
----------------------------------------------
function CheckChoice(self, player)    
    if not player:Exists() then return end    
	
	local choiceZoneID = self:GetVar("choiceZone") or 0
	
	-- if we are in LUP station so we can open the choice box
    if self:GetVar("currentZone") == choiceZoneID then
		local visitedZones = player:GetLocationsVisited().locations or {}
		local strText = ""
		local newMap = choiceZoneID
		
		-- check if the player has been to NT and show the choicebox
		for k, zoneID in ipairs(visitedZones) do
			if zoneID == 1900 then				
				return true
			end
		end		
		
		-- if this isn't a choice box we're going to NS
		self:SetVar("transferZoneID", 1200)
		self:SetVar("teleportString", "UI_TRAVEL_TO_NS")
		
		return false
    end										
end

----------------------------------------------
-- When the player interacts with the UI confirmation widget
----------------------------------------------
function SetDestination(self, player)    	
	local curMap = self:GetVar("currentZone")
	local newMap = self:GetVar("choiceZone") or 0
	
	if curMap == choiceZoneID then
		newMap = 1200
	end
	
	self:SetVar("transferZoneID", newMap)
end 

function baseChoiceBoxRespond(self, msg)
	--print("ChoiceBoxRespond " .. msg.identifier .. " - " .. msg.iButton .. " - " .. msg.buttonIdentifier .. " - " .. msg.sender:GetName().name)			
	-- player has picked a destination, display the correct message box
	if msg.iButton ~= -1 then
		local newMap = tonumber(stripStr(self, msg.buttonIdentifier, "zoneID_"))	
		local strText = ""
		
		if not newMap then return end
		
		if newMap == 1200 then
			strText = "UI_TRAVEL_TO_NS" 
		else
			strText = "UI_TRAVEL_TO_NEXUS_TOWER"
		end	
		
		self:SetVar("teleportString", strText)
		self:SetVar("transferZoneID", newMap)
		
		msg.sender:DisplayMessageBox{bShow = true, identifier = "TransferBox", callbackClient = self, text = strText}
	else
		-- player canceled so terminate interaction
        msg.sender:TerminateInteraction{type = "fromInteraction", ObjIDTerminator = self}
	end	
end 

function stripStr(self, String, pat)
	return string.sub(String, string.len(pat)+1)
end 
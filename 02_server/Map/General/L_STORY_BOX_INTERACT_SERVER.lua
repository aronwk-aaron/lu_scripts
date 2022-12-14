--------------------------------------------------------------
-- Generic Story Box Interaction script
-- server script, sets a player flag for the player reading the story plaque

-- created by brandi.. 10/21/10 - pulled set flag off the client script
--------------------------------------------------------------


function onUse(self,msg)
	local player = msg.user
	local possessor = msg.user:GetPossessor().possessorID
	-- make sure we get the actual player, since we are using this ID to reroute the event below
	if possessor:Exists() and possessor:GetID() ~= player:GetID() then
		player = possessor
	end
	if player:Exists() then
		-- check to see if there is a valid achievement mission set in HF config data, then UpdateMissionTask if needed.
		if self:GetVar('storyText') then    
			local boxFlag = self:GetVar('altFlagID') or (10000 + LEVEL:GetCurrentZoneID() + tonumber(string.sub(self:GetVar('storyText'), -2))) 
			
			if (player:GetFlag{iFlagID = boxFlag}.bFlag == false) then
				player:SetFlag{iFlagID = boxFlag, bFlag = true}
				self:FireEventClientSide{ args = 'achieve', rerouteID = player }
			end	
		end
	end
end


--------------------------------------------------------------
-- Server script for scroll reader in Aura Mar
-- completes a missions for the player

-- created by brandi.. 10/28/10
-- updated mrb... 12/15/10 -- change onuse to onmessageboxrespond
--------------------------------------------------------------

----------------------------------------------
-- sent when the object story box is closed;
-- this can be done by hitting the x, esc or enter
----------------------------------------------
function onMessageBoxRespond(self, msg)
	-- player got to the last page so update the missions
	if msg.identifier == "story_end" then
		local player = msg.sender
		
		if not player:Exists() then return end
		
		-- if the player is on the mission to read the scrolls, complete the mission
		if player:GetMissionState{missionID = 969}.missionState == 2 then
			if player:GetInvItemCount{ iObjTemplate = 12318}.itemCount >= 10 then
				player:RemoveItemFromInventory{iObjTemplate = 12318, iStackCount = 10 }
			end
			
			player:UpdateMissionTask{taskType = "complete", value = 969, value2 = 1, target = self}
		end	 
	end
end 
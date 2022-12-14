--------------------------------------------------------------
-- server side script for the Cole in the monastery
-- if the player action emotes near him while wearing a mask

-- created by Brandi... 6/17/11
--------------------------------------------------------------


require('02_server/Map/njhub/L_NPC_MISSION_SPINJITZU_SERVER')

-- list of all action and more action emotes
local validEmotes 	= {393}
local maskLOT 		= 14499
local emoteMission 	= 1818


--------------------------------------------------------------
-- someone emoted at cole
--------------------------------------------------------------
function onEmoteReceived(self,msg)
	-- parse through all the valid emotes to wake the guard
    for k,emote in ipairs(validEmotes) do
		-- the emote a player did matches an emote in the valid list
		if msg.emoteID == emote then

			local player = msg.senderID
			local playerHelmet = player:GetEquippedItemInfo{slot = "hair"}.lotID
			if not playerHelmet then return end
			if playerHelmet == maskLOT then
				-- update the achievement for the player
				player:UpdateMissionTask{taskType = "complete", value = emoteMission, value2 = 1, target = self}
			end

			break
		end
    end
end

--------------------------------------------------------------
-- complete the mission to scare Cole
--------------------------------------------------------------
function onMissionDialogueOK(self,msg)
	
	local MissionState = msg.iMissionState
	local player = msg.responder
	
	-- if the player is turning in the mission to scare cole
	if msg.missionID == 1818 and MissionState == 4 then
	
		if player:GetInvItemCount{ iObjTemplate = 14499}.itemCount >= 1 then
			-- take the non deletable mask, and give them a deletable version
			player:RemoveItemFromInventory{iObjTemplate = 14499, itemCount = 1}
		end
		
		player:AddItemToInventory{iObjTemplate = 16644, itemCount = 1, bMailItemsIfInvFull = true, showFlyingLoot = false }
		
	end
	spinMissionDialogueOK(self,msg)
	
end
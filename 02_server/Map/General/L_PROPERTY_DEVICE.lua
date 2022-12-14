--------------------------------------------------------------

-- L_PROPERTY_DEVICE.lua

-- Server side Doctor Overbuild Property Device Script
-- Completes a mission when the player builds this device on a property
-- created dcross ... 4/18/11
-- updated mrb... 5/10/11 - updated fx id
--------------------------------------------------------------

local PropertyMissionID = 1291

function onStartup(self)
    GAMEOBJ:GetZoneControlID():FireEvent{senderID=self, args="CheckForPropertyOwner"}
end

----------------------------------------------
-- Check to see if the quickbuild is built upon a property
----------------------------------------------
function onRebuildComplete(self, msg)
	local player = msg.userID
	local propertyOwnerID = self:GetNetworkVar("PropertyOwnerID") or false

	if player:GetMissionState{missionID = PropertyMissionID}.missionState == 2 then
		if propertyOwnerID then -- checking to see if the current level matches our list of property levels
			self:PlayFXEffect{effectID = 641, effectType = "create", name = "callhome"}
			player:UpdateMissionTask{taskType = "complete", value = PropertyMissionID, value2 = 1, target = self}
		end
	end
end

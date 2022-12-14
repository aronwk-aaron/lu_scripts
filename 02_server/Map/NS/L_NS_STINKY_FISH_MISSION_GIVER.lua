--------------------------------------------------------------
-- Server side script giving stinky fish
-- Created mrb... 6/13/11
--------------------------------------------------------------

-- Associate inventory items to dispense on keyed mission ID values.
local MissionItemTable = {[1897] = {item = 6885, num = 5}}

----------------------------------------------
-- Catch and parse dialogue acceptance messages
----------------------------------------------
function onMissionDialogueOK(self, msg)     
    local player = msg.responder
    local missionID = msg.missionID
    
    if MissionItemTable[missionID] then    
        local itemMissionState = msg.iMissionState

        -- Adds/Removes mission associated items to the player's inventory
        -- based on the itemMissionState
		if itemMissionState == 1 or itemMissionState == 9 then
			-- Player has accepted item mission, add necessary items
			player:AddItemToInventory{iObjTemplate = MissionItemTable[missionID].item, itemCount = MissionItemTable[missionID].num, bMailItemsIfInvFull = true}
		end
    end
end 
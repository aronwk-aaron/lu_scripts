--------------------------------------------------------------
-- Server side script for the Wishing Well
-- Created mrb... 6/7/11
--------------------------------------------------------------

-- Associate inventory items to dispense on keyed mission ID values.
local MissionItemTable = {[1881] = {14591}}

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
        for i, val in ipairs(MissionItemTable[missionID]) do
            if((itemMissionState == 1) or (itemMissionState == 9)) then
                -- Player has accepted item mission, add necessary items if they aren't there
                if(player:GetInvItemCount{iObjTemplate = val}.itemCount == 0) then
                    player:AddItemToInventory{iObjTemplate = val, itemCount = 1, bMailItemsIfInvFull = true}
                end
            
            elseif((itemMissionState == 4) or (itemMissionState == 12)) then
                -- Player has turned in the mission, remove necessary items
                player:RemoveItemFromInventory{iObjTemplate = val, itemCount = 1}
            end
        end
    end
end 
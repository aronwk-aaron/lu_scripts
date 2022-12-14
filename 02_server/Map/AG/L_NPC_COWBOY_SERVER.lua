--------------------------------------------------------------
-- Server side script for the Wishing Well
-- Created mrb... 6/7/11
-- updated abeechler ... 6/10/11 - Added refactored object visibility script functionality
--------------------------------------------------------------
require('02_server/Map/General/L_VIS_TOGGLE_NOTIFIER_SERVER')

-- Associate inventory items to dispense on keyed mission ID values.
local MissionItemTable = {[1880] = {14378}}

-- Table mapping mission IDs to spawner network names
local VisibilityMissionTable = {[1880] = {"PlungerGunTargets"}}

----------------------------------------------------------------
-- Catch object instantiation
----------------------------------------------------------------                   
function onStartup(self)

	setGameVariables(self, VisibilityMissionTable)
	
end 

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
    
    baseMissionDialogueOK(self, msg)
end 
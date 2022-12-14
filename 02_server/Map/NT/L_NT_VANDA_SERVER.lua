------------------------------------------------------------------------------
--server script that gives the required items when accepting Vanda Darkflame's spy missions


-- Dave Deleted it all 4-26-2011
--------------------------------------------------------------------------------
require('02_server/Map/NT/L_NT_BC_SUBMIT_SERVER')

-- Associate inventory items to dispense on keyed mission ID values.
local MissionItemTable = {[1183] = {12479, 12480, 12481}}

----------------------------------------------
-- Catch and parse dialogue acceptance messages
----------------------------------------------
function onMissionDialogueOK(self, msg)  
    
    local player = msg.responder
    local missionID = msg.missionID
    
    if(MissionItemTable[missionID]) then

        -- Removes mission associated items from the player's inventory
        -- based on the mission completed state
        for i, val in ipairs(MissionItemTable[missionID]) do
            if(msg.bIsComplete) then
                -- Player has turned in the mission, remove necessary items
                player:RemoveItemFromInventory{iObjTemplate = val, itemCount = 1}
            end
        end
    end
    
    baseMissionDialogueOK(self, msg) 
end

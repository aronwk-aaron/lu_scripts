--------------------------------------------------------------

-- L_NPC_EPSILON_SERVER.lua

-- Server side script for Epsilon Starcracker, AG NPC
-- created abeechler - 6/10/11
--------------------------------------------------------------
require('ai/AG/L_AG_SENTINEL_GUARD')

local nexusMisID = 1851	        -- Finish this mission to join Nexus Force, initiating a celebration
local celebrationID = 22        -- Joined Nexus Force celebration ID

----------------------------------------------
-- Catch and parse dialogue acceptance messages
----------------------------------------------
function onMissionDialogueOK(self, msg)
    -- Confirm player existence     
    local player = msg.responder
    if not player:Exists() then return end
    
    local missionID = msg.missionID
    
    if((missionID == nexusMisID) and (msg.bIsComplete)) then
        -- We are turning in the mission required to join Nexus Force
        -- Start the celebration!
        player:StartCelebrationEffect{rerouteID = player, celebrationID = celebrationID}
    
    end
    
end 
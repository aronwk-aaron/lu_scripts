--------------------------------------------------------------

-- L_NT_BC_SUBMIT_SERVER.lua

-- This script is for ending the breadcrumb missions when the player gets to their destination.
-- created abeechler ... 4/4/10 - Breadcrumb script refactor

--------------------------------------------------------------

local ResetMissionsTable = {[999] = {1335},
                            [1002] = {1355},
                            [1006] = {1349},
                            [1009] = {1348},
                            [1379] = {1335},
                            [1380] = {1355},
                            [1378] = {1349},
                            [1377] = {1348}}
                                
function baseMissionDialogueOK(self, msg) 
    
    local player = msg.responder
    local missionID = msg.missionID
    
    if(ResetMissionsTable[missionID]) then
        -- Turns off mission associated breadcrumb paths
        for i, val in ipairs(ResetMissionsTable[missionID]) do
            player:ResetMissions{missionID = val}
        end
    end
end

function onMissionDialogueOK(self, msg) 
    baseMissionDialogueOK(self, msg) 
end

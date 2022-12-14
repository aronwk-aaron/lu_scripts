--------------------------------------------------------------

-- L_NT_NAOMI_BREADCRUMB_SERVER.lua

-- When the player accepts their first mission within the tower they are given a hidden mission that
-- has breadcrumbs lead them to their faction leader.
-- The second half of the script complete missions auto complete repeatable missions that just display the breadcrumbs that
-- lead to other faction leaders incase they are lost.
-- Updated abeechler ... 4/4/10 - refactored scripts for Naomi simplification

--------------------------------------------------------------
                           
local CompleteBCMissionTable = {[1377] = {1378, 1379, 1380, 1349, 1335, 1355},
                                [1378] = {1377, 1379, 1380, 1348, 1335, 1355},
                                [1379] = {1377, 1378, 1380, 1348, 1349, 1355},
                                [1380] = {1377, 1378, 1379, 1348, 1349, 1335}}

local MatchingBCTable = {[1377] = 1348,
                         [1378] = 1349,
                         [1379] = 1335,
                         [1380] = 1355}
                                
-- 1377: SENTINEL
    -- 1348: hidden breadcrumb
-- 1378: ASSEMBLY
    -- 1349: hidden breadcrumb
-- 1379: VENTURE
    -- 1335: hidden breadcrumb
-- 1380: PARADOX
    -- 1355: hidden breadcrumb

function onMissionDialogueOK(self, msg) 

	local player = msg.responder
	local missionID = msg.missionID
	
	-- We don't care if this is not a breadcrumb mission
	if not MatchingBCTable[missionID] then return end
	
	-- We add the breadcrumb mission so the player can see them
	player:AddMission{ missionID = MatchingBCTable[missionID] }
	
	local missionState = msg.iMissionState
        
    if((CompleteBCMissionTable[missionID]) and (missionState == 1 or missionState == 9)) then
        -- Resets missions so that only the desired breadcrumbs are on
        for i, val in ipairs(CompleteBCMissionTable[missionID]) do
            player:ResetMissions{missionID = val}
        end
    end

end

--------------------------------------------------------------

-- L_NT_VENTURESPEEDPAD_SERVER.lua

-- Handles processing of Venture Speed-Pad events
-- including player skill casts and mission updatess
-- updated abeechler ... 3/31/11 - refactored scripts and simplified functionality

--------------------------------------------------------------

local speedPadSkillID = 927                                 -- The Venture Speed-Pad skill buff
local missionsToUpdate = {1047, 1330, 1331, 1332}	        -- These are the missionID's to update when the teleporter is used

function onCollisionPhantom(self, msg)
    -- Obtain a reference to the player that touched us
    local player = msg.senderID
	
	-- Cast the selected skill on the player
	player:CastSkill{skillID = speedPadSkillID}
	
	-- Update the missions for the user			
	for k, missionID in ipairs(missionsToUpdate) do
		-- Update the task
		player:UpdateMissionTask{target = self, value = missionID, value2 = 1, taskType = "complete"}
	end
end

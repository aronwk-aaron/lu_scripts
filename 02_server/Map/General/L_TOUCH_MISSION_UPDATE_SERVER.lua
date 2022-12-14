--------------------------------------------------------------

-- L_TOUCH_MISSION_UPDATE_SERVER.lua

-- Server side script for touch events submitting missions
-- created abeechler - 7/12/11
--------------------------------------------------------------

local defaultUpdateID = 1732        -- Escape the Space Ship mission

function onCollisionPhantom(self, msg) 
    -- Obtain the mission ID to update
    local updateMissionID = self:GetVar("TouchCompleteID") or defaultUpdateID
    -- Obtain the touch object and confirm it is an existing player
    local player = msg.objectID
	if not player:Exists() then return end
	
	-- Determine the mission state progress
	local missionState = player:GetMissionState{missionID = updateMissionID}.missionState
	
	if((missionState == 2) or (missionState == 10)) then
	    -- Update the task
        player:UpdateMissionTask{target = self, value = updateMissionID, value2 = 1, taskType = "complete"}
    end
end

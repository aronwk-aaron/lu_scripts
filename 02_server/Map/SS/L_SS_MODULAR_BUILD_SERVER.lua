--------------------------------------------------------------
--This script is on the rocket module build area in the spaceship.
-- It checks if the player completed the rocket build and completes the mission
--
-- created mrb... 5/20/11 
--------------------------------------------------------------
local missionNum = 1732 -- mission on mardolf to build a rocket with a certain rocket part

-- The player exits the modular build
function onModularBuildExit(self, msg)
    -- has the player completed a rocket?
    if msg.bCompleted then
		local player = msg.playerID
		
		-- is the player on the mission to build a rocket
		if player:GetMissionState{missionID = missionNum}.missionState == 2 then 
			player:UpdateMissionTask{taskType = "complete", value = missionNum, value2 = 1, target = self}
		end
	end
end 
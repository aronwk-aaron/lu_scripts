--------------------------------------------------------------
-- Server Script for all grow flowers

-- edited brandi 10/25/10... added player check, put achievements in table at the top that can easily be added too
--			or taken away from, added a check for a variable that can be set in HF for missions
-- edited pml 11/9/10... added a second mission variable to handle 2 missions on a single flower. In the future, 
--          if needed, we should change the mission variable to a list that can support many missions.
--------------------------------------------------------------

--***************************************************
-- TO ADD A MISSION SPECIFIC FLOWER
-- the ID of the mission needs to be added to the config data in Happy Flower on the flower
-- missionID  1:####
--****************************************************

-- table of achievements for watering flowers
local achievements = { 143, 152, 153, 1409, 1507, 1544, 1581, 1845 }
-- time the flowers will stay bloomed and alive
local flowerAlive = 6 

-- catches when a skill is cast on the flowers
function onSkillEventFired( self, msg )
	local player = msg.casterID
	if not player:Exists() then return end
	-- check to see if the flower is already blooming, keeps the player from spamming one flower
    if not self:GetNetworkVar("blooming") then
		-- checks what cast a skill on the flower
        if msg.wsHandle == "waterspray" or msg.wsHandle == "shovelgrow" then
			-- lets the server script know that the flower is blooming, and tells all client scripts so all players can see the flower bloom
            self:SetNetworkVar("blooming", true)
			-- kill the flower after a time, annoying arbitary number, but it works
			local bloomTimer = self:GetAnimationTime{animationID = "bloom"}.time
			bloomTimer = bloomTimer + flowerAlive -- time of bloom animation plus the time the flower should stay alive
            GAMEOBJ:GetTimer():AddTimerWithCancel( bloomTimer, "FlowerDie", self )
        
            -- allows the loot to be distributed for the player
            self:AddActivityUser{userID = player}
            self:DistributeActivityRewards{userID = player, bAutoAddCurrency = false, bAutoAddItems = false}
		    self:RemoveActivityUser{userID = player}
        	
        	-- Update Achievements
			for k,v in ipairs(achievements) do
				player:UpdateMissionTask {taskType = "complete", value = v, value2 = 1, target = self}
			end
        	
        	-- if there is a mission for this flower, the ID of the mission needs to be added to the config data in Happy Flower
        	-- missionID  1:####
			local mission = self:GetVar("missionID")
			if mission then
				if player:GetMissionState{missionID = mission}.missionState == 2 then
					player:UpdateMissionTask{taskType = "complete", value = mission, value2 = 1, target = self}
				end
			end
			-- if there is a second mission for this flower, the ID of the mission needs to be added to the config data in Happy Flower
        	-- missionID2  1:####
			local mission2 = self:GetVar("missionID2")
			if mission2 then
				if player:GetMissionState{missionID = mission2}.missionState == 2 then
					player:UpdateMissionTask{taskType = "complete", value = mission2, value2 = 1, target = self}
				end
			end
        end
    end

end


function onTimerDone (self, msg)
	-- when the timer is done, kill the flower
    if msg.name == "FlowerDie" then
        self:RequestDie{}
    end
end

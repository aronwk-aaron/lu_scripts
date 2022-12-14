--------------------------------------------------------------
--  server script on a trigger in FV to prototype Brick Fury shooting horsemen that have been lured into his range
--  

-- created Brandi... 2/19/10
-- updated Steve... 5/14/10  - added achievement update for 854
-- updated Brandi... 11/4/10 - fixed a bug where the blank player table wasnt actually clearing out
-- updated by brandi... 4/28/11 - added a table of missions to update and deleted all the put players in a table 
--                                    and take them, with a new message, it isnt needed
--------------------------------------------------------------

local missions = {854, 738, 1432, 1530, 1567, 1604}

function onFireEvent(self,msg)

	-- Fire event from scripts\ai\FV\L_ACT_HORSEMEN_1.lua
	if msg.args == "HorsemanDeath" then
		for k,player in ipairs(self:GetObjectsInPhysicsBounds().objects) do
			--print("update missions for "..player:GetName().name)
			for k,missionID in ipairs(missions) do
				player:UpdateMissionTask{taskType = "complete", value = missionID, value2 = 1, target = self}
			end
				
			
		end
	end
	
end


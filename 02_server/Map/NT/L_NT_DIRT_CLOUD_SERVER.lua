--------------------------------------------------------------
-- server side script on the dirt clouds in NT
--
-- created by Brandi - 4/1/11... need to add daily missions when they get created
--------------------------------------------------------------

-- table to find the mission ID based on the spawner network name
local missions = {
					["Dirt_Clouds_Sent"] = {1333,1253}, -- mission to clean up the sentinel area
					["Dirt_Clouds_Assem"] = {1333,1276}, -- mission to clean up the Assembly area
					["Dirt_Clouds_Para"] = {1333,1277},  -- mission to clean up Paradox area
                    ["Dirt_Clouds_Halls"] = {1333,1283}  -- mission to clean up the halls
                 }

-- when the cloud first loads, set cloud to on
function onStartup(self,msg)
	self:SetVar("CloudOn", true)
end

-- when a skill hits the cloud
function onSkillEventFired( self, msg )
	-- if the skill isnt isnt the soap sprayer, exit out of the script
    if not msg.wsHandle == "soapspray" then return end
    -- if the cloud is ready off, exit out of the script
	if not self:GetVar("CloudOn") then return end
	-- get the spawner network name that this cloud is on
	local mySpawner = self:GetStoredConfigData().configData.spawner_name
	-- get the missions assicated with the spawner network
	local myMis = missions[mySpawner] or false
	-- exit out of the script if there's no missions
	if not myMis then return end
	local player = msg.casterID
	-- parse through the missions
	for k,missionID in ipairs(myMis) do 
		-- check to see if the player is on that mission
		player:UpdateMissionTask{taskType = "complete", value = missionID, value2 = 1, target = self}
	end
	-- set the cloud to off
	self:SetVar("CloudOn",false)
	-- kill the cloud
	self:RequestDie{killType = "VIOLENT"}
end
				
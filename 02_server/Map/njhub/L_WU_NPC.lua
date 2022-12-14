--------------------------------------------------------------
-- server side script on Wu
-- this script resets the hidden achievements for collecting the dragon emblems
-- 
-- created by brandi... 7/26/11
--------------------------------------------------------------

require('02_server/Map/AM/L_TEMPLE_SKILL_VOLUME')

-- daily mission to collect the dragon emblems
local minidragonsMisID = 2040
-- hidden achievement to collect the dragon emblems
local minidragonsAchieveIDs = {2064,2065,2066,2067}


function onMissionDialogueOK(self,msg)

	local misDiaID = msg.missionID
	
	-- get the player
	local player = msg.responder
	
	if (misDiaID == minidragonsMisID) and (msg.iMissionState == 4 or msg.iMissionState == 12) then
	
		player:SetFlag{iFlagID = 2099, bFlag = true}
		
		local chest = self:GetObjectsInGroup{ group = "DragonEmblemChest", ignoreSpawners = true }.objects
		-- tell the arm to the play the platform animation, which is just the arm laying there but with bouncer
		for k,obj in ipairs(chest) do
			if obj:Exists() then
				obj:NotifyClientObject{name = "showChest", param1 = 1, paramObj = player, rerouteID = player }
				break
			end
		end
		
		GAMEOBJ:GetTimer():AddTimerWithCancel(5, "turnMinidragonsOff", self)
		return
		
	end

	-- get out if the mission isnt being offered to the player
	if not (msg.iMissionState == 1) and not (msg.iMissionState == 9) then return end
	


	-- make sure the dragon emblem mission is the one the player took
	if minidragonsMisID == misDiaID then
		
		
		-- for all the dragon emblem achievements, reset the achievement and add it back to the player
		-- have to added it back because achievements only get added to the player on map load
		for k,achieveID in ipairs(minidragonsAchieveIDs) do
			player:ResetMissions{missionID = achieveID}
			player:AddMission{missionID = achieveID}
		end
		
		player:SetFlag{iFlagID = 2099, bFlag = false}
		
		local DragonChest = self:GetObjectsInGroup{ group = "DragonEmblemChest", ignoreSpawners = true }.objects
		-- tell the arm to the play the platform animation, which is just the arm laying there but with bouncer
		for k,obj in ipairs(DragonChest) do
			if obj:Exists() then
				obj:NotifyClientObject{name = "showChest", param1 = 0, paramObj = player, rerouteID = player }
				break
			end
		end
	end
	
end

function onTimerDone(self,msg)

	
	if msg.name == "turnMinidragonsOff" then
	
		local minidragons = self:GetObjectsInGroup{ group = "Minidragons", ignoreSpawners = true }.objects
		-- tell the arm to the play the platform animation, which is just the arm laying there but with bouncer
		for k,obj in ipairs(minidragons) do
			if obj:Exists() then
				--obj:NotifyClientObject{name = showChest, paramObj = player, rerouteID = player }
				obj:StopFXEffect{name = "on" }
			end
		end
				
	end	
end


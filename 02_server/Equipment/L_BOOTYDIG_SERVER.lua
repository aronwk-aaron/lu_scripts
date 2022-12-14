--------------------------------------------------------------

-- L_BOOTYDIG_SERVER.lua

-- Server side Booty Dig Script
-- Completes a mission when the player spawns this object on property
-- created dcross ... 6/3/11
-- fixed by mbermann ... 6/6/11
--------------------------------------------------------------

local PropertyMissionID = 1881
local BootyFlag = 1110

--register for property messages and store parent info
function onStartup(self)
	GAMEOBJ:GetZoneControlID():FireEvent{senderID=self, args="CheckForPropertyOwner"}

end


function onFireEventServerSide(self, msg)	
	local propertyOwnerID = self:GetNetworkVar("PropertyOwnerID")
		
	if msg.args == "ChestReady" then
		-- client started chest open animation and thinks the player is on the mission and on a property
	
		-- double check the player is actually on a property
		if propertyOwnerID == 0 then
			self:RequestDie{killType = "SILENT"}
		end
	elseif msg.args == "ChestOpened" then
		-- clients chest has opened, time to shine the god light and complete the mission
		local player = self:GetParentObj().objIDParent
		if not player:Exists() then
			return 
		end
		local playerID = player:GetID()
		local missionstate = player:GetMissionState{missionID = PropertyMissionID}.missionState
		
		-- don't complete the mission if the player is on thier own property
		if playerID ~= propertyOwnerID then
			-- double check the player is eligible to complete the mission
			if  missionstate == 2 or missionstate == 10 then
			    -- make sure we haven't dug up the treasure from this same property already this instance.
			    -- booty flag is a session flag that is set the first time the mission task is completed on a property visit
			    if not player:GetFlag{iFlagID = BootyFlag}.bFlag then 
				    player:UpdateMissionTask{taskType = "complete", value = PropertyMissionID, value2 = 1, target = self}
				    self:PlayFXEffect{effectID = 7730, effectType = "cast", name = "bootyshine"}
				    self:DropItems{iLootMatrixID = 231, owner = player, sourceObj = self}
				    self:DropCurrency{iAmount  = 75, owner = player}
				    player:SetFlag{iFlagID = BootyFlag, bFlag = true }
		        end
			end
		end
	elseif msg.args == "ChestDead" then
		-- chest is ready to die
		self:RequestDie{killerID = player, lootOwnerID = player}
	end
end




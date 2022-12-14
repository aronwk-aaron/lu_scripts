--------------------------------------------------------------
-- server side script to on the darkitect reveal to set the player stats down
-- 
-- created brandi... 11/9/10
-- Adjusted to be used in FV and NT by Ray.... 12/16/10
--------------------------------------------------------------

require('o_mis') --added required lua script for Split function

--------------------------------------------------------------
-- when the player completes the mission
--------------------------------------------------------------
function Darkitect(self,player)
	-- get the player
	-- start a timer to drop the stats 
	GAMEOBJ:GetTimer():AddTimerWithCancel( 20, "HealthDrain_"..player:GetID(), self )
	-- notify the client to start the reveal
	self:NotifyClientObject{name = "reveal", paramObj = player, rerouteID = player }
end

--------------------------------------------------------------
-- when the player completes the mission
--------------------------------------------------------------
function onTimerDone(self,msg)
	--Spliting the message name back into the timers name and the player's ID
	local var = split(msg.name, "_") 
	local player = '' 
	
	-- if theres a player ID, convert it back to a GAMEOBJ
	if var[2] then
		player = GAMEOBJ:GetObjectByID(var[2]) 
	end
	--Check to see if the player still exists
	if not player:Exists() then   
		return 
	end
	
	-- set the players stats down
	if var[1] ==  "HealthDrain" then
		player:SetArmor{armor = 0}
		player:SetHealth{health = 1}
		player:SetImagination{imagination = 0}
	
		if player:GetMissionState{missionID = 1295}.missionState == 2 then --if statement to check if the player is on the right mission
			player:SetFlag{iFlagID = 1911, bFlag = true} -- set player flag to the variable
		end
	end
end


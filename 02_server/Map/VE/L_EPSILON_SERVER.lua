--------------------------------------------------------------
-- Server script for on Epsolion in the venture explorer battle instance

-- created by brandi.. 11/10/10
-- updated brandi.. 11/12/10 - to acount for all the different missions
-------------------------------------------------------------- 

--------------------------------------------------------------
-- when a player accepts the console mission from MG
--------------------------------------------------------------
function onMissionDialogueOK(self,msg)
	local player = msg.responder
	-- check that it is the correct mission and that the player just accepted it
	if (msg.missionID == 1220 and msg.iMissionState == 1) 
				or (msg.missionID == 1225 and (msg.iMissionState == 1 or msg.iMissionState == 9)) then
		-- for loop go from numbers 0 - 9, which match up with the numbers on the consoles, and the last digit of the player flags
		for i = 0,9 do
			--create the flag number
			local flag = 1010 + i
			-- set the flag to false
			player:SetFlag{iFlagID = flag, bFlag = false}
		end
		-- add a timer to update the console so the flag has time to be set before the consoles check it
		GAMEOBJ:GetTimer():AddTimerWithCancel( 3, "updatepicktype",self )
	end
	
end

--------------------------------------------------------------
-- when the timer is done, set the update the picktype
--------------------------------------------------------------
function onTimerDone(self,msg)
	if msg.name == "updatepicktype" then
		-- get all the consoles
		local consoles = self:GetObjectsInGroup{group = "Consoles", ignoreSpawners = true}.objects
		-- in each console tell it to update the picktype
		for k,v in ipairs(consoles) do
			v:NotifyClientObject()
		end
	end
end
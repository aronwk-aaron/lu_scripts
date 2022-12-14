----------------------------------------
-- Server side script on the npc who offers the rescue the prisioners daily
--
-- created by brandi... 6/28/11
-- updated by nfoster.. 8/17/11
----------------------------------------

local CageMissionID = 2039
local CageMissionFlagStart = 2020
local NumMissionFlags = 6

function onUse(self,msg)
		
	local player = msg.user
	local stateMsg = player:GetMissionState{missionID = CageMissionID, cooldownInfoRequested = true}

	-- We don't care about this mission unless its available
	if ( stateMsg.missionState ~= 1 ) and ( stateMsg.missionState ~= 9 ) then return end

	if stateMsg.cooldownFinished then

        local bFlagSet = player:GetFlag{iFlagID = (CageMissionFlagStart + 1) }.bFlag
        
        -- If any of the flags has already been unset then no need to do it again
        if not bFlagSet then return end
		
        for i = 1,NumMissionFlags do
			-- create the player flag number
			local flagNum = CageMissionFlagStart + i
			-- set player flag to true
			--print("changing flag "..flagNum)
			player:SetFlag{iFlagID = flagNum, bFlag = false}
		end
	end

end
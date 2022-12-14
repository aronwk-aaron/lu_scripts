--------------------------------------------------------------
-- Completes the hidden achievement to send an ingame mail to 
-- the player so they can complete the missions.
--
-- created mrb... 5/17/11
--------------------------------------------------------------

local mailMission = 1728	-- mission to get the item out of your mailbox
local mailAchivement = 1729	-- hidden achievement that sends the player mail

function onMissionDialogueOK(self, msg)
	-- if we're not on the right mission do nothing
	if msg.missionID ~= mailMission then return end

	if msg.iMissionState == 1 then
		-- complete the achievment
		msg.responder:UpdateMissionTask{taskType = "complete", value = mailAchivement, value2 = 1, target = self}
	elseif msg.bIsComplete then 
		-- tell the client to do give the npc the staff and do the animations
		self:NotifyClientObject{name = "switch", rerouteID = msg.responder}
	end
end 

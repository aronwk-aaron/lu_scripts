--------------------------------------------------------------
-- server side script to on the darkitect reveal to set the player stats down
-- 
-- created brandi... 11/9/10
-- Updated by Ray... 12/17/10 to make it a centralized celebration
--------------------------------------------------------------

require('02_server/Map/General/L_DARKITECT_REVEAL_SERVER') --added required lua script for Split function

--------------------------------------------------------------
-- when the player completes the mission
--------------------------------------------------------------
function onMissionDialogueOK(self, msg)
	-- scroll mission on wong
	if msg.missionID == 734 and msg.iMissionState == 4 then
		Darkitect(self,msg.responder)
	end
end

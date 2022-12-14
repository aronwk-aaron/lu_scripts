--------------------------------------------------------------
-- server side script to on the darkitect reveal to set the player stats down
-- 
-- created brandi... 11/9/10
--------------------------------------------------------------

require('02_server/Map/General/L_DARKITECT_REVEAL_SERVER') --added required lua script for Split function

--------------------------------------------------------------
-- when the player completes the mission
--------------------------------------------------------------
function onUse(self, msg)
	Darkitect(self,msg.user)
	msg.user:UpdateMissionTask{taskType = "complete", value = 1344, value2 = 1, target = self}
end


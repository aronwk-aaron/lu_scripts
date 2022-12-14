----------------------------------------
-- Server side script on the ice moving platform for the multiplayer puzzle in the ice attic
--
-- created by brandi... 6/16/11
----------------------------------------

require('02_server/Map/General/L_BASE_SWITCH_ACTIVATED_SERVER')

function notifyObjectActivated(self,button,msg)
	switchNotifyObjectActivated(self,button,msg)
	self:GoToWaypoint{iPathIndex = 1}
end


function notifyObjectDeactivated(self,button,msg)
	switchNotifyObjectDeactivated(self,button,msg)
	self:GoToWaypoint{iPathIndex = 0}
end
--------------------------------------------------------------
-- Server side interact loot spawner script on the imagination shrines, uses a script that requires
-- scripts\02_client\Map\General\L_SET_INTERACT_WITH_VAR_CHECK.lua for client side script
-- 
-- created by brandi... 6/13/11
--------------------------------------------------------------


require('02_server/Map/General/L_BASE_INTERACT_DROP_LOOT_SERVER')

local defaultCooldownTime = 5

function onCheckUseRequirements(self, msg)
	if self:GetRebuildState{}.iState == 2 then
		return baseCheckUseRequirements(self, msg)
	end
end



function onUse(self, msg)  
	if self:GetRebuildState{}.iState == 2 then
		baseUse(self, msg)
	end
end

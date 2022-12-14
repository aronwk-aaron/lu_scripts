--------------------------------------------------------------
-- Description:
--
-- Client script for Guild Master in the FV area
-- Lets client know the object can be interacted with
--
--------------------------------------------------------------


--------------------------------------------------------------
-- Handle this message to override pick type
--------------------------------------------------------------
function onGetOverridePickType(self, msg)
	msg.ePickType = 4
	return msg
end

function onClientUse(self,msg)
	msg.targetObject = 0
	local player = GAMEOBJ:GetControlledID()
	if not player:Exists() then return end
	
	UI:SendMessage("pushGameState", {{"state", "Reforging"}})
	player:HandleInteractionCamera{cameraTargetID = self, actionType = "ACTION_TYPE_ENABLE" }	
end


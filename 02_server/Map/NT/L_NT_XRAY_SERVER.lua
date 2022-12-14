--------------------------------------------------------------

-- L_NT_XRAY_SERVER.lua

-- Script attaching skill cast functionality
-- created abeechler ... 2/15/11

--------------------------------------------------------------

local xRaySkillID = 1220        	-- The ID of the skill cast by the XRay Machine to irradiate the Player

function onOffCollisionPhantom(self, msg)
	local player = msg.senderID
	
	-- Cast skill on player for xRay effect
	player:CastSkill{skillID = xRaySkillID}
end

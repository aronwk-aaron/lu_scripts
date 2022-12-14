--------------------------------------------------------------
-- L_AG_BUGSPRAYER.lua
-- Casts a skill when the rebuild is complete
-- Completes a mission when the player spawns this object on property
-- created dcross ... 6/6/11
--------------------------------------------------------------
local bugsprayskill = 1435

function onRebuildComplete(self,msg)
	local player = msg.userID:GetID()
	GAMEOBJ:GetTimer():AddTimerWithCancel( 1, player, self )
end

function onTimerDone (self, msg)
	local player = GAMEOBJ:GetObjectByID(msg.name) or 0
	
	self:CastSkill{skillID = bugsprayskill, player}
end

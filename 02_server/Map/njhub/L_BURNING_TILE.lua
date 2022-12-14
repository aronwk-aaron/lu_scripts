
--------------------------------------------------------------
-- Server side Script on the burning tiles in the monastery fire attic
-- 
-- created by brandi... 6/9/11
--------------------------------------------------------------


-- cast the skill on the player when they client says they collide with it
function onFireEventServerSide(self,msg)
	if msg.args == "PlayerEntered" then
		local player = msg.senderID 
		if player and player:Exists() then
			self:CastSkill{skillID = 726, optionalTargetID = player}
		end
	end
end
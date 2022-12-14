--------------------------------------------------------------
-- server side Script on the lightning balls in the lightning garden

-- created by brandi... 7/3/11
--------------------------------------------------------------


function onCollisionPhantom(self,msg)
		
	local myPos = self:GetPosition().pos
	local objPos = msg.objectID:GetPosition().pos		
	local newVec = {x = (objPos.x - myPos.x) * 2.5, y = 15, z = (objPos.z - myPos.z) * 2.5}
	
	-- do knockback on player, knocking them in the direction they came from
	msg.objectID:Knockback{vector = newVec, Caster = self, Originator = self}
	
	-- when a player collides, play a knockback fx
	self:PlayFXEffect{ name = "knockback" , effectType = "knockback" }	

end



--------------------------------------------------
-- Generic Knockback script onDeath
--
-- created 8/11/11 - mrb...
--------------------------------------------------

function onOnHit(self, msg)
	local hitNum = self:GetVar("numberOfHits") or 1
	
	if hitNum < 2 then
		self:SetVar("numberOfHits", hitNum+1)
		
		self:SetHealth{health = self:GetMaxHealth().health / 2}
		
		return
	end
	
	local player = msg.attacker
	
	if not player or not player:Exists() then
		player = self
	end
	
	local skill = self:GetSkills().skills[1]
	
	if skill then
		self:CastSkill{skillID = skill, optionalOriginatorID =  player}
	end
	
	self:PlayEmbeddedEffectOnAllClientsNearObject{ radius = 16.0, fromObjectID = self, effectName = "camshake" }
	self:RequestDie{killerID = player}
end

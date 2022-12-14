function onStartup(self,msg)
	self:SetProximityRadius{radius = 10, name="ChaseProx", collisionGroup = 8 }

end

function onProximityUpdate(self, msg)
	if not msg.name == "ChaseProx" then return end
	if msg.status == "ENTER"  then
		
		--self:CastSkill{skillID = 589}
		local myPos = self:GetPosition().pos
		local objPos = msg.objId:GetPosition().pos		
		local newVec = {x = (objPos.x - myPos.x) * 2.5, y = 15, z = (objPos.z - myPos.z) * 2.5}
		
		-- do knockback, fx and animation
		msg.objId:Knockback{vector = newVec, Caster = self, Originator = self}
	end
end

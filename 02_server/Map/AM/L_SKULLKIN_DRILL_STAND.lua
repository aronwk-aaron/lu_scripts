---------------------------------------------
-- Server side script on the skullkin drill platform
--
-- updated by mrb... 1/3/10 - changed radius height
---------------------------------------------	

-- notifications sent from the drill object
function onNotifyObject(self, msg)
	if msg.name == "activate" then
		-- set the stand to active
		self:SetVar("bActive", true)
		-- start the knockback prox radius
		self:SetProximityRadius{name = "knockback", radius = 5, height = 14, collisionGroup = 1, shapeType = "CYLINDER"}	
	elseif msg.name == "deactivate" then
		-- set the stand to inactive and clear the prox
		self:SetVar("bActive", false)
		self:ClearProximityRadius()
	end
end

function onProximityUpdate(self, msg)	
	-- do knockback if the player entered into the radius
	if msg.name == "knockback" then
		if msg.status == "ENTER" and self:GetVar("bActive") then
			-- vector math to find out the direction to knock the player back
			local myPos = self:GetPosition().pos
			local objPos = msg.objId:GetPosition().pos		
			local newVec = {x = (objPos.x - myPos.x) * 4.5, y = 15, z = (objPos.z - myPos.z) * 4.5}
			
			-- do knockback, fx and animation
			msg.objId:Knockback{vector = newVec, Caster = self, Originator = self}
			msg.objId:PlayFXEffect{name = "pushBack", effectID = 1378, effectType = "create"}
			msg.objId:PlayAnimation{ animationID = "knockback-recovery" }
		end
	end
end 
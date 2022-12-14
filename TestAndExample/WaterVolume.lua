function onCollisionPhantom(self, msg)

	msg.objectID:AddRunSpeedModifier{ uiModifier = 250, i64Caster = self }
	
	local currentVel = msg.objectID:GetLinearVelocity().linVelocity
	currentVel.x = currentVel.x * 0.5
	currentVel.z = currentVel.z * 0.5
	currentVel.y = currentVel.y * 0.2
	
	msg.objectID:SetLinearVelocity{ linVelocity = currentVel }
	
	msg.objectID:SetGravityScale{ scale = 0.6 }
	
	msg.objectID:SetAllowJumpWithoutSupport{ bAllow = true }
	
	msg.objectID:SetJumpHeightScale{ fScale = 0.5 }
	
	msg.objectID:SetVelocityResistance{ resistance = 0.4 } end

function onOffCollisionPhantom(self, msg)

    msg.objectID:RemoveRunSpeedModifier{ uiModifier = 250, i64Caster = self }
	
	msg.objectID:SetGravityScale{ scale = 1.0 }
	
	msg.objectID:SetAllowJumpWithoutSupport{ bAllow = false }
	
	msg.objectID:SetJumpHeightScale{ fScale = 1.0 }
	
	msg.objectID:SetVelocityResistance{ resistance = 0.0 }

end

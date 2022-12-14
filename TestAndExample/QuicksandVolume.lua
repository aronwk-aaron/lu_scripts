function onCollisionPhantom(self, msg)

	msg.objectID:AddRunSpeedModifier{ uiModifier = 100, i64Caster = self }
	
	local vel = {x = 0, y = 0, z = 0}
	msg.objectID:SetLinearVelocity{ linVelocity = vel }
	
	msg.objectID:SetGravityScale{ scale = 0.03 }
	
	msg.objectID:SetAllowJumpWithoutSupport{ bAllow = true }
	
	msg.objectID:SetJumpHeightScale{ fScale = 0.7 }
	
	msg.objectID:SetVelocityResistance{ resistance = 0.9 }
	
end


function onOffCollisionPhantom(self, msg)

    msg.objectID:RemoveRunSpeedModifier{ uiModifier = 100, i64Caster = self }
	
	msg.objectID:SetGravityScale{ scale = 1.0 }
	
	msg.objectID:SetAllowJumpWithoutSupport{ bAllow = false }
	
	msg.objectID:SetJumpHeightScale{ fScale = 1.0 }
	
	msg.objectID:SetVelocityResistance{ resistance = 0.0 }
	
	local vel = {x = 0, y = 6, z = 0}
	msg.objectID:ModifyLinearVelocity{ linVelocity = vel }

end
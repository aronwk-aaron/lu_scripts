--------------------------------------------------------------

-- L_FRICTION_VOLUME_SERVER.lua

-- Attached to editor desired volumes allowing for HF config data 
-- manipulation of friction values.
-- created abeechler ... 2/15/11

--------------------------------------------------------------

local defaultFrictionAmt = 1.5		-- Volume default friction amount

function onStartup(self, msg)
	-- Initialize the desired friction parameters
	local frictionAmount = self:GetVar("FrictionAmt") or defaultFrictionAmt
	
	-- Set the initialized friction volume effects
	self:SetPhysicsVolumeEffect{EffectType = 'FRICTION', amount = frictionAmount}
end

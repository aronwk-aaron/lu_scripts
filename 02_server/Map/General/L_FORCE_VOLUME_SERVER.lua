--------------------------------------------------------------

-- L_FORCE_VOLUME_SERVER.lua

-- Attached to editor desired volumes allowing for HF config data 
-- manipulation of force values.
-- created abeechler ... 2/15/11

--------------------------------------------------------------

local defaultForceAmt = 0		-- Volume default push amount
local defaultForceX = 0			-- Push default vector x val
local defaultForceY = 0			-- Push default vector y val
local defaultForceZ = 0			-- Push default vector z val

function onStartup(self, msg)
	-- Initialize the desired force parameters
	local forceAmount = self:GetVar("ForceAmt") or defaultForceAmt
	local forceX = self:GetVar("ForceX") or defaultForceX
	local forceY = self:GetVar("ForceY") or defaultForceY
	local forceZ = self:GetVar("ForceZ") or defaultForceZ
	
	-- Set the initialized force volume effects
	self:SetPhysicsVolumeEffect{EffectType = 'PUSH', amount = forceAmount, direction = {x = forceX, y = forceY, z = forceZ}}
end

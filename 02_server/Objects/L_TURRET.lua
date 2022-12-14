-- L_TURRET.lua
-- attach to basic turret NPCs/enemies to make them not be movable and immune to knockbacks, stuns and pull to points
-- Added: MEdwards 1/18/11
require('02_server/Enemy/General/L_SUSPEND_LUA_AI')
function onStartup(self) 
    -- turn off lua ai
    suspendLuaAI(self)
	self:SetGravityScale{scale = 0.0}
	self:SetStunImmunity{StateChangeType = "PUSH", bImmuneToStunAttack = true, bImmuneToInterrupt = true} -- Make immune to stuns
	self:SetStatusImmunity{ StateChangeType = "PUSH", bImmuneToPullToPoint = true, bImmuneToKnockback = true } -- Make immune to move/teleport behaviors
end

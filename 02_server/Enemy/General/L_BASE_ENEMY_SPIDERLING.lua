----------------------------------------
-- Base Server side script for Spiderling type enemies
--
-- Created by abeechler... 2/1/11 - moved script and updated
----------------------------------------
require('02_server/Enemy/General/L_SUSPEND_LUA_AI')

function onStartup(self) 
	baseStartup(self)
end

function baseStartup(self) 
    self:SetStunImmunity{StateChangeType = "PUSH", bImmuneToStunAttack = true, bImmuneToInterrupt = true, bImmuneToStunMove = true, bImmuneToStunTurn = true, bImmuneToStunUseItem = true, bImmuneToStunEquip = true, bImmuneToStunInteract = true} -- Make immune to stuns
    self:SetStatusImmunity{ StateChangeType = "PUSH", bImmuneToPullToPoint = true, bImmuneToKnockback = true } -- Make immune to knockbacks and pulls
    
    -- turn off lua ai
    suspendLuaAI(self)

end

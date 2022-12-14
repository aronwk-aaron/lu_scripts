----------------------------------------
-- Server side Survival spider script
--
-- updated mrb... 10/20/10 - cleaned up script, added setnetworkvar
----------------------------------------
require('02_server/Enemy/Waves/L_BASE_WAVES_GENERIC_ENEMY_SERVER')

iPoints = 300 -- global constant for the enemies point value

function onStartup(self)
    baseWavesStartup(self, nil)
    
     -- Make immune to move/teleport behaviors, Immunities and stuns
    self:SetStunImmunity{StateChangeType = "PUSH", bImmuneToStunAttack = true, bImmuneToInterrupt = true, bImmuneToStunMove = true, bImmuneToStunTurn = true, bImmuneToStunUseItem = true, bImmuneToStunEquip = true, bImmuneToStunInteract = true} -- Make immune to stuns
    self:SetStatusImmunity{ StateChangeType = "PUSH", bImmuneToPullToPoint = true, bImmuneToKnockback = true } -- Make immune to knockbacks and pulls
end 

function onGetActivityPoints(self, msg)
    return baseWavesGetActivityPoints(self, msg, nil)
end 

function onDie(self, msg)
    baseWavesDie(self, msg, nil)
end 
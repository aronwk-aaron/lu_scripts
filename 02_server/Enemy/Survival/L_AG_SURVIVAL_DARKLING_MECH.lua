----------------------------------------
-- Server side Survival darkling mech script
--
-- updated mrb... 10/20/10 - cleaned up script, added setnetworkvar
----------------------------------------
require('02_server/Enemy/Waves/L_BASE_WAVES_GENERIC_ENEMY_SERVER')

iPoints = 200 -- global constant for the enemies point value

function onStartup(self)
    baseWavesStartup(self, nil)
    
    -- Have to set the faction to 4 for mechs
    self:SetFaction{faction = 4}
end 

function onGetActivityPoints(self, msg)
    return baseWavesGetActivityPoints(self, msg, nil)
end 

function onDie(self, msg)
    baseWavesDie(self, msg, nil)
end 
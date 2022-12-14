----------------------------------------
-- Server side Survival strombie script
--
-- updated mrb... 10/20/10 - cleaned up script, added setnetworkvar
----------------------------------------
require('02_server/Enemy/Waves/L_BASE_WAVES_GENERIC_ENEMY_SERVER')

iPoints = 100 -- global constant for the enemies point value

function onStartup(self)
    baseWavesStartup(self, nil)
end 

function onGetActivityPoints(self, msg)
    return baseWavesGetActivityPoints(self, msg, nil)
end

function onDie(self, msg)
    baseWavesDie(self, msg, nil)
end

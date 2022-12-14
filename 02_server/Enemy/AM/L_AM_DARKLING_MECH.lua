----------------------------------------
-- Server side script for Mech enemies in AM
--
-- created mrb... 1/7/11 - moved script and updated
----------------------------------------
require('02_server/Enemy/General/L_BASE_ENEMY_MECH')

local qbTurretLOT = 13171

function onStartup(self) 
	-- LOT for the turret that spawns on mech death.
	self:SetVar("qbTurretLOT", qbTurretLOT)
	
	baseStartup(self)
end 

function onDie(self, msg)
	baseDie(self, msg)
end

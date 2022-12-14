----------------------------------------
-- Server side script for Mech enemies in the VE instance
--
-- created abeechler... 3/18/11 - moved script and updated
----------------------------------------
require('02_server/Enemy/General/L_BASE_ENEMY_MECH')

local qbTurretLOT = 8432

function onStartup(self) 
	-- LOT for the turret that spawns on mech death.
	self:SetVar("qbTurretLOT", qbTurretLOT)
	
	baseStartup(self)
end 

function onDie(self, msg)
	baseDie(self, msg)
end

---------------------------------------------
-- main script for the static shield generator
-- used old script and broke it up to work for either a qb sheild generator or a static one
--
-- created by brandi... 1/13/11
---------------------------------------------

require('02_server/Map/AM/L_SHIELD_GENERATOR_BASE')

--------------------------------------------------------------
-- on startup, set proximities
--------------------------------------------------------------
function onStartup(self,msg)
	baseStartup(self,msg)
	StartShield( self, msg )
end

function onChildLoaded(self, msg)
	baseChildLoaded(self, msg)
end


--------------------------------------------------------------
-- when something enters the proximity
--------------------------------------------------------------
function onProximityUpdate(self,msg)
	-- enemies entered the shields radius
    if msg.status == "ENTER" and msg.name == "shield" then
		EnemyEnteredShield(self,msg)
	end
end

--------------------------------------------------------------
-- when the shield smashs, stop the activity timer
--------------------------------------------------------------
function onDie(self, msg)
    baseDie(self, msg)
end



function onActivityTimerUpdate(self, msg)
	baseActivityTimerUpdate(self, msg)
end

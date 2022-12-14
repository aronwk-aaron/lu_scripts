----------------------------------------
-- Server script for the AM dragons
--
-- created mrb... 1/7/11
-- updated mrb... 3/10/11 - removed chest var
----------------------------------------
require('02_server/Enemy/General/L_BASE_ENEMY_DRAGON')

local DragonSmashingGolem = 8340 

function onStartup(self) 
	-- set constant varibales for the dragon
	self:SetVar("DragonSmashingGolem", DragonSmashingGolem)
	
	baseStartup(self)
end

--check if armor is depleted then start timer and make it immune to damage
function onHitOrHealResult(self, msg)	
	baseHitOrHealResult(self, msg)
end

-- Check timer to revive
function onTimerDone(self, msg)
	baseTimerDone(self, msg)
end

--Store the QB so we can use it to smash the Dragon
function onChildLoaded( self,msg )
	baseChildLoaded(self, msg)
end

--Notify the Dragon when the rebuild state changes
function onNotifyObject( self, msg )
	baseNotifyObject(self, msg)
end

function onDie(self,msg)
	baseDie(self, msg)
end  
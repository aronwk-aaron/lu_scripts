----------------------------------------
-- Generic Server side script that casts 
-- Script to make the Skeleton Engineer self destruct when it gets low on life
--
-- created mrb... 1/7/11 - moved script and updated
----------------------------------------
require('02_server/Enemy/General/L_ENEMY_NJ_BUFF')

function onStartup(self)
	baseStartup(self)
end 

--check if armor is depleted then start timer and make it immune to damage
function onOnHit(self, msg)
    if self:GetHealth().health < 12 and not self:GetVar("injured") then
		self:SetVar("injured", true)
		self:CastSkill{skillID = 953}
		-- set a 4.25 timer to kill self
		GAMEOBJ:GetTimer():AddTimerWithCancel( 4.5 , "SelfDestruct", self )
    end
end

--After timer, kill self
function onTimerDone(self, msg)
    if msg.name == "SelfDestruct" then
        self:RequestDie()
    end 
end

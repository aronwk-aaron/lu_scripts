--------------------------------------------------------------

-- L_COUNTDOWN_DESTROY_AI.lua

-- Allows AI to establish a suicide countdown behavior useful
-- for situations when AI are created from other objects 
-- (statues, eggs, etc.)
-- Created abeechler... 2/3/11
-- updated by brandi... 6/7/11 - added a check to see if the enemy is aggroing on the player before just killing it
-- updated by brandi... 8/25/11 - if the enemy is aggroed on the player when it should die, it starts a timer to see if the player is actually fighting that enemy
-------------------------------------------------------------
require('02_server/Enemy/General/L_SUSPEND_LUA_AI')

local defaultSuicideTimer = 60

function onStartup(self) 
	countdownStartup(self)
end

function countdownStartup(self)
    
    -- Add a 'suicide timer' that removes a spawned entity after a requested (or default)
    -- period of time
    local suicideTimer = self:GetVar("suicideTimer") or defaultSuicideTimer
    if suicideTimer and suicideTimer ~= 0 then
        GAMEOBJ:GetTimer():AddTimerWithCancel(suicideTimer, "Dead", self)
    end
    
end

-- the enemy was hit
function onOnHit(self,msg)
	if not self:GetVar("ShouldBeDead") then return end
	
	-- if the enemy should be dead, but was hit, then the player is still fighting it
	GAMEOBJ:GetTimer():CancelTimer("IsBeingAttacked", self)
	GAMEOBJ:GetTimer():AddTimerWithCancel(5, "Dead", self)
	
end


function onTimerDone(self, msg)
	baseTimerDone(self, msg)
end

function baseTimerDone(self, msg)
    
    if msg.name == "Dead" then
    
		-- set enemy should be dead to true
		self:SetVar("ShouldBeDead",true)
		-- enemy is busy aggroing a player
		if self:GetVar("Busy") then
			GAMEOBJ:GetTimer():AddTimerWithCancel(5, "IsBeingAttacked", self)
		-- kill the enemy
		else
			self:RequestDie()
		end
		
	-- the enemy wasnt attacked during the timer, kill it
	elseif msg.name == "IsBeingAttacked" then
	
		self:RequestDie()
		
    end
    
end


function onNotifyCombatAIStateChange(self,msg)
    local State = msg.currentState
    
    if State == "DEAD" then return end
    
	if State == "AGGRO" then
		self:SetVar("Busy",true)
	else
		self:SetVar("Busy",false)
		if self:GetVar("ShouldBeDead") then
			self:RequestDie()
		end
	end
end
		

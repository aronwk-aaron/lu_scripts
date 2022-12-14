---------------------------------------------
-- this script is for property pushback
-- basically on interact the moving platform goes up, and when it reaches the top, it smashes itself
-- brandi 6/25/10
-- updated by brandi... 11/18/10 - added timer for the smash effect and moved file location in the folder structure
--------------------------------------------

local EFFECT_DELAY = 5		-- the amount of time before the flashing effect is started after the QB is completed
local DIE_DELAY = 5			-- the amount of time the siren will flash before being destroyed

function onStartup(self)
	-- stop the platform from moving up the path until it is interacted with
	self:StopPathing()
end

function onUse(self,msg)
	-- check to make sure the rebuild is done
	if self:GetRebuildState{}.iState == 2 then
		-- go up the platform
		self:GoToWaypoint{iPathIndex = 1}   
	end
end

function onArrivedAtDesiredWaypoint(self, msg)	
	-- set a time to smash QB
	GAMEOBJ:GetTimer():AddTimerWithCancel( EFFECT_DELAY , "PlayEffect", self )
end

function onTimerDone(self, msg)
	if msg.name == "SmashPlatform" then
		--smash the platform
		self:RequestDie{killerID = self, killType = "VIOLENT"}
	elseif msg.name == "PlayEffect" then    
		self:SetNetworkVar("startEffect", DIE_DELAY)
        -- at the top of the path, wait then smash itself
		GAMEOBJ:GetTimer():AddTimerWithCancel(DIE_DELAY, "SmashPlatform", self )
	end
end
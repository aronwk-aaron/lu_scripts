--------------------------------------------------------------

-- L_BSPINNERS_VOL.lua

-- Extended kill counter object that manages the Blade Spinners 
-- room events.

-- Created abeechler... 9/28/11 

-------------------------------------------------------------

require('02_server/Map/General/L_KILL_COUNTER_UTIL')

local targetNetwork = "BladeSpinners_IRail"     -- The spawner network to activate on room exit events
local targetCine = "PopUpBlades_IRail_QBSpawn"  -- A cinematic to play on room exit events
local spawnDelay = 2                            -- Wait delay for targetNetwork activation

----------------------------------------------------------------
-- Enable an object extending kill counter functionality to 
-- process limit events
----------------------------------------------------------------
function processEvent(self, bUpperLimitReached)

    if bUpperLimitReached then
        -- Obtain hooks to the player objects currently in the volume
        local playersInMe = self:GetObjectsInPhysicsBounds().objects
        
        -- Iterate through the players in the volume
        for i, player in ipairs(playersInMe) do
            -- Play the target cinematic
            player:PlayCinematic{pathName = targetCine, rerouteID = player} 
        end

	    -- After a delay, spawn the Ice Rail QB
	    GAMEOBJ:GetTimer():AddTimerWithCancel(spawnDelay, "SpawnIceRail", self)
    end
    
end

----------------------------------------------------------------
-- a set timer is done.. ding
----------------------------------------------------------------
function onTimerDone(self,msg)

	if msg.name == "SpawnIceRail" then
		-- Obtain a hook to the target spawner
		local spawner = LEVEL:GetSpawnerByName(targetNetwork)

		-- If we have a spawner, actiavte it
		if(spawner) then
		    spawner:SpawnerActivate()
		end
	end
	
end

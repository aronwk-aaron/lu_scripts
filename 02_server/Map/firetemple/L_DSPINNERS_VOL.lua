--------------------------------------------------------------

-- L_DSPINNERS_VOL.lua

-- Extended kill counter object that manages the Dart Spinners 
-- room events.

-- Created abeechler... 9/29/11 

-------------------------------------------------------------

require('02_server/Map/General/L_KILL_COUNTER_UTIL')

local targetNetwork = "DartSpinEarthRail"    -- The spawner network to activate on room exit events
local targetCine = "3Tier_EarthRailSpawn"    -- A cinematic to play on room exit events
local spawnDelay = 2                         -- Wait delay for targetNetwork activation

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

	    -- After a delay, spawn the Earth Rail QB
	    GAMEOBJ:GetTimer():AddTimerWithCancel(spawnDelay, "SpawnEarthRail", self)
    end
    
end

----------------------------------------------------------------
-- a set timer is done.. ding
----------------------------------------------------------------
function onTimerDone(self,msg)

	if msg.name == "SpawnEarthRail" then
		-- Obtain a hook to the target spawner
		local spawner = LEVEL:GetSpawnerByName(targetNetwork)

		-- If we have a spawner, actiavte it
		if(spawner) then
		    spawner:SpawnerActivate()
		end
	end
	
end

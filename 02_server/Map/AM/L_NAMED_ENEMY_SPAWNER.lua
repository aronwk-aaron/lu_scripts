--------------------------------------------------------------
-- Server side Zone Script for aura mar, handles the randomized spawning of named enemies
-- 
-- created by brandi... 11/22/10
-- updated by brandi... 1/18/11 - lowered the max respawn time by one hour to 30 minutes
-- updated by abeechler ... 8/31/11 - named enemies spawn every 7.5 to 15 minutes
--------------------------------------------------------------

-- table of named enemies				
local NamedMobs = {
					11988, -- Ronin
					11984, -- Spiderling
					12654, -- Horsemen
					11986, -- Admiral
					11983, -- Mech
					11982, -- Stromling
					11985  -- Pirate
				  }
					
			
--------------------------------------------------------------
-- custom function to get the named enemy to spawn and use the zone script to actually spawn it
--------------------------------------------------------------
function SpawnNamedEnemy(self)
	-- get a random enemy from the table
	local enemy = NamedMobs[math.random(1,#NamedMobs)]
	-- use the zone script custom functon to spawn the enemy
	setSpawnerNetwork(self, "Named_Enemies", 1, enemy)
	-- print("Named Enemy that is spawning"..enemy)

end


--------------------------------------------------------------
-- custom function - called from the zone script when an enemy on the named spawner network dies
--------------------------------------------------------------
function NamedEnemyDeath(self,other,msg)
	-- create the delay, between 7.5 and 15 minutes - math.random provides a number between 0 and 1, 
	-- add 1 to make sure it is more than 1, and multiply by 450, which is 7.5 minutes in seconds
	local spawnDelay = math.floor((math.random() + 1 ) * 450)
	-- start a timer for the delay between named enemies
	GAMEOBJ:GetTimer():AddTimerWithCancel(spawnDelay, "SpawnNewEnemy", self)
	-- print("Time until the next named Enemy"..spawnDelay)
end

--------------------------------------------------------------
--  when the timer is done, spawn another named enemy
--------------------------------------------------------------
function NamedTimerDone(self,msg)
	if msg.name == "SpawnNewEnemy" then
		SpawnNamedEnemy(self)
	end
end
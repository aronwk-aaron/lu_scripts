------------------------------------------------------
-- Spawns a skeleton from the coffin

-- created brandi... 6/7/11 
------------------------------------------------------

require('02_server/Map/General/L_SPAWN_ENEMY_FROM_SMASHABLE')

local SmashableVariables = {
							enemyLOTtoSpawn = 14024,	-- lot of the enemy to spawn
							wakeUpFX = { {[9017] = "cast"},{[9018] = "burst"} },	--fx to play when the smashable is about to hatch
							burstFX = {  }			-- fx to play when the smashable breaks and the enemy spawns
						   }
--  all below are for the enemy that spawns
local EnemyVariables = {
							serverScript = "scripts/02_server/Map/njhub/L_COFFIN_ENEMIES.lua",				
						}
--------------------------------------------------------------
-- if a script is attached, call SetVariables
--------------------------------------------------------------
function onStartup(self,msg)
	self:CastSkill{skillID = 1127}
	SetVariables(self,SmashableVariables,EnemyVariables)
	baseStartup(self,msg)
end
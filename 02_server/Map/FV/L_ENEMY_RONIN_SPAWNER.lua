------------------------------------------------------
-- Spawns a ronin from the statue

-- updated brandi... 6/7/11 -- rewrote to make more generic
------------------------------------------------------

require('02_server/Map/General/L_SPAWN_ENEMY_FROM_SMASHABLE')

local SmashableVariables = {
							enemyLOTtoSpawn = 7815,	-- lot of the enemy to spawn
						   }
--  all below are for the enemy that spawns
local EnemyVariables = {
							serverScript = "scripts/02_server/Enemy/General/L_COUNTDOWN_DESTROY_AI.lua",	
							tetherRadius = 50,
							softtetherRadius = 45,
							aggroRadius = 40,
							wanderRadius = 30,		
						}

--------------------------------------------------------------
-- if a script is attached, call SetVariables
--------------------------------------------------------------
function onStartup(self,msg)
	SetVariables(self,SmashableVariables,EnemyVariables)
	baseStartup(self,msg)
end
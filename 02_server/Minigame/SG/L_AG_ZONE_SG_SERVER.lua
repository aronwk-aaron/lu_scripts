--------------------------------------------------------------
-- Includes
--------------------------------------------------------------
require('o_mis')
require('o_ShootingGallery')
require('ai/MINIGAME/SG_GF/L_GF_SG')

-- @TODO: Add Path Changing on waypoint, need to get [Closest Waypoint on New Path]
--        Also need [Number of Waypoints on Path]
-- @TODO: Optimize

--------------------------------------------------------------
-- Locals and Constants
CONSTANTS = {}
TABLES = {}
LOCALS = {}
--------------------------------------------------------------

-- cannon constants
CONSTANTS["CANNON_TEMPLATEID"] = 7583
CONSTANTS["IMPACT_SKILLID"] = 396

CONSTANTS["PROJECTILE_TEMPLATEID"] = 7833
CONSTANTS["CANNON_PLAYER_OFFSETx"] = 0
CONSTANTS["CANNON_PLAYER_OFFSETy"] = 0
CONSTANTS["CANNON_PLAYER_OFFSETz"] = -3
CONSTANTS["Reward_Model_Matrix"] = 157

CONSTANTS["CANNON_VELOCITY"] = 220.0

CONSTANTS["CANNON_MIN_DISTANCE"] = 100.0
CONSTANTS["CANNON_REFIRE_RATE"] = 400 --800

CONSTANTS["CANNON_BARREL_OFFSETx"] = 0
CONSTANTS["CANNON_BARREL_OFFSETy"] = 0
CONSTANTS["CANNON_BARREL_OFFSETz"] = 0

CONSTANTS["CANNON_SUPER_CHARGE"] = 7849 
CONSTANTS["CANNON_PROJECTILE"] = 1822
CONSTANTS["CANNON_SUPERCHARGE_SKILL"] = 398
CONSTANTS["CANNON_SKILL"] = 397 

CONSTANTS["CANNON_TIMEOUT"] = -1
CONSTANTS["CANNON_FOV"] = 58.6
CONSTANTS["CANNON_USE_LEADERBOARDS"] = true
CONSTANTS["STREAK_MOD"] = 2

-- for Animations
TABLES["VALID_ACTORS"] = {3109, 3110, 3111, 3112, 3125, 3126}
TABLES["STREAK_BONUS"] = {1,2,5,10}
TABLES["VALID_EFFECTS"] = {3122}

-- Super Charger  is charged for this amount of time
CONSTANTS["ChargedTime"] = 10
-- The amount of points needed to supper charge
CONSTANTS["ChargedPoints"] = 25000
-- Modle reward grp name
CONSTANTS["Reward_Model_GrpName"] = "QBRewardGroup"
-- Activity ID 
CONSTANTS["ActivityID"] = 7583
-- Activity ID 

-- Reward Score and Loot Matrix\
-- 1
CONSTANTS["Score_Reward_1"] = 50000
CONSTANTS["Score_LootMatrix_1"] = 279
-- 2
CONSTANTS["Score_Reward_2"] = 100000
CONSTANTS["Score_LootMatrix_2"] = 280
-- 3
CONSTANTS["Score_Reward_3"] = 200000
CONSTANTS["Score_LootMatrix_3"] = 281
-- 4
CONSTANTS["Score_Reward_4"] = 400000
CONSTANTS["Score_LootMatrix_4"] = 282
-- 5
CONSTANTS["Score_Reward_5"] = 800000
CONSTANTS["Score_LootMatrix_5"] = 283


--------------------------------------------------------------
-- Wave Data
waves = {}
PLAYER_SCORE = {}
--------------------------------------------------------------
-- Syntax:     [Time]   [Text to Show Player]
--------------------------------------------------------------
AddWave(waves,	30.0,	"Wave;One"   )		
AddWave(waves,	30.0,	"Wave;Two" )
AddWave(waves,	30.0,	"Wave;Three" )
-- wave constants
CONSTANTS["NUM_WAVES"] = #waves
CONSTANTS["FIRST_WAVE_START_TIME"] = 4.0
CONSTANTS["IN_BETWEEN_WAVE_PAUSE"] = 7.0

--------------------------------------------------------------
-- Spawn Data
spawns = {}
SPAWN_DATA = {}
--------------------------------------------------------------
-- Startup do not chaged!!!
--------------------------------------------------------------
function onStartup(self)
	-- set game state
	LOCALS["GameStarted"] = false
	LOCALS["CurSpawnNum"] = 0
	LOCALS["ThisWave"] = 0
	LOCALS["GameScore"] = 0
	LOCALS["GameTime"] = 0
	LOCALS["NumShots"] = 0
	LOCALS["NumKills"] = 0
	LOCALS["MaxStreak"] = 0
	--self:SetVar("StreakBonus",0)
	self:SetVar("StopCharge", false )
	self:SetVar("NumberOfCharges", 0 ) 
	wave1Score = 0
	wave2Score = 0
	wave3Score = 0	
    self:SetVar("WaveStatus", true)
    --self:SetVar("StreakBonus", 0)
    self:SetVar("CONSTANTS", CONSTANTS)
    self:SetVar("timelimit", waves[1].timeLimit)
    totalscore = 0
end

----------------------------------------------------------------------------------------------------------------------------
-- Do not Chage -- 
----------------------------------------------------------------------------------------------------------------------------

function onPlayerLoaded(self, msg)
    if (msg) then
        mainPlayerLoaded(self, msg)
    end
end

function onObjectLoaded(self, msg)
    if (msg) then
		mainObjectLoaded(self, msg)
    end
end

function onNotifyObject(self, msg)
    if( msg) then
        mainNotifyObject(self, msg)
    end
end

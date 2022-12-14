--------------------------------------------------------------
-- Server side Zone Script for area volumes in aura mar, handles the randomized spawning
-- 
-- created by mrb... 11/5/10
-- edited by brandi.. 12/13/10 - split the single script into a base script and one script for each section
-- edited by brandi.. 1/17/11 - change spawn groups to try to get more mechs
--------------------------------------------------------------

require('02_server/Map/AM/L_BASE_RANDOM_SPAWNER')

-- local constants
local mobDeathResetNumber = 20	-- how many mobs need to die in a section before a new load is picked
local zoneName = "str"
-- number of players in the area to change the spawn numbers on
local changeNum = 15
--============================================================

-- table of variables of the object LOT's to spawn in
local mobs = -- variableName = enemyLOT
{   
    stromb = 11212, 
	mech = 11213,  
	spider = 11214, 
	pirate = 11215, 
	admiral = 11216, 
	gorilla = 11217,
	ronin = 11218,
	horse = 11219,
	dragon = 11220,
}

local sets =  
-- FORMAT: 
--{-- Load # -------------------------- **
--      {LOT = mobs.Var, num = #toSpawn, name = "stringEndingSpawnerName"}, -- keep repeating in the same format for each different spawnerNetwork in the load
--		iChance = ##, -- % to spawn
--},
-- 
-- sectionMultipliers = 	-- section multipliers, this is the reference of how many sections are in a zone and the spawn mulitplier
--	  {						-- there needs to be one of these for ever section in the zone
--		  secA = 1,		-- section reference for secA with a x1 multiplier
--		  secB = 1.2, 	-- section reference for secB with a x1.2 multiplier
--	  }

	{ 
		{-- ** Load 1 -------------------------- **
			{LOT = mobs.stromb, num = 4, name = "type1",},
			{LOT = mobs.pirate, num = 3, name = "type2",},
			{LOT = mobs.ronin, num = 3, name = "type3",},
			iChance = 45, -- % to spawn
		},
		{-- ** Load 2 -------------------------- **
			{LOT = mobs.stromb, num = 3, name = "type1",},
			{LOT = mobs.pirate, num = 3, name = "type2",},
			{LOT = mobs.mech, num = 3, name = "type3",},
			iChance = 20, -- % to spawn
		}, 
		{-- ** Load 3 -------------------------- **
			{LOT = mobs.stromb, num = 4, name = "type1",},
			{LOT = mobs.admiral, num = 2, name = "type2",},
			{LOT = mobs.spider, num = 1, name = "type3",},
			iChance = 10, -- % to spawn
		}, 
		{-- ** Load 4 -------------------------- **
			{LOT = mobs.mech, num = 3, name = "type1",},
			{LOT = mobs.spider, num = 1, name = "type2",},
			{LOT = mobs.stromb, num = 4, name = "type3",},
			iChance = 3, -- % to spawn
		},  
		{-- ** Load 5 -------------------------- **
			{LOT = mobs.horse, num = .8, name = "type1",},
			{LOT = mobs.ronin, num = 5, name = "type2",},
			{LOT = mobs.pirate, num = 2, name = "type3",},
			iChance = 1, -- % to spawn
		}, 
		{-- ** Load 6 -------------------------- **
			{LOT = mobs.gorilla, num = 1, name = "type1",},
			{LOT = mobs.pirate, num = 5, name = "type2",},
			{LOT = mobs.admiral, num = 2, name = "type3",},
			iChance = 1, -- % to spawn
		},
		{-- ** Load 7 -------------------------- **
			{LOT = mobs.admiral, num = 2, name = "type1",},
			{LOT = mobs.stromb, num = 4, name = "type2",},
			{LOT = mobs.ronin, num = 2, name = "type3",},
			iChance = 3, -- % to spawn
		}, 
		{-- ** Load 8 -------------------------- **
			{LOT = mobs.admiral, num = 3, name = "type1",},
			{LOT = mobs.gorilla, num = 1, name = "type2",},
			{LOT = mobs.horse, num = 1, name = "type3",},
			iChance = 1, -- % to spawn
		}, 
		{-- ** Load 9 -------------------------- **
			{LOT = mobs.ronin, num = 3, name = "type1",},
			{LOT = mobs.ronin, num = 3, name = "type2",},
			{LOT = mobs.ronin, num = 3, name = "type3",},
			iChance = 5, -- % to spawn
		}, 
		{-- ** Load 10 -------------------------- **
			{LOT = mobs.pirate, num = 4, name = "type1",},
			{LOT = mobs.pirate, num = 4, name = "type2",},
			{LOT = mobs.pirate, num = 4, name = "type3",},
			iChance = 1, -- % to spawn
		},
	}
	
local sectionMultipliers = -- section multipliers
		{
			secA = 1,
			secB = 1,
			secC = 1.2,
		}


-- Event Zone loads =======================================
-- these alternate zone loads will be used if the event is in progress
local eventsToCheck =
{
	-- FORMAT: 
	-- Zone: em_str_secA_type# -------------------------- 
	--{-- Load # -------------------------- **
	--    {LOT = mobs.Var, num = #toSpawn, name = "stringEndingSpawnerName"}, -- keep repeating in the same format for each different spawnerNetwork in the load
	--	  sectionMultipliers = 	-- section multipliers, this is the reference of how many sections are in a zone and the spawn mulitplier
	--	  {						-- there needs to be one of these for ever section in the zone
	--		  secA = 1,		-- section reference for secA with a x1 multiplier
	--		  secB = 1.2, 	-- section reference for secB with a x1.2 multiplier
	--	  }
	--},
	pirateDay = 
	{   	
		-- Zone: em_str_secA_type# -------------------------- 
		str = 	
		{
			{-- ** Load 1 -------------------------- **
				{LOT = mobs.pirate, num = 5, name = "type1",},
				{LOT = mobs.pirate, num = 5, name = "type2",},
				{LOT = mobs.pirate, num = 5, name = "type3",},
				iChance = 80, -- % to spawn
			}, 
			{-- ** Load 2 -------------------------- **
				{LOT = mobs.admiral, num = 5, name = "type1",},
				{LOT = mobs.admiral, num = 5, name = "type2",},
				{LOT = mobs.admiral, num = 5, name = "type3",},
				iChance = 20, -- % to spawn
			}, 
			sectionMultipliers = -- section multipliers
			{
				secA = 1,
				secB = 1,
				secC = 1.2,
			},
		},
		-- Zone: em_zip_secA_type# --------------------------
		zip = 	
		{ 
			{-- ** Load 1 -------------------------- **
				{LOT = mobs.pirate, num = 5, name = "type1",},
				{LOT = mobs.pirate, num = 5, name = "type2",},
				{LOT = mobs.pirate, num = 5, name = "type3",},
				iChance = 80, -- % to spawn
			}, 
			{-- ** Load 2 -------------------------- **
				{LOT = mobs.admiral, num = 5, name = "type1",},
				{LOT = mobs.admiral, num = 5, name = "type2",},
				{LOT = mobs.admiral, num = 5, name = "type3",},
				iChance = 20, -- % to spawn
			}, 
			sectionMultipliers = -- section multipliers
			{
				secA = 1,
				secB = 1,
			},
		},
	},
}



--========================================================s====

-- when the level starts up, start the spawners
function onStartup(self, msg)
	-- set variables on the base scripts
	setGameVariables(sets,eventsToCheck,zoneName,sectionMultipliers,changeNum,mobDeathResetNumber,mobs)
	-- start the base script
    baseStartup(self, msg)
end

-- when a player enters with the volume
function onCollisionPhantom(self,msg)
	baseCollisionPhantom(self,msg)
end

-- when a player leaves a volume
function onOffCollisionPhantom(self,msg)
	baseOffCollisionPhantom(self,msg)
end


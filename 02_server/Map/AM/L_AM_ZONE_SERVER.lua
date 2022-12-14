--------------------------------------------------------------
-- Server side Zone Script for aura mar, handles the randomized spawning
-- 
-- created by mrb... 11/5/10
--------------------------------------------------------------

-- local constants
local mobDeathResetNumber = 100	-- how many mobs need to die in a section before a new load is picked
local zonePrefix = "em"			-- start of the spanwer name string
local zoneNameConst = 2			-- Do Not Change: constant for the location of the zoneName when split(spawnerName, "_") is called
local sectionIDConst = 3		-- Do Not Change: constant for the location of the sectionID when split(spawnerName, "_") is called

--============================================================

require('02_server/Map/AM/L_NAMED_ENEMY_SPAWNER')

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

local zones =  
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
{   	
	-- Zone: em_str_secA_type1 -------------------------- 
	str =
	{ 
		{-- ** Load 1 -------------------------- **
			{LOT = mobs.stromb, num = 5, name = "type1",},
			{LOT = mobs.stromb, num = 5, name = "type2",},
			{LOT = mobs.stromb, num = 5, name = "type3",},
			iChance = 60, -- % to spawn
		},
		{-- ** Load 2 -------------------------- **
			{LOT = mobs.pirate, num = 5, name = "type1",},
			{LOT = mobs.pirate, num = 5, name = "type2",},
			{LOT = mobs.pirate, num = 5, name = "type3",},
			iChance = 20, -- % to spawn
		}, 
		{-- ** Load 3 -------------------------- **
			{LOT = mobs.ronin, num = 5, name = "type1",},
			{LOT = mobs.ronin, num = 5, name = "type2",},
			{LOT = mobs.ronin, num = 5, name = "type3",},
			iChance = 10, -- % to spawn
		}, 
		{-- ** Load 4 -------------------------- **
			{LOT = mobs.spider, num = 5, name = "type1",},
			{LOT = mobs.spider, num = 5, name = "type2",},
			{LOT = mobs.spider, num = 5, name = "type3",},
			iChance = 10, -- % to spawn
		},  
		sectionMultipliers = -- section multipliers
		{
			secA = 1,
			secB = 1,
			secC = 1.2,
		},
	},
	-- Zone: em_zip_secA_type1 --------------------------
	zip =
	{ 
		{-- ** Load 1 -------------------------- **
			{LOT = mobs.stromb, num = 2, name = "type1",},
			{LOT = mobs.stromb, num = 2, name = "type2",},
			{LOT = mobs.stromb, num = 2, name = "type3",},
			{LOT = mobs.stromb, num = 2, name = "type4",},
			iChance = 50, -- % to spawn
		},
		{-- ** Load 2 -------------------------- **
			{LOT = mobs.pirate, num = 2, name = "type1",},
			{LOT = mobs.pirate, num = 2, name = "type2",},
			{LOT = mobs.pirate, num = 2, name = "type3",},
			{LOT = mobs.pirate, num = 2, name = "type4",},
			iChance = 25, -- % to spawn
		}, 
		{-- ** Load 3 -------------------------- **
			{LOT = mobs.ronin, num = 2, name = "type1",},
			{LOT = mobs.ronin, num = 2, name = "type2",},
			{LOT = mobs.ronin, num = 2, name = "type3",},
			{LOT = mobs.ronin, num = 2, name = "type4",},
			iChance = 15, -- % to spawn
		}, 
		{-- ** Load 4 -------------------------- **
			{LOT = mobs.spider, num = 2, name = "type1",},
			{LOT = mobs.spider, num = 2, name = "type2",},
			{LOT = mobs.spider, num = 2, name = "type3",},
			{LOT = mobs.spider, num = 2, name = "type4",},
			iChance = 10, -- % to spawn
		},  
		sectionMultipliers = -- section multipliers
		{
			secA = 1,
			secB = 1,
		},
	},
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

--============================================================

-- print function that only works in an internal build
function debugPrint(self, text)	
	if self:GetVersioningInfo().bIsInternal then
		print(text)
	end
end

-- splits a string based on the pattern passed in
function split(str, pat)
   local t = {}
   
   -- splits a string based on the given pattern and returns a table
   string.gsub(str .. pat, "(.-)" .. pat, function(result) table.insert(t, result) end)
   
   return t
end   

function onStartup(self,msg)
	print("** This a Prototype Script attached to " .. self:GetName().name .. ". **")
    print("** This script needs to be completed by Brandi. **")
    print("** This file is located at scripts\02_server\Map\AM\L_AM_ZONE_SERVER.lua **")
end

function onZoneLoadedInfo(self, msg)
    math.randomseed( os.time() )
    -- check if an event is happening and set the zones table correctly
	checkEvents(self)
	-- set and activate the initial spawnerNetworks for the map
	spawnMapZones(self)

end

----------------------------------------------------------------
-- Custom function: checks holliday events and sets the zones table if one is valid
----------------------------------------------------------------
function checkEvents(self)
	-- loop through the eventsToCheck table, if the event is active than use the alternate zones table for that event.
	for event,eventZoneTable in pairs(eventsToCheck) do
		if self:GetHolidayEvent{eventToCheck = event}.isValid then
			-- we found a valid event so set the zones table and return
			zones = eventZoneTable
			
			return
		end
	end	
end

----------------------------------------------------------------
-- Custom function: Sets up all the sections in the map to spawn
----------------------------------------------------------------
function spawnMapZones(self)    
	-- loop through the zones and to spawn all of the sections in the map
    for zoneName,tLoads in pairs(zones) do		
		-- spawn the mobs on the spawners based on the sectionName
		for sectionID, iMultiplier in pairs(tLoads.sectionMultipliers) do
			local sectionName = zonePrefix .. "_" .. zoneName .. "_" .. sectionID
			
			-- spawn section
			spawnSection(self, sectionName, iMultiplier)
		end
    end
    
	-- spawn named enemy
	SpawnNamedEnemy(self)
    
    -- we have finished initializing the map so set bInit to true
    self:SetVar("bInit", true)
end

----------------------------------------------------------------
-- Custom function: Sets up a section in the map to spawn
----------------------------------------------------------------
function spawnSection(self, sectionName, iMultiplier)
	-- get a random load from the zones table based on the sectionName
	local spawnLoad = getRandomLoad(self, sectionName)
	
	-- if we dont find a load the return
	if not spawnLoad then return end
	
	-- loop through the spawn load and set and spawn each spawner network
	for k, spawnerData in ipairs(spawnLoad) do
		if spawnerData.name then
			-- get the number of mobs to maintain and adjust based on the multiplier, rounded down
			local spawnNum = math.floor(spawnerData.num * iMultiplier)
			-- concat the spawner network name
			local spawnerName = sectionName .. "_" .. spawnerData.name
			
			-- set up the spawner network
			setSpawnerNetwork(self, spawnerName, spawnNum, spawnerData.LOT)
		end
    end   
end

----------------------------------------------------------------
-- Custom function: Spawns mobs on a spawner network, Now...
----------------------------------------------------------------
function setSpawnerNetwork(self, spawnerName, spawnNum, spawnLOT)
	-- get the spawner object
    local spawner = LEVEL:GetSpawnerByName(spawnerName)
    
    -- if we have a spawner object lets set it up
    if spawner then
        -- set the LOT to spawn if it's sent to the function
        if spawnLOT then
            spawner:SpawnerSetSpawnTemplateID{iObjTemplate = spawnLOT}
        end
        
        -- set the number of LOT's to spawn if it's sent to the function
        if spawnNum then            
            spawner:SpawnerSetNumToMaintain{uiNum = spawnNum}
        end
        
        -- activate and reset the spawner network
        spawner:SpawnerActivate()
        spawner:SpawnerReset()
        
        -- if we are still initializing the map then set a Lua Notification for when a mob dies on this spawner network
        if not self:GetVar("bInit") then
			self:SendLuaNotificationRequest{requestTarget = spawner, messageName = "NotifySpawnerOfDeath"}
		end
    end
end

----------------------------------------------------------------
-- Custom function: Returns a random spawn set from the zones table or false
----------------------------------------------------------------
function getRandomLoad(self, sectionName)
	-- get the zoneName and sectioinID from the section name string
	local zoneInfo = split(sectionName, "_")	
	-- set the get the section load table from the zones table
	local sectionData = zones[zoneInfo[zoneNameConst]]
	-- set the variables for the random weight system
	local weightTable = {}
	local totalWeight = 0
	
	-- create a table based on the sectionData weights, incrementing the weights
	for k,load in ipairs(sectionData) do
		totalWeight = totalWeight + load.iChance
		table.insert(weightTable, totalWeight)		
	end
	
	-- get a random number based on the totalWeight and divide it by totalWeight
	local randWeight = math.random(0,totalWeight)
    
    -- loop through the section load table and find the right load to use based on the randWeight
	for k,weight in ipairs(weightTable) do
		if randWeight <= weight then
			local randLoad = zones[zoneInfo[zoneNameConst]][k]
			
			--debugPrint(self, '** Spawning: ' .. sectionName .. ' using: ' .. k)
			--debugPrint(self, "randWeight = " .. randWeight .. " -> weight = ".. weight)
			
			if randLoad then 
				return randLoad 
			end
		end
	end		    
    
    return false
end 

function notifyNotifySpawnerOfDeath(self, other, msg)
	-- message sent from an enemy's spawner network when it dies
	local spawnerName = other:GetStoredConfigData().configData.spawner_name
	
	-- if we dont have a spawner name then return
	if not spawnerName then return end
	
	if spawnerName == "Named_Enemies" then
		NamedEnemyDeath(self,other,msg)
		return
	end
	
	-- strip out the section name from the full spawner name
	local sectionName = string.sub(spawnerName, 1, -7)	
	-- get the mob death count for this section
	local mobDeathCount = self:GetVar("mobsDead_" .. sectionName) or 0
	
	mobDeathCount = mobDeathCount + 1
	
	--debugPrint(self, "NotifySpawnerOfDeath " .. msg.objectID:GetName().name .. " @ " .. tostring(spawnerName) .. " count = " .. mobDeathCount) 
	
	-- if we have met the mobDeathResetNumber then spawn this section with a new random load
	if mobDeathCount >= mobDeathResetNumber then
		mobDeathCount = 0
		
		-- split out the different parts of the sectionName to send to the spawnSection function
		local zoneInfo = split(sectionName, "_")
		
		spawnSection(self, sectionName, zones[zoneInfo[zoneNameConst]].sectionMultipliers[zoneInfo[sectionIDConst]])
	end	
	
	-- set the mobDeathCount
	self:SetVar("mobsDead_" .. sectionName, mobDeathCount)	
end 
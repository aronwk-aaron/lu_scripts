--------------------------------------------------------------
-- Server side base Script for aura mar, handles the randomized spawning
--
-- created by mrb... 11/5/10
-- edited by brandi.. 12/13/10 - split the single script into a base script and one script for each section
-- updated by abeechler ... 8/31/11 - added proper clamped network resets when attempting to pulse the named enemy spawner
--------------------------------------------------------------

require('02_server/Map/AM/L_NAMED_ENEMY_SPAWNER')

-- local constants
local mobDeathResetNumber = 0	-- how many mobs need to die in a section before a new load is picked
local zonePrefix = "em"			-- start of the spanwer name string
local zoneNameConst = 2			-- Do Not Change: constant for the location of the zoneName when split(spawnerName, "_") is called
local sectionIDConst = 3		-- Do Not Change: constant for the location of the sectionID when split(spawnerName, "_") is called
local zoneName = ""				-- zone name sent from volume script
local zones =  {}				-- sets of enemies sent from volume script
local eventsToCheck = {}		-- sets of event specific spawn sets of enemies sent from volume script
local sectionMultipliers = {}	-- section mulitpliers sent from volume script
local changeNum = 0				-- number of player in the volume to change the max spawn number sent from volume script
local mobs = {}
local respawnTime = 80			-- respawn timer on the enemies
--============================================================




--============================================================

function setGameVariables(passedsets, passedevents, passedzoneName,passedsectionMultipliers,passedchangeNum,passedmobDeathResetNumber,passedmobs)
	zones = passedsets
	eventsToCheck = passedevents
	zoneName = passedzoneName
	sectionMultipliers = passedsectionMultipliers
	changeNum = passedchangeNum
	mobDeathResetNumber = passedmobDeathResetNumber
	mobs = passedmobs
end

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

function baseStartup(self, msg)
	-- variable to keep track of the players in the volume
	self:SetVar("TotalPlayers", 0)
	-- variable to keep track of the state of enemies spawn, min for less spawned, max for more spawned
	self:SetVar("SpawnState", "min")
	-- variable for when the spawn number changed to set a delay so it doesnt keep spawning again
	self:SetVar("JustChanged", false)

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

	-- spawn the mobs on the spawners based on the sectionName
	for sectionID, iMultiplier in pairs(sectionMultipliers) do
		local sectionName = zonePrefix .. "_" .. zoneName .. "_" .. sectionID

		-- spawn section
		spawnSection(self, sectionName, iMultiplier)
	end

    -- the start area volume controls the Named enemy spawners
    if zoneName == "str" then
		-- spawn named enemy
		SpawnNamedEnemy(self)
    end

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

    -- check to see if the script is trying to spawn more than 1 gorilla, and dont let it
    if spawnLOT == 11217 and spawnNum > 1 then
			spawnNum = 1
	end

    -- if we have a spawner object lets set it up
    if spawner then
        -- set the LOT to spawn if it's sent to the function
        if spawnLOT then
            spawner:SpawnerSetSpawnTemplateID{iObjTemplate = spawnLOT}
            spawner:SpawnerSetRespawnTime{ fTime  = respawnTime }
        end

        -- set the number of LOT's to spawn if it's sent to the function
        if spawnNum then

            spawner:SpawnerSetNumToMaintain{uiNum = spawnNum}
            --print("FROM SCRIPT: the number set to spawn is "..spawnNum.." and the lot is "..spawnLOT.." and the number of nodes on the spawner is "..spawner:SpawnerGetNumNodes().uiNum.." on spawner network "..spawnerName.." the number set to maintain is "..spawner:SpawnerGetNumToMaintain().uiNum)
        end

        -- we are setting to pulse a spawner network with a clamped
        -- max spawn and need to reset it
	    if spawnerName == "Named_Enemies" then
		    spawner:SpawnerReset()
	    end

        spawner:SpawnerActivate()

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
	local sectionData = zones
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
			local randLoad = zones[k]

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

	-- if a named enemy dies, tell the named enemy script
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

		spawnSection(self, sectionName, sectionMultipliers[zoneInfo[sectionIDConst]])
	end

	-- set the mobDeathCount
	self:SetVar("mobsDead_" .. sectionName, mobDeathCount)
end

----------------------------------------------------------------------------------------------------

----------------------------------------------------------------
-- when a player enters the volume, add to the totalplayers
----------------------------------------------------------------
function baseCollisionPhantom(self,msg)


	-- set the player
	local player = msg.objectID
	-- make sure the player actually exists
	if player:Exists() and player:IsCharacter().isChar then

		-- get the number of players that were in the volume
		local TotalPlayers = table.maxn(self:GetObjectsInPhysicsBounds().objects)
		self:SetVar("TotalPlayers", TotalPlayers)
		--print("Player "..player:GetName().name.." ENTERED - TotalPlayers is "..TotalPlayers.." in volume "..self:GetName().name)

		-- check if players are now higher than the change number
		-- make sure the spawn rate wasnt just reset and that it is in the min amount spawned state
		if TotalPlayers >= changeNum and not self:GetVar("JustChanged") and self:GetVar("SpawnState") == "min" then
			-- go to the function to turn up the spawn numbers
			SpawnersUp(self)
		end
	end
end

----------------------------------------------------------------
-- when a player leaves the volume, subtract from the total players
----------------------------------------------------------------
function baseOffCollisionPhantom(self,msg)
	-- set the player
	local player = msg.objectID
	-- make sure the player actually exists
	if player:Exists() and player:IsCharacter().isChar then
		-- get the number of players that were in the volume
		local TotalPlayers = table.maxn(self:GetObjectsInPhysicsBounds().objects)

		-- set the number of players
		self:SetVar("TotalPlayers", TotalPlayers)
		--print("Player "..player:GetName().name.." EXITED - TotalPlayers is "..TotalPlayers.." in volume "..self:GetName().name)

		-- check if players are now lower than the change number
		-- make sure the spawn rate wasnt just reset and that it is in the max amount spawned state
		if TotalPlayers < changeNum and not self:GetVar("JustChanged") and self:GetVar("SpawnState") == "max" then
			-- go to the function to turn down the spawn numbers
			SpawnersDown(self)
		end
	end
end

----------------------------------------------------------------
-- custom function - turn the spawn numbers up
----------------------------------------------------------------
function SpawnersUp(self)
	--print("spawners ramp up")
	-- set the spawn state to max
	self:SetVar("SpawnState", "max")
	-- set the just changed state to true
	self:SetVar("JustChanged", true)
	-- make timer to maintain the change state
	GAMEOBJ:GetTimer():AddTimerWithCancel( 60, "StateChange", self )
	-- loop through the sections in the area
	for name,num in pairs(sectionMultipliers) do
		-- loop through the types in the spawn sets
		for i = 1,#zones[1] do
			-- create the spawner network name
			local spawnerName = zonePrefix .. "_" .. zoneName .. "_" .. name.."_type"..i
			-- use the spawner network name to find out how many enemies are spawned on the spawner network.
			local spawner = LEVEL:GetSpawnerByName(spawnerName)

			if spawner then
				local oldNum = spawner:SpawnerGetNumToMaintain().uiNum
				-- add one to the number ccurrently spawned
				if oldNum == 0 then return end
				local newNum = tonumber(oldNum) + 1

				if (newNum > spawner:SpawnerGetNumNodes().uiNum) then
					newNum = oldNum
					--print("%%%%%%%%%%%%%%% ALERT!!! SPAWN NUMBER HAD TO BE ADJUSTED %%%%%%%%%%%%%%%%%")
					--print(" new number is "..newNum.." and max is "..spawner:SpawnerGetNumNodes().uiNum)
				end

				setSpawnerNetwork(self, spawnerName, newNum)


			end
		end
	end
end

----------------------------------------------------------------
-- custom function - turn the spawn numbers down
----------------------------------------------------------------
function SpawnersDown(self)
	--print("spawners ramp down")
	-- set the spawn state to max
	self:SetVar("SpawnState", "min")
	-- set the just changed state to true
	self:SetVar("JustChanged", true)
	-- make timer to maintain the change state
	GAMEOBJ:GetTimer():AddTimerWithCancel( 60, "StateChange", self )
		-- loop through the sections in the area
	for name,num in pairs(sectionMultipliers) do
		-- loop through the types in the spawn sets
		for i = 1,#zones[1] do
			-- create the spawner network name
			local spawnerName = zonePrefix .. "_" .. zoneName .. "_" .. name.."_type"..i
			-- use the spawner network name to find out how many enemies are spawned on the spawner network.
			local spawner = LEVEL:GetSpawnerByName(spawnerName)

			if spawner then
				local oldNum = spawner:SpawnerGetNumToMaintain().uiNum
				local newNum = oldNum
				-- make sure the the spawn
				if oldNum > 1 then
					newNum = oldNum - 1
				end

				setSpawnerNetwork(self, spawnerName, newNum)
			end
		end
	end
end


----------------------------------------------------------------
-- timer to control state change
----------------------------------------------------------------
function onTimerDone(self,msg)
	NamedTimerDone(self,msg)
	if msg.name == "StateChange" then
		-- set the just changed state to false
		self:SetVar("JustChanged", false)
		-- get the spawn state
		local SpawnState = self:GetVar("SpawnState")
		-- get the total number of players in the volume
		local TotalPlayers = self:GetVar("TotalPlayers")
		-- check to see if the spawn state should have changed during the pause
		-- if the spawnstate is min and the total players is greater than the change number
		if SpawnState == "min" and TotalPlayers >= changeNum then
			-- turn the spawn numbers up
			SpawnersUp(self)
		-- if the spawnstate is max and the total players is less than the change number
		elseif SpawnState == "max" and TotalPlayers < changeNum then
			-- turn the spawn numbers down
			SpawnersDown(self)
		end
	end
end

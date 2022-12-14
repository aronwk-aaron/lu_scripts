---------------------------------------------
-- Server side script on a volume in the skullkin area of crux prime
-- this script adjusts the number of enemies spawned based on the number of players in the area
--
-- created by brandi... 11/14/10
---------------------------------------------

-- Skullkin_Engineer_1 - 1
-- Skullkin_Engineer_2 - 1
-- Skullkin_Engineer_3 - 1
-- Skullkin_Engineer_4 - 1
-- Skullkin_Engineer_5 - 1
-- Skullkin_Engineer_6 - 1
-- Skullkin_Miner_1 - 5
-- Skullkin_Miner_2 - 5
-- Skullkin_Miner_3 - 5
-- Skullkin_Miner_4 - 5
-- Skullkin_Miner_5 - 5
-- Skullkin_Miner_6 - 5
-- Skullkin_Patrollers - 4

-- number of players in the area to change the spawn numbers on
local changeNum = 10

----------------------------------------------------------------
-- Set Variables
----------------------------------------------------------------
function onStartup(self,msg)
	-- variable to keep track of the players in the volume
	self:SetVar("TotalPlayers", 0)
	-- variable to keep track of the state of enemies spawn, min for less spawned, max for more spawned
	self:SetVar("SpawnState", "min")
	-- variable for when the spawn number changed to set a delay so it doesnt keep spawning again
	self:SetVar("JustChanged", false)
end

----------------------------------------------------------------
-- when a player enters the volume, add to the totalplayers
----------------------------------------------------------------
function onCollisionPhantom(self,msg)
	-- set the player
	local player = msg.objectID
	-- make sure the player actually exists
	if player:Exists() then
		-- get the number of players that were in the volume
		local TotalPlayers = self:GetVar("TotalPlayers")
		-- add to that the new player
		TotalPlayers = TotalPlayers + 1
		-- set the number of players
		self:SetVar("TotalPlayers", TotalPlayers)
		--print("Player entered - TotalPlayers is "..TotalPlayers)
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
function onOffCollisionPhantom(self,msg)
	-- set the player
	local player = msg.objectID
	-- make sure the player actually exists
	if player:Exists() then
		-- get the number of players that were in the volume
		local TotalPlayers = self:GetVar("TotalPlayers")
		-- subtract to that the new player
		TotalPlayers = TotalPlayers - 1
		-- set the number of players
		self:SetVar("TotalPlayers", TotalPlayers)
		--print("Player Exited - TotalPlayers is "..TotalPlayers)
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
	-- for loop to get and use the numbers 1 to 6
	-- luckily, there are 6 spawner networks for both the engineers and miners
	for i = 1,6 do
		-- set spawner network name for skullkin engineers
		local engSpawn = "Skullkin_Engineer_"..i
		-- get the spawner network
		local spawner = LEVEL:GetSpawnerByName(engSpawn)
		-- set the max spawned to 2
		spawner:SpawnerSetNumToMaintain{uiNum = 2}
		-- reset spawner network
		spawner:SpawnerReset()
		-- set spawner network name for skullkin miners
		local minerSpawn = "Skullkin_Miner_"..i
		-- get the spawner network
		spawner = LEVEL:GetSpawnerByName(minerSpawn)
		-- set the max spawned to 6
		spawner:SpawnerSetNumToMaintain{uiNum = 6}
		-- reset spawner network
		spawner:SpawnerReset()
	end
	-- get the spawner network for the patrollers
	local spawner = LEVEL:GetSpawnerByName("Skullkin_Patrollers")
	-- set the max spawned to 6
	spawner:SpawnerSetNumToMaintain{uiNum = 6}
	-- reset spawner network
	spawner:SpawnerReset()
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
	-- for loop to get and use the numbers 1 to 6
	-- luckily, there are 6 spawner networks for both the engineers and miners
	for i = 1,6 do
		-- set spawner network name for skullkin engineers
		local engSpawn = "Skullkin_Engineer_"..i
		-- get the spawner network
		local spawner = LEVEL:GetSpawnerByName(engSpawn)
		-- set the max spawned to 1
		spawner:SpawnerSetNumToMaintain{uiNum = 1}
		-- reset spawner network
		spawner:SpawnerReset()
		-- set spawner network name for skullkin miners
		local minerSpawn = "Skullkin_Miner_"..i
		-- get the spawner network
		spawner = LEVEL:GetSpawnerByName(minerSpawn)
		-- set the max spawned to 4
		spawner:SpawnerSetNumToMaintain{uiNum = 4}
		-- reset spawner network
		spawner:SpawnerReset()
	end
	-- get the spawner network for the patrollers
	local spawner = LEVEL:GetSpawnerByName("Skullkin_Patrollers")
	-- set the max spawned to 4
	spawner:SpawnerSetNumToMaintain{uiNum = 4}
	-- reset spawner network
	spawner:SpawnerReset()
end

----------------------------------------------------------------
-- timer to control state change
----------------------------------------------------------------
function onTimerDone(self,msg)
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
----------------------------------------
-- Server side script on the Waves room in the fire temple
--
-- created by brandi... 6/16/11
----------------------------------------

-- delay between all enemies in a wave dying, and starting the cinematics				
local CamDelay = 1 --5

-- enemy spawn networks name setup
local enemySpawnerPre = "Waves_"
local enemySpawnerPost = "_Spawner"

-- cameras
local doorCam = "WavesDoorCam"
local spawningCam = "WavesSpawnerSpinners"

-- groups
local roomVolume = "WavesRoomVolume"
local doorIndicators = "WavesDoorIndicator"
local door = "WavesDoor"
local elevatorSpinner = "WavesElevatorSpinner"
local spawnerSpinners = "WavesSpinner"


-- wave loadouts for both a small group and a large group
local waves = {
					{
						{name = "Blacksmith", LargeNum = 3, SmallNum = 2 },
						{name = "Hand", LargeNum = 2, SmallNum = 1 },
						{name = "Marksman", LargeNum = 2, SmallNum = 1 }
					},
					{
						{name = "Hand", LargeNum = 2, SmallNum = 2 },
						{name = "Scientist", LargeNum = 4, SmallNum = 2 },
						{name = "Wolf", LargeNum = 2, SmallNum = 1 },
						{name = "Beetle", LargeNum = 2, SmallNum = 1 }
					},
					{
						{name = "Blacksmith", LargeNum = 2, SmallNum = 1 },
						{name = "Scientist", LargeNum = 2, SmallNum = 1 },
						{name = "Marksman", LargeNum = 2, SmallNum = 1 },
						{name = "Overseer", LargeNum = 2, SmallNum = 1 },
						{name = "Wolf", LargeNum = 2, SmallNum = 1 },
						{name = "Beetle", LargeNum = 1, SmallNum = 1 },
						{name = "Hand", LargeNum = 3, SmallNum = 1 },
						{name = "Bonezai", LargeNum = 1, SmallNum = 1 }
					}
				}

------------------------------------------------------------------------
-- GAME MESSAGES
------------------------------------------------------------------------


function onCollisionPhantom(self,msg)
	if self:GetVar("bStarted") then return end
	
	self:SetVar("bStarted",true)
	
	if GAMEOBJ:GetZoneControlID():GetVar("initialPlayerCount")  > 2 then
		self:SetVar("LargeTeam",true)
		
		-- get the spawner network for ledge frakjaw
		--local spawner = LEVEL:GetSpawnerByName(extraRocks)
		
		-- if we have a spawner object lets set it up
		--if not spawner then return end
		--spawner:SpawnerActivate()
		
	end
	
	ActivateWaveSpinners(self,1)
	
end

-- the spawner spinners fire an event when all the enemies are dead
function notifyFireEvent(self,spinner,msg)
	if msg.args == "SpawnedEnemiesDead" then
	
		self:SendLuaNotificationCancel{requestTarget = spinner, messageName = "FireEvent"}
	
		-- find out how many spawner spinners are alive
		local activeSpinners = self:GetVar("SpinnersActive")
		if not activeSpinners then return end
		
		-- remove one spinner for the one that just fired the evene
		activeSpinners = activeSpinners - 1
		
		-- if for some reason more spinners get removed than are still active
		if activeSpinners < 0 then
			print( "Warning!! too many spinners decativated")
			return
		end
		
		-- set the number of active spinners back
		self:SetVar("SpinnersActive",activeSpinners)

		-- if theres still some spinner active, leave the function
		if activeSpinners > 0 then return end
		
		-- fire deactivated event
		GAMEOBJ:GetTimer():AddTimerWithCancel(CamDelay, "ShowDoor", self)
		
	end
	
end

-- CUSTOM FUNCTION - turn the spawner spinners on for the wave
function ActivateWaveSpinners(self,waveNum)
	
	-- wave isnt valid
	if waveNum > table.maxn(waves) then
		--waves done
		return
	end
	
	-- custom function to play cinematics
	PlayCamera(self,spawningCam)
	
	-- set the current way
	self:SetVar("CurrentWave",waveNum)
	
	-- for each load out in the wave, start that spinner with the right load out
	for k,enemyInfo in ipairs(waves[waveNum]) do
		
		-- get the spawner network for that spinner enemy
		local spawner = LEVEL:GetSpawnerByName(enemySpawnerPre..enemyInfo.name..enemySpawnerPost)
		if spawner then 
		
			local spawnNum = 0
			
			-- get the spawn load out based on player load
			if self:GetVar("LargeTeam") then
				spawnNum = enemyInfo.LargeNum
			else
				spawnNum = enemyInfo.SmallNum
			end
			
			-- make sure an enemy is suppose to spawn
			if spawnNum > 0 then
			
				-- set spawner network up
				spawner:SpawnerSetMaxToSpawn{iNum = spawnNum}
				spawner:SpawnerSetNumToMaintain{uiNum = spawnNum}
						
				-- get total number of active spinners
				local spinnersUp = self:GetVar("SpinnersActive") or 0
				
				-- get the spinner for this enemy
				local spinnersT = self:GetObjectsInGroup{ group = spawnerSpinners..enemyInfo.name, ignoreSpawners = true }.objects
				for k,spinner in ipairs(spinnersT) do
					if spinner:Exists() then
						-- tell the spinner to spawn the enemies
						spinner:FireEvent{args = "SpawnEnemies"}
						self:SendLuaNotificationRequest{requestTarget = spinner, messageName = "FireEvent"}
						-- add new spinner to total number of spinners
						spinnersUp = spinnersUp +1
					end
				end
				
				-- set the total number of active spinners
				self:SetVar("SpinnersActive",spinnersUp)
				
			end
			
		end
	end
end

-- custom function: play cinematic for players in the room
function PlayCamera(self,cine)

	-- get the volume around the room
	local roomTrigger = self:GetObjectsInGroup{ group = roomVolume, ignoreSpawners = true }.objects
	if table.maxn(roomTrigger) == 0 then return end
	
	for k,trigger in ipairs(roomTrigger) do
	
		if trigger:Exists() then
		
			-- get the players in the volume
			local playersT = trigger:GetObjectsInPhysicsBounds().objects
			if table.maxn(playersT) == 0 then return end
			
			-- play the cinematic and remove poison for all the players
			for k,player in ipairs(playersT) do
				if player:Exists() then
					player:RemoveBuff{uiBuffID = 60}
					player:PlayCinematic{pathName = cine, rerouteID = player} 
				end
			end
			
		end
	end
	
end

-- timers finished
function onTimerDone(self,msg)

	-- enemies have been dead for a few seconds, show the door indicators come one
	if msg.name == "ShowDoor" then
		PlayCamera(self,doorCam)
		GAMEOBJ:GetTimer():AddTimerWithCancel(1, "TurnOnIndicator", self)
		
		local cineTime = LEVEL:GetCinematicInfo(doorCam) or 3
		GAMEOBJ:GetTimer():AddTimerWithCancel(cineTime, "SpawnNextWave", self)
		
	-- get the door indicator and turn it on
	elseif msg.name == "TurnOnIndicator" then
		local doorIndicator = self:GetObjectsInGroup{ group = doorIndicators..self:GetVar("CurrentWave"), ignoreSpawners = true }.objects
		if table.maxn(doorIndicator) == 0 then return end
		for k,indicator in ipairs(doorIndicator) do
			if indicator:Exists() then
				indicator:FireEvent{args = "IndicatorOn"}
				break
			end
		end
		
		-- the current wave was the last wave, room is done
		if self:GetVar("CurrentWave") == table.maxn(waves) then
		
			-- get the door and open it
			local doorT = self:GetObjectsInGroup{ group = door, ignoreSpawners = true }.objects
			if table.maxn(doorT) == 0 then return end
			for k,doorV in ipairs(doorT) do
				if doorV:Exists() then
					doorV:FireEvent{args = "IndicatorOn"}
					break
				end
			end
			
			-- get the elevator spinner and make it interactive
			local elevators = self:GetObjectsInGroup{ group = "WavesElevatorSpinner", ignoreSpawners = true }.objects
			if table.maxn(elevators) == 0 then return end
			for k,elevator in ipairs(elevators) do
				if elevator:Exists() then
					elevator:FireEvent{args = "TurnOn"}
					break
				end
			end
			
		end
		
	-- time to spawn the next wave
	elseif msg.name == "SpawnNextWave" then
	
		-- spawn the next wave
		ActivateWaveSpinners(self,self:GetVar("CurrentWave") + 1)
		
	end
	
end
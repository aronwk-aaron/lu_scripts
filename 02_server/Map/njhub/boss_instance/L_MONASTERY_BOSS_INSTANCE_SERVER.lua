

----------------------------------------------------------------
-- LOTS
----------------------------------------------------------------
local chestLOT = 16486
local ledgeFrakjaw = 16289
local lowerFrakjawLOT = 16048
local counterweight = 16141

----------------------------------------------------------------
-- groups
----------------------------------------------------------------
local chestSpawnPoint = "ChestSpawnPoint"

----------------------------------------------------------------
-- spawner network names
----------------------------------------------------------------
local ledgeFrakjawSpawner 	= "LedgeFrakjaw"
local lowerFrakjawSpawner 	= "LowerFrakjaw"
local baseEnemiesSpawner 	= "EnemySpawnPoints_"
local counterweightSpawner  = "Counterweights"
local fireRailSpawner 		= "FireRailActivatorQB"
local extraRocks			= "ExtraRocks"

----------------------------------------------------------------
-- cameras
----------------------------------------------------------------
local ledgeFrakSummon 		= "FrakjawSummoning"
local baseCounterweightQB 	= "CounterweightQB"
local baseCounterweightSpawn = "CWQBSpawn"
local bottomFrakSummon 		= "BottomFrakjawSummoning"
local bottomFrakSpawn 		= "BottomFrakjawSpawning"
local treasureChestSpawning = "TreasureChestSpawning"
local fireRailSpawn 		= "RailQBSpawn"

----------------------------------------------------------------
-- animations
----------------------------------------------------------------
local summon	 	= "summon"
local teleportout 	= "teleport-out"
local teleportin 	= "teleport-in"
local stunned 		= "stunned"

----------------------------------------------------------------
-- audio cues
----------------------------------------------------------------
local AudioWave 	= "Monastery_Frakjaw_Battle_"
local BattleOver = "Monastery_Frakjaw_Battle_Win" 
local counterSmashSound = "{d76d7b9d-9dc2-4e52-a315-69b25ef521ca}"


----------------------------------------------------------------
-- enemy lots for the waves
----------------------------------------------------------------
local enemies  = 	{
						bonewolf = 16191,
						blacksmith = 14007,
						marksman = 14008,
						commando = 14009,
						madscientist = 16511
					}

----------------------------------------------------------------
-- wave loadouts for both a small group and a large group
----------------------------------------------------------------
local waves = {
					{
						{LOT = enemies.marksman, LargeNum = 2, SmallNum = 1 },
						{LOT = enemies.blacksmith, LargeNum = 4, SmallNum = 3 },
						{LOT = enemies.commando, LargeNum = 2, SmallNum = 1 },
						{LOT = enemies.madscientist, LargeNum = 1, SmallNum = 0 }
					},
					{
						{LOT = enemies.bonewolf, LargeNum = 1, SmallNum = 0 },
						{LOT = enemies.blacksmith, LargeNum = 2, SmallNum = 2 },
						{LOT = enemies.marksman, LargeNum = 2, SmallNum = 1 },
						{LOT = enemies.madscientist, LargeNum = 1, SmallNum = 1 }
					},
					{
						{LOT = enemies.bonewolf, LargeNum = 2, SmallNum = 1 },
						{LOT = enemies.marksman, LargeNum = 2, SmallNum = 1 },
						{LOT = enemies.commando, LargeNum = 2, SmallNum = 2 },
						{LOT = enemies.madscientist, LargeNum = 1, SmallNum = 0 }
					},
					{
						{LOT = enemies.blacksmith, LargeNum = 2, SmallNum = 2 },
						{LOT = enemies.bonewolf, LargeNum = 1, SmallNum = 1 },
						{LOT = enemies.commando, LargeNum = 3, SmallNum = 1 },
						{LOT = enemies.marksman, LargeNum = 2, SmallNum = 0 }
					},
					{
						{LOT = enemies.madscientist, LargeNum = 1 },
						{LOT = enemies.bonewolf, LargeNum = 2 },
						{LOT = enemies.commando, LargeNum = 3 },
						{LOT = enemies.marksman, LargeNum = 2  }
					}
				}
				
local waveNum = #waves
local DelayToCounterSpawn = 2
				
-- required for all activities
require('ai/ACT/L_ACT_GENERIC_ACTIVITY_MGR')				
				
-- get the total number of players that are supposed to load in the instance
function onZoneLoadedInfo(self,msg)
	self:SetVar("ProjectedPlayerLoad",msg.maxPlayersSoft)
	-- activate the activity
	self:SetActivityParams{ modifyMaxUsers = true, maxUsers = 4, modifyActivityActive = true,  activityActive = true} 
end

----------------------------------------------------------------
-- when each player loads in
----------------------------------------------------------------
function onPlayerLoaded(self,msg)

	-- cancel any timer set to wait for new players
	GAMEOBJ:GetTimer():CancelTimer("WaitingForPlayers", self)
	
	-- get the table of players to see how many other players are in the map
	local TotalPlayersLoaded = self:GetVar("TotalPlayers") or {}
	-- get the player that loaded in
	local player = msg.playerID
	
	-- add the player to the activity
	UpdatePlayer(self, player)
	
	--remove the activity cost from the player as they load into the map
	local takeCost = self:ChargeActivityCost{user = player}.bSucceeded
	
    -- get the players max stats and then max them out
    local maxHealth = player:GetMaxHealth{}.health
    local maxArmor = player:GetMaxArmor{}.armor
    local maxImagination = player:GetMaxImagination{}.imagination
    
    player:SetHealth{ health = maxHealth }    
    player:SetArmor{ armor = maxArmor }
    player:SetImagination{ imagination = maxImagination }
    
    -- if no one is in the table yet, put the new player in the table
    if table.maxn(TotalPlayersLoaded) == 0 then
		table.insert(TotalPlayersLoaded,msg.playerID:GetID())
	-- if theres others in the table, make sure the player isnt one of them
	else
		local foundPlayer = false
		for k,v in ipairs(TotalPlayersLoaded) do
			if ( player:GetID() == v ) then
				foundPlayer = true
				break
			end
			
		end
		if not foundPlayer then
			table.insert(TotalPlayersLoaded,player:GetID())
		end
	end
	
	-- set players to unique start points
	TeleportPlayer(self,player,table.maxn(TotalPlayersLoaded))
	
	--set the total player to a setvar
	self:SetVar("TotalPlayers", TotalPlayersLoaded)
	
	-- find out how many players are loaded and how many should be loaded to see if everyone that needs to be loaded is loaded
	if table.maxn(TotalPlayersLoaded) == self:GetVar("ProjectedPlayerLoad") then
		-- set if a team is a large team or not, for wave load out purposes
		if table.maxn(TotalPlayersLoaded) > 2 then
			self:SetVar("LargeTeam",true)
			
			-- get the spawner network for ledge frakjaw
			local spawner = LEVEL:GetSpawnerByName(extraRocks)
			
			-- if we have a spawner object lets set it up
			if not spawner then return end
			spawner:SpawnerActivate()
			
		end
		-- start the instance and return out
		StartFight(self)
		return 
	end
	-- tell the client to player the waiting for players cinematic
	self:NotifyClientObject{name = "PlayerLoaded", paramObj = msg.userID, rerouteID = player}
	-- start a timer to wait for other players, if someone doesnt load in the time, start the instance anyway
	GAMEOBJ:GetTimer():AddTimerWithCancel(45, "WaitingForPlayers", self)

end

----------------------------------------------------------------
-- called when a player exits the zone
----------------------------------------------------------------
function onPlayerExit(self,msg)
	-- remove the player from the activity
	UpdatePlayer(self, player, false)
	
	-- tell the client to player the waiting for players cinematic
	self:NotifyClientObject{name = "PlayerLeft", paramObj = msg.playerID , rerouteID = msg.playerID}
end

----------------------------------------------------------------
-- set players to unique start points
----------------------------------------------------------------
function TeleportPlayer(self,player,position)
	
	-- get the point to teleport the player to
	local spawnObj = self:GetObjectsInGroup{ group = 'SpawnPoint'..position, ignoreSpawners = true }.objects
	
	for k,obj in ipairs(spawnObj) do
		if obj:Exists() then
			-- get the position and rotation of that point
			local pos = obj:GetPosition().pos
			local rot = obj:GetRotation()

			-- tele players there
			player:Teleport{pos = pos, x = rot.x, y = rot.y, z = rot.z, w = rot.w, bSetRotation = true}     

		end 
	end

end

----------------------------------------------------------------
-- custom function: starts the instance
----------------------------------------------------------------
function StartFight(self)

	-- make sure the instance hasnt already started
	if self:GetVar("FightStarted") then return end
	-- set that we are starting the instance
	self:SetVar("FightStarted",true)
	
	-- get the spawner network for ledge frakjaw
	local spawner = LEVEL:GetSpawnerByName(ledgeFrakjawSpawner)
    
	-- if we have a spawner object lets set it up
	if not spawner then return end
	spawner:SpawnerActivate()
	-- request the spawner tell us when it spawns something
	self:SendLuaNotificationRequest{requestTarget = spawner, messageName = "SpawnedObjectLoaded"}
	
end

----------------------------------------------------------------
-- a spawner network with a notification request has spawned something
----------------------------------------------------------------
function notifySpawnedObjectLoaded(self, other, msg)

	-- we cant chect the spawner name, so we have to check the lot of what spawned
	if msg.objectID:GetLOT().objtemplate == ledgeFrakjaw then
	
		-- save frakjaw as ledge frakjaw
		self:SetVar("LedgeFrakjaw",msg.objectID)
 
		-- have frakjaw summon the first wave
		SummonWave(self,msg.objectID)
		return
		
	elseif msg.objectID:GetLOT().objtemplate == counterweight then 
		
		-- we want to know when a player is interacting with the qb pile 
		self:SendLuaNotificationRequest{requestTarget = msg.objectID, messageName = "RebuildNotifyState"}
		-- when the counterweight has been built and moved to the end of its path
		self:SendLuaNotificationRequest{requestTarget = msg.objectID, messageName = "PlatformAtLastWaypoint"}
		return
		
	elseif msg.objectID:GetLOT().objtemplate == lowerFrakjawLOT then 
	
		-- lower frakjaw has just spawned, have him play an animation and fx
		msg.objectID:PlayAnimation{animationID = teleportin}
		
		-- save out lower frakjaw
		self:SetVar("LowerFrakjaw",msg.objectID)
		
		-- stun frakjaw for a few seconds when he first spawns in
		msg.objectID:SetStunned{StateChangeType = "PUSH", bCantAttack = true, bCantMove = true, bIgnoreImmunity = true, bCantTurn = true}
		
		-- request onhit notifies
		self:SendLuaNotificationRequest{requestTarget = msg.objectID, messageName = "OnHit"}
		self:SendLuaNotificationRequest{requestTarget = msg.objectID, messageName = "Die"}
		
		-- tell the client to switch health bars
		self:NotifyClientObject{name = "LedgeFrakjawDead"}
		
		-- for a larger team, spawn the number for a larger team
		if self:GetVar("LargeTeam") then
		
			-- double frakjaw's health if its a larger team
			local FJHealth = msg.objectID:GetHealth().health
			FJHealth = FJHealth * 2
			msg.objectID:SetMaxHealth{health = FJHealth}
			msg.objectID:SetHealth{health = FJHealth}
			
			local animTime = msg.objectID:GetAnimationTime{animationID = teleportout}.time
		
			if animTime == 0 then
				animTime = 2
			end
			
			GAMEOBJ:GetTimer():AddTimerWithCancel(animTime, "LowerFrakjawSpawnIn_"..msg.objectID:GetID(), self)
			-- after the cienematic is over unstun frakjaw
			GAMEOBJ:GetTimer():AddTimerWithCancel(animTime+5, "Unstun_"..msg.objectID:GetID(), self)
			
		else
			-- after the cienematic is over unstun frakjaw
			GAMEOBJ:GetTimer():AddTimerWithCancel(5, "Unstun_"..msg.objectID:GetID(), self)
		end

		return
		
	end
	
	-- for everyone else, all the wave enemies, tell them to let us know when they die
	self:SendLuaNotificationRequest{requestTarget = msg.objectID, messageName = "Die"}
	
	-- put anything else in the trash Mobs table
	local TEnemy = self:GetVar("TrashMobsAlive") or {}
	table.insert(TEnemy,msg.objectID:GetID())
	self:SetVar("TrashMobsAlive",TEnemy)
	
	-- stun enemies for a few seconds when they first spawn in
	msg.objectID:SetStunned{StateChangeType = "PUSH", bCantAttack = true, bCantMove = true, bIgnoreImmunity = true, bCantTurn = true}
	-- after the cienematic is over unstun frakjaw
	GAMEOBJ:GetTimer():AddTimerWithCancel(3, "Unstun_"..msg.objectID:GetID(), self)
	
end

----------------------------------------------------------------
-- the counterweights quickbuild pile has been interacted with
----------------------------------------------------------------
function notifyRebuildNotifyState(self,counterweight,msg)

	-- someone is building the pile, play the cinematic
	if msg.iState == 5  then -- building
		self:NotifyClientObject{name = "PlayCinematic", paramStr = "CounterweightQB"..(self:GetVar("WaveNum")), paramObj = counterweight }
	-- someone stopped building the counterweight
	elseif msg.iState == 6 then -- 
		self:NotifyClientObject{name = "EndCinematic"}
	-- quickbuild was started but not finished, so it died and it needs to respawn
	elseif msg.iState == 4 and msg.iPrevState == 6 then
		SpawnCounterweight(self)
	end
		
end

----------------------------------------------------------------
-- the counterweights are at the end of their path
----------------------------------------------------------------
function notifyPlatformAtLastWaypoint(self,counterWeight,msg)

	-- tell the counterweight to die
	counterWeight:RequestDie()
	
	-- get frakjaw
	local frakjaw = self:GetVar("LedgeFrakjaw")
	
	-- if for some reason he doesnt exist, tell the client
	if not frakjaw:Exists() then
		self:NotifyClientObject{name = "LedgeFrakjawDead"}
		return
	end
	
	-- frakjaw does damage to him self
	frakjaw:CastSkill{skillID = 1635}

	-- play animation for frakjaw getting hit with the counterweight
	frakjaw:PlayAnimation{animationID = stunned}
	frakjaw:PlayNDAudioEmitter{m_NDAudioEventGUID = counterSmashSound}
	
	-- if its on the 4th wave (the wave coming up), then we need to start the process of switching frakjaws
	if self:GetVar("WaveNum") == 3 then
		LowerFrakjaw(self,frakjaw)
		return
	end
	
	-- just a normal wave, start a timer to spawn the next wave
	GAMEOBJ:GetTimer():AddTimerWithCancel(2, "SpawnNextWave", self)
	
end

----------------------------------------------------------------
-- lower frakjaw has been hit
----------------------------------------------------------------
function notifyOnHit(self,frakjaw,msg)

	-- if his health is less than 50% and we havent already spawned his last wave
	if frakjaw:GetHealth().health <= ( frakjaw:GetMaxHealth().health / 2) and not self:GetVar("OnLastWave") then
		
		-- starting last wave
		self:SetVar("OnLastWave", true)
		
		-- we dont need to know when hes been hit anymore
		self:SendLuaNotificationCancel{requestTarget = frakjaw, messageName = "OnHit"}
		
		-- stun frakjaw during his animation and summoning
		frakjaw:SetStunned{StateChangeType = "PUSH", bCantAttack = true, bCantMove = true, bIgnoreImmunity = true, bCantTurn = true}
		-- after the cienematic is over unstun frakjaw
		GAMEOBJ:GetTimer():AddTimerWithCancel(5, "Unstun_"..frakjaw:GetID(), self)
		
		-- get all enemies alive and stun them while the player is watching a cinematic
		local TEnemy = self:GetVar("TrashMobsAlive")
		
		local RemoveEnemyKey = {}
		if TEnemy then
			for k,enemyID in ipairs(TEnemy) do
				local enemy = GAMEOBJ:GetObjectByID(enemyID)
				if not enemy:Exists() then
					-- stun the enemy during his animation and summoning
					enemy:SetStunned{StateChangeType = "PUSH", bCantAttack = true, bCantMove = true, bIgnoreImmunity = true, bCantTurn = true}
					-- after the cienematic is over unstun the enemy
					GAMEOBJ:GetTimer():AddTimerWithCancel(5, "Unstun_"..enemy:GetID(), self)
				else
					table.insert(RemoveEnemyKey,k)
				end
			end
		end
		
		if RemoveEnemyKey then
			for k,enemyKey in ipairs(RemoveEnemyKey) do
				table.remove(TEnemy,enemyKey)
			end
			
			self:SetVar("TrashMobsAlive",TEnemy)
		end
		
		
		
		LowerFJSummon(self,frakjaw)
		
		RemovePoison(self)

	end
		
end

----------------------------------------------------------------
-- someone from a spawnernetwork died
----------------------------------------------------------------
function notifyDie(self,other,msg)

	-- lower frakjaw died, fight over
	if other:GetLOT().objtemplate == lowerFrakjawLOT then
	
		GAMEOBJ:GetTimer():AddTimerWithCancel(DelayToCounterSpawn, "FightOver", self)
	
	-- one of the wave enemies died
	else
		
		-- get the table of trash mobs and take the dead one out of it
		local TEnemy = self:GetVar("TrashMobsAlive") or {}
		local EnemyToDelete  = 0
		for k,enemy in ipairs(TEnemy) do
			if other:GetID() == enemy then
				EnemyToDelete = k
				break
			end
		end
		
		table.remove(TEnemy,EnemyToDelete)	
	
		self:SetVar("TrashMobsAlive",TEnemy)
		
		-- if no enemies are left alive, then the wave is over
		if #TEnemy == 0 then
			
			GAMEOBJ:GetTimer():AddTimerWithCancel(DelayToCounterSpawn, "WaveOver", self)
		end
		
	end
	
end

----------------------------------------------------------------
-- play cinematic and animation for lower frakjaw summoning
----------------------------------------------------------------
function LowerFJSummon(self,frakjaw)

	-- get the time for the frak summon cinematic
	local cineTime = tonumber(LEVEL:GetCinematicInfo(bottomFrakSummon )) or 4
	-- tell the client to play the cinematic
	self:NotifyClientObject{name = "PlayCinematic", paramStr = bottomFrakSummon }
	-- halfway through the cinematic, spawn the enemies
	GAMEOBJ:GetTimer():AddTimerWithCancel(cineTime/2, "SpawnWave", self)
	
	-- play the summon animation
	frakjaw:PlayAnimation{animationID = summon}
	
end
----------------------------------------------------------------
-- custom function: frakjaw summons a new wave of enemies, ledge frak only
----------------------------------------------------------------
function SummonWave(self,ledgeFrakjaw)

	-- tell the client to play the summon animation
	self:NotifyClientObject{name = "PlayCinematic", paramStr = ledgeFrakSummon }
	-- have frakjaw play summon animation
	ledgeFrakjaw:PlayAnimation{animationID = summon}
	
		-- get the wave number, or start it at 1
	local wave = self:GetVar("WaveNum") or 0

	-- the first, fourth and fifth waves dont need stop any music
	if wave >= 1 and wave < (waveNum-1) then
		self:NotifyClientObject{name = "StopMusic", paramStr = AudioWave..(wave-1) }
	end
	
	-- after frakjaw moves down, the music doesnt change
	if wave < (waveNum-1) then
		self:NotifyClientObject{name = "StartMusic", paramStr = AudioWave..wave } 
	end

	-- start a timer for when the wave should actually spawn
	GAMEOBJ:GetTimer():AddTimerWithCancel(4, "SpawnWave", self)
	
end

----------------------------------------------------------------
-- Custom function: Spawns mobs on a spawner network, Now...
----------------------------------------------------------------
function setSpawnerNetwork(self, spawnLOT,	spawnNum, spawnerName)
	-- get the spawner object
    local spawner = LEVEL:GetSpawnerByName(spawnerName)
    
    -- if we have a spawner object lets set it up
    if not spawner then return end
    
    -- reset the spawner
	spawner:SpawnerReset()
	
	-- set the LOT to spawn if it's sent to the function
	if not spawnLOT then return end
	spawner:SpawnerSetSpawnTemplateID{iObjTemplate = spawnLOT}
	
	
	-- if there is a spawn num,and its more than 0
	if spawnNum and spawnNum > 0 then            

		-- get the total spawned already, or make it
		local totalSpawned = self:GetVar("TotalAliveInWave") or 0
		
		-- request to be notified when anything spawns
		self:SendLuaNotificationRequest{requestTarget = spawner, messageName = "SpawnedObjectLoaded"}
		
		-- for each enemy to be spawned for this LOT
		for i = totalSpawned +1 ,totalSpawned + spawnNum do
			-- spawn that enemy at the next node on the spawner network, so the enemies spawn in a line
			spawner:SpawnerSpawnNewAtIndex{spawnLocIndex = i}

		end
		
	end
       
end

----------------------------------------------------------------
-- custom function: activates the spawner netwrok on the qb counterweight
----------------------------------------------------------------
function SpawnCounterweight(self)

	-- get the spawner object
	local spawner = LEVEL:GetSpawnerByName(counterweightSpawner)
	
	-- if we have a spawner object lets set it up
	if not spawner then return end
	
	-- request the spawner let us know when an object has spawned
	self:SendLuaNotificationRequest{requestTarget = spawner, messageName = "SpawnedObjectLoaded"}
	
	-- spawn the counterweight on the index that goes with that wave, nodes start at 0, so take away 1
	spawner:SpawnerSpawnNewAtIndex{spawnLocIndex = self:GetVar("WaveNum") - 1}
	
end

----------------------------------------------------------------
-- custom function: all the enemies have died from the wave, start up for next one
----------------------------------------------------------------
function WaveOver(self)

	-- get the wave num 
	local onWaveNum = self:GetVar("WaveNum")
	-- leave if its the last wave
	if onWaveNum >= (waveNum-1) then return end
	
	-- get the camera time for the counterweight spawning camera
	local cineTime = tonumber(LEVEL:GetCinematicInfo(baseCounterweightSpawn..onWaveNum )) or 3
	-- tell the client to play the cinematic
	self:NotifyClientObject{name = "PlayCinematic", paramStr = baseCounterweightSpawn..onWaveNum }
	-- start a time to  spawn the qb pile
	GAMEOBJ:GetTimer():AddTimerWithCancel(cineTime/2, "SpawnQB", self)
	
	RemovePoison(self)

end

----------------------------------------------------------------
-- custom function: all the enemies have died from the wave, start up for next one
----------------------------------------------------------------
function RemovePoison(self)
	local TPlayers = self:GetVar("TotalPlayers")
	for k,playerID in ipairs(TPlayers) do
		local player = GAMEOBJ:GetObjectByID(playerID)
		if player:Exists() then
			player:RemoveBuff{uiBuffID = 60}
		end
	end
	
end

----------------------------------------------------------------
-- custom function: starting the lower frak part, play animation and fx on ledge frak to show him getting ready to move
----------------------------------------------------------------
function LowerFrakjaw(self,frakjaw)

	frakjaw:PlayAnimation{animationID = teleportout}
	
	local animTime = frakjaw:GetAnimationTime{animationID = teleportout}.time
	
	if animTime == 0 then
		animTime = 2
	end
	
	GAMEOBJ:GetTimer():AddTimerWithCancel(animTime, "StartLowerFrakjawCam", self)
	
	self:NotifyClientObject{name = "StopMusic", paramStr = AudioWave..(waveNum-3) }
	self:NotifyClientObject{name = "StartMusic", paramStr = AudioWave..(waveNum-2) }
	
end

----------------------------------------------------------------
-- custom function: frak is dead
----------------------------------------------------------------
function FightOver(self,msg)

	-- tell the client to turn off the health ui
	self:NotifyClientObject{name = "GroundFrakjawDead"}
		
	-- go through all the spawners for enemies and kill any left alive
	for i = 1,4 do
		-- get the spawner object
		local spawner = LEVEL:GetSpawnerByName(baseEnemiesSpawner..i)
		
		if spawner then
			spawner:SpawnerDestroyObjects{bDieSilent = false}
		end
	end
	
	RemovePoison(self)
	
	self:NotifyClientObject{name = "StopMusic", paramStr = AudioWave..(waveNum-2) }
	self:NotifyClientObject{name = "FlashMusic", paramStr = BattleOver }

	-- tell the client to play the cienmatic of the treasure chest spawning
	self:NotifyClientObject{name = "PlayCinematic", paramStr = treasureChestSpawning }
	-- get the time from the camera
	local cineTime = tonumber(LEVEL:GetCinematicInfo(treasureChestSpawning )) or 2
	-- start a timer to switch to the rail qb camera
	GAMEOBJ:GetTimer():AddTimerWithCancel(cineTime - .5, "SpawnRailQB", self)
	
	-- get the blue M in the map to know where to spawn the treasure chest
	local ChestSpawn = self:GetObjectsInGroup{ group = chestSpawnPoint, ignoreSpawners = true }.objects
	
	for k,obj in ipairs(ChestSpawn) do
	
		if obj:Exists() then
		
			local mypos = obj:GetPosition().pos
			local myRot = obj:GetRotation()
			
			-- incase something bad happens use the killerID
			local config = { {"parent_tag", self} }

			-- spawn a treasure chest
			RESMGR:LoadObject { objectTemplate = chestLOT , x = mypos.x , y = mypos.y , z = mypos.z ,owner = self,
								rw= myRot.w, rx= myRot.x, ry= myRot.y , rz = myRot.z, configData = config}
			break
			
		end
		
	end
	
end

----------------------------------------------------------------
-- a set timer is done.. ding
----------------------------------------------------------------
function onTimerDone(self,msg)

	local var = split(msg.name, "_") --Spliting the message name back into the timers name and the player's ID
	local obj = ''
		
	if var[2] then
		obj = GAMEOBJ:GetObjectByID(var[2]) --Resetting the players Object ID into a Variable
	end
	
	-- done waiting for players
	if var[1] == "WaitingForPlayers" then
	
		-- go to custom start fight function
		StartFight(self)
		
	-- time to spawn next wave
	elseif var[1] == "SpawnNextWave" then
	
		-- go to custom play summon animation and start the camera
		SummonWave(self,self:GetVar("LedgeFrakjaw"))
		
	-- time to actually spawn the next wave
	elseif var[1] == "SpawnWave" then
		
		-- get the wave number, or start it at 1
		local wave = self:GetVar("WaveNum") or 0
		
		-- set new wave
		wave = wave + 1
		
		-- set to next wave
		self:SetVar("WaveNum",wave)
		
		-- use the wave num to find the right entry in the waves table set at the beginning
		for k,v in ipairs(waves[wave]) do
		
			-- for a larger team, spawn the number for a larger team
			if self:GetVar("LargeTeam") then
				setSpawnerNetwork(self,v.LOT,v.LargeNum,baseEnemiesSpawner..k)
			-- otherwise, spawn the small one
			else
				setSpawnerNetwork(self,v.LOT,v.SmallNum,baseEnemiesSpawner..k)
			end

		end
		
	-- time to unstun frak from being stunned
	elseif var[1] == "Unstun" then
	
		-- unstun him
		obj:SetStunned{StateChangeType = "POP", bCantAttack = true, bCantMove = true, bIgnoreImmunity = true, bCantTurn = true}
		
	-- time to spawn a counterweight
	elseif var[1] == "SpawnQB" then
		
		SpawnCounterweight(self)
		
	-- time to move frakjaw
	elseif var[1] == "StartLowerFrakjawCam" then
	
		-- kill ledge frakjaw
		self:GetVar("LedgeFrakjaw"):RequestDie{killType = "SILENT"}

		-- start a timer to spawn the second version on the ground
		GAMEOBJ:GetTimer():AddTimerWithCancel(1, "SpawnLowerFrakjaw", self)
		-- tell the client to play the camera
		self:NotifyClientObject{name = "PlayCinematic", paramStr = bottomFrakSpawn }
		
	-- time to actaully spawn lower frakjaw
	elseif var[1] == "SpawnLowerFrakjaw" then
		
		-- get the spawner
		local spawner = LEVEL:GetSpawnerByName(lowerFrakjawSpawner)
		
		-- request to know when something spawns
		self:SendLuaNotificationRequest{requestTarget = spawner, messageName = "SpawnedObjectLoaded"}
    
		-- if we have a spawner, activate it
		if not spawner then return end
		spawner:SpawnerActivate()

		
	-- time to spawn the fire rail qb
	elseif var[1] == "SpawnRailQB" then
	
		-- tell the client to play the camera
		self:NotifyClientObject{name = "PlayCinematic", paramStr = fireRailSpawn }
		
		--get the spawner
		local spawner = LEVEL:GetSpawnerByName(fireRailSpawner)

		-- if we have a spawner, actiavte it
		spawner:SpawnerActivate()
		
	elseif var[1] == "LowerFrakjawSpawnIn" then
	
		LowerFJSummon(self,obj)
	
	elseif var[1] == "WaveOver" then
		
		WaveOver(self)
	
	elseif var[1] == "FightOver" then
	
		FightOver(self)
		
	end
	
end

----------------------------------------------
-- splits a string based on the pattern passed in
----------------------------------------------
function split(str, pat)
    local t = {}
    -- Creates a table of strings based on the passed in pattern   
    string.gsub(str .. pat, "(.-)" .. pat, function(result) table.insert(t, result) end)

    return t
end
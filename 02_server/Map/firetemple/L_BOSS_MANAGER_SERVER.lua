function onStartup(self)
    debugPrint(self,"** This a Prototype Script attached to " .. self:GetName().name .. ". **")
    debugPrint(self,"** This script needs to be completed by Someone. **")
    debugPrint(self,"** This file is located at <res/scripts/02_client/map/LD>. **")
end



-- print function that only works in an internal build
function debugPrint(self, text)	
	if self:GetVersioningInfo().bIsInternal then
		print(text)
	end
end

-----------------------------------------------------------------------

local elementalOrder = { "earth","ice","lightning","fire"}

-- portal timers
local Timers = { earth = 40, ice = 30, lightning = 40, fire = 20 }

-- rail node that portal is located on
local RailNode = { earth = 14, ice = 5, lightning = 10, fire = 3 }

-- rail node that portal is located on
local RailLength = { earth = 15, ice = 6, lightning = 21, fire = 4 }

-- Groups
local CutsceneVolume = "BossCutsceneVolume"
local gameSpaceVolume = "BossGameSpace"
local SpawnerSpinners = "BossSpawnerSpinners"

-- Spawners
local CenterPortalSpawner = "BossCenterPortal"
local ElementalPortalSpawner = "BossPortalSpawn_"
local LGTornadoSpawner = "BossLGTornado"
local EndpostSpawner = "BossEndposts_"
local ActivatorSpawner = "BossActivators_"
local GarmadonSpawner = "BossLordGarmadon"
local baseEnemiesSpawner = "BossSpawnerSpinner_"
local BouncerSpawner = "BossEndBouncer"
local LightningBouncerSpawner = "BossLightningBouncers"

-- Cinematics
local BeginningCine = "BossStartCam"
local Phase2Cine = "BossLGCam"
local SpawnWaveCine = "BossSpawnWaveCam"
local WaveOverCine = "BossWaveOverCam"
local SpawnBouncerCine = "BossEndBouncerSpawnCam"

-- celebrations
local IntroCutScene = 26
local PortalDeadCutScene = 27

-- timers
local DelayToCounterSpawn = 2

-- missions
local DestroyPortalMissions = {2094}
----------------------------------------------------------------
-- enemy lots for the waves
----------------------------------------------------------------
local enemies  = 	{
						blacksmith = 16836,
						overseer = 16847,
						marksman = 16849,
						wolf = 13996,
						beetle = 13998,
						vulture = 14000,
						hand = 14002,
						frakjaw = 16854,
						tornado = 16807,
						portal = 16802,
						garmadon  = 16810
					}

----------------------------------------------------------------
-- wave loadouts for both a small group and a large group
----------------------------------------------------------------
local waves = {
					{
						{LOT = enemies.marksman, LargeNum = 2, SmallNum = 1 },
						{LOT = enemies.beetle, LargeNum = 2, SmallNum = 1 },
						{LOT = enemies.blacksmith, LargeNum = 2, SmallNum = 1 },
						{LOT = enemies.wolf, LargeNum = 2, SmallNum = 1 }
					},
					{
						{LOT = enemies.beetle, LargeNum = 1, SmallNum = 0 },
						{LOT = enemies.blacksmith, LargeNum = 2, SmallNum = 2 },
						{LOT = enemies.vulture, LargeNum = 3, SmallNum = 2 },
						{LOT = enemies.overseer, LargeNum = 2, SmallNum = 1 }
					},
					{
						{LOT = enemies.blacksmith, LargeNum = 2, SmallNum = 1 },
						{LOT = enemies.hand, LargeNum = 4, SmallNum = 2 },
						{LOT = enemies.vulture, LargeNum = 2, SmallNum = 2 },
						{LOT = enemies.marksman, LargeNum = 2, SmallNum = 0 }
					},
					{
						{LOT = enemies.hand, LargeNum = 2, SmallNum = 2 },
						{LOT = enemies.frakjaw, LargeNum = 1, SmallNum = 1 },
						{LOT = enemies.blacksmith, LargeNum = 3, SmallNum = 1 },
						{LOT = enemies.beetle, LargeNum = 2, SmallNum = 0 }
					}
				}

------------------------------------------------------------------------
-- GAME MESSAGES
------------------------------------------------------------------------


function onCollisionPhantom(self,msg)
	if self:GetVar("bStarted") then return end
	
	self:SetVar("bStarted",true)
	
	if GAMEOBJ:GetZoneControlID():GetVar("initialPlayerCount") > 2 then
		self:SetVar("LargeTeam",true)
		
		-- get the spawner network for ledge frakjaw
		--local spawner = LEVEL:GetSpawnerByName(extraRocks)
		
		-- if we have a spawner object lets set it up
		--if not spawner then return end
		--spawner:SpawnerActivate()
		
	end
	
	PlayCelebration(self,IntroCutScene)
	
	GAMEOBJ:GetTimer():AddTimerWithCancel(1, "SpawnStartingPortal", self)

	
end

function onNotifyObject(self,msg)
	if msg.name == "ActivatorUsed" then
		if not ( msg.param1 == self:GetVar("PortalNode") ) then return end
		
		self:SendLuaNotificationRequest{requestTarget = msg.ObjIDSender, messageName = "PlayerRailArrivedNotification"}
		
		-- stop portal from teleporting away
		GAMEOBJ:GetTimer():CancelTimer("TeleportPortal", self)
		
	end
end

------------------------------------------------------------------------
-- LUA NOTIFICATIONS
------------------------------------------------------------------------

-----------
-- Phase 1
-----------

function notifyCelebrationCompleted(self,player,msg)

	self:SendLuaNotificationCancel{requestTarget= player, messageName="CelebrationCompleted"}
	local playersStillInCutscene = self:GetVar("PlayersInCutscene")
	playersStillInCutscene = playersStillInCutscene - 1
	self:SetVar("PlayersInCutscene",playersStillInCutscene)
	if playersStillInCutscene > 0 then return end
	
	
	if msg.celebrationID == IntroCutScene then
		PlayCinematic(self,BeginningCine)
		local cineTime = tonumber(LEVEL:GetCinematicInfo(BeginningCine)) or 3
		
		GAMEOBJ:GetTimer():AddTimerWithCancel(cineTime - .5 , "KillStartingPortal", self)
		GAMEOBJ:GetTimer():AddTimerWithCancel(cineTime, "UnstunTornado", self)
		
	-----------
	-- Phase 2
	-----------
	elseif msg.celebrationID == PortalDeadCutScene then
	
		UpdateMission(self)
		
		PlayCinematic(self,Phase2Cine)
		
		local cineTime = tonumber(LEVEL:GetCinematicInfo(Phase2Cine)) or 3
		self:NotifyClientObject{name = "TurnOnHealthBar", paramObj  = self:GetVar("Garmadon") }
		
		GAMEOBJ:GetTimer():AddTimerWithCancel(cineTime + 5 , "Unstun_"..self:GetVar("Garmadon"):GetID(), self)
	end
end

function notifyPlayerRailArrivedNotification(self,activator,msg)

	local pathLength = LEVEL:GetPathWaypoints(msg.pathName)
	if msg.waypointNumber == (table.maxn(pathLength) - 1 )then
		activator:RequestDie()
		return
	end

	if self:GetVar("PortalHit") then return end
	if not ( msg.waypointNumber == RailNode[elementalOrder[self:GetVar("ElementNumber")]] ) then return end

	--self:SendLuaNotificationCancel{requestTarget = activator, messageName = "PlayerRailArrivedNotification"}
	self:SetVar("PortalHit",true)
	
	print("PORTAL HIT")
	local portal = self:GetVar("ElementPortalSpawner")
	
	portal:PlayAnimation{ animationID = "onhit"}
	-- TODO: play hit fx/animation on the portal
	
	
	if not self:GetVar("PortalAlreadyHitOnce") then
		self:SetVar("PortalAlreadyHitOnce",true)
		-- TODO: after we get the hit fx/animation, use the timer for that in the timer to teleport the portal again
		GAMEOBJ:GetTimer():AddTimerWithCancel(1, "TeleportPortal", self)
	
	-- time for the next element
	else
		self:SetVar("PortalAlreadyHitOnce",true)
		
		local animTime = portal:GetAnimationTime{animationID = "onhit"}.time 
		
		if animTime == 0 then
			animTime = 1.5
		end
		
		GAMEOBJ:GetTimer():AddTimerWithCancel(animTime, "StartNextElementalPhase", self)
	
		
		
		
	end

end



function notifySpawnedObjectLoaded(self, other, msg)

-----------
-- Phase 1
-----------

	-- we cant chect the spawner name, so we have to check the lot of what spawned
	if msg.objectID:GetLOT().objtemplate == enemies.tornado then
		-- stun LGT for a few seconds when he first spawns in
		self:SetVar("LGTornado",msg.objectID)
		
	elseif msg.objectID:GetLOT().objtemplate == enemies.portal then
		-- find out node
		self:SetVar("Portal",msg.objectID)
		self:SetVar("PortalNode",msg.spawnNode)
		local teleportTimer = Timers[self:GetVar("CurrentElement")]
		
		--if not self:GetVar("LargeTeam") then
			--teleportTimer = teleportTimer * 2
		--end
		
		GAMEOBJ:GetTimer():AddTimerWithCancel(teleportTimer, "TeleportPortal", self)
-----------
-- Phase 2
-----------
	elseif msg.objectID:GetLOT().objtemplate == enemies.garmadon then
		
		-- save out lower frakjaw
		self:SetVar("Garmadon",msg.objectID)
		
		-- stun frakjaw for a few seconds when he first spawns in
		msg.objectID:SetStunned{StateChangeType = "PUSH", bCantAttack = true, bCantMove = true, bIgnoreImmunity = true, bCantTurn = true}
		
		-- request onhit notifies
		self:SendLuaNotificationRequest{requestTarget = msg.objectID, messageName = "HitOrHealResult"}
		--self:SendLuaNotificationRequest{requestTarget = msg.objectID, messageName = "Die"}
		
		self:SetVar("WaveNum",0)
		
		self:SetVar("GarmadonPos",msg.objectID:GetPosition().pos)
		self:SetVar("GarmadonRot",msg.objectID:GetRotation())
		
		self:SetVar("LGFaction",msg.objectID:GetFaction().factionList)
		
		if self:GetVar("LargeTeam") then
		
			-- double frakjaw's health if its a larger team
			local FJHealth = msg.objectID:GetHealth().health
			FJHealth = FJHealth * 2
			msg.objectID:SetMaxHealth{health = FJHealth}
			msg.objectID:SetHealth{health = FJHealth}
			
		end
		
	end
end

-----------
-- Phase 2
-----------

function notifyHitOrHealResult(self,garmadon,msg)
	
	if not msg.receiver:GetID() == garmadon:GetID() then return end
	if msg.diedAsResult then
		--fight over
		GAMEOBJ:GetTimer():AddTimerWithCancel(3, "StartSpawnBouncerCine", self)
		self:NotifyClientObject{name = "GarmadonIsDead"}
		return
	end
	
	local newHealth = garmadon:GetHealth().health
	local maxHealth = garmadon:GetMaxHealth().health
	local currentWave = self:GetVar("WaveNum")
	local nextWave = currentWave + 1
	
	if newHealth <= ( maxHealth - (maxHealth * ( (1/(table.maxn(waves)+1) * nextWave) ) ) ) then
		self:SetVar("WaveNum",nextWave)
		StartNewWave(self,garmadon,nextWave)
	end
end


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
		GAMEOBJ:GetTimer():AddTimerWithCancel(DelayToCounterSpawn, "WaveOver", self)
		
	end

end
------------------------------------------------------------------------
-- CUSTOM FUNCTIONS
------------------------------------------------------------------------

-----------
-- Phase 1
-----------
function PlayCelebration(self,cutscene)
	local playersT = GetPlayersInRange(self)
	if table.maxn(playersT) > 0 then
		for k,playerID in ipairs(playersT) do
			local player = GAMEOBJ:GetObjectByID(playerID)
			if player:Exists() then
				player:RemoveBuff{uiBuffID = 60}
				player:StartCelebrationEffect{celebrationID = cutscene, rerouteID = player}
				self:SendLuaNotificationRequest{requestTarget = player, messageName = "CelebrationCompleted"}
			end
		end
		local totalPlayers = self:GetVar("PlayersInCutscene") or 0
		self:SetVar("PlayersInCutscene", totalPlayers + table.maxn(playersT))
	end
end

-- custom function: all the enemies have died from the wave, start up for next one
function PlayCinematic(self,cine)
	local playersT = GetPlayersInRange(self)
	if table.maxn(playersT) > 0 then
		for k,playerID in ipairs(playersT) do
			local player = GAMEOBJ:GetObjectByID(playerID)
			if player:Exists() then
				player:RemoveBuff{uiBuffID = 60}
				player:PlayCinematic{pathName = cine, rerouteID = player} 
			end
		end
	end
end

function GetPlayersInRange(self)
	local PlayersT = {}
	
	local cutsceneTrigger = self:GetObjectsInGroup{ group = CutsceneVolume, ignoreSpawners = true }.objects
	if table.maxn(cutsceneTrigger) == 0 then return end
	for k,trigger in ipairs(cutsceneTrigger) do
		if trigger:Exists() then
			local triggerPlayersT = trigger:GetObjectsInPhysicsBounds().objects
			if table.maxn(triggerPlayersT) > 0 then
				for k,player in ipairs(triggerPlayersT) do
					if player:Exists() then
						local bAdd = true
						if table.maxn(PlayersT) > 0 then
							for k,tPlayerID in ipairs(PlayersT) do
								if tPlayerID == player:GetID() then 
									bAdd = false
								end
							end
						end
						if bAdd then
							table.insert(PlayersT,player:GetID())
						end
					end
				end
			end
		end
	end
	return PlayersT
end

function StartElement(self,elementNum)
	local elementString = elementalOrder[elementNum]
	self:SetVar("CurrentElement",elementString)
	
	print("Starting element "..elementString)
	local portalSpawner = LEVEL:GetSpawnerByName(ElementalPortalSpawner..elementString)
	self:SetVar("ElementPortalSpawner",portalSpawner)
	
	TeleportPortal(self,portalSpawner)
	
	self:SetVar("PortalAlreadyHitOnce",false)
	
	--start rails
	local endpostSpawner = LEVEL:GetSpawnerByName(EndpostSpawner..elementString)
	endpostSpawner:SpawnerActivate()
	
	local activatorSpawner = LEVEL:GetSpawnerByName(ActivatorSpawner..elementString)
	activatorSpawner:SpawnerActivate()
	
	if elementString == "lightning" then
		local bouncerSpawner = LEVEL:GetSpawnerByName(LightningBouncerSpawner)
		bouncerSpawner:SpawnerActivate()
	end

	
end


function TeleportPortal(self,portalSpawner)
	
	DestroyPortal(self,portalSpawner)

	local totalNodes = portalSpawner:SpawnerGetNumNodes().uiNum
	
	if totalNodes == 0 then return end
	local nextNode = GetNewNode(self,totalNodes)
	
	--nextNode = 1
	
	portalSpawner:SpawnerSpawnNewAtIndex{spawnLocIndex = nextNode}
	self:SendLuaNotificationRequest{requestTarget = portalSpawner, messageName = "SpawnedObjectLoaded"}
	print("Spawning portal at "..nextNode)
	
	self:SetVar("PortalHit",false)
end


function DestroyPortal(self,portalSpawner)
	portalSpawner:SpawnerDeactivate()
	portalSpawner:SpawnerDestroyObjects{bDieSilent = false}

end

function DestroyRails(self,elementString)

	local endpostSpawner = LEVEL:GetSpawnerByName(EndpostSpawner..elementString)
	endpostSpawner:SpawnerDeactivate()
	endpostSpawner:SpawnerDestroyObjects()
	
	local activatorSpawner = LEVEL:GetSpawnerByName(ActivatorSpawner..elementString)
	activatorSpawner:SpawnerDeactivate()
	activatorSpawner:SpawnerDestroyObjects()

	if elementString == "lightning" then
		local bouncerSpawner = LEVEL:GetSpawnerByName(LightningBouncerSpawner)
		bouncerSpawner:SpawnerDeactivate()
		bouncerSpawner:SpawnerDestroyObjects()
	end

	
end

function GetNewNode(self,totalNodes)
	local nextNode = math.random(0,totalNodes-1)
	-- nodes start at 0 not 1, substact 1
	
	if nextNode == self:GetVar("PortalNode") then
		nextNode = GetNewNode(self,totalNodes)
	end
	
	return nextNode
end

function UpdateMission(self)
	local playersT = GetPlayersInRange(self)
	if table.maxn(playersT) > 0 then
		for k,playerID in ipairs(playersT) do
			local player = GAMEOBJ:GetObjectByID(playerID)
			
			for k,misID in ipairs(DestroyPortalMissions) do
				player:UpdateMissionTask{taskType = "complete", value = misID, value2 = 1, target = self}
			end
			
		end
	end
end


-----------
-- Phase 2
-----------
	
function StartNewWave(self,garmadon,nextWave)
	
	PlayCinematic(self,SpawnWaveCine)

	local cineTime = tonumber(LEVEL:GetCinematicInfo(SpawnWaveCine)) or 3
	
	garmadon:SetFaction{faction = -1}
	-- stun frakjaw for a few seconds when he first spawns in
	garmadon:SetStunned{StateChangeType = "PUSH", bCantAttack = true, bCantMove = true, bIgnoreImmunity = true, bCantTurn = true}
	
	local oPos = { pos = "", rot = ""}

	oPos.pos = self:GetVar("GarmadonPos")
	oPos.rot = self:GetVar("GarmadonRot")
		
	garmadon:Teleport{pos = oPos.pos, x=oPos.rot.x, y=oPos.rot.y, z=oPos.rot.z, w=oPos.rot.w, bSetRotation=true}
	
	print("Play go transparent animation")
	garmadon:PlayAnimation{ animationID = "summon" }
	
	local animTime = garmadon:GetAnimationTime{animationID = "summon"}.time 
	
	if animTime == 0 then
		animTime = 1.5
	end
	
	GAMEOBJ:GetTimer():AddTimerWithCancel(animTime, "MakeLGTransparent", self)
	
	GAMEOBJ:GetTimer():AddTimerWithCancel(cineTime/2, "SpawnEnemies", self)
	
	
end



-- CUSTOM FUNCTION - turn the spawner spinners on for the wave
function ActivateWaveSpinners(self,waveNum)
	
	-- wave isnt valid
	if waveNum > table.maxn(waves) then
		--waves done
		return
	end
	
	local spinnerNum = 1
	local spawnerNum = 1
	
	-- for each load out in the wave, start that spinner with the right load out
	for k,enemyInfo in ipairs(waves[waveNum]) do
		
		-- get the spawner network for that spinner enemy
		local spawner = LEVEL:GetSpawnerByName(baseEnemiesSpawner..spinnerNum.."_"..spawnerNum)
		
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
				spawner:SpawnerSetSpawnTemplateID{iObjTemplate = enemyInfo.LOT}
				
				
				if spinnerNum == 1 then
					spinnerNum = 2
				elseif spinnerNum == 2 then
					spinnerNum = 1
					spawnerNum = spawnerNum + 1
				end
				
				
			end
			
		end
	end
	
	-- get total number of active spinners
	local spinnersUp = self:GetVar("SpinnersActive") or 0
	
	-- get the spinner for this enemy
	local spinnersT = self:GetObjectsInGroup{ group = SpawnerSpinners, ignoreSpawners = true }.objects
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


function onTimerDone(self,msg)

	local var = split(msg.name, "_") --Spliting the message name back into the timers name and the player's ID

		


-----------
-- Phase 1
-----------
	if var[1] == "SpawnStartingPortal" then
		local portalSpawner = LEVEL:GetSpawnerByName(CenterPortalSpawner)
		portalSpawner:SpawnerActivate()
		
		local tornadoSpawner = LEVEL:GetSpawnerByName(LGTornadoSpawner)
		tornadoSpawner:SpawnerActivate()
		self:SendLuaNotificationRequest{requestTarget = tornadoSpawner, messageName = "SpawnedObjectLoaded"}
		
	elseif var[1] == "KillStartingPortal" then
		local portalSpawner = LEVEL:GetSpawnerByName(CenterPortalSpawner)
		portalSpawner:SpawnerDeactivate()
		portalSpawner:SpawnerDestroyObjects()
		
		GAMEOBJ:GetTimer():AddTimerWithCancel(2, "StartEarth", self)
	elseif var[1] == "UnstunTornado" then
		local tornado = self:GetVar("LGTornado")
		tornado:NotifyObject{name = "FindAPath"}
	
	elseif var[1] == "StartEarth" then
	
		StartElement(self,1)
		self:SetVar("ElementNumber",1)
		
	elseif var[1] == "TeleportPortal" then
	
		TeleportPortal(self,self:GetVar("ElementPortalSpawner"))
		
	elseif var[1] == "StartNextElementalPhase" then
	
		DestroyPortal(self,self:GetVar("ElementPortalSpawner"))
		
		local elementNum = self:GetVar("ElementNumber")
		DestroyRails(self,elementalOrder[elementNum])
	
		if elementNum < 4 then --4 then  UNDO THIS
			GAMEOBJ:GetTimer():AddTimerWithCancel(5, "StartNextElement", self)
		else
			self:GetVar("LGTornado"):NotifyObject{name = "StopPathing"}
			GAMEOBJ:GetTimer():AddTimerWithCancel(5, "StartNextPhase", self)
		end
	
	elseif var[1] == "StartNextElement" then
	
		local elementNum = self:GetVar("ElementNumber")
		
		elementNum = elementNum + 1
		self:SetVar("ElementNumber",elementNum)
		
		local tornado = self:GetVar("LGTornado")
		tornado:NotifyObject{name = "NewElement", param1 = elementNum }
		
		StartElement(self,elementNum)
		
	elseif var[1] == "StartNextPhase" then
	
		PlayCelebration(self,PortalDeadCutScene)
	
		GAMEOBJ:GetTimer():AddTimerWithCancel(.5, "DestroyPhase1", self)
		
	elseif var[1] == "DestroyPhase1" then
	
		self:GetVar("LGTornado"):RequestDie()
		
		DestroyPortal(self,self:GetVar("ElementPortalSpawner"))

-----------
-- Phase 2
-----------
		local LGSpawner = LEVEL:GetSpawnerByName(GarmadonSpawner)
		LGSpawner:SpawnerActivate()
		self:SendLuaNotificationRequest{requestTarget = LGSpawner, messageName = "SpawnedObjectLoaded"}
		
	elseif var[1] == "Unstun" then
	
		local obj = ''
			
		if var[2] then
			obj = GAMEOBJ:GetObjectByID(var[2]) --Resetting the Object ID into a Variable
		end
	
		if obj:GetLOT().objtemplate == enemies.garmadon then
			for k,faction in ipairs(self:GetVar("LGFaction")) do
				 if(k == 1) then
					-- Our first faction - flush and add
					obj:SetFaction{faction = faction}
				else
					-- Add
					obj:ModifyFaction{factionID = faction, bAddFaction = true}
				end
			end
		end
		-- unstun him
		obj:SetStunned{StateChangeType = "POP", bCantAttack = true, bCantMove = true, bIgnoreImmunity = true, bCantTurn = true}
	
	elseif var[1] == "SpawnEnemies" then
	
		-- spawn the next wave
		ActivateWaveSpinners(self,self:GetVar("WaveNum"))
	
	elseif var[1] == "WaveOver" then
		
		PlayCinematic(self,WaveOverCine)

		local cineTime = tonumber(LEVEL:GetCinematicInfo(WaveOverCine)) or 3
		GAMEOBJ:GetTimer():AddTimerWithCancel(.5, "GarmadonBack", self)
		GAMEOBJ:GetTimer():AddTimerWithCancel(cineTime + 2, "Unstun_"..self:GetVar("Garmadon"):GetID(), self)
	
	elseif var[1] == "MakeLGTransparent" then
		
		--tell client to make transparent
		self:NotifyClientObject{name = "LGVisible", paramObj  = self:GetVar("Garmadon"), param1 = 0}
	
	elseif var[1] == "GarmadonBack" then
	
		print("play garmadon coming back to this realm animation")
		self:NotifyClientObject{name = "LGVisible", paramObj  = self:GetVar("Garmadon"), param1 = 1}
	
	elseif var[1] == "StartSpawnBouncerCine" then
	
		PlayCinematic(self,SpawnBouncerCine)
		GAMEOBJ:GetTimer():AddTimerWithCancel(.5, "SpawnBouncer", self)
		
	elseif var[1] ==  "SpawnBouncer" then
		
		local bouncerSpawner = LEVEL:GetSpawnerByName(BouncerSpawner)
		bouncerSpawner:SpawnerActivate()
		
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
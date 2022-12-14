--------------------------------------------------------------
-- Generic Survival Instance Server Zone Script: requiring this 
-- file gives the custom functions for the Survival game.
--
-- updated mrb... 7/18/11 - updated for solo missions
--------------------------------------------------------------

--------------------------------------------------------------
-- Includes
--------------------------------------------------------------
require('ai/ACT/L_ACT_GENERIC_ACTIVITY_MGR')

--//////////////////////////////////////////////////////////////////////////////////

-- Script only local variables
local gGamestate =
{
    tPlayers = {},          -- players who have entered the game
    tWaitingPlayers = {},   -- players who haven't accepted yet
    iNumberOfPlayers = 0,   -- number of players given from ZoneLoadedInfo
    iCurrentSpawned = 0,    -- currently spawned enemies
    iTotalSpawned = 0,      -- total number of spawned mobs
    iWaveNum = 1,           -- current wave number
}

--//////////////////////////////////////////////////////////////////////////////////

-- helper function that prints out a variable to the log
function dumpVar(name,var,indent)
	if not self:GetVersioningInfo().bIsInternal then return end -- only do this print on internal builds
	
	if( indent == nil ) then
		indent = ""
	end
	if( type(var) == "table" ) then
		print( indent .. name .. " is a table with " .. table.maxn(var) .. " entries:" )
		local i,v = next(var)
		while i do
			dumpVar(i,v,indent .. "  ")
			i, v = next(var, i)
		end
	else
		local startOfLine = indent .. name .. " is "
		if( type(var) == "userdata" ) then
			if( type(var.GetID) == "function" ) then
				print( startOfLine .. "an object proxy with ID = " .. var:GetID() )
			else
				print( startOfLine .. "unknown userdata" )
			end
		elseif( var == nil ) then
			print( startOfLine .. "nil" )
	    elseif( var == true ) then
	        print( startOfLine .. "true" )
	    elseif( var == false ) then
	        print( startOfLine .. "false" )
		else
			print( startOfLine .. "a(n) " .. type(var) .. " with value = " .. var )
		end
	end
end

function onZoneLoadedInfo(self, msg)
	-- set the number of players that should be coming into the game
    self:SetNetworkVar('NumberOfPlayers', msg.maxPlayersSoft) 
end

----------------------------------------------------------------
-- Startup of the object
----------------------------------------------------------------
function baseStartup(self, newMsg)         
    -- Initialize the pseudo random number generator and return 
    math.randomseed( os.time() )
    self:SetVar('playersAccepted', 0)
    self:SetVar('playersReady', false)
end

function playerConfirmed(self)
    local playersConfirmed = {}
    
    for k,v in ipairs(gGamestate.tPlayers) do
        local bPass = false
        for key,value in ipairs(gGamestate.tWaitingPlayers) do
            if value == v then
                bPass = true
            end
        end
        
        if not bPass then                        
            table.insert(playersConfirmed, v)
        end
    end
    
    self:SetNetworkVar('PlayerConfirm_ScoreBoard', playersConfirmed)
end

----------------------------------------------------------------
-- Player has loaded into the map
----------------------------------------------------------------
function basePlayerLoaded(self, msg, newMsg)
	local playerID = msg.playerID:GetID()
	
	-- set player to auto-respawn
    msg.playerID:SetPlayerAllowedRespawn{dontPromptForRespawn = true}  
    
    msg.playerID:PlayerSetCameraCyclingMode{ cyclingMode = ALLOW_CYCLE_TEAMMATES, bAllowCyclingWhileDeadOnly = true }  	
	
    -- adding the players to the gGamestate tables
    table.insert(gGamestate.tPlayers, playerID)    
    table.insert(gGamestate.tWaitingPlayers, playerID)    
            
    -- setting up player ui
    self:SetNetworkVar('Define_Player_To_UI', playerID)
    
    -- freeze the player movement/controls
    if not self:GetNetworkVar('wavesStarted') then
        -- updating the scoreboard for the new players
        
        self:SetNetworkVar('Update_ScoreBoard_Players', gGamestate.tPlayers)        
        
		if gConstants.introCelebration then
			self:SetNetworkVar("WatchingIntro", gConstants.introCelebration .. "_" .. playerID)
		else
			self:SetNetworkVar('Show_ScoreBoard', true)
		end
    end
        
    -- move players to correct spawn locations
    SetPlayerSpawnPoints(self)
    
    if not self:GetNetworkVar('wavesStarted') then
        playerConfirmed(self) 
    else
        local player = msg.playerID
        
        if not playerID then return end
        table.insert(gGamestate.tWaitingPlayers, playerID)
        UpdatePlayer(self, player)        
        GetLeaderboardData(self, player, self:GetActivityID().activityID, 1)
        --set player stats to max
        player:SetHealth{health = player:GetMaxHealth{}.health}
        --print('max health = ' .. playerID:GetMaxHealth{}.health)
        player:SetArmor{armor = player:GetMaxArmor{}.armor}
        player:SetImagination{imagination = player:GetMaxImagination{}.imagination}
    end	
end

----------------------------------------------------------------
-- Player has exited the map
----------------------------------------------------------------
function basePlayerExit(self, msg, newMsg)
    local playerNum = 0
    --print('player ' .. msg.playerID:GetName().name .. ' has exited')
        
    for i = 1, table.maxn(gGamestate.tPlayers) do
        if gGamestate.tPlayers[i] == msg.playerID:GetID() then
            playerNum = i
        end
    end
    
    if playerNum ~= 0 then
        table.remove(gGamestate.tPlayers, playerNum)
        -- set player to not auto-respawn
        msg.playerID:SetPlayerAllowedRespawn{dontPromptForRespawn=false}
    end    
                
    playerNum = 0
    
    for k,v in ipairs(gGamestate.tWaitingPlayers) do
        if msg.playerID:GetID() == v then
            playerNum = k
        end
    end
    
    if playerNum ~= 0 then    
        table.remove(gGamestate.tWaitingPlayers, playerNum)
    end
        
    if not self:GetNetworkVar('wavesStarted') then  
        playerConfirmed(self)
        --print('num of players left waiting: ' .. table.maxn(gGamestate.tWaitingPlayers))
        
        if table.maxn(gGamestate.tPlayers) == 0 then return end
        
        if table.maxn(gGamestate.tWaitingPlayers) == 0 then           
            --print('All players have accepted')        
            ActivityTimerStopAllTimers(self)
            ActivityTimerStart(self, 'AllAcceptedDelay', 1, gConstants.startDelay) --(timerName, updateTime, stopTime)
        elseif table.maxn(gGamestate.tPlayers) > table.maxn(gGamestate.tWaitingPlayers) then
            if not self:GetVar('AcceptedDelayStarted') then
                self:SetVar('AcceptedDelayStarted', true)
                ActivityTimerStart(self, 'AcceptedDelay', 1, gConstants.acceptedDelay ) --(timerName, updateTime, stopTime)
            end
        end        
    else  
        UpdatePlayer(self, msg.playerID, true)
        
        if checkAllPlayersDead() then          
            GameOver(self)
        end
    end
    
    SetActivityValue(self, msg.playerID, 1, 0)
    SetActivityValue(self, msg.playerID, 2, 0)
    
    local numPlayers = self:GetNetworkVar('NumberOfPlayers')
    
    self:SetNetworkVar('NumberOfPlayers', numPlayers - 1)
end

----------------------------------------------------------------
-- Received a fire event messaged from someplace on the server
----------------------------------------------------------------
function baseFireEvent(self,msg, newMsg)   
    if msg.args == 'start' then
        StartWaves(self)  
    elseif msg.args == 'DeactivateRewards' then
        --print('fireevent DeactivateRewards')
        spawnerResetT(tSpawnerNetworks.rewardNetworks)
    end
end

----------------------------------------------------------------
-- A player had died
----------------------------------------------------------------
function basePlayerDied(self, msg, newMsg)	
    local curTime = ActivityTimerGetCurrentTime(self, 'ClockTick')
    local finalTime = GetActivityValue(self, msg.playerID, 1) --ActivityTimerGetCurrentTime(self, 'ClockTick')
    local finalWave = GetActivityValue(self, msg.playerID, 2)
    
    -- tell the client that the player has died and do GameOver
    self:NotifyClientZoneObject{name = 'Player_Died', paramObj = msg.playerID, rerouteID = msg.playerID, param1 = finalTime, param2 = finalWave, paramStr = tostring(checkAllPlayersDead())} --
    
	if not self:GetNetworkVar("wavesStarted") then 	
		msg.playerID:Resurrect()
		
		return
	end
	
	GameOver(self)
end

----------------------------------------------------------------
-- This is called when players hit the UI to exit or stop the game.
----------------------------------------------------------------
function baseMessageBoxRespond(self, msg, newMsg)	
    if (msg.identifier == "RePlay" ) then 	
        --print("************* RePlay *************"..msg.sender:GetName().name)	
        PlayerAccepted(self, msg.sender)  
        playerConfirmed(self)
    elseif (msg.identifier == "Exit_Question" ) and msg.iButton == 1 then 		
        --print("************* Exit *************"..msg.sender:GetName().name)
        ResetStats(msg.sender)        
        self:SetNetworkVar('Exit_Waves', msg.sender:GetID())  
        
        if returnLoc then
			-- send player to a specific location
			msg.sender:TransferToLastNonInstance{ playerID = msg.sender, bUseLastPosition = false, pos_x = returnLoc.x, pos_y = returnLoc.y, pos_z = returnLoc.z, rot_x = returnLoc.rx, rot_y = returnLoc.ry, rot_z = returnLoc.rz, rot_w = returnLoc.rw}  
		else
			msg.sender:TransferToLastNonInstance{ playerID = msg.sender, bUseLastPosition = true} 
		end
    end	
end

----------------------------------------------------------------
-- Custom function: Checks to see if all players have accepted,
-- if they have then the game is started.
----------------------------------------------------------------
function PlayerAccepted(self, playerID)
    local playerNum = 0
    
    -- check to see if the player who accepted is in the waiting players table
    for k,v in ipairs(gGamestate.tWaitingPlayers) do
        if playerID:GetID() == v then
            playerNum = k
            break
        end
    end
    
    if playerNum == 0 then return end
    
    table.remove(gGamestate.tWaitingPlayers, playerNum)
    --print('num of players left waiting: ' .. table.maxn(gGamestate.tWaitingPlayers))
    if table.maxn(gGamestate.tWaitingPlayers) == 0  and table.maxn(gGamestate.tPlayers) >= self:GetNetworkVar('NumberOfPlayers') then           
        --print('All players have accepted')        
        ActivityTimerStopAllTimers(self)
        ActivityTimerStart(self, 'AllAcceptedDelay', 1, gConstants.startDelay) --(timerName, updateTime, stopTime)
    else
        if not self:GetVar('AcceptedDelayStarted') then
            self:SetVar('AcceptedDelayStarted', true)
            ActivityTimerStart(self, 'AcceptedDelay', 1, gConstants.acceptedDelay) --(timerName, updateTime, stopTime)
        end
    end
end

function ResetStats(playerID)
    -- set the player's imag, health and armor to full
    if playerID:Exists() then
        --set player stats to max
        --print('health = ' .. playerID:GetHealth{}.health)
        --print('armor = ' .. playerID:GetArmor{}.armor)
        --print('imagination = ' .. playerID:GetImagination{}.imagination)
        playerID:SetHealth{health = playerID:GetMaxHealth{}.health}
        playerID:SetArmor{armor = playerID:GetMaxArmor{}.armor}
        playerID:SetImagination{imagination = playerID:GetMaxImagination{}.imagination}
        --print('new health = ' .. playerID:GetHealth{}.health)
        --print('new armor = ' .. playerID:GetArmor{}.armor)
        --print('new imagination = ' .. playerID:GetImagination{}.imagination)       
        --print('new imagination = ' .. playerID:GetImagination{}.imagination)    
    end
end

----------------------------------------------------------------
-- Custom function: Starts the game.
----------------------------------------------------------------
function StartWaves(self)    
    SetupActivity(self, 4)    
	self:SetNetworkVar("WatchingIntro", false)
    self:SetVar('playersReady', true)
    self:SetVar('baseMobSetNum', 1)
    self:SetVar('randMobSetNum', 1)
    self:SetVar('AcceptedDelayStarted', false)
    gGamestate.tWaitingPlayers = {}
    
    -- loop through the players and get them ready for the game to start
    for k,v in ipairs(gGamestate.tPlayers) do
        local playerID = GAMEOBJ:GetObjectByID(v)   
        
        if not playerID then return end
        
        table.insert(gGamestate.tWaitingPlayers, v)
        UpdatePlayer(self, playerID)        
        GetLeaderboardData(self, playerID, self:GetActivityID().activityID, 1)
        ResetStats(playerID)         
        
        if not self:GetVar('firstTimeDone') then
            --remove the activity cost from the player as they load into the map
            local takeCost = self:ChargeActivityCost{user = playerID}.bSucceeded
            --print('cost taken for: ' .. playerID:GetName().name .. ' = ' .. tostring(takeCost))
        end
    end
    
    self:SetVar('firstTimeDone', true)

    -- needed to get rewards -- taskType = DB name for series of achievments, target = activityID, value1 = what it will evaluate 
    local sTaskType = 'survival_time_team'
    
    if table.maxn(gGamestate.tPlayers) == 1 then
        sTaskType = 'survival_time_solo'
    end
    
    self:SetVar('missionType', sTaskType)    
    self:SetNetworkVar('wavesStarted', true)
    self:SetNetworkVar('Start_Wave_Message', "Start!")  
end

----------------------------------------------------------------
-- Custom function: Happens when all players have died, this 
-- stops all running processes and resets gGamestate variables
----------------------------------------------------------------
function GameOver(self, bWon)  
    if not checkAllPlayersDead() and not bWon then return end
    
    ActivityTimerStopAllTimers(self)
        
    -- reset ticks
    gGamestate.iWaveNum = 1                     -- current wave number
    gGamestate.iTotalSpawned = 0                -- number of mobs smashed
    gGamestate.iCurrentSpawned = 0
    self:SetNetworkVar('wavesStarted', false)
	self:SetNetworkVar("Start_Cool_Down", false)
    SetPlayerSpawnPoints(self)
    
    clearSpawners()
        
    for k,v in ipairs(gGamestate.tPlayers) do   
        local playerID = GAMEOBJ:GetObjectByID(v)
        
        if not playerID then return end
        
        local timeVar = GetActivityValue(self, playerID, 1)
        local scoreVar = GetActivityValue(self, playerID, 0)
        local waveVar = GetActivityValue(self, playerID, 2)
        
        self:NotifyClientZoneObject{name = 'Update_ScoreBoard', paramObj = playerID, paramStr = tostring(waveVar), param1 = timeVar}
        
        if bWon then
			SetPlayerSpawnPoints(self)
			self:SetNetworkVar('Show_ScoreBoard', true)
		else
			playerID:Resurrect()
		end
        
        local sTaskType = self:GetVar('missionType') or 'survival_time_team'
        
        playerID:UpdateMissionTask{ taskType = sTaskType, value = timeVar, value2 = self:GetActivityID().activityID} --  target = self, 
        
        -- update mission 479 if the player is on it and has lasted 60 seconds
        local misState = playerID:GetMissionState{missionID = 479}.missionState
        
        if  misState > 1  and misState < 4 and timeVar >= 60 then
            playerID:UpdateMissionTask{taskType = "complete", value = 479, value2 = 1, target = self}
        end
        
        -- this is to have everyone get their own time at the end of the match
        StopActivity(self, playerID, waveVar, timeVar, scoreVar)  
        
        --print('***************************')
        --print('send update mission task')
        --print(playerID:GetName().name .. ' ' .. self:GetName().name)
        --print(sTaskType)
        --print(self:GetLOT().objtemplate)
        --print(timeVar)
        --print('***************************')
        
    end
end

----------------------------------------------------------------
-- Custom function: If the game has ended and the player won
----------------------------------------------------------------
function GameWon(self)      
	-- kill the activity timers
    ActivityTimerStopAllTimers(self)
    
    local resetTime = wavePreloads[gGamestate.iWaveNum - 1].winDelay or 30
    
    -- start the reset timer
    ActivityTimerStart(self, 'GameOver_Win', 1, resetTime) --(timerName, updateTime, stopTime)  
	self:SetNetworkVar('Start_Timed_Wave', {resetTime, gGamestate.iWaveNum - 1})
end

----------------------------------------------------------------
-- Called when the player is resurrected
----------------------------------------------------------------
function basePlayerResurrected(self, msg, newMsg) 
	self:NotifyClientZoneObject{name = 'Player_Res', paramObj = msg.playerID, rerouteID = msg.playerID}
	
	if self:GetNetworkVar("wavesStarted") then return end
	
	-- tell the client to show the scoreboard
    self:SetNetworkVar('Show_ScoreBoard', true)    
    
	TelePlayerToSpawnPoint(self, msg.playerID)
end

----------------------------------------------------------------
-- Custom function: Checks to see if all the players are dead,
-- then stops the game.
----------------------------------------------------------------
function checkAllPlayersDead()    
    -- loop through the players and see if they are all dead
    for k,v in ipairs(gGamestate.tPlayers) do
        local playerID = GAMEOBJ:GetObjectByID(v)
        
        if playerID:Exists() then        
			if not playerID:IsDead().bDead then
				return false
			end
        end
    end
    
    return true
end

----------------------------------------------------------------
-- Teleports the players to the correct locations for the start of the game
----------------------------------------------------------------
function SetPlayerSpawnPoints(self)
	-- looop through the players and teleprot them to the correct positions
    for k,v in ipairs(gGamestate.tPlayers) do           
        local playerID = GAMEOBJ:GetObjectByID(v)
        
        TelePlayerToSpawnPoint(self, playerID, k)
    end
end

----------------------------------------------------------------
-- Teleports the players to the correct locations for the start of the game
----------------------------------------------------------------
function TelePlayerToSpawnPoint(self, playerID, spawnNum)
	if playerID:Exists() then        
		if not spawnNum then
			for k,v in ipairs(gGamestate.tPlayers) do  
				if playerID:GetID() == v then
					spawnNum = k
				end
			end
		end
		
		local spawnObj = self:GetObjectsInGroup{ group = 'P' .. spawnNum .. '_Spawn', ignoreSpawners = true }.objects[1]
		
		if spawnObj then
			local pos = spawnObj:GetPosition().pos
			local rot = spawnObj:GetRotation()
		
			playerID:Teleport{pos = pos, x = rot.x, y = rot.y, z = rot.z, w = rot.w, bSetRotation = true}       
		end 
    end
end

----------------------------------------------------------------
-- Custom function: Spawns mobs on a spawner network, Now...
----------------------------------------------------------------
function spawnNow(spawnerName, spawnNum, spawnLOT)
    local spawner = LEVEL:GetSpawnerByName(spawnerName)
    
    if spawner then
        --print('*** Spawn Now!!')
        -- set the LOT to spawn if it's sent to the function
        if spawnLOT then
            spawner:SpawnerSetSpawnTemplateID{iObjTemplate = spawnLOT}
        end
        
        -- set the number of LOT's to spawn if it's sent to the function
        if spawnNum then
            spawner:SpawnerSetMaxToSpawn{iNum = spawnNum}
            spawner:SpawnerSetNumToMaintain{uiNum = spawnNum}
        end
        
        -- activate and reset the spawner network
        spawner:SpawnerActivate()
        spawner:SpawnerReset()
    end
end

----------------------------------------------------------------
-- Custom function: Decides how to spawn mobs
----------------------------------------------------------------
function spawnWave(self)        
	-- dont do this if the minigame hasn't started
    if not self:GetNetworkVar('wavesStarted') then return end
    
    local spawnNum = gGamestate.iWaveNum
    local waveLoad = wavePreloads[spawnNum]
    
    -- there is no wavePreload for this spawnNum end game and print warning
    if not waveLoad then
		if self:GetVersioningInfo().bIsInternal then -- only do this print on internal builds
			print("** missing waveLoad **")
        end
        
        GameOver(self, true)        
        
        return
    end
    
    --print("** starting wave #" .. gGamestate.iWaveNum .. " **")      
    
    if waveLoad.winDelay then -- if we have a winDelay this is the last wave
        -- tell clients to display win message
        self:SetNetworkVar('Won_Wave', gGamestate.iWaveNum)
        
        -- if we dont want to wait for the notify from some object (treasureChest) then do end the game
        if not waveLoad.winNotify then
            GameWon(self)
        end
    
		for k,playerID in ipairs(gGamestate.tPlayers) do		
			local player = GAMEOBJ:GetObjectByID(playerID)
			
			if player:Exists() then
				if player:IsDead().bDead then
					player:Resurrect()
				end
			end
		end
    else     
		-- if we have an optTime start the timer for the next wave
		if waveLoad.optTime then
			--print("Wave time = " .. waveLoad.optTime)
			ActivityTimerStart(self, 'TimedWave', 1, waveLoad.optTime) --(timerName, updateTime, stopTime)
			self:SetNetworkVar('Start_Timed_Wave', {waveLoad.optTime, gGamestate.iWaveNum})
		else
			-- display new wave message
			self:SetNetworkVar('New_Wave', gGamestate.iWaveNum)
		end
    end
    

    
    -- if we have an optional event send it out to the eventGroup
    if waveLoad.optEvent then
        -- see if we have an optEvent to override the global eventGroup
        local groupName = waveLoad.optEventGroup or gGamestate.eventGroup
        
        if groupName then
            -- get the objects in the group
            local group = GAMEOBJ:GetObjectsInGroup{group = groupName, ignoreSpawners = true}
            
            -- fireEvent to each object in the group
            for k,obj in ipairs(group) do
                obj:FireEvent{senderID = self, args = waveLoad.optEvent}
            end
        end
    end    
	
	-- if we have a celebration to play then do that
	if waveLoad.optCelebration then
        self:SetNetworkVar('startCelebration', waveLoad.optCelebration)
	end
	
	-- if we have a celebration to play then do that
	if waveLoad.optCinematic then
		local cineTime = LEVEL:GetCinematicInfo(waveLoad.optCinematic) or 0
		
		-- if we have a valid cinematic then start the cinematicDone timer and tell the client to play it
		if cineTime > 0 then 
			ActivityTimerStart(self, "cinematicDone", cineTime, cineTime)
			self:SetNetworkVar('startCinematic', waveLoad.optCinematic)
		end
	end
	
	-- reset the current spawned # of Objs
    gGamestate.iCurrentSpawned = 0    
    
    -- spawn the mobs on the spawners based on the waveLoad
    for k,tMob in ipairs(waveLoad) do
        if tMob.name then
            spawnNow(tMob.name, tMob.num, tMob.LOT)
            
            local num = tMob.num or 1
            
            gGamestate.iCurrentSpawned = gGamestate.iCurrentSpawned + num
        end
    end    
    
    -- increment the waveNum and set the current spawned
    gGamestate.iWaveNum = gGamestate.iWaveNum + 1 
    --print("** Spawned Enemies = " .. gGamestate.iCurrentSpawned)
    gGamestate.iTotalSpawned = gGamestate.iTotalSpawned + gGamestate.iCurrentSpawned
    
	self:SetNetworkVar("numRemaining", gGamestate.iCurrentSpawned)
end

----------------------------------------------------------------
-- Custom function: Clears the spawner networks
----------------------------------------------------------------
function clearSpawners()
    --search through the list of spawner names and clear them
    for k,name in pairs(spawnerNames) do 
        local spawner = LEVEL:GetSpawnerByName(name)
        
        if spawner then                            
            spawner:SpawnerDestroyObjects()            
            spawner:SpawnerDeactivate()
            spawner:SpawnerReset()
        end
    end
end

----------------------------------------------------------------
-- Received a notify object message 
----------------------------------------------------------------
function UpdateSpawnedEnemies(self, enemy, score)
	if not self:GetNetworkVar("wavesStarted") then return end
    
    gGamestate.iCurrentSpawned = gGamestate.iCurrentSpawned - 1      
    
    --print("currentSpawned = " .. gGamestate.iCurrentSpawned)
    if enemy:Exists() then
		-- check to make sure the player is in the activity
		if  enemy:IsCharacter().isChar and IsPlayerInActivity(self, enemy) then        
			-- update kill score
			UpdateActivityValue(self, enemy, 0, score) 
		end
	end
    
    if gGamestate.iCurrentSpawned < 1 then     
		local nextWave = gGamestate.iWaveNum
        local curTime = ActivityTimerGetCurrentTime(self, 'ClockTick')
        local curWave = gGamestate.iWaveNum-1
		
        -- if there's no more waves then we won and dont want to store out info for the last wave
        if nextWave >= table.maxn(wavePreloads) then
			-- if we dont want to wait for the notify from some object (treasureChest) then do end the game
			if not wavePreloads[nextWave] then
				GameWon(self)
				
				return false
			end
			
			-- kill the activity timers
			ActivityTimerStopAllTimers(self)    
			-- update the timer with the current time
			self:SetNetworkVar('Update_Timer', curTime)   
        end

		ActivityTimerStart(self, 'WaveCompleteDelay', gConstants.waveCompleteDelay, gConstants.waveCompleteDelay) --(timerName, updateTime, stopTime) 
		
        --print("*** Next round in " .. gConstants.waveTime .. " seconds ***")
        -- set player score
        
		for k,playerID in ipairs(gGamestate.tPlayers) do		
			local player = GAMEOBJ:GetObjectByID(playerID)
			
			if player:Exists() then
				SetActivityValue(self, player, 1, curTime)
				SetActivityValue(self, player, 2, curWave)
        
				local waveMissions = wavePreloads[curWave].updateMissions or {}
				
				for k, missionID in ipairs(waveMissions) do
					player:UpdateMissionTask{taskType = "complete", value = missionID, value2 = 1, target = self}
				end		
				
				-- update solo missions when there is only one player
				if table.maxn(gGamestate.tPlayers) == 1 then
					local waveSoloMissions = wavePreloads[curWave].soloUpdateMissions or {}
					
					for k, missionID in ipairs(waveSoloMissions) do
						player:UpdateMissionTask{taskType = "complete", value = missionID, value2 = 1, target = self}
					end		
				end
			end
		end
		
        self:SetNetworkVar('Wave_Complete', {curWave, curTime})
        
        return true
    end
    
	self:SetNetworkVar("numRemaining", gGamestate.iCurrentSpawned)
	
	return false
end

function UpdateMissionForAllPlayers(self, missionID)
	for k,playerID in ipairs(gGamestate.tPlayers) do		
		local player = GAMEOBJ:GetObjectByID(playerID)
		
		if player:Exists() then
			player:UpdateMissionTask{taskType = "complete", value = missionID, value2 = 1, target = self}
		end
	end
end

----------------------------------------------------------------
-- When activity is stopped this is needed to update the leaderboard.
----------------------------------------------------------------
function baseDoCalculateActivityRating(self, msg)    
    msg.outActivityRating = msg.fValue2
    
    return msg
end

-- activity timers 
----------------------------------------------------------------
-- When ActivityTimerUpdate is sent, basically when a timer hits it updateInterval.
----------------------------------------------------------------
function onActivityTimerUpdate(self, msg)
    if msg.name == "AcceptedDelay" then
        --print('update delay timer to ' .. math.ceil(msg.timeRemaining))
        self:SetNetworkVar('Update_Default_Start_Timer', math.ceil(msg.timeRemaining))                      
    elseif msg.name == "ClockTick" then
        self:SetNetworkVar('Update_Timer', msg.timeElapsed)                            
    elseif msg.name == "NextWaveTick" or msg.name == "TimedWave" or msg.name == "GameOver_Win" then
		self:SetNetworkVar('Update_Cool_Down', math.ceil(msg.timeRemaining))  
    end    
end

----------------------------------------------------------------
-- When ActivityTimerDone is sent, basically when the activity timer has reached it's duration.
-- TODO: make the waves not respawn until all the mobs in a wave are dead
----------------------------------------------------------------
function onActivityTimerDone(self, msg)
    if msg.name == "AcceptedDelay" then --or msg.name == "AllAcceptedDelay"       
        --print('update delay timer to 0')
        self:SetNetworkVar('Update_Default_Start_Timer', 0)                      
        ActivityTimerStart(self, 'AllAcceptedDelay', 1, 1)
    elseif msg.name == "AllAcceptedDelay" then --or msg.name == "AllAcceptedDelay"       
        --print('accepted delay *******************************')         
        self:SetNetworkVar('Clear_Scoreboard', true)                      
        ActivityTimerStart(self, 'StartDelay', 4, 4) --(timerName, updateTime, stopTime)  
        StartWaves(self)    
    elseif msg.name == "StartDelay" then        
        --print('adding in timers *******************************')        
        ActivityTimerStart(self, 'ClockTick', 1) --(timerName, updateTime, stopTime)   
        spawnWave(self) 
        ActivityTimerStart(self, 'PlaySpawnSound', 3, 3) --(timerName, updateTime, stopTime)          
    elseif msg.name == "PlaySpawnSound" then
        -- play war horn sound
        for k,v in ipairs(gGamestate.tPlayers) do      
            GAMEOBJ:GetObjectByID(v):PlayNDAudioEmitter{m_NDAudioEventGUID = '{ca36045d-89df-4e96-a317-1e152d226b69}'}             
        end                            
    elseif msg.name == "NextWaveTick" then
        self:SetNetworkVar("Start_Cool_Down", false)
        spawnWave(self)  
    elseif msg.name == "WaveCompleteDelay" then
        self:SetNetworkVar('Start_Cool_Down', gConstants.waveTime)    
		ActivityTimerStart(self, 'NextWaveTick', 1, gConstants.waveTime) --(timerName, updateTime, stopTime) 
    elseif msg.name == "TimedWave"  then
		ActivityTimerStart(self, 'WaveCompleteDelay', gConstants.waveCompleteDelay, gConstants.waveCompleteDelay) --(timerName, updateTime, stopTime) 
        
        local curTime = ActivityTimerGetCurrentTime(self, 'ClockTick')
        local curWave = gGamestate.iWaveNum-1
        
        self:SetNetworkVar('Wave_Complete', {curWave, curTime})
    elseif msg.name == "GameOver_Win" then
        GameOver(self, true)  
    elseif msg.name == "cinematicDone" then
		local bossObjs = self:GetObjectsInGroup{ group = 'boss', ignoreSpawners = true }.objects
		
		for k, obj in ipairs(bossObjs) do
			obj:NotifyObject{ObjIDSender = self, name = "startAI"}
		end
    end
end 
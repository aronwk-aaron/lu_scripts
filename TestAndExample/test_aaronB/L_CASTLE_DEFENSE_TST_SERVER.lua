--------------------------------------------------------------

-- L_CASTLE_DEFENSE_TST_SERVER.lua

-- Server side test script for Castle Defense prototyping.
-- created abeechler ... 8/5/11

--------------------------------------------------------------

-- 13925 Castle Corner Inner 2 9499 3 4210
-- 13926 Castle Gate 2 9503 3 4214
-- 13927 Castle Tower 2 9507 3 4218
-- 13928 Castle Wall Bridge 2 9508 3 4219
-- 13929 Castle Wall Straight 2 9514 3 4225
-- 13930 Castle Wall T 2 9517 3 4228
-- 13931 Castle Wall Tower With Top
-- 13932 Castle Wall Widening 2 9520 3 4231

-- 14202 Castle Wall Tower With Top QB
-- 14206 Castle Corner Inner QB
-- 14207 Castle Gate QB
-- 14208 Castle Tower QB
-- 14209 Castle Wall Bridge QB
-- 14210 Castle Wall Straight QB
-- 14211 Castle Wall T QB
-- 14213 Castle Wall Widening QB

-- 16131 Center Object

--if(child:GetLOT().objtemplate == gCenterLOT) then
--    if child:GetID() == gCenterIDs.center1:GetID() then
--        print("team 2 wins")
--        message_string = "TEAM 2 WINS!!"
--        bDisplayMessage = true
--    elseif child:GetID() == gCenterIDs.center2:GetID() then
--        print("team 1 wins")
--        message_string = "TEAM 1 WINS!!"
--        bDisplayMessage = true
--    end
--end

--------------------------------------------------------------
-- Includes
--------------------------------------------------------------
require('ai/ACT/L_ACT_GENERIC_ACTIVITY_MGR')


-- Center piece lot number
local gCenterLOT = 16131

local gCenterSpawned = 0

local gGameOver = false

-- Center piece object IDs
local gCenterIDs =
{
	center1 = 0,
	center2 = 0
}

local HealthCBLOT = 16206
local ShieldCBLOT = 16207
local DragonCBLOT = 16208
local AttackCBLOT = 16209

local ShieldCBCount = 0
local DragonCBCount = 0
local AttackCBCount = 0
local HealthCBCount = 0

local team1Score = 0
local team2Score = 0

--//////////////////////////////////////////////////////////////////////////////////
-- User Config local variables
local gConstants = 
{
    acceptedDelay = 2,          -- how long to wait after all the players have accepted before starting the game.
    startDelay = 2,             -- how long to wait after all the players have accepted before starting the game.
    returnZone = 89,          -- map number the player will return to on exit
    returnLoc = { x = 0, y = 0, z = 0 } -- {x,y,z} location that the player will be teleported to in the returnZone on exit
}


--============================================================
-- Script only local variables
local gGamestate =
{
    tPlayers = {},          -- players who have entered the game
    tWaitingPlayers = {},   -- players who haven't accepted yet
    iNumberOfPlayers = 0	-- number of players given from ZoneLoadedInfo
}


----------------------------------------------------------------
-- Received when the script is loaded
----------------------------------------------------------------
function onStartup(self)
    -- Initialize the pseudo random number generator and return 
    math.randomseed(os.time())
    self:SetVar('playersAccepted', 0)
    self:SetVar('playersReady', false)
    --self:MiniGameSetParameters{numTeams = 1, playersPerTeam = 4}
     
end

function onChildRemoved(self, msg)

	local child = msg.childID
	
	local message_string = "test"
	local bDisplayMessage = false
	
	if(gGameOver == true) then return end
	
	if(bDisplayMessage == true) then
		gGameOver = true
		for i = 1, table.maxn(gGamestate.tPlayers) do
			local playerID = GAMEOBJ:GetObjectByID(gGamestate.tPlayers[i]) 
			playerID:DisplayMessageBox{bShow = true, 
											imageID = 1, 
											text = message_string, 
											callbackClient = self, 
											identifier = "score thing"}
		end
	end
	
end


----------------------------------------------------------------
-- Player is fully loaded and has completed the load handshake process.
----------------------------------------------------------------
function onPlayerReady(self, msg)
     if not self:GetVar('SurvivalStartupComplete') then
        self:SetVar('SurvivalStartupComplete', true)
    end
end

----------------------------------------------------------------
-- Player has loaded into the map
----------------------------------------------------------------
function onPlayerLoaded(self, msg)	
	
   -- adding the players to the gGamestate tables
    table.insert(gGamestate.tPlayers, msg.playerID:GetID())    
    table.insert(gGamestate.tWaitingPlayers, msg.playerID:GetID())    
        
    -- adding player to mini game team
    --self:MiniGameAddPlayer{playerID = msg.playerID}    
    --self:MiniGameSetTeam{playerID = msg.playerID, teamID = 1}

    -- setting up player ui
    self:SetNetworkVar('Define_Player_To_UI', msg.playerID:GetID())
    
    -- freeze the player movement/controls
    if not self:GetNetworkVar('wavesStarted') then
        -- updating the scoreboard for the new players
        
        self:SetNetworkVar('Update_ScoreBoard_Players', gGamestate.tPlayers)
        
        self:SetNetworkVar('Show_ScoreBoard', true)
    end
        
    -- TODO set this up to work with teams
    -- move players to correct spawn locations
    SetPlayerSpawnPoints(self)
    
    msg.playerID:PlayerSetCameraCyclingMode{ cyclingMode = ALLOW_CYCLE_TEAMMATES, bAllowCyclingWhileDeadOnly = true }  
    
    if not self:GetNetworkVar('wavesStarted') then
        playerConfirmed(self) 
    else
        local playerID = msg.playerID
        
        if not playerID then return end
        table.insert(gGamestate.tWaitingPlayers, v)
        UpdatePlayer(self, playerID)        
        --playerID:SetUserCtrlCompPause{bPaused = false}
        GetLeaderboardData(self, playerID, self:GetActivityID().activityID, 50)
        --set player stats to max
        playerID:SetHealth{health = playerID:GetMaxHealth{}.health}
        --print('max health = ' .. playerID:GetMaxHealth{}.health)
        playerID:SetArmor{armor = playerID:GetMaxArmor{}.armor}
        playerID:SetImagination{imagination = playerID:GetMaxImagination{}.imagination}
    end         
end

----------------------------------------------------------------
-- Player has exited the map
----------------------------------------------------------------
function onPlayerExit(self, msg)
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
        --print('num of players left waiting: ' .. #gGamestate.tWaitingPlayers)
        
        if #gGamestate.tPlayers == 0 then return end
        
        if table.maxn(gGamestate.tWaitingPlayers) == 0 then           
            --print('All players have accepted')        
            ActivityTimerStopAllTimers(self)
            ActivityTimerStart(self, 'AllAcceptedDelay', 1, gConstants.startDelay) --(timerName, updateTime, stopTime)
        elseif #gGamestate.tPlayers > #gGamestate.tWaitingPlayers then
            if not self:GetVar('AcceptedDelayStarted') then
                self:SetVar('AcceptedDelayStarted', true)
                ActivityTimerStart(self, 'AcceptedDelay', 1, gConstants.acceptedDelay ) --(timerName, updateTime, stopTime)
            end
        end        
    else  
        UpdatePlayer(self, msg.playerID, true)
        
        if checkAllPlayersDead() then          
            GameOver(self, msg.playerID)
        end
    end
    
    SetActivityValue(self, msg.playerID, 1, 0)
    local numPlayers = self:GetNetworkVar('NumberOfPlayers')
    
    self:SetNetworkVar('NumberOfPlayers', numPlayers - 1)
end


function onZoneLoadedInfo(self, msg)
    self:SetNetworkVar('NumberOfPlayers', msg.maxPlayersSoft)
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
-- This is called when players hit the UI to exit or stop the game.
----------------------------------------------------------------
function baseMessageBoxRespond(self, msg, newMsg)
    if (msg.identifier == "RePlay" ) then 	
        PlayerAccepted(self, msg.sender)  
        playerConfirmed(self)
    elseif (msg.identifier == "Exit_Question" ) and msg.iButton == 1 then 		
        ResetStats(msg.sender)        
        self:SetNetworkVar('Exit_Waves', msg.sender:GetID())  
        -- send player to a specific location
        msg.sender:TransferToLastNonInstance{ playerID = msg.sender, bUseLastPosition = false, pos_x = 131.83, pos_y = 376, pos_z = -180.31, rot_x = 0, rot_y = -0.268720, rot_z = 0, rot_w = 0.963218}  
    end	
end


----------------------------------------------------------------
-- Custom function: Checks to see if all players have accepted,
-- if they have then the game is started.
----------------------------------------------------------------
function PlayerAccepted(self, playerID)
    local playerNum = 0
    
    print("PLAYER ACCEPTED")
    
    -- Figure out what player num this guy is.
    for k,v in ipairs(gGamestate.tWaitingPlayers) do
        if playerID:GetID() == v then
            playerNum = k
        end
    end
    
    
    if playerNum == 0 then return end
    
    -- TODO make sure this value is correct
    table.remove(gGamestate.tWaitingPlayers, playerNum)
    if table.maxn(gGamestate.tWaitingPlayers) == 0  and #gGamestate.tPlayers >= self:GetNetworkVar('NumberOfPlayers') then   
		print("accepted option 1")                
        ActivityTimerStopAllTimers(self)
        ActivityTimerStart(self, 'AllAcceptedDelay', 1, gConstants.startDelay) --(timerName, updateTime, stopTime)
    else
        if not self:GetVar('AcceptedDelayStarted') then
			print("accepted option 2")        
            self:SetVar('AcceptedDelayStarted', true)
            --ActivityTimerStart(self, 'AcceptedDelay', 1, gConstants.acceptedDelay) --(timerName, updateTime, stopTime)
            ActivityTimerStart(self, 'AcceptedDelay', 1, 2) --(timerName, updateTime, stopTime)
        end
    end
end


function ResetStats(playerID)
    -- set the player's imag, health and armor to full
    if playerID:Exists() then
        --set player stats to max
        playerID:SetHealth{health = playerID:GetMaxHealth{}.health}
        playerID:SetArmor{armor = playerID:GetMaxArmor{}.armor}
        playerID:SetImagination{imagination = playerID:GetMaxImagination{}.imagination}
    end
end


----------------------------------------------------------------
-- Custom function: Starts the game.
----------------------------------------------------------------
function StartWaves(self)    
    SetupActivity(self, 4)  
	self:ActivityStart()
    self:SetVar('playersReady', true)
    self:SetVar('AcceptedDelayStarted', false)
    gGamestate.tWaitingPlayers = {}
    
    for k,v in ipairs(gGamestate.tPlayers) do
        local playerID = GAMEOBJ:GetObjectByID(v)   
        
        if not playerID then return end
        
        table.insert(gGamestate.tWaitingPlayers, v)
        UpdatePlayer(self, playerID)        
        GetLeaderboardData(self, playerID, self:GetActivityID().activityID, 50)
        ResetStats(playerID)         
        
        if not self:GetVar('firstTimeDone') then
            --remove the activity cost from the player as they load into the map
            local takeCost = self:ChargeActivityCost{user = playerID}.bSucceeded
        end
    end
    
    self:SetVar('firstTimeDone', true)

    -- needed to get rewards -- taskType = DB name for series of achievments, target = activityID, value1 = what it will evaluate 
    local sTaskType = 'survival_time_team'
    
    if #gGamestate.tPlayers == 1 then
        sTaskType = 'survival_time_solo'
    end
    
    self:SetVar('missionType', sTaskType)
    
    --print('start smashables')
    self:SetNetworkVar('wavesStarted', true)
    self:SetNetworkVar('Start_Wave_Message', "Start!")  
    
    -- Start the score accumulation
    team1Score = 0
    team2Score = 0
    GAMEOBJ:GetTimer():AddTimerWithCancel(1, "printScore", self)

end

function onTimerDone(self,msg)

	if msg.name == "printScore" then
	    printScore(self)
	    GAMEOBJ:GetTimer():AddTimerWithCancel(1, "printScore", self)
	end
	
end

function printScore(self) 
    local team1Walls = self:GetVar("team1Walls") or {}
    local team2Walls = self:GetVar("team2Walls") or {}
    
    -- Get Team 1 Score
    team1Score = team1Score + calculateScoreTally(self, "Team1")
    -- Get Team 2 Score
    team2Score = team2Score + calculateScoreTally(self, "Team2")
    
    -- Print Out!
    print("------------------------------")
    print("TEAM                SCORE")
    print(string.format("%-20s %5d", "Team 1", team1Score))    
    print(string.format("%-20s %5d", "Team 2", team2Score))
    print("------------------------------")  
end

function calculateScoreTally(self, groupName)
    local scoreTally = 0
    local wallObjects = self:GetObjectsInGroup{group = groupName, ignoreSpawners = false}.objects
    
    for i, wall in ipairs(wallObjects) do
        if(wall:Exists() and wall:GetVar("built")) then
            scoreTally = scoreTally + 1
        end
    end
    
    return scoreTally
end

----------------------------------------------------------------
-- Custom function: Checks to see if all the players are dead,
-- then stops the game.
----------------------------------------------------------------
function checkAllPlayersDead()
    local deadPlayers = 0
    
    for k,v in ipairs(gGamestate.tPlayers) do
        local playerID = GAMEOBJ:GetObjectByID(v)
        
        if not playerID then return end
        
        if playerID:IsDead().bDead then
            deadPlayers = deadPlayers + 1
        end
    end
    
    if deadPlayers == table.maxn(gGamestate.tPlayers) then
        return true
    end
    
    return false
end

-- Create a SetPlayerSpawnPoints per team
function SetPlayerSpawnPoints(self)
    for k,v in ipairs(gGamestate.tPlayers) do           
        local playerID = GAMEOBJ:GetObjectByID(v)
        
        if not playerID then return end
        
        local spawnObj = self:GetObjectsInGroup{ group = 'P' .. k .. '_Spawn', ignoreSpawners = true }.objects[1]
        
        if spawnObj then
            local pos = spawnObj:GetPosition().pos
            local rot = spawnObj:GetRotation()
        
			print("SPAWN POINT FOUND")
            playerID:Teleport{pos = pos, x = rot.x, y = rot.y, z = rot.z, w = rot.w, bSetRotation = true}       
        end 
    end
end

----------------------------------------------------------------
-- Custom function: Happens when all players have died, this 
-- stops all running processes and resets gGamestate variables
----------------------------------------------------------------
function GameOver(self, player)  
    if not checkAllPlayersDead() then return end
    
    local finalTime = ActivityTimerGetCurrentTime(self, 'ClockTick')
    
    ActivityTimerStopAllTimers(self)
        
    for k,v in ipairs(gGamestate.tPlayers) do   
        local playerID = GAMEOBJ:GetObjectByID(v)
        
        if not playerID then return end
        
        local timeVar = GetActivityValue(self, playerID, 1)
        local scoreVar = GetActivityValue(self, playerID, 0)
        
        self:NotifyClientZoneObject{name = 'Update_ScoreBoard', paramObj = playerID, paramStr = tostring(scoreVar), param1 = timeVar}
        
        playerID:Resurrect()
          
        -- this is to have everyone get their own time at the end of the match
        StopActivity(self, playerID, scoreVar, timeVar)  
        
    end
        
    self:SetNetworkVar('wavesStarted', false)        
    
    SetPlayerSpawnPoints(self)
	
end

function basePlayerResurrected(self, msg, newMsg)
    self:SetNetworkVar('Show_ScoreBoard', true)
end

----------------------------------------------------------------
-- When activity is stopped this is needed to update the leaderboard.
----------------------------------------------------------------
function onDoCalculateActivityRating(self, msg)
    -- get the time for the player    
    --print('Score = ' .. msg.fValue1)
    --print('Time = ' .. msg.fValue2)
    
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
    elseif msg.name == "SpawnTick" and not self:GetVar('isCoolDown') then
        --spawnMobs(self)                           
    end    
end

----------------------------------------------------------------
-- When ActivityTimerDone is sent, basically when the activity timer has reached it's duration.
----------------------------------------------------------------
function onActivityTimerDone(self, msg)
    if msg.name == "AcceptedDelay" then --or msg.name == "AllAcceptedDelay"       
        --print('update delay timer to 0')
        self:SetNetworkVar('Update_Default_Start_Timer', 0)                      
        ActivityTimerStart(self, 'AllAcceptedDelay', 1, 1)
    elseif msg.name == "AllAcceptedDelay" then --or msg.name == "AllAcceptedDelay"       
        --print('accepted delay *******************************')         
        self:SetNetworkVar('Clear_Scoreboard', true)                      
        ActivityTimerStart(self, 'StartDelay', 3, 3) --(timerName, updateTime, stopTime)  
        StartWaves(self)    
    elseif msg.name == "StartDelay" then        
        --print('adding in timers *******************************')        
        ActivityTimerStart(self, 'ClockTick', 1) --(timerName, updateTime, stopTime) 
       -- spawnMobs(self)
        ActivityTimerStart(self, 'PlaySpawnSound', 3, 3) --(timerName, updateTime, stopTime)          
    elseif msg.name == "CoolDownStart" then
        --print('cool down start timer *******************************')
        self:SetVar('isCoolDown', true)
        ActivityTimerStop(self, 'SpawnTick')  
        
        --print('stopping clock tick')          
    elseif msg.name == "CoolDownStop" then       
        --print('cool down stop timer *******************************')
        self:SetVar('isCoolDown', false)       

       -- spawnMobs(self)         
        ActivityTimerStart(self, 'PlaySpawnSound', 3, 3) --(timerName, updateTime, stopTime)          
    elseif msg.name == "PlaySpawnSound" then
        -- play war horn sound
        for k,v in ipairs(gGamestate.tPlayers) do      
            GAMEOBJ:GetObjectByID(v):PlayNDAudioEmitter{m_NDAudioEventGUID = '{ca36045d-89df-4e96-a317-1e152d226b69}'}             
        end      
    end
end


--============================================================

--============================================================
-- Game messages sent to the BASE_SURVIVAL_SERVER.lua file, these
-- must be in this script. Only change to add custom functionality, 
-- but leav e the base*message*(self, msg, newMsg) in the function.
--============================================================


----------------------------------------------------------------
-- Received a fire event messaged from the client
----------------------------------------------------------------
function onFireEventServerSide(self, msg)   
    baseFireEventServerSide(self, msg, newMsg)
end

----------------------------------------------------------------
-- A player has respawned
----------------------------------------------------------------
function onPlayerResurrected(self, msg)
    basePlayerResurrected(self, msg, newMsg)
end

----------------------------------------------------------------
-- Received a notify object message 
----------------------------------------------------------------
function onNotifyObject(self, msg)

	-- add to this CBs ref count. If it is 4 then do whatever
	if(msg.name == "cb_added") then
		if(msg.param1 == HealthCBLOT) then
			HealthCBCount = HealthCBCount + 1 
			if(HealthCBCount == 4) then
				print("ALL 4")
				-- do something
			end
		elseif(msg.param1 == DragonCBLOT) then
			DragonCBCount = DragonCBCount + 1
			if(DragonCBCount == 4) then
				print("ALL 4")
				-- do something
			end
		
		elseif(msg.param1 == AttackCBLOT) then
			AttackCBCount = AttackCBCount + 1
			if(AttackCBCount == 4) then
				print("ALL 4")
				-- do something
			end
		
		elseif(msg.param1 == ShieldCBLOT) then
			ShieldCBCount = ShieldCBCount + 1
			if(ShieldCBCount == 4) then
				print("ALL 4")
				-- do something
			end
		end
		
		print("CB ADDED: " .. msg.param1)
		return
	end
	
	-- remove from this CBs ref count. If it is 3 then undo whatever
	if(msg.name == "cb_removed") then
		print("CB REMOVED: " .. msg.param1)
		
		if(msg.param1 == HealthCBLOT) then
			HealthCBCount = HealthCBCount - 1 
			if(HealthCBCount == 3) then
				print("WAS 4")
				-- do something
			end
		elseif(msg.param1 == DragonCBLOT) then
			DragonCBCount = DragonCBCount - 1
			if(DragonCBCount == 3) then
				print("WAS 4")
				-- do something
			end
		
		elseif(msg.param1 == AttackCBLOT) then
			AttackCBCount = AttackCBCount - 1
			if(AttackCBCount == 3) then
				print("WAS 4")
				-- do something
			end
		
		elseif(msg.param1 == ShieldCBLOT) then
			ShieldCBCount = ShieldCBCount - 1
			if(ShieldCBCount == 3) then
				print("WAS 4")
				-- do something
			end
		end
		return
	end
	
	
    local player = msg.ObjIDSender
    
    -- check to make sure the player is in the activity
    if not IsPlayerInActivity(self, player) then return end
    
    -- update kill score
    UpdateActivityValue(self, player, 0, msg.param1)     
end

----------------------------------------------------------------
-- This is called when players hit the UI to exit or stop the game.
----------------------------------------------------------------
function onMessageBoxRespond(self,msg)
    baseMessageBoxRespond(self, msg, newMsg)
end

----------------------------------------------------------------
-- Notification that a ui element used.
----------------------------------------------------------------
function onActivityStateChangeRequest(self,msg)
    baseActivityStateChangeRequest(self, msg, newMsg)
end

----------------------------------------------------------------
-- Utility Script Functions
---------------------------------------------------------------
function split(str, pat)
    local t = {}
    -- creates a table of strings based on the passed in pattern   
    string.gsub(str .. pat, "(.-)" .. pat, function(result) table.insert(t, result) end)

    return t
end 

function string.starts(String,Start)
    -- finds if a string starts with a giving string.
   return string.sub(String,1,string.len(Start))==Start
end 

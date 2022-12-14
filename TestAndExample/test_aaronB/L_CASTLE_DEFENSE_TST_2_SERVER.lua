--------------------------------------------------------------

-- L_CASTLE_DEFENSE_TST_SERVER.lua

-- Server side test script for Castle Defense prototyping.
-- created abeechler ... 8/5/11

--------------------------------------------------------------

--------------------------------------------------------------
-- Includes
--------------------------------------------------------------
require('ai/ACT/L_ACT_GENERIC_ACTIVITY_MGR')

local scorePrintDelay = 1
local scoreCalcDelay = 1
local scoreLimit = 3960
local bGameOver = false
local bQueueingChar = true

local cannonballObjID = 16748

local teamScoreTable = {}
local teamTable = {{}, {}}  -- A nested table of teams
local playerTeamTable = {}  -- A player keyed table mapping player IDs to their mapped team value

----------------------------------------------------------------
-- User Config local variables
----------------------------------------------------------------
local gConstants = 
{
    acceptedDelay = 2,                   -- how long to wait after all the players have accepted before starting the game.
    startDelay = 2,                      -- how long to wait after all the players have accepted before starting the game.
}

----------------------------------------------------------------
-- Script only local variables
----------------------------------------------------------------
local gGamestate =
{
    tPlayers = {},                       -- players who have entered the game
    tQueuedPlayers = {},
    iNumberOfPlayers = 0	             -- number of players given from ZoneLoadedInfo
}

----------------------------------------------------------------
-- Player has loaded into the map
----------------------------------------------------------------
function onPlayerLoaded(self, msg)
    local playerID = msg.playerID
    if not playerID then return end
        
    UpdatePlayer(self, playerID)        
    -- Set player stats to max
    playerID:SetHealth{health = playerID:GetMaxHealth{}.health}
    playerID:SetArmor{armor = playerID:GetMaxArmor{}.armor}
    playerID:SetImagination{imagination = playerID:GetMaxImagination{}.imagination} 

    bQueueingChar = true
    table.insert(gGamestate.tPlayers, playerID:GetID())
    table.insert(gGamestate.tQueuedPlayers, playerID:GetID()) 
    
end

function onPlayerAddedToLocalTeam(self, msg)
    local playerID = msg.playerID
    local iTeamNum = msg.iTeamID + 1
    
    -- Assign to a valid team table
    if(teamTable[iTeamNum] == nil) then
        teamTable[iTeamNum] = {}
    end
    table.insert(teamTable[iTeamNum], playerID)
    
    -- Establish a proper player mapping on the playerTeamTable
    playerTeamTable[playerID] = iTeamNum
    -- Spawn at team appropriate grouping
    SetPlayerSpawnPoints(self, playerID)
    
end

----------------------------------------------------------------
-- Player has exited the map
----------------------------------------------------------------
function onPlayerExit(self, msg)
   local playerNum = 0
    --print('player ' .. msg.playerID:GetName().name .. ' has exited')
    
    self:FireEventClientSide{args = "StopCD_UI", rerouteID = msg.playerID}
        
    for i = 1, table.maxn(gGamestate.tPlayers) do
        if gGamestate.tPlayers[i] == msg.playerID:GetID() then
            playerNum = i
        end
    end
    
    if playerNum ~= 0 then
        table.remove(gGamestate.tPlayers, playerNum)
    end

    playerNum = 0
    
    for k,v in ipairs(gGamestate.tQueuedPlayers) do
        if msg.playerID:GetID() == v then
            playerNum = k
        end
    end
    
    if playerNum ~= 0 then    
        table.remove(gGamestate.tQueuedPlayers, playerNum)
    end    

    UpdatePlayer(self, msg.playerID, true)
    
    local numPlayers = self:GetNetworkVar('NumberOfPlayers')
    self:SetNetworkVar('NumberOfPlayers', numPlayers - 1)
    
    if(bQueueingChar) then
        ProcessPlayerCount(self)
    end
end


function onZoneLoadedInfo(self, msg)
    self:SetNetworkVar('NumberOfPlayers', msg.maxPlayersSoft)
end

----------------------------------------------------------------
-- Sent a player when they are restarting into a new game either
-- by choice, or by force.
----------------------------------------------------------------
function processReturningPlayer(self, player)
    RemoveActivityItems(player)
    teamScoreTable = {}
    bQueueingChar = true
    
    -- Rebuild the walls
    for i, tTab in ipairs(teamTable) do
        local wallObjects = self:GetObjectsInGroup{group = "Team" .. tostring(i), ignoreSpawners = true}.objects
    
        for i, wall in ipairs(wallObjects) do
            -- If the wallState is '2', it is built
            local wallState = wall:GetRebuildState().iState
            if(wall:Exists() and (wallState ~= 2)) then
                wall:FireEvent{senderID=self, args="Rebuild"}
            end
        end
    end
    
    table.insert(gGamestate.tQueuedPlayers, player:GetID())
    self:FireEventClientSide{args = "StopCD_UI", rerouteID = player}
    self:FireEventClientSide{args = "Show_Startup", rerouteID = player}
    RestartPlayer(self, player)
end

----------------------------------------------------------------
-- This is called when players hit the UI to exit or stop the game.
----------------------------------------------------------------
function baseMessageBoxRespond(self, msg, newMsg)  
        
    if(msg.identifier == "Exit_Question" ) and msg.iButton == 1 then 		
        ResetStats(msg.sender)
        RemoveActivityItems(msg.sender)        
        -- Send player to a specific location
        msg.sender:TransferToLastNonInstance{ playerID = msg.sender, bUseLastPosition = true}
  
    elseif(msg.identifier == "Win_Window") then
        if(msg.iButton == 1) then
            processReturningPlayer(self, msg.sender)
            
        elseif(msg.iButton == 0) then
            local tCountdown = self:GetVar("tCountdown")
            
            if(tCountdown > 0) then
                RemoveActivityItems(msg.sender)
                ResetStats(msg.sender)       
                -- Send player to a specific location
                msg.sender:TransferToLastNonInstance{ playerID = msg.sender, bUseLastPosition = true}
            end
        end
    
    elseif msg.identifier == "ActivityCloseButtonPressed" and msg.iButton == -1 then  
        -- When the player hits the activity close button, the 'x' in the top right
        ExitBox(self, msg.sender) 
    end
end

function ExitBox(self, player)	
    if player:Exists() then
		local text = "Are you sure you want to exit?"
		
        -- Display exit box
        player:DisplayMessageBox{bShow = true, 
                         imageID = 1, 
                         text = text, 
                         callbackClient = self, 
                         identifier = "Exit_Question"}
    end
    
end

function RemoveActivityItems(player)
    if (player:GetInvItemCount{iObjTemplate = cannonballObjID}.itemCount >= 1) then 
		-- Take the cannonballs from the player
		player:RemoveItemFromInventory{iObjTemplate = cannonballObjID, iStackCount = 1}
	end
end

----------------------------------------------------------------
-- Custom function: Checks to see if all players have accepted,
-- if they have then the game is started.
----------------------------------------------------------------
function ProcessPlayerCount(self)
    if(table.maxn(gGamestate.tQueuedPlayers) >= self:GetNetworkVar('NumberOfPlayers')) then
        self:SetNetworkVar("Pop_State", true)
        ActivityTimerStopAllTimers(self)
        ActivityTimerStart(self, 'StartDelay', 3, 3) --(timerName, updateTime, stopTime) 
    end
end

----------------------------------------------------------------
-- When ActivityTimerUpdate is sent, basically when a timer hits it updateInterval.
----------------------------------------------------------------
function onActivityTimerUpdate(self, msg)
    
	if((msg.name == "printScore") and (bGameOver == false)) then
        for tNom, tScores in pairs(teamScoreTable) do
            self:FireEventClientSide{args = tNom, param2 = tScores[2]}
        end
	    
	elseif((msg.name == "calculateScore") and (bGameOver == false)) then
        calculateScoreTally(self)
        
    elseif msg.name == "printTimeCountdown" then
        local tCountdown = self:GetVar("tCountdown")
        self:FireEventClientSide{args = tCountdown, param2 = 2}
        
        -- Check for the game start condition
        tCountdown = tCountdown - 1
        if(tCountdown <= 0) then
            -- The countdown is over, force initiate the next game
            self:ActivityTimerStop(self, "printTimeCountdown")
            self:SetVar("tCountdown", 0)
            startIdlePlayers(self, msg)
        else
            -- Set the timer and continue the countdown
            self:SetVar("tCountdown", tCountdown)
        end
        
	end   
	
end

----------------------------------------------------------------
-- Iterate through the current game players, and eject any players
-- currently not ready for the next game
----------------------------------------------------------------
function startIdlePlayers(self)
    for i, checkPID in ipairs(gGamestate.tPlayers) do
        -- By default, we assume the player has not readied-up
        local bNotQueued = true
        
        for j, waitingPID in ipairs(gGamestate.tQueuedPlayers)  do
            if(checkPID == waitingPID) then
                bNotQueued = false
                break
            end
        end
        
        if(bNotQueued) then
            local idlePlayer = GAMEOBJ:GetObjectByID(checkPID)
            -- Our current checking playerID has not readied-up
            -- Close the response window
            idlePlayer:DisplayMessageBox{bShow = false, identifier = "Win_Window"}
            -- Process them as a returning player
            processReturningPlayer(self, idlePlayer)
            
            -- remove him from the game for idling
            -- ResetStats(idlePlayer)   
            -- Close the response window
            -- idlePlayer:DisplayMessageBox{bShow = false, identifier = "Win_Window"}    
            -- Send player to a specific location
            -- idlePlayer:TransferToLastNonInstance{playerID = idlePlayer, bUseLastPosition = true}
        end
    end
end

----------------------------------------------------------------
-- When ActivityTimerDone is sent, basically when the activity timer has reached it's duration.
----------------------------------------------------------------
function onActivityTimerDone(self, msg)
    if msg.name == "StartDelay" then        
        --print('adding in timers *******************************')        
        ActivityTimerStart(self, 'PlaySpawnSound', 3, 3) --(timerName, updateTime, stopTime)
        -- Initiate player activity
        self:SetNetworkVar("Show_Countdown", true)          
    elseif msg.name == "PlaySpawnSound" then
        -- Play war horn sound
        for k,v in ipairs(gGamestate.tPlayers) do      
            GAMEOBJ:GetObjectByID(v):PlayNDAudioEmitter{m_NDAudioEventGUID = '{ca36045d-89df-4e96-a317-1e152d226b69}'}             
        end
        StartGame(self)  
        self:FireEventClientSide{args = "StartCD_UI"}
    end
end

function ResetStats(playerID)
    -- Set the player's imag, health and armor to full
    if playerID:Exists() then
        -- Set player stats to max
        playerID:SetHealth{health = playerID:GetMaxHealth{}.health}
        playerID:SetArmor{armor = playerID:GetMaxArmor{}.armor}
        playerID:SetImagination{imagination = playerID:GetMaxImagination{}.imagination}
    end
end

----------------------------------------------------------------
-- Custom function: Starts the game.
----------------------------------------------------------------  
function StartGame(self)
    for k,v in ipairs(gGamestate.tPlayers) do
        local playerID = GAMEOBJ:GetObjectByID(v)   
        if not playerID then return end
        
        UpdatePlayer(self, playerID)        
        ResetStats(playerID)         
        
        if not self:GetVar('firstTimeDone') then
            -- Remove the activity cost from the player as they load into the map
            local takeCost = self:ChargeActivityCost{user = playerID}.bSucceeded
        end
    end
    
    self:SetVar('firstTimeDone', true)

    gGamestate.tQueuedPlayers = {}  
    bGameOver = false
    bQueueingChar = false
    
    -- Initiate player activity
    self:SetNetworkVar("Start_Message", true)  
        
    -- Start the score accumulation
    ActivityTimerStart(self, "calculateScore", scoreCalcDelay)
    ActivityTimerStart(self, "printScore", scorePrintDelay)
end

function RestartPlayer(self, player)
    if(not player:Exists()) then return end
      
    player:Resurrect()
    SetPlayerSpawnPoints(self, player)
	
end

function calculateScoreTally(self)
    
    for i, tTab in ipairs(teamTable) do
        local currentScore = 0
        local teamString = "Team" .. tostring(i)
        if(teamScoreTable[teamString]) then
            currentScore = teamScoreTable[teamString][1]
        end
        
        local scoreTally = 0
        local wallObjects = self:GetObjectsInGroup{group = teamString, ignoreSpawners = true}.objects
    
        for i, wall in ipairs(wallObjects) do
            -- If the wallState is '2', it is built
            local wallState = wall:GetRebuildState().iState
            if(wall:Exists() and (wallState == 2)) then
                scoreTally = scoreTally + 1
            end
        end
        
        currentScore = currentScore + scoreTally
        local limitPercent = math.ceil(100 * (currentScore / scoreLimit))
        
        teamScoreTable[teamString] = {currentScore, limitPercent}
    end
    
    winCheck(self)
    
end

function winCheck(self)
    if(bGameOver == true) then return end
    
    local winningTeam = {}
    for tNom, tScores in pairs(teamScoreTable) do
        if(tScores[2] >= 100) then
            table.insert(winningTeam, tNom)
        end
    end
    
    local numWinners = table.maxn(winningTeam)
    if(numWinners > 0) then
        local message_string = ""
	    local bDisplayMessage = true
	
        if(numWinners > 1) then
            message_string = "TIE!!!  Play Again?"
        else
            message_string = winningTeam[1] .. " WINS!!!  Play Again?"
        end
        
        for i = 1, table.maxn(gGamestate.tPlayers) do
			local playerID = GAMEOBJ:GetObjectByID(gGamestate.tPlayers[i]) 
			playerID:DisplayMessageBox{bShow = true,
									   text = message_string, 
									   callbackClient = self, 
									   identifier = "Win_Window"}
		end
        
        bGameOver = true
        self:SetVar("superShotTable", {})
        ActivityTimerStopAllTimers(self)
        
        -- Start a countdown for y/n responses
        self:SetVar("tCountdown", 30)
        ActivityTimerStart(self, "printTimeCountdown", 1)
    end
    
end

function SetPlayerSpawnPoints(self, playerID)
    local iTeamID = 0
    local iOffsetID = 0
    local bFound = false
    
    for teamIndex, team in ipairs(teamTable) do
        for offsetIndex, pID in ipairs(team) do
        
            if(playerID:GetID() == pID:GetID()) then
                iTeamID = teamIndex
                iOffsetID = offsetIndex
                bFound = true
                break
            end
        
        end
        
        if(bFound) then
            break
        end
    end
    
    local pointGroup = "Spawn" .. tostring(iTeamID) .. "_" .. tostring(iOffsetID)
    -- print("@@@@@ " .. playerID:GetName().name .. " - SPAWNING AT: " .. pointGroup)
    
    local spawnObjs = self:GetObjectsInGroup{group = pointGroup, ignoreSpawners = true}.objects
    for i, spawnObject in ipairs(spawnObjs) do
		if(spawnObject:Exists()) then
			local pos = spawnObject:GetPosition().pos
            local rot = spawnObject:GetRotation()
        
            playerID:Teleport{pos = pos, x = rot.x, y = rot.y, z = rot.z, w = rot.w, bSetRotation = true}
            
            break
		end
	end
    
end

----------------------------------------------------------------
-- Received a fire event messaged from the client
----------------------------------------------------------------
function onFireEventServerSide(self, msg)   
    if msg.args == "CheckPlayerCount" then
        ProcessPlayerCount(self)
    end
end

function onFireEvent(self, msg)
	-- Receive the sending object ID and the message to parse
	local eventType = msg.args
	local sendObj = msg.senderID:GetID()
	
	-- Missing a valid event type?
	if not eventType then return end
	
	-- Obtain the current super shot table
	local superShotTable = self:GetVar("superShotTable") or {}
	
	if eventType == "incSuperShotTbl" then
	    -- If there is a valid player, increment accordingly
	    -- otherwise establish a new player entry
	    if(superShotTable[sendObj]) then
	        -- We have an entry for this player, update it
	        superShotTable[sendObj] = superShotTable[sendObj] + 1
	        -- Clamp to five
	        if(superShotTable[sendObj] > 5) then
	            superShotTable[sendObj] = 5
	        end
	    
	    else
	        superShotTable[sendObj] = 1
	    end
	    
	elseif eventType == "resetSuperShotTbl" then
	    if(superShotTable[sendObj]) then
	        -- Reset the super shot counter
	        superShotTable[sendObj] = 0
	    end
	end
	
	-- print("@@@@@ SUPER SHOT GUAGE = " .. tostring(superShotTable[sendObj]))
	-- Save the table update
	self:SetVar("superShotTable", superShotTable)
	    
end

----------------------------------------------------------------
-- A player has been resurrected
----------------------------------------------------------------
function basePlayerResurrected(self, msg, newMsg)
    ProcessPlayerCount(self)
end

----------------------------------------------------------------
-- A player has respawned
----------------------------------------------------------------
function onPlayerResurrected(self, msg)
    basePlayerResurrected(self, msg, newMsg)
end

----------------------------------------------------------------
-- This is called when players hit the UI to exit or stop the game.
----------------------------------------------------------------
function onMessageBoxRespond(self,msg)
    baseMessageBoxRespond(self, msg, newMsg)
end

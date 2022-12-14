--------------------------------------------------------------

-- L_BOSS_SPIDER_QUEEN_ENEMY_SERVER.lua

-- Server side Spider Queen Boss fight behavior script
-- created abeechler ... 5/12/11

--------------------------------------------------------------

local spiderWaveCntTable = {2, 3}             -- The number of Dark Spiderling enemies to spawn per indexed wave number

local ROFImpactCnt = 2                        -- The number of ROF impacts in each quadrant of the arena selected at random

local SpiderlingID = 16197                    -- Reference obj ID for hatched Spiderlings

local hatchCounter = 0                        -- Global counter mainting visibility over how many eggs we have prepped to hatch per wave
local hatchList = {}                          -- Global list maintaining a record of all the eggs we have prepped to hatch for a wave

local defaultFacingZone = "Zone3Vol"          -- Maintains a default facing to ensure appropriate Spider Boss positioning for teleported players
local inZoneTable = {}                        -- Keeps track through player ID index what quadrant of the zone the player is in now
local fromZoneTable = {}                      -- Keeps track through player ID index what quadrant of the zone the player was last in

local defaultAnimPause = 2.5                  -- Default period of time to pause between missing animation actions
local spiderJeerAnim = "taunt"                -- Animation Spider Boss plays to antagonize the player
local spiderROFAnim = "attack-fire"           -- Animation Spider Boss plays to telegraph the ROF attack
local spiderWithdrawAnim = "withdraw"         -- Animation Spider Boss plays to withdraw to the top of the mountain
local spiderAdvanceAnim = "advance"           -- Animation Spider Boss plays to come back down from the mountain
local spiderWithdrawIdle = "idle-withdrawn"   -- Animation Spider Boss plays to idle on the mountain
local spiderShootLeft = "attack-shoot-left"   -- Animation Spider Boss plays to RFS shoot CCW
local spiderShootRght = "attack-shoot-right"  -- Animation Spider Boss plays to RFS shoot CW
local spiderSingleShot = "attack-fire-single" -- Animation Spider Boss plays for a single shot

local bossBulletSkill = 303                   -- Generic Spider Boss long range attack
local bossSmashSkill = 322                    -- Generic Spider Boss short range attack
local bossQueueSkill = 1568                   -- Empty skill to queue for special attack timing
local bossLandingSkill = 1539                 -- Generic Spider Boss landing attack
local bossSwipeSkill = 	1573				  -- Generic Spider Boss landing attack

local smashSkillLength = 3.1                  -- Time (in seconds) the boss smash skill lasts

local s1DelayMin = 10                         -- Minimum time until calling for another Rapid Fire Shot
local s1DelayMax = 15                         -- Maximum time until calling for another Rapid Fire Shot
local s2DelayMin = 10                         -- Minimum time until calling for another Rain Of Fire
local s2DelayMax = 15                         -- Maximum time until calling for another Rain Of Fire

local instanceZoneID = 1102                   -- Zone ID for the Spider Queen fight instance
local instanceMissionID = 1941                -- Achievement to update for beating the instanced Boss
     
-- Establishes a link for the Spider to identify rapid fire targets based on zone reference
local rapidFireTargetTable = {
                                ["Zone1Vol"] = {"Zone8Targets", "Zone1Targets", "Zone2Targets"},
                                ["Zone2Vol"] = {"Zone1Targets", "Zone2Targets", "Zone3Targets"},
                                ["Zone3Vol"] = {"Zone2Targets", "Zone3Targets", "Zone4Targets"},
                                ["Zone4Vol"] = {"Zone3Targets", "Zone4Targets", "Zone5Targets"},
                                ["Zone5Vol"] = {"Zone4Targets", "Zone5Targets", "Zone6Targets"},
                                ["Zone6Vol"] = {"Zone5Targets", "Zone6Targets", "Zone7Targets"},
                                ["Zone7Vol"] = {"Zone6Targets", "Zone7Targets", "Zone8Targets"},
                                ["Zone8Vol"] = {"Zone7Targets", "Zone8Targets", "Zone1Targets"}
                             }

----------------------------------------------------------------
-- On Startup, process necessary AI events
----------------------------------------------------------------
function onStartup(self)
    -- Make immune to stuns
    self:SetStunImmunity{StateChangeType = "PUSH", bImmuneToStunAttack = true, bImmuneToStunMove = true, bImmuneToStunTurn = true, bImmuneToStunUseItem = true, bImmuneToStunEquip = true, bImmuneToStunInteract = true, bImmuneToStunJump = true} 
    -- Make immune to knockbacks and pulls
    self:SetStatusImmunity{StateChangeType = "PUSH", bImmuneToPullToPoint = true, bImmuneToKnockback = true, bImmuneToInterrupt = true}
    -- A state suspending scripted movement AI
    self:SetVar("Set.SuspendLuaMovementAI", true)   
    -- A state suspending scripted AI
    self:SetVar("Set.SuspendLuaAI", true)    
    
    -- Seed random pulls
    math.randomseed(os.time())
    
    -- Determine Spider Boss health transition thresholds
    local spiderBossHealth = self:GetMaxHealth().health
    local transitionTickHealth = spiderBossHealth / 3
    
    local Stage2HealthThreshold = spiderBossHealth - transitionTickHealth
    local Stage3HealthThreshold = spiderBossHealth - (2 * transitionTickHealth)
    local ThresholdTable = {Stage2HealthThreshold, Stage3HealthThreshold}
    
    self:SetVar("ThresholdTable", ThresholdTable)
    self:SetVar("CurrentBossStage", 1)

    -- Obtain faction and collision group to save for subsequent resets
    self:SetVar("SBFactionList", self:GetFaction().factionList)
    self:SetVar("SBCollisionGroup", self:GetCollisionGroup().colGroup)
end

----------------------------------------------
-- Object instantiation catch
----------------------------------------------
function onPhysicsComponentReady(self, msg) 
	-- Stop our initial ability to attack
	ToggleAttacking(self, false)
	
end

----------------------------------------------
-- Sent when it is time to procure zone script data
----------------------------------------------
function onFireEventServerSide(self, msg) 
    if msg.args == "QueryZoneScript" then
        -- Query our containing property for the IDs of various spawner networks
	    --
	    -- RESULT: This Object now has a variable set called "SpiderEggNetworkID" 
	    -- 		   that contains the spider egg spawn network ID
	    --
	    --         This Object now has a variable set called "ROFTargetGroupIDTable"
	    --         that contains the IDs of the various ROF Target Group spawners
	    --
	    --         This Object now has a variable set called "LandingTarget"
	    --         that contains a reference to the object that will cast the landing skill
	    --
	    --         This Object now has a variable set called "ScreamEmitter"
	    --         that contains a reference to the object that will project the Spider's mountain scream
	    GAMEOBJ:GetZoneControlID():FireEvent{senderID=self, args="RetrieveZoneData"}
	    
    end
    
end

----------------------------------------------
-- Catch Spiderling clean-up events
----------------------------------------------
function onFireEvent(self, msg)
	-- Receive the sending object ID and the message to parse
	local eventType = msg.args
	-- Missing a valid event type?
	if not eventType then return end
	
	if eventType == "CleanupSpiders" then
		-- The zone object is requesting we cleanup
		-- the remaining live Spiderlings
		CleanupSpiders(self)
	end
end

----------------------------------------------------------------
-- Catch Spiderling deaths in order to process when a wave ends 
----------------------------------------------------------------
function notifyDie(self, spiderlingID, msg)
    -- Get the game object of the child
	local child = spiderlingID
	
	-- Check to see if the child is Spiderling
	if(child:GetLOT().objtemplate ~= SpiderlingID) then return end
	
	-- Play the Spider Boss scream
	local screamEmitter = self:GetVar("ScreamEmitter")
	self:NotifyClientObject{name = "EmitScream", paramObj = screamEmitter}
    
    -- Grab the current wave death counter
    local deathCounter = self:GetVar("deathCounter") or 0
    
    -- Increment the counter
    deathCounter = deathCounter + 1
    self:SetVar("deathCounter", deathCounter)
    
    -- Grab the current wave count
    local currentStage = self:GetVar("CurrentBossStage") 
    local spiderWaveCnt = spiderWaveCntTable[currentStage]
    
    -- Have we finished the wave?
    if(deathCounter >= spiderWaveCnt) then
        -- Activate the Spider Boss
        WithdrawSpider(self, false)
    end
    
    -- Remove reference from the Spiderling table
    local spiderlingTable = self:GetVar("spiderlingTable") or {}
    -- Iterate through the table and find the dead Spiderling
    for i, sID in ipairs(spiderlingTable) do
        if(sID:GetID() == child:GetID()) then
            table.remove(spiderlingTable, i)
            break
        end
    end
    self:SetVar("spiderlingTable", spiderlingTable)
    
    -- Cancel the notification request
	self:SendLuaNotificationCancel{requestTarget = child, messageName = "Die"}
	
end

----------------------------------------------------------------
-- Catch Spiderling spawns to subscribe to proper notifies and de-couple
-- from parent
----------------------------------------------------------------
function onChildLoaded(self, msg)
    -- Get the game object of the child
    local child = msg.childID
    
    -- Check to see if the child is Spiderling
	if(child:GetLOT().objtemplate ~= SpiderlingID) then return end
	-- We have a Spiderling, de-couple it from the parent Spider Boss
	child:SetParentObj{bSetToSelf = true}
	-- Ensure it is the enemy of the player
    child:SetFaction{faction = 4}
    -- Receive notification on death
    self:SendLuaNotificationRequest{ requestTarget = child, messageName = "Die" }
    -- Add to a spawned Spiderling table
    local spiderlingTable = self:GetVar("spiderlingTable") or {}
    table.insert(spiderlingTable, child)
    self:SetVar("spiderlingTable", spiderlingTable)
end

----------------------------------------------------------------
-- Catch zone volume sensing collision events and process accordingly
----------------------------------------------------------------
function notifyCollisionPhantom(self, cVol, cMsg)
    -- Obtain the player that instigated the collision notify
    local player = cMsg.objectID
    local playerID = player:GetID()
    -- Obtain the name of the group the volume that was collided with is in
    local cVolGroup = string.sub(cVol:GetStoredConfigData{optionalKey = "groupID"}.configData["groupID"], 1, -2)
    
    if((cVolGroup == "AggroVol") or (cVolGroup == "TeleVol")) then
        -- How many targetable players are there?
        local currentPlayerCount = GAMEOBJ:GetZoneControlID():GetVar("numberOfPlayers") or 1
        
        -- How many people are in the safe zone?
        local aggroVol = self:GetVar("AggroVol")
        if(table.maxn(aggroVol:GetObjectsInPhysicsBounds().objects) == currentPlayerCount) then
            self:SetVar("Aggro", false)
            ToggleAttacking(self, false)
        end
        
        -- Have we teleported?
        if(cVolGroup == "TeleVol") then
            -- Update the zone tables with the default position of the player
            zoneTableUpdate(self, playerID, defaultFacingZone)
        end
        
    else
        -- Update the zone tables with the current position of the colliding player
        zoneTableUpdate(self, playerID, cVolGroup)
    end
end

----------------------------------------------------------------
-- Update the Spider Boss reference tables for current/previous
-- arena player positioning
----------------------------------------------------------------
function zoneTableUpdate(self, updatePlayer, updateZone)
    -- Update the zone tables with the current position of the update player
    local fromZoneBuf = inZoneTable[updatePlayer] or updateZone
    inZoneTable[updatePlayer] = updateZone
    fromZoneTable[updatePlayer] = fromZoneBuf
end

----------------------------------------------------------------
-- Catch volume sensing collision off events and process accordingly
----------------------------------------------------------------
function notifyOffCollisionPhantom(self, cVol, cMsg)
    -- Obtain the player that instigated the collision notify
    local player = cMsg.objectID
    local playerID = player:GetID()
    -- Obtain the name of the group the volume that was collided with is in
    local cVolGroup = string.sub(cVol:GetStoredConfigData{optionalKey = "groupID"}.configData["groupID"], 1, -2)
    
    if(cVolGroup == "AggroVol") then
        -- How many targetable players are there?
        local currentPlayerCount = GAMEOBJ:GetZoneControlID():GetVar("numberOfPlayers") or 1
        
        -- How many people are in the safe zone?
        if(table.maxn(cVol:GetObjectsInPhysicsBounds().objects) < currentPlayerCount) then
            -- The Spider Queen has a viable target - pop her attack stun state
            self:SetVar("Aggro", true)
            ToggleAttacking(self, true)
        end
        
    end
    
end

----------------------------------------------------------------
-- Register boss damaged events and process when necessary
----------------------------------------------------------------
function onHitOrHealResult(self, msg)
    -- It isn't the Spider Boss
    if msg.receiver:GetID() ~= self:GetID() then return end
    -- The Spider Boss has fallen!
    if(msg.diedAsResult) then 
        -- Immediately cancel all skill timers
        SpiderSkillManager(self, false)
        -- Run the property clearing events
        GAMEOBJ:GetTimer():AddTimerWithCancel(0.1, "Clear", self)
        -- If we are on the Spider Queen Instance, update the achievement
        if(LEVEL:GetCurrentZoneID() == instanceZoneID) then
            -- Obtain a current list of players in the zone
            local playerTable = GAMEOBJ:GetZoneControlID():GetVar("PlayerTable") or {}
            -- Iterate through the Player Table and update the appropriate 
            -- mission for each player
            for i, playerID in ipairs(playerTable) do
                local player = GAMEOBJ:GetObjectByID(playerID)
                
                if(player:Exists()) then
                    -- We have a valid player, update the mission
                    player:UpdateMissionTask{taskType = "complete", value = instanceMissionID, value2 = 1, target = self}
                end
            end
        end
        return 
    end
    
    local stoppedFlag = self:GetVar("stoppedFlag")
    local ThresholdTable = self:GetVar("ThresholdTable")
    local currentStage = self:GetVar("CurrentBossStage")
    local currentThreshold = ThresholdTable[currentStage] or 0
    
    -- Catch for instances of players being ready 
    -- before the Spider Boss was 
    if(stoppedFlag) then
        self:SetVar("Aggro", true)
        ToggleAttacking(self, true)
    end
    
    if(self:GetHealth().health <= currentThreshold) then
        local isWithdrawn = self:GetVar("isWithdrawn") or false
        if(not isWithdrawn) then 
            -- We have hit a stage threshold!
            GAMEOBJ:GetTimer():CancelAllTimers(self)
            self:CancelSkillCast()
        
            -- Is Special Attacking?
            local bSpecialAttacking = self:GetVar("isSpecialAttacking")
            if(bSpecialAttacking) then
                -- Pop any current stun states
                self:SetStunned{StateChangeType = "POP", 
                        bCantMove = true,
                        bCantJump = true,
                        bCantTurn = true,
                        bCantAttack = true,
                        bCantUseItem = true,
                        bCantEquip = true,
                        bCantInteract = true,
                        bIgnoreImmunity = true}
            end
            -- Mark as not special attacking
            self:SetVar("isSpecialAttacking", false)
            -- We no longer need to lock specials
            self:SetVar("bSpecialLock", false)
	    
	        -- Withdraw the Spider Boss
	        WithdrawSpider(self, true)
	    end
    end
    
end

----------------------------------------------
-- Toggle Spider for custom scripted events
----------------------------------------------
function ToggleForSpecial(self, bOn)
    
    local stateChange = "PUSH"
    
    if(bOn) then
        -- Stun the boss
        stateChange = "PUSH" 
    else
        -- Un-stun the boss
        stateChange = "POP" 
    end
    
    -- Update stun state
    self:SetStunned{StateChangeType = stateChange, 
                    bCantMove = true,
                    bCantJump = true,
                    bCantTurn = true,
                    bCantAttack = true,
                    bCantUseItem = true,
                    bCantEquip = true,
                    bCantInteract = true,
                    bIgnoreImmunity = true}
    
    -- Mark special attacking state
    self:SetVar("isSpecialAttacking", bOn)
    
end

----------------------------------------------
-- Toggle Spider Boss' ability to attack
---------------------------------------------
function ToggleAttacking(self, bOn)
    local stoppedFlag = self:GetVar("stoppedFlag") or false
    local stateChangeType = "POP"
    
    if(not bOn) then
        -- If we already have pushed an attack stop, prevent further pushes
        if(stoppedFlag) then return end
        
        stateChangeType = "PUSH"
        self:SetVar("stoppedFlag", true)
    else
		-- if we never pushed, don't allow a pop
		if(not stoppedFlag) then return end

        self:SetVar("stoppedFlag", false)
    end
    
    self:SetStunned{StateChangeType = stateChangeType, bCantAttack = true, bIgnoreImmunity = true}
end

----------------------------------------------
-- Transitions the Spider Boss between its two central
-- positions based on the value of bWithdrawn
----------------------------------------------
function WithdrawSpider(self, bWithdrawn)
    -- Check the boss withdrawn state
    local isWithdrawn = self:GetVar("isWithdrawn") or false
    -- Control duplicate Withdraw calls
    if((bWithdrawn and isWithdrawn) or ((not bWithdrawn) and (not isWithdrawn))) then return end
    
    -- Process the flag parameter
    if(bWithdrawn) then
        -- Move the Spider to its withdrawn location
        -- deactivating its AI Skills and providing invulnerability
        self:SetStunned{StateChangeType = "PUSH", 
                    bCantMove = true,
                    bCantJump = true,
                    bCantTurn = true,
                    bCantAttack = true,
                    bCantUseItem = true,
                    bCantEquip = true,
                    bCantInteract = true,
                    bIgnoreImmunity = true}
        
        self:NotifyClientObject{name = "SetColGroup", param1 = 10}
        -- Rotate for anim
        self:SetRotation{x = 0, y = -0.005077, z = 0, w = 0.999, bTeleport = true}
        
        -- Run the withdraw animation and prepare a timer for hatching post leap
        local animTime = playAnimAndReturnTime(self, spiderWithdrawAnim)
        local withdrawTime = animTime - 0.25
        
        -- Set faction to no longer pull player attention
        self:SetFaction{faction = -1}
        -- Grant current status immunity
        self:SetStatusImmunity{ StateChangeType = "PUSH", bImmuneToSpeed = true, bImmuneToBasicAttack = true, bImmuneToDOT = true}
        -- Prepare a timer for post leap
        GAMEOBJ:GetTimer():AddTimerWithCancel(withdrawTime, "WithdrawComplete", self)
        
    else
        -- Move the Spider to its ground location
        -- preparing its stage attacks, and removing invulnerability
        
        -- Run the advance animation and prepare a timer for resuming AI
        local animTime = playAnimAndReturnTime(self, spiderAdvanceAnim)
        local attackPause = animTime - 0.4
        -- Prepare a timer for post leap attack
        GAMEOBJ:GetTimer():AddTimerWithCancel(attackPause, "AdvanceAttack", self)
        -- Prepare a timer for post leap 
        GAMEOBJ:GetTimer():AddTimerWithCancel(animTime, "AdvanceComplete", self)
    end
    
    -- Mark the Boss' withdrawn state
    self:SetVar("isWithdrawn", bWithdrawn)
        
end

----------------------------------------------
-- Begin processing Rain Of Fire attack event
----------------------------------------------
function RunRapidFireShooter(self)
    -- Turn off the Spider Boss
    ToggleForSpecial(self, true)
    
    -- Obtain the primary attack target
    local attackFocusID = getRandomPlayer(self)
    -- Declare the attack target table
    local attackTargetTable = {}
    
    -- Obtain the primary and secondary zone targets based on the attackTarget's
    -- current zone and a random subsequent sweep direction
    local primaryZone = inZoneTable[attackFocusID]
    local secondaryTargetGroup = rapidFireTargetTable[primaryZone][2]
    
    -- Use a random numeric flag to select CW versus CCW
    -- 1 = CW, 2 = CCW
    local dirSelect = math.random(2)
    local primaryTargetGroup = 0
    local tertiaryTargetGroup = 0
    if(dirSelect == 1) then
        -- We are shooting clockwise
        primaryTargetGroup = rapidFireTargetTable[primaryZone][1]
        tertiaryTargetGroup = rapidFireTargetTable[primaryZone][3]
    else
        -- We are shooting counter-clockwise
        primaryTargetGroup = rapidFireTargetTable[primaryZone][3]
        tertiaryTargetGroup = rapidFireTargetTable[primaryZone][1]
    end
    
    local primaryTargetObjs = self:GetObjectsInGroup{group = primaryTargetGroup, ignoreSpawners = true}.objects
    local secondaryTargetObjs = self:GetObjectsInGroup{group = secondaryTargetGroup, ignoreSpawners = true}.objects
    local tertiaryTargetObjs = self:GetObjectsInGroup{group = tertiaryTargetGroup, ignoreSpawners = true}.objects
    
    -- Prepare for sorting by handling the zone 1 overlap edge case.
    local keyOrderString = "CWOrder"
    if((primaryTargetGroup == "Zone1Targets") or (secondaryTargetGroup == "Zone1Targets") or (tertiaryTargetGroup == "Zone1Targets") or
       (primaryTargetGroup == "Zone8Targets") or (secondaryTargetGroup == "Zone8Targets") or (tertiaryTargetGroup == "Zone8Targets")) then
        keyOrderString = "CWOrder2"
    end
    
    local sortTables = {primaryTargetObjs, secondaryTargetObjs, tertiaryTargetObjs}
    for i, sTable in ipairs(sortTables) do
        -- Establish a sort list
        local toSort = {}
        
        -- Format the table to sort
        for j, tableObj in ipairs(sTable) do
            local objPriority = tableObj:GetStoredConfigData{optionalKey = keyOrderString}.configData[keyOrderString]
            table.insert(toSort, {tableObj = tableObj, objPriority = objPriority})
        end
        
        -- Sort the table
        local sortFunction = 0
        if(dirSelect == 1) then
            -- We are sorting clockwise
            sortFunction =  function(A, B) return A.objPriority < B.objPriority end
        else
            -- We are sorting counter-clockwise
            sortFunction =  function(A, B) return A.objPriority > B.objPriority end
        end
        table.sort(toSort, sortFunction)
        
        -- Append the results to the attackTargetTable
        for k, sortObj in ipairs(toSort) do
            if((i ~= 2) or ((k ~= 1) and (k ~= table.maxn(toSort)))) then
                table.insert(attackTargetTable, sortObj.tableObj)
            end
        end
        
    end
    
    -- Save the attack target list results
    self:SetVar("attackTargetTable", attackTargetTable)
    -- Initiate the RFS Manager
    -- Rotate towards the target
    local rofFireFlag = self:CastSkill{skillID = 1480, optionalTargetID = attackTargetTable[4]}
    -- Run the RFS
    RapidFireShooterManager(self)
    
    local spiderRFSShootingAnim = spiderSingleShot
    if(dirSelect == 1) then
        -- We are shooting clockwise
        spiderRFSShootingAnim = spiderShootRght
    else
        -- We are shooting counter-clockwise
        spiderRFSShootingAnim = spiderShootLeft
    end
    local animTime = playAnimAndReturnTime(self, spiderRFSShootingAnim)

end

----------------------------------------------
-- Manage Rapid Fire Shooter attack event
----------------------------------------------
function RapidFireShooterManager(self)
    -- Obtain the attack target list
    local attackTargetTable = self:GetVar("attackTargetTable") or {}
    
    if(table.maxn(attackTargetTable) > 0) then
        -- Fire the rapid fire shot skill on our first element
        local rofFireFlag = self:CastSkill{skillID = 1394, optionalTargetID = attackTargetTable[1]}
        -- Remove it from our target list
        table.remove(attackTargetTable, 1)
        -- Save the target list results
        self:SetVar("attackTargetTable", attackTargetTable)
        
        GAMEOBJ:GetTimer():AddTimerWithCancel(0.3, "PollRFSManager", self)
    else
        -- Jeer the player, telegraphing finish
        local animTime = playAnimAndReturnTime(self, spiderJeerAnim)
        GAMEOBJ:GetTimer():AddTimerWithCancel(animTime, "RFSTauntComplete", self)
       
    end

end

----------------------------------------------
-- Begin processing Rain Of Fire attack event
----------------------------------------------
function RunRainOfFire(self)
    -- Turn off the Spider Boss
    ToggleForSpecial(self, true)
    -- Push the ROF attack stun state
    self:SetStunned{StateChangeType = "PUSH", bCantAttack = true, bIgnoreImmunity = true}                
    
    -- The Spider Queen Boss has executed a ROF Attack
    local ROFTargetGroupIDTable = self:GetVar("ROFTargetGroupIDTable")
    if(not ROFTargetGroupIDTable) then return end
    
    -- Build a list of all the desired impact 
    -- locations for this attack
    local impactList = {}
    
    -- Iterate through the ROF Target groups, placing random elements from each
    -- in the impact list, save the first list - which selects all its targets
    for i, trgtGrp in ipairs(ROFTargetGroupIDTable) do
        -- Obtain the group targets
        local targetList = trgtGrp:SpawnerGetAllObjectIDsSpawned().objects
        
        -- Is this the first group?
        if(i == 1) then
            -- Take all its elements
            for j, trgt in ipairs(targetList) do
                table.insert(impactList, trgt)
            end
            
        else
            -- Select a random set number of impact targets from each group
            for i = 1, ROFImpactCnt do
                -- Select a random ROF target
	            local randomTrgtLoc = math.random(table.maxn(targetList))
	            local randomTrgt = targetList[randomTrgtLoc]
	            
	            --Add it to the impact list
	            table.insert(impactList, randomTrgt)
                --Remove it from our target list
	            table.remove(targetList, randomTrgtLoc)
	    
	            if((table.maxn(targetList) <= 0)) then 
                    break
                end
            end
            
        end
    
    end
    
    -- Save the impact list results
    self:SetVar("impactList", impactList)
    -- Initiate the ROF Manager
    -- project the attack with a custom anim
    local animTime = playAnimAndReturnTime(self, spiderROFAnim)
    GAMEOBJ:GetTimer():AddTimerWithCancel(animTime, "StartROF", self)
    
end

----------------------------------------------
-- Manage ROF wave event
----------------------------------------------
function RainOfFireManager(self)
    -- Obtain the impact list
    local impactList = self:GetVar("impactList") or {}
    
    if(table.maxn(impactList) > 0) then
        -- Fire the impact skill on our first element
        impactList[1]:CastSkill{skillID = 1376}
        -- Remove it from our impact list
        table.remove(impactList, 1)
        -- Save the impact list results
        self:SetVar("impactList", impactList)
        
        GAMEOBJ:GetTimer():AddTimerWithCancel(0.5, "PollROFManager", self)
    else
        -- We have finished a round of Rain Of Fire, prep the skill manager
        -- for another potential round
        -- Pop the ROF attack stun state
        self:SetStunned{StateChangeType = "POP", bCantAttack = true, bIgnoreImmunity = true}
        
        -- Determine an appropriate random time to check our manager again 
        local spiderCooldownDelay = math.random(s2DelayMin, s2DelayMax)
        -- Set a timer based on our random cooldown determination
        -- to pulse the SpiderSkillManager again
        GAMEOBJ:GetTimer():AddTimerWithCancel(spiderCooldownDelay, "PollSpiderSkillManager", self)
    end
    
end

----------------------------------------------
-- Begin processing Spiderling wave event
----------------------------------------------
function SpawnSpiderWave(self)
	
	-- The Spider Queen Boss is withdrawing and requesting the spawn 
	-- of a hatchling wave
    local SpiderEggNetworkID = self:GetVar("SpiderEggNetworkID") or 0
    if(SpiderEggNetworkID == 0) then return end
    
    local maxSpiderEggCnt = SpiderEggNetworkID:SpawnerGetNumToMaintain().uiNum
    local spiderWaveCnt = self:GetVar("SpiderWaveCount") or 0
	    
	-- Clamp invalid Spiderling number requests to the maximum amount of eggs available
	if((spiderWaveCnt > maxSpiderEggCnt) or (spiderWaveCnt < 0)) then
	    spiderWaveCnt = maxSpiderEggCnt
	end
	
	-- Reset our wave manager reference variables
    hatchCounter = spiderWaveCnt
    hatchList = {}

    -- Run the wave manager
    SpiderWaveManager(self)
	
end

----------------------------------------------
-- Manage Spiderling wave event
----------------------------------------------
function SpiderWaveManager(self)

    local spiderWaveCnt = self:GetVar("SpiderWaveCount") or 0
    local SpiderEggNetworkID = self:GetVar("SpiderEggNetworkID") or 0
    
    -- Reset the spider egg spawner network to ensure a maximum number of eggs
	SpiderEggNetworkID:SpawnerReset()
	
    -- Obtain a list of all the eggs on the egg spawner network
	local spiderEggList = SpiderEggNetworkID:SpawnerGetAllObjectIDsSpawned().objects
	if(table.maxn(spiderEggList) <= 0) then 
        GAMEOBJ:GetTimer():AddTimerWithCancel(1, "PollSpiderWaveManager", self)
        return
    end
	
	-- A check for wave mangement across multiple spawn iterations
	if(hatchCounter < spiderWaveCnt) then
	    -- We have already prepped some objects for hatching, 
	    -- remove them from our list for random egg pulls
	    for i, sVal in ipairs(spiderEggList) do
	        if(hatchList[sVal:GetID()]) then
	            -- We have found a prepped egg, remove it from the spiderEggList
	            spiderEggList[i] = nil
	        end
	    end

	end
	
	-- Select a number of random spider eggs from the list equal to the 
	-- current number needed to complete the current wave
	for i = 1, spiderWaveCnt do
	    -- Select a random spider egg
	    local randomEggLoc = math.random(table.maxn(spiderEggList))
	    local randomEgg = spiderEggList[randomEggLoc]
	    
	    if((randomEgg) and (randomEgg:Exists())) then
	        -- Prep the selected spider egg
	        randomEgg:FireEvent{senderID=self, args="prepEgg"}
	    
	        -- Add the prepped egg to our hatchList
	        hatchList[randomEgg:GetID()] = randomEgg
	        -- Decrement the hatchCounter
	        hatchCounter = hatchCounter - 1
	    end
	    
	    -- Remove it from our spider egg list
	    table.remove(spiderEggList, randomEggLoc)
	    
	    if((table.maxn(spiderEggList) <= 0) or (hatchCounter <= 0)) then 
            break
        end
	end
	
	if(hatchCounter > 0) then
	    -- We still have more eggs to hatch, poll the SpiderWaveManager again
	    GAMEOBJ:GetTimer():AddTimerWithCancel(1, "PollSpiderWaveManager", self)
	
	else
	    -- We have successfully readied a full wave
	    -- initiate hatching!
	    for key, hatchEgg in pairs(hatchList) do
	        hatchEgg:FireEvent{senderID=self, args="hatchEgg"}
	    end
	    hatchList = {}
	    
	end
	
end

----------------------------------------------
-- Sense for Spider Boss skill casting to process timing events
----------------------------------------------
function onCastSkill(self, msg)
    if msg.skillID == bossSmashSkill then
        -- We are melee smash attacking!
        self:SetVar("bSpecialLock", true)
        -- Prepare a timer for special attack unlocking
        GAMEOBJ:GetTimer():AddTimerWithCancel(smashSkillLength, "UnlockSpecials", self)
	
	end
end

----------------------------------------------------------------
-- Manages the processing and timing of Spider Boss stage specific
-- special skill firing
----------------------------------------------------------------
function SpiderSkillManager(self, bActive)
    -- Active state?
    if(not bActive) then
        GAMEOBJ:GetTimer():CancelTimer("PollSpiderSkillManager", self)
        return
    end
    
    -- Are we committed to a special attack locking skill?
    if(self:GetVar("bSpecialLock")) then
        -- Queue the empty skill to mark when to use a special skill
        self:SetVar("bSpecialQueued", true)
        return
    end
    
    -- Are we withdrawn?
    local isWithdrawn = self:GetVar("isWithdrawn") or false
    
    if(not isWithdrawn) then
        -- Grab the current Spider stage
        local currentStage = self:GetVar("CurrentBossStage")
        
        if(currentStage == 2) then
            -- Run the Rapid Fire Shooter skill
            RunRapidFireShooter(self)

        elseif(currentStage == 3) then
            -- Run the Rain Of Fire skill
            RunRainOfFire(self)

        end 
    end
end

----------------------------------------------------------------
-- Called when timers are done
----------------------------------------------------------------
function onTimerDone(self,msg)

	if msg.name == "PollSpiderWaveManager" then
	    -- Call the manager again to attempt to finish prepping a Spiderling wave
	    -- Run the wave manager
        SpiderWaveManager(self)
    
    elseif msg.name == "PollROFManager" then
        -- Call the manager again to attempt to initiate an impact on another random location
        -- Run the ROF Manager
        RainOfFireManager(self) 
        
    elseif msg.name == "PollRFSManager" then
        -- Call the manager again to attempt to initiate a rapid fire shot at the next sequential target
        -- Run the ROF Manager
        RapidFireShooterManager(self)
    
    elseif msg.name == "StartROF" then
        -- Re-enable Spider Boss
        ToggleForSpecial(self, false)
                    
        RainOfFireManager(self)
        
    elseif msg.name == "PollSpiderSkillManager" then
        -- Call the skill manager again to attempt to run the current Spider Boss
        -- stage's special attack again
        SpiderSkillManager(self, true)
        
    elseif msg.name == "RFS" then
        RunRapidFireShooter(self)
        
    elseif msg.name == "RFSTauntComplete" then 
        -- Determine an appropriate random time to check our manager again 
        local spiderCooldownDelay = math.random(s1DelayMin, s1DelayMax)
        -- Set a timer based on our random cooldown determination
        -- to pulse the SpiderSkillManager again
        GAMEOBJ:GetTimer():AddTimerWithCancel(spiderCooldownDelay, "PollSpiderSkillManager", self)
        -- Re-enable Spider Boss
        ToggleForSpecial(self, false)
        
    elseif msg.name == "WithdrawComplete" then
        -- Play the Spider Boss' mountain idle anim
        playAnimAndReturnTime(self, spiderWithdrawIdle)
        -- The Spider Boss has retreated, hatch a wave!
        local currentStage = self:GetVar("CurrentBossStage")
        -- Prepare a Spiderling wave and initiate egg hatch events
	    self:SetVar("SpiderWaveCount", spiderWaveCntTable[currentStage])
	    SpawnSpiderWave(self)
	    
	elseif msg.name == "AdvanceAttack" then 
	    -- Fire the melee smash skill to throw players back
	    local landingTarget = self:GetVar("LandingTarget") or false
	    
	    if((landingTarget) and (landingTarget:Exists())) then
            local advSmashFlag = landingTarget:CastSkill{skillID = bossLandingSkill}
            landingTarget:PlayEmbeddedEffectOnAllClientsNearObject{radius = 100, fromObjectID = landingTarget, effectName = "camshake-bridge"}
	    end
	    
	elseif msg.name == "AdvanceComplete" then 
	    -- Reset faction and collision
	    local SBFactionList = self:GetVar("SBFactionList")
	    local SBCollisionGroup = self:GetVar("SBCollisionGroup")
	    
	    for i, fVal in ipairs(SBFactionList) do
	        if(i == 1) then
	            -- Our first faction - flush and add
	            self:SetFaction{faction = fVal}
	        else
	            -- Add
	            self:ModifyFaction{factionID = fVal, bAddFaction = true}
	        end
	    end
        
        self:NotifyClientObject{name = "SetColGroup", param1 = SBCollisionGroup}
        
	    -- Grab the current wave count
        local currentStage = self:GetVar("CurrentBossStage") 
        -- Advance to the next Boss stage
        local advancedStage = currentStage + 1
	    self:SetVar("CurrentBossStage", advancedStage)
	    -- Reset the current wave death counter
	    self:SetVar("deathCounter", 0)
        
        -- Wind up, telegraphing next round
        local animTime = playAnimAndReturnTime(self, spiderJeerAnim)
        GAMEOBJ:GetTimer():AddTimerWithCancel(animTime, "AdvanceTauntComplete", self)
    
    elseif msg.name == "AdvanceTauntComplete" then
        -- Grab the current boss stage
        local currentStage = self:GetVar("CurrentBossStage")
        -- Declare a default special Spider Boss skill cooldown
        local spiderCooldownDelay = 10
	    if(currentStage == 2) then
	        spiderCooldownDelay = math.random(s1DelayMin, s1DelayMax)
	    elseif(currentStage == 3) then
	        spiderCooldownDelay = math.random(s2DelayMin, s2DelayMax)
	    end
	    -- Set a timer based on our random cooldown determination
        -- to pulse the SpiderSkillManager
        GAMEOBJ:GetTimer():AddTimerWithCancel(spiderCooldownDelay, "PollSpiderSkillManager", self)
        
        -- Remove current status immunity
        self:SetStatusImmunity{ StateChangeType = "POP", bImmuneToSpeed = true, bImmuneToBasicAttack = true, bImmuneToDOT = true}
        
        self:SetStunned{StateChangeType = "POP", 
                    bCantMove = true,
                    bCantJump = true,
                    bCantTurn = true,
                    bCantAttack = true,
                    bCantUseItem = true,
                    bCantEquip = true,
                    bCantInteract = true,
                    bIgnoreImmunity = true}
        
    elseif  msg.name == "Clear" then
        GAMEOBJ:GetZoneControlID():FireEvent{senderID=self, args="ClearProperty"}
        GAMEOBJ:GetTimer():CancelAllTimers(self)
	
	elseif msg.name == "UnlockSpecials" then
	    -- We no longer need to lock specials
        self:SetVar("bSpecialLock", false)
        
        -- Did we queue a spcial attack?
        if(self:GetVar("bSpecialQueued")) then
            self:SetVar("bSpecialQueued", false)
            SpiderSkillManager(self, true)
        end
	    
	end
	
end

----------------------------------------------
-- Utility function capable of playing a priority 
-- animation on a target and returning either the
-- anim time, or a desired default
----------------------------------------------
function playAnimAndReturnTime(self, animID)
	-- Get the anim time
	local animTimer = self:GetAnimationTime{animationID = animID}.time 
	
	-- If we have an animation play it
	if animTimer > 0 then 
		self:PlayAnimation{animationID = animID, fPriority = 4.0}
	end
	
	-- If the anim time is less than the the default time use default
	if animTimer < defaultAnimPause then
		animTimer = defaultAnimPause
	end
	
	return animTimer
end

----------------------------------------------
-- Obtain and return a random player ID from a list
-- of all current players in the zone
----------------------------------------------
function getRandomPlayer(self)

    -- Obtain a current list of players in the zone
    local playerTable = GAMEOBJ:GetZoneControlID():GetVar("PlayerTable") or {}
    local playerTableLen = table.maxn(playerTable)
    
    local playerTarget = 0
    -- Process the list for the first random existing player from the list
    for i = 1, playerTableLen do
        -- Grab a random player from the list
        local randomPlayerLoc = math.random(playerTableLen)
	    local randomPlayer = playerTable[randomPlayerLoc] or 0
	    
	    if(GAMEOBJ:GetObjectByID(randomPlayer):Exists()) then
	        -- We have found a valid player
	        -- set and exit list processing
	        playerTarget = randomPlayer
	        break
	    else
	        -- Remove the nonexistant reference and search again
	        table.remove(playerTable, randomPlayerLoc)
	    end
    end
    
    -- Return the results
    return playerTarget
    
end

----------------------------------------------
-- Iterate through the Spiderling table and 
-- destroy any currently alive entries
----------------------------------------------
function CleanupSpiders(self)
    local spiderlingTable = self:GetVar("spiderlingTable") or {}
    -- Iterate through the table
    for k, spiderling in ipairs(spiderlingTable) do
	    spiderling:RequestDie{killerID = self, killtype = "VIOLENT"}
    end
end

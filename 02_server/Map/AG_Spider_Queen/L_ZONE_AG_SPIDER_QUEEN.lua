----------------------------------------------------------------
-- level specific Server script for repeatable spider boss fight
-- based on the AG small property
-- this script should be in the zone script in the DB
--
-- created mrb... 6/29/11
-- updated abeechler ... 7/14/11 - Refactored instance script to remove property functionality
----------------------------------------------------------------

--------------------------------------------------------------
-- Includes
--------------------------------------------------------------
require('02_server/Map/Property/AG_Small/L_ZONE_AG_PROPERTY')
require('ai/ACT/L_ACT_GENERIC_ACTIVITY_MGR')

--//////////////////////////////////////////////////////////////////////////////////
-- User Config local variables
-- player flags. These have to be different for each property map. these are set up in the db
local flags = {}
local chestObject = 16318

local destroyedCinematic = "DesMaelstromInstance"       -- What to play when we clear the property

local GUIDMaelstrom = "{7881e0a1-ef6d-420c-8040-f59994aa3357}"  -- ambient sounds for when the Maelstrom is on
local GUIDPeaceful	= "{c5725665-58d0-465f-9e11-aeb1d21842ba}" -- happy ambient sounds when no maestrom is preset

----------------------------------------------------------------
-- leave the functions below alone
----------------------------------------------------------------
function onZoneLoadedInfo(self, msg)
    --self:SetVar('ExpectedNumOfPlayers', msg.maxPlayersSoft)
    loadInstance(self)
    -- set up the activity
    self:SetActivityParams{ modifyMaxUsers = true, maxUsers = 2, modifyActivityActive = true,  activityActive = true} 
end

----------------------------------------------------------------
-- 
----------------------------------------------------------------
function basePlayerLoaded(self, msg)
	
	local player = msg.playerID
	
	-- add the player to the activity
	UpdatePlayer(self, player)
	
	--remove the activity cost from the player as they load into the map
	local takeCost = self:ChargeActivityCost{user = player}.bSucceeded
	
	-- print('cost taken for: ' .. player:GetName().name .. ' = ' .. tostring(takeCost))
    
    local maxHealth = player:GetMaxHealth{}.health
    local maxArmor = player:GetMaxArmor{}.armor
    local maxImagination = player:GetMaxImagination{}.imagination
    
    player:SetHealth{ health = maxHealth }
    --print("set health=" .. player:GetHealth{}.health)
    
    player:SetArmor{ armor = maxArmor }
    --print("set armor=" .. player:GetArmor{}.armor)
    
    player:SetImagination{ imagination = maxImagination }
    --print("set imagination=" .. player:GetImagination{}.imagination)
    
    player:Play2DAmbientSound{m_NDAudioEventGUID = GUIDMaelstrom}
    
    local pID = self:GetVar("playerID") or false
    if(not pID) then
        setGameVariables(false,false,flags)
	
	    self:SetVar("IsInternal", player:GetVersioningInfo().bIsInternal)

	    self:SetNetworkVar("unclaimed",true)
	
	    --spawn the spots
	    SpawnSpots(self)
	    self:SetVar("playerID",player:GetID())
	
	    -- custom function that starts all the maelstrom 
	    StartMaelstrom(self,player)
	else
	    self:NotifyClientObject{ name = "maelstromSkyOn", rerouteID = player }
	end
end

----------------------------------------------------------------
-- process event calls
----------------------------------------------------------------
function onFireEvent(self, msg)
    -- Receive the sending object ID and the message to parse
	local eventType = msg.args
	
	-- Missing a valid event type?
	if not eventType then return end
	
	if eventType == "ClearProperty" then
        -- Initiate the chain of events that process the conversion of
        -- the Player property
	    local player = GAMEOBJ:GetObjectByID(self:GetVar("playerID"))
        -- Start the camera that shows the maelstrom dying
	    GAMEOBJ:GetZoneControlID():NotifyClientObject{name = "PlayCinematic", paramStr = destroyedCinematic}
	    player:SetFlag{iFlagID = flags.defeatedProperty, bFlag=true}
	    -- Start the timer for the next phase	
        GAMEOBJ:GetTimer():AddTimerWithCancel( 0.5, "tornadoOff", self )
    
    else
        baseOnFireEvent(self, msg)
        
	end
	
end

----------------------------------------------------------------
-- called when a player exits the zone
----------------------------------------------------------------
function onPlayerExit(self,msg)
	-- remove the player from the activity
	UpdatePlayer(self, player, false)
	
	removePlayerRef(self, msg)
	
end

----------------------------------------------------------------
-- called when timers are done
----------------------------------------------------------------
function onTimerDone(self,msg)
	if msg.name == "ShowVendor" or msg.name == "BoundsVisOn" or msg.name == "GuardFlyAway" then
		return
	end
	
	if msg.name == "killSpider" then
		local spawnTarget = self:GetObjectsInGroup{group = "Land_Target", ignoreSpawners = true}.objects 
		
		for k,obj in ipairs(spawnTarget) do
			if obj:Exists() then			
				-- get the location of the landing spot
				local mypos = obj:GetPosition().pos
				local myRot = obj:GetRotation()
				
				local config = { {"parent_tag", self} }
				
				-- check to see if we need to spawn a chest
				if chestObject then
					-- spawn a treasure chest
					RESMGR:LoadObject { objectTemplate = chestObject , x = mypos.x , y = mypos.y , z = mypos.z ,owner = self,
										rw= myRot.w, rx= myRot.x, ry= myRot.y , rz = myRot.z, configData = config}
				end
				
				break
			end
		end
        
	end	
	
	baseTimerDone(self,msg,newMsg)
end

------------------------------------------------
---- called when an activity timer is updated
------------------------------------------------
--function onActivityTimerUpdate(self, msg)
--    -- update the ui with the current time
--    if msg.name == "Boss_Timer" then
--        --self:UIMessageServerToAllClients{strMessageName = "UpdateFootRaceScoreboard", args = {{"time", msg.timeElapsed }} }
--    end
--end

------------------------------------------------
---- called when an activity timer is finished
------------------------------------------------
--function onActivityTimerDone(self, msg)
--    if msg.name == "Start_Timer_Delay" then
--        ----------------------------------------------------------------------------------------------------------------------
--        --The flow from accepting the footrace eventually gets to this statement after countdowns and animations
--        ----------------------------------------------------------------------------------------------------------------------        
--        ActivityTimerStart(self, "Boss_Timer", 0.20, self:GetVar("startTime")) --ActivityTimerStart(self, timerName, updateTime, stopTime)
--        --self:UIMessageServerToAllClients{strMessageName = "ToggleFootRaceScoreboard", args = {{"visible", true }, {"time", self:GetVar("startTime") }} }
--    end
--end 
----------------------------------------------------------------
-- level specific Server script for Property Pushback in AG small property
-- this script requires a base script
-- this script should be in the zone script in the DB
-- updated 6/18/10 added tutorial mission stuff
-- updated mrb... 9/7/10 - added brickLinkMissionID
-- updated abeechler... 7/25/11 - Spider Boss clean-up included in log-out calls
----------------------------------------------------------------

--------------------------------------------------------------
-- Includes
--------------------------------------------------------------
require('zone/PROPERTY/L_BASE_PROPERTY_SERVER')

--//////////////////////////////////////////////////////////////////////////////////
-- User Config local variables
local OwnerChecked = false

local GUIDMaelstrom = "{7881e0a1-ef6d-420c-8040-f59994aa3357}"  -- ambient sounds for when the Maelstrom is on
local GUIDPeaceful	= "{c5725665-58d0-465f-9e11-aeb1d21842ba}" -- happy ambient sounds when no maestrom is preset

--GROUPS, set in Happy Flower on objects
local Group = {
				Guard			= "Guard", -- mission giver npc
				PropertyPlaque	= "PropertyPlaque", -- make sure this matching the client script
				PropertyVendor	= "PropertyVendor", -- the object the player actually rents the property from
				Land_Target     = "Land_Target",
				Spider_Scream   = "Spider_Scream", -- mountain emitter for Boss screaming
                ROF_Targets 	= {"ROF_Targets_00", "ROF_Targets_01", "ROF_Targets_02", "ROF_Targets_03", "ROF_Targets_04"}, -- the groups of Spider Boss attack targets
				SpiderEggs      = "SpiderEggs", -- the smashable egg objects capable of hatching Dark Spiderlings
				Rocks           = "Rocks", -- the smashable rock objects
                Enemies         = "SpiderBoss", -- the Spider Boss AI instance
                ZoneVolumes     = {"Zone1Vol", "Zone2Vol", "Zone3Vol", "Zone4Vol", "Zone5Vol", "Zone6Vol", "Zone7Vol", "Zone8Vol", "AggroVol", "TeleVol"}, --each group contains a single volume that handles zone sensing for the map's four quadrants
                FXManager		= "FXObject" -- the hidden object underground (small yellow box) that controls all the env fx for the map
			  }

-- Spawner networks, set in happy flower
local Spawners = {
					Enemy 			= "SpiderBoss", -- this can be as many spawner networks as necessary, but all spawner networks with enemies should be listed
					BossSensors     = {"Zone1Vol", "Zone2Vol", "Zone3Vol", "Zone4Vol", "Zone5Vol", "Zone6Vol", "Zone7Vol", "Zone8Vol", "RFS_Targets", "AggroVol", "TeleVol"},
					Land_Target     = "Land_Target",
					Spider_Scream   = "Spider_Scream", -- mountain emitter for Boss screaming
                    ROF_Targets 	= {"ROF_Targets_00", "ROF_Targets_01", "ROF_Targets_02", "ROF_Targets_03", "ROF_Targets_04"}, -- the spawner network for the Spider Boss attack targets
					PropMG  		= "PropertyGuard", -- spawns the mission giver for this property
					FXManager		= "FXObject", -- the hidden object underground (small yellow box) that controls all the env fx for the map
					PropObjs		= "BankObj", -- spawns objects that player's can interact with once a property is claimed
					SpiderEggs      = "SpiderEggs", -- the smashable egg objects capable of hatching Dark Spiderlings
					Rocks           = "Rocks", -- the smashable rock objects
					SpiderRocket    = { "SpiderRocket_Bot","SpiderRocket_Mid","SpiderRocket_Top" }, -- spawns the pieces of the Spider Boss entry rocket
                    AmbientFX		= { "BirdFX","SunBeam" }  -- the ambient happy effects for the property, they are on by default and are turned off if maelstrom is spawned
				 }
				 
-- Special spawner networks that differentiate the Property versus the Instance
local PropertySpawners = {
                            Mailbox   = "Mailbox", -- property mailbox
					        Launcher  = "Launcher" -- property launcher
                         }
                         
local InstanceSpawners = {
                            Instancer = "Instancer" -- instance interact
                         }
				 
-- player flags. These have to be different for each property map. these are set up in the db
local flags = { 
				defeatedProperty 	= 71,  -- when the player builds the claim marker, this flag is set
				placedModel 		= 73,	-- when a player places a model for the first time, this flag is set
				guardFirstMission	= 891, -- make sure the player has started the guards first mission, workaround for 1.9
				guardMission		= 320, -- last mission for the guard
				password			= "s3kratK1ttN", -- behavior password build qb object with behaviors
				brickLinkMissionID  = 951           -- Achievement ID to complete on property rental
			  }
			  
local destroyedCinematic = "DestroyMaelstrom"       -- What to play when we clear the property

----------------------------------------------------------------
-- leave the functions below alone
----------------------------------------------------------------

----------------------------------------------------------------
-- Called when the player fully loads into the map, passes the variables set above,
-- Sets up the map for maelstrom if the player has not defeated this map before
----------------------------------------------------------------			
function onPlayerLoaded(self, msg)
    if  OwnerChecked == false then  -- only check for owner when the first player enters property
		checkForOwner(self)
    end
	local propertyOwner = self:GetVar("PropertyOwner")
	-- returns true or false if the property is rented or not
	local rented = false
	if propertyOwner ~= 0 then  
	    rented = true
	end
	self:SetVar("rented", rented)
	
	if(not rented) then
        -- establish a player table (if one doesn't exist), and add the loaded 
        -- player's ID to it
        local playerTable = self:GetVar("PlayerTable") or {}
        local player = msg.playerID
        local playerID = player:GetID()
        table.insert(playerTable, playerID)
        self:SetVar("PlayerTable", playerTable)
    
        -- establish a player count (if one doesn't exist) and maintain accordingly
        local numPlayers = self:GetVar("numberOfPlayers") or 0
	    numPlayers = numPlayers + 1
	    self:SetVar("numberOfPlayers", numPlayers)
	end
	
    basePlayerLoaded(self,msg,newMsg)
end

----------------------------------------------------------------
-- Utility function used to determine whether to spawn the 
-- Property Guard based on mission status
----------------------------------------------------------------
function propGuardCheck(self, msg)
    -- mission state 
    local mState = msg.playerID:GetMissionState{missionID = flags.guardMission}.missionState
    local firstMState = msg.playerID:GetMissionState{missionID = flags.guardFirstMission}.missionState
    
    -- do we meet the requirements?
    if (firstMState < 8) or ((mState ~= 8) and (mState ~= 4)) then
		ActivateSpawner(self,Spawners.PropMG) -- spawn guard
	end
end

----------------------------------------------------------------
-- leave the functions below alone
----------------------------------------------------------------
function onZoneLoadedInfo(self, msg)
	loadProperty(self)
end

function loadInstance(self)
    setGameVariables(Group,Spawners,flags)
	-- spawn instance only objects
	ActivateSpawner(self, InstanceSpawners.Instancer)
end

function loadProperty(self)
    setGameVariables(Group,Spawners,flags)
	-- remove unwanted objects
	ActivateSpawner(self, PropertySpawners.Launcher)
	ActivateSpawner(self, PropertySpawners.Mailbox)
end

----------------------------------------------------------------
-- Adds Spider Boss property specific functionality to AG Small
----------------------------------------------------------------
function onFireEvent(self, msg)
    baseOnFireEvent(self, msg)
end

function baseOnFireEvent(self, msg)
	-- Receive the sending object ID and the message to parse
	local eventType = msg.args
	local sendObj = msg.senderID
	
	-- Missing a valid event type?
	if not eventType then return end
	
	if eventType == "RetrieveZoneData" then
	    -- Establish a script hook to the Spider Boss
	    self:SetVar("SpiderBossID", sendObj)
	    
	    -- Establish a network variable for objects to use
	    -- to retrieve information about the spider egg network
	    sendObj:SetVar("SpiderEggNetworkID", RetrieveSpawnerID(self, Spawners.SpiderEggs))
	
	    -- Establish a network variable for objects to use
	    -- to retrieve information about the Rain Of Fire targets
	    local ROFTargetGroupTable = {}
	    
	    -- Build an ID table for Target Groups
	    for i, nom in ipairs(Spawners.ROF_Targets) do
	        table.insert(ROFTargetGroupTable, RetrieveSpawnerID(self, Spawners.ROF_Targets[i]))
	    end
	    
	    sendObj:SetVar("ROFTargetGroupIDTable", ROFTargetGroupTable)
	    
	    -- Establish a variable for objects casting the landing attack
	    processGroupObjects(self, Group.Land_Target)
	    
	    -- Establish a variable for object emitting the Spider Scream
	    processGroupObjects(self, Group.Spider_Scream)
	    
	    -- Process zone volumes for proper object notifications
	    processGroupObjects(self, Group.ZoneVolumes)
	
	elseif eventType == "CheckForPropertyOwner" then
		-- An object has queried us for the ID of the property owner,
		-- return it to the sender
		local propertyOwner = self:GetVar("PropertyOwner") or 0
		sendObj:SetNetworkVar("PropertyOwnerID", propertyOwner)
		
    elseif eventType == "ClearProperty" then
        -- Initiate the chain of events that process the conversion of
        -- the Player property
	    local player = GAMEOBJ:GetObjectByID(self:GetVar("playerID"))
        -- Start the camera that shows the maelstrom dying
	    GAMEOBJ:GetZoneControlID():NotifyClientObject{name = "PlayCinematic", paramStr = destroyedCinematic}
	    player:SetFlag{iFlagID = flags.defeatedProperty, bFlag=true}
	    -- Start the timer for the next phase	
        GAMEOBJ:GetTimer():AddTimerWithCancel( 0.5, "tornadoOff", self )
            
	end
end

----------------------------------------------------------------
-- Utility function useful for group object processing
----------------------------------------------------------------
function processGroupObjects(self, group)
    -- We are process group objects for the Spider Boss to reference,
    -- obtain a handle to her
    local spiderBossID = self:GetVar("SpiderBossID")
    
    if(type(group) == "table") then
        -- Process table data according to identity
        if(group == Group.ZoneVolumes) then
            -- Loop through the zone volume group table and obtain a handle 
	        -- to each
	        for j, groupNom in ipairs(group) do
	            -- Iterate through the destination group and catch the first valid destination object
	            local zoneVol = self:GetObjectsInGroup{group = groupNom, ignoreSpawners = true}.objects
	            -- Ensure we actually executed a check
                local checkExecuted = false
	            for k, obj in ipairs(zoneVol) do
	                local exists = obj:Exists()
	                if exists then
	                    checkExecuted = true
	                    -- Subscribe for collision events
	                    spiderBossID:SendLuaNotificationRequest{requestTarget=obj, messageName="CollisionPhantom"}
	                    -- If we are at the AggoVol obj, subscribe for an off-collision event
	                    if(groupNom == "AggroVol") then
	                        spiderBossID:SendLuaNotificationRequest{requestTarget=obj, messageName="OffCollisionPhantom"}
	                        spiderBossID:SetVar("AggroVol", obj)
	                    end
	                
	                    break
	                
	                end
	            end
	            
	            -- Ensure iterative execution
	            if(not checkExecuted) then
	                GAMEOBJ:GetTimer():AddTimerWithCancel(0.3 , "ProcessGroupObj_ZoneVolumes", self)
	                break
	            end
	        end
	    
        end
        
    else
        -- Process singular group data according to identity
        -- Determine through group name the variable we are setting
        local setVarNom = group
        if(group == Group.Land_Target) then
            setVarNom = "LandingTarget"
        elseif(group == Group.Spider_Scream) then
            setVarNom = "ScreamEmitter"
        end
        
        -- Obtain the objects within the desired group
        local groupObjects = self:GetObjectsInGroup{group = group, ignoreSpawners = true}.objects
        -- Ensure we actually executed a check
        local checkExecuted = false
        -- Iterate through the objects and process for the first entity
        for k, obj in ipairs(groupObjects) do
            local exists = obj:Exists()
	        if exists then
	            checkExecuted = true
	            -- Store the reference
	            spiderBossID:SetVar(setVarNom, obj)
	            
	            break
	            
	        end
	    end
	    
	    -- Ensure iterative execution
	    if(not checkExecuted) then
	        GAMEOBJ:GetTimer():AddTimerWithCancel(0.3 , "ProcessGroupObj_" .. setVarNom, self)
	    end
    
    end
end

----------------------------------------------------------------
-- activates the spawner for the maelstrom spots
----------------------------------------------------------------
function SpawnSpots(self)
	-- activate all the ROF Targets
	for k,v in ipairs(Spawners.ROF_Targets) do
	    ActivateSpawner(self, v)
	end
	
	-- activate the landing target
	ActivateSpawner(self, Spawners.Land_Target)
end

----------------------------------------------------------------
-- deactive the spawner for the maelstrom spots and then delete them
----------------------------------------------------------------
function KillSpots(self)
	-- deactivate all the ROF Targets
	for k,v in ipairs(Spawners.ROF_Targets) do
	    DeactivateSpawner(self,v)
	end
	
	for j,u in ipairs(Group.ROF_Targets) do
	    local spots = self:GetObjectsInGroup{group = u, ignoreSpawners = true}.objects
	    ObjectRequestDie(self,spots)
	end
	
	-- deactivate the land target
	DeactivateSpawner(self, Spawners.Land_Target)
	local trgt = self:GetObjectsInGroup{group = Spawners.Land_Target, ignoreSpawners = true}.objects
	ObjectRequestDie(self, trgt)
end

----------------------------------------------------------------
-- activates the spawner for the Spider Boss crashed rocket
----------------------------------------------------------------
function SpawnCrashedRocket(self)
	-- activate all the rocket crash parts
	for k,v in ipairs(Spawners.SpiderRocket) do
	    ActivateSpawner(self, v)
	end
end

----------------------------------------------------------------
-- deactives the spawners for the Spider Boss crashed rocket and 
-- then delete them
----------------------------------------------------------------
function KillCrashedRocket(self)
	-- deactivate all the rocket crash parts
	for k,v in ipairs(Spawners.SpiderRocket) do
	    DeactivateSpawner(self,v)
	    DestroySpawner(self,v)
	end
end

----------------------------------------------------------------
-- turns all the maelstrom on if the player hasn't defeated the maelstrom for this property yet
----------------------------------------------------------------
function StartMaelstrom(self,player)

	-- activate the Spider Boss spawner and build all the necessary sensor objects
	ActivateSpawner(self, Spawners.Enemy)
	for k,v in ipairs(Spawners.BossSensors) do
	    ActivateSpawner(self, v)
	end
	
	if Spawners.BehaviorObjs then
		for k,v in ipairs(Spawners.BehaviorObjs) do
			ActivateSpawner(self,v)
		end
	end   
          
	-- activate the spawner for the fx
	ActivateSpawner(self,Spawners.FXManager)
	-- activate the spawner for the mountain emitter
	ActivateSpawner(self,Spawners.Spider_Scream)
	-- activate the spawner for the eggs
    ActivateSpawner(self,Spawners.SpiderEggs)
    -- activate the spawner for the rocks
    ActivateSpawner(self,Spawners.Rocks)	
    -- activate the rocket crash parts
    SpawnCrashedRocket(self)	
	
	if Spawners.AmbientFX then
        for k,v in ipairs(Spawners.AmbientFX) do
            DeactivateSpawner(self,v)
            DestroySpawner(self,v)
            ResetSpawner(self,v)
        end
    end
	    
	startTornadoFX(self)
	
	-- notify the client to change the env settings 
	self:NotifyClientObject{ name = "maelstromSkyOn", rerouteID = player }
	
end

----------------------------------------------------------------
-- 
----------------------------------------------------------------
function baseNotifyCollisionPhantom(self,other,msg)
	-- This function is included to ensure the functionality
	-- found for this in the base script is properly cleared
    -- out to ensure there are no errors on accidental execution 
end

----------------------------------------------------------------
-- retrieve spawner ID
----------------------------------------------------------------
function RetrieveSpawnerID(self,spawnerName)
	local spawnerID = LEVEL:GetSpawnerByName(spawnerName)
	if spawnerID then
		return spawnerID
	else
		WarningPrint(self,'WARNING: No Spawner found for spawner named ' .. spawnerName)
	end
end

----------------------------------------------------------------
-- called when a timer is done
----------------------------------------------------------------
function baseTimerDone(self,msg)
		
	if msg.name == "GuardFlyAway" then
		-- the guard is "flying" away, delete him and turn the boundry animation on
		if LEVEL:GetCurrentZoneID() ~= 1150 then
			local GuardObjs = self:GetObjectsInGroup{ group = Group.Guard, ignoreSpawners = true }.objects
			local Guard = false
			-- Iterate through the group and catch the first valid object
            for k,obj in ipairs(GuardObjs) do
		        if obj:Exists() then
			        Guard = obj
		            break
	            end
	        end
	        
			GAMEOBJ:GetZoneControlID():NotifyClientObject{ name = "GuardChat", paramObj = Guard }
			GAMEOBJ:GetTimer():AddTimerWithCancel( 5, "KillGuard", self ) 
		end
		-- tell the client script to play the animation on the boundry asset
		
	elseif msg.name == "KillGuard" then
		KillGuard(self)
		
    elseif msg.name == "tornadoOff" then
		-- finds the fx manager
		local fxObjs = self:GetObjectsInGroup{group = Group.FXManager, ignoreSpawners = true}.objects
	    local fx = false
	    -- Iterate through the group and catch the first valid object
        for k,obj in ipairs(fxObjs) do
		    if obj:Exists() then
			    fx = obj
		        break
	        end
	    end
	    
		-- turn the tornado and vortex fx off
		if fx then
			fx:StopFXEffect{name = "TornadoDebris"}
			fx:StopFXEffect{name = "TornadoVortex"} 
			fx:StopFXEffect{name = "silhouette"}
		else
			WarningPrint(self,"Warning: No object found in the group "..Group.FXManager)
		end
		GAMEOBJ:GetTimer():AddTimerWithCancel( 1.2, "ShowVendor", self )
		GAMEOBJ:GetTimer():AddTimerWithCancel( 2, "ShowClearEffects", self ) 
		
	elseif msg.name == "ShowClearEffects" then
		-- finds the fx manager
		local fxObjs = self:GetObjectsInGroup{group = Group.FXManager, ignoreSpawners = true}.objects
	    local fx = false
	    -- Iterate through the group and catch the first valid object
        for k,obj in ipairs(fxObjs) do
		    if obj:Exists() then
			    fx = obj
		        break
	        end
	    end
	    
		-- play the light in the center of the property to show the maelstrom being defeated
		if fx then
			fx:PlayFXEffect{name = "beam", effectType = "beamOn"}
		else
			WarningPrint(self,"Warning: No object found in the group "..Group.FXManager)
		end
		GAMEOBJ:GetTimer():AddTimerWithCancel( 2, "killSpider", self ) 
		GAMEOBJ:GetTimer():AddTimerWithCancel( 1.5, "turnSkyOff", self ) 
		GAMEOBJ:GetTimer():AddTimerWithCancel( 8, "killFXObject", self ) 

	elseif msg.name == "turnSkyOff" then
		self:NotifyClientObject{ name = "SkyOff" }
		
	elseif msg.name == "killSpider" then
		-- kill all the enemies
		local enemies = self:GetObjectsInGroup{group = Group.Enemies}.objects
		ObjectRequestDie(self,enemies)
		for k,v in ipairs(Spawners.BossSensors) do
	        DeactivateSpawner(self,v)
		    DestroySpawner(self,v)
	    end
		
		-- clean the arena
		DeactivateSpawner(self,Spawners.SpiderEggs)
		DestroySpawner(self,Spawners.SpiderEggs)
		DeactivateSpawner(self,Spawners.Rocks)
		DestroySpawner(self,Spawners.Rocks)
		KillSpots(self)
		KillCrashedRocket(self)
		-- deactivate the spawner for the mountain emitter
	    DeactivateSpawner(self,Spawners.Spider_Scream)
		DestroySpawner(self,Spawners.Spider_Scream)
		
		local playerTable = self:GetVar("PlayerTable") or {}
        -- iterate through the table and find the exiting player
        for i, pID in ipairs(playerTable) do 
            local player = GAMEOBJ:GetObjectByID(pID)
            player:Stop2DAmbientSound{m_NDAudioEventGUID = GUIDMaelstrom } -- kill the maelstrom windy sound
		    player:Play2DAmbientSound{m_NDAudioEventGUID = GUIDPeaceful}-- start the happy bird sounds
        end
		
	elseif msg.name == "ShowVendor" then
		-- tell the client script to show the vendor
		GAMEOBJ:GetZoneControlID():NotifyClientObject{ name = "vendorOn" }
		if Spawners.AmbientFX then
            for k,v in ipairs(Spawners.AmbientFX) do
                ActivateSpawner(self,v)
            end
        end
		
	elseif msg.name == "BoundsVisOn" then
		-- tell the client script to turn the boundry on
		--GAMEOBJ:GetZoneControlID():NotifyClientObject{name = "boundsOn" }
		GAMEOBJ:GetZoneControlID():NotifyClientObject{name = "boundsAnim" }
		
	elseif msg.name == "runPlayerLoadedAgain" then
		checkForOwner(self)
		
	elseif msg.name == "pollTornadoFX" then
        startTornadoFX(self)
	
	elseif msg.name == "killFXObject" then

		local fxObjs = self:GetObjectsInGroup{group = Group.FXManager, ignoreSpawners = true}.objects
	    local fx = false
	    -- Iterate through the group and catch the first valid object
        for k,obj in ipairs(fxObjs) do
		    if obj:Exists() then
			    fx = obj
		        break
	        end
	    end
	    
		--stop the light fx
		if fx then
			fx:StopFXEffect{name = "beam"}
			-- kill the fx object
			DestroySpawner(self,Spawners.FXManager)
			self:SetVar("FXObjectGone", true)
		else
		    WarningPrint(self,"Warning: No object found in the group "..Group.FXManager)
			GAMEOBJ:GetTimer():AddTimerWithCancel( 1, "killFXObject", self )
		end
		
    elseif startsWith(msg.name, "ProcessGroupObj") then
        local processNom = split(msg.name, "_")[2]
        
        if(processNom == "LandingTarget") then
            processGroupObjects(self, Group.Land_Target)
        elseif(processNom == "ScreamEmitter") then
            processGroupObjects(self, Group.Spider_Scream)
        elseif(processNom == "ZoneVolumes") then
            processGroupObjects(self, Group.ZoneVolumes)
        end
	end	
end

----------------------------------------------------------------
-- called when the player rents a zone, turns on the property border
----------------------------------------------------------------
function onZonePropertyRented(self, msg)
	baseZonePropertyRented(self,msg,newMsg)
	
	if msg.playerID:GetFlag{iFlagID = 108}.bFlag == false then
		msg.playerID:SetFlag{iFlagID = 108, bFlag = true}
	end

	
end

----------------------------------------------------------------
-- called when the player places a model
----------------------------------------------------------------
function onZonePropertyModelPlaced(self, msg)
	
	local player = msg.playerID
	--the player placed their first model, set the flag to true
	if player:GetFlag{iFlagID = 101}.bFlag == false then
        baseZonePropertyModelPlaced(self,msg,newMsg) --it turns off the spots and sets a player flag
		player:SetFlag{iFlagID = 101, bFlag = true}
		-- if they are one the place 4 models mission, update the tutorial
		if player:GetMissionState{missionID = 871}.missionState == 2 then
			self:SetNetworkVar("Tooltip","AnotherModel")
		end
	-- the player placed a second model, set the flag
	elseif player:GetFlag{iFlagID = 102}.bFlag == false then
	    player:SetFlag{iFlagID = 102, bFlag = true}
	    -- if they are one the place 4 models mission, update the tutorial
	    if player:GetMissionState{missionID = 871}.missionState == 2 then
			self:SetNetworkVar("Tooltip","TwoMoreModels")
		end
	-- the player placed a third model, set the flag
	elseif player:GetFlag{iFlagID = 103}.bFlag == false then
	    player:SetFlag{iFlagID = 103, bFlag = true}
	-- the player placed a third model, set the flag
	elseif player:GetFlag{iFlagID = 104}.bFlag == false then
		--tell the client to close a tooltip, if it isnt open, it shouldnt do anything
		self:SetNetworkVar("Tooltip","TwoMoreModelsOff")
        player:SetFlag{iFlagID = 104, bFlag = true}  
	--the player has a tooltip telling them to place a model, which they just placed, so it needs to close it
	elseif self:GetVar("tutorial") == "placeModel" then
		self:SetVar("tutorial","TutorialOver")
		self:SetNetworkVar("Tooltip","PutAway")
		
	end
end

----------------------------------------------------------------
-- called when the player picks up a model
----------------------------------------------------------------
function onZonePropertyModelPickedUp(self, msg)

    local player = msg.playerID
	-- first time the player picked up a model, set their flag
	if player:GetFlag{iFlagID = 109}.bFlag == false then
		player:SetFlag{iFlagID = 109, bFlag = true}
		-- if they are on the mission to pick up a model, update the tutorial
		if player:GetMissionState{missionID = 891}.missionState == 2 then
			self:SetNetworkVar("Tooltip","Rotate")
		end
	end
	-- if the player has already picked up a model, is on the mission, but hasnt rotated a model, update the tutorial
	if player:GetFlag{iFlagID = 110}.bFlag == false and player:GetMissionState{missionID = 891}.missionState == 2 then
		self:SetNetworkVar("Tooltip","Rotate")
	-- if the player is on the mission, but has done the other to parts, then just turn the tooltip off
	elseif player:GetMissionState{missionID = 891}.missionState == 2 then
		self:SetNetworkVar("Tooltip","PickUpModelOff")
	end
		
end

----------------------------------------------------------------
-- called when the player removes a model from their property
----------------------------------------------------------------
function onZonePropertyModelRemoved(self, msg)
    local player = msg.playerID
    -- if this is the first time they have done it, set a flag
    if player:GetFlag{iFlagID = 111}.bFlag == false then
		player:SetFlag{iFlagID = 111, bFlag = true}
	end
end

----------------------------------------------------------------
-- called when the player removes a model from their property while its equipped
----------------------------------------------------------------
function onZonePropertyModelRemovedWhileEquipped(self, msg)
    local player = msg.playerID
    -- if this is the first time they have done it, set a flag
    if player:GetFlag{iFlagID = 111}.bFlag == false then
		player:SetFlag{iFlagID = 111, bFlag = true}
	end
end

----------------------------------------------------------------
-- called when the player enters property edit mode
----------------------------------------------------------------
function onZonePropertyEditBegin(self, msg)	
	-- tell the client the player entered edit mode
	self:SetNetworkVar("PlayerAction","Enter")
end

----------------------------------------------------------------
-- called when the player equips a model
----------------------------------------------------------------
function onZonePropertyModelEquipped(self,msg)
	-- tell the client the player equipped a model
	self:SetNetworkVar("PlayerAction","ModelEquipped")
end

----------------------------------------------------------------
-- called when the player rotates a model
----------------------------------------------------------------
function onZonePropertyModelRotated(self,msg)
	local player = msg.playerID
	-- if the player hasnt rotated a model before, set a flag
	if player:GetFlag{iFlagID = 110}.bFlag == false then 
		player:SetFlag{iFlagID = 110, bFlag = true}  
		-- if they are on the mission to rotate a model, update the tutorial
		if player:GetMissionState{missionID = 891}.missionState == 2 then
			self:SetNetworkVar("Tooltip","PlaceModel")
			-- used in pickupmodel to close the tooltip
			self:SetVar("tutorial","placeModel")
		end
	end
end

----------------------------------------------------------------
-- called when the player leaves property edit mode
----------------------------------------------------------------
function onZonePropertyEditEnd(self, msg)
	self:SetNetworkVar("PlayerAction","Exit")
end

----------------------------------------------------------------
-- called from the generator object when they die
----------------------------------------------------------------
function notifyDie(self,other,msg)
	baseNotifyDie(self,other,msg)
end

-------------------------------------------------------
-- called when a player exits the zone
----------------------------------------------------------------
function onPlayerExit(self,msg)
    local rented = self:GetVar("rented")
    
    if(not rented) then
        removePlayerRef(self, msg)
	    local numPlayers = self:GetVar("numberOfPlayers") or 0
	    
	    if(numPlayers == 0) then
	        -- Clean up any spawned Spiderlings
	        local spiderBoss = self:GetVar("SpiderBossID")
	        spiderBoss:FireEvent{args = "CleanupSpiders"}
	        -- Reset the Spider Boss network
	        DeactivateSpawner(self,Spawners.Enemy)
			DestroySpawner(self,Spawners.Enemy)
			ResetSpawner(self,Spawners.Enemy)
	        -- Finalize zone reset
	        basePlayerExit(self,other,msg)
	    end
	else
	    basePlayerExit(self,other,msg)
    end
end

----------------------------------------------------------------
-- utility function handling the process of player removal
----------------------------------------------------------------
function removePlayerRef(self, msg)
    -- maintain the player count
    local numPlayers = self:GetVar("numberOfPlayers") or 0
	numPlayers = numPlayers - 1
	self:SetVar("numberOfPlayers", numPlayers)
	
	-- update player table
    local playerTable = self:GetVar("PlayerTable") or {}
    local player = msg.playerID
    local playerID = player:GetID()
    -- iterate through the table and find the exiting player
    for i, pID in ipairs(playerTable) do
        if(pID == playerID) then
            -- remove the exiting player from the table
            table.remove(playerTable, i)
            break
        end
    end
    self:SetVar("PlayerTable", playerTable)
end

----------------------------------------------------------------
-- called from the orb when something collides with it
----------------------------------------------------------------
function notifyCollisionPhantom(self,other,msg)
    baseNotifyCollisionPhantom(self,other,msg)
end

----------------------------------------------------------------
-- called from the quickbuild behavior model when its done rebuilding
----------------------------------------------------------------
function notifyRebuildComplete(self,other,msg)
    baseNotifyRebuildComplete(self,other,msg)
end

----------------------------------------------------------------
-- called when notify object message is recieved
----------------------------------------------------------------
function onNotifyObject(self,msg)
	-- send from the guard when the player accepts the mission to rotate, pick up and put away
	if msg.name == "LastMissionAccepted" then
		local player = msg.ObjIDSender
		--check to see if the player already did all the stuff in the tutorial, then skip it
		if player:GetMissionState{missionID = 891}.missionState ~= 4  then 
			self:SetNetworkVar("Tooltip","ThinkingHat")
		end
	end
end

----------------------------------------------------------------
-- called when timers are done
----------------------------------------------------------------
function onTimerDone(self,msg)
	baseTimerDone(self,msg,newMsg)
end

----------------------------------------------
-- Splits a string based on the pattern passed in
----------------------------------------------
function split(str, pat)
    local t = {}
    -- creates a table of strings based on the passed in pattern   
    string.gsub(str .. pat, "(.-)" .. pat, function(result) table.insert(t, result) end)

    return t
end 

----------------------------------------------
-- Parses strings for token identification
----------------------------------------------
function startsWith(String,Start)
    -- finds if a string starts with a giving string.
   return string.sub(String,1,string.len(Start))==Start
end 
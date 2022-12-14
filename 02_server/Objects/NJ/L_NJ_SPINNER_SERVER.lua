----------------------------------------
-- BASE script on the ninjago spinner
-- Generic Server Spinner Traps
--
-- updated by mrb... 6/16/11 - refactored
---------------------------------------------
-- current objIDs: 
-- Imagination: 16155 or 16154 or 16153 or 16152 or 14385 or 14384 or 14383 or 14382
-- Earth: 		16203 or 16213 or 16214 or 16215 or 16216 or 16217 or 16218 or 16219
-- Fire:		16220 or 16221 or 16222 or 16223 or 16224 or 16225 or 16226 or 16227
-- Ice:			16228 or 16229 or 16230 or 16231 or 16232 or 16233 or 16234 or 16235
-- Lightning:	16236 or 16237 or 16238 or 16239 or 16240 or 16241 or 16242 or 16243
---------------------------------------------
-- config data variables for HF; defaults listed. ** if nothing is set the spinner defaults to a toggle elevator spinner **
-- type -> 0:elevator 					-- other types; blade, arrow 
-- spin_distance -> 1:3.5				-- setting this will change the distance the player has to be from the object to cast the skill
-- damage_radius -> 1:7					-- this changes the radius of the damage proximity 
-- damage_height -> 1:-4				-- this changes the height of the damage proximity, it's negative cause the pivot point of these objects are at the top of the object
-- skill_pulse_time -> 1:1				-- this is how long to wait to pulse a skill
-- reset_time -> 1:0 					-- this is how long to wait before putting the spinner back to it's initial state, 0 means the spinner toggles on skill cast with no reset time
-- once_only -> 7:1 					-- if this is set it will move once and lock in place and will never be able to be triggered again
-- static -> 7:0						-- if this is set to 1 then the spinner will be locked in it's starting position unless triggered from an event
-- element_type -> 0:imagination		-- other types; fire, earth, ice, lightning, collision, imagination
-- spawner_network -> 0:networkName		-- spawner network to activate/deactivate with the spinner.
-- noninteract -> 7:0					-- if this is set to 1 it will make the spinner not interactive, interact can be turned on by fire event

--- cinematics
-- on_cinematic -> 0:spinner1on			-- animation to play when the spinner is put into the active state
-- off_cinematic -> 0:spinner1off		-- animation to play when the spinner is put into the inactive state

--- audio
-- audioMovementBeginGUID -> 0:{5c30c263-00ae-42a2-80a3-2ae33c8f13fe} -- audio oneshot to play when the spinner starts moving
-- audioMovementEndGUID -> 0:{5c30c263-00ae-42a2-80a3-2ae33c8f13fe} -- audio oneshot to play when the spinner stops moving
-- audioMovementGUID -> 0:{7f770ade-b84c-46ad-b3ae-bdbace5985d4} -- audio loop to play while the spinner moves
-- audioSpinningGUID -> 0:{8dcf670f-9fe9-4f14-b5ba-0a8e0943c2f6} -- audio loop to play while the spinner spins in the active state

--- spawners
-- NoSpawnerFX -> 7:0			-- set to 7:1 if you do not want the spawner spinner fx to play when activated
-- spawnNw1 -> 0:spawnerName	-- first spawner network to activate/deactivate
-- spawnNw# -> 0:spawnerName#	-- consecutive spawner networks to activate/deactivate, should be spawnNw2, spawnNw3, etc...

--- fire events
-- name_activated_event --> 0:event1	-- event name to fire when the spinner is put into the active state
-- group_activated_event --> 0:group1	-- group name to fire the on_event_name to, this has to be set to fire the on event
-- name_deactivated_event --> 0:event2	-- event name to fire when the spinner is put into the inactive state
-- group_deactivated_event --> 0:group1	-- group name to fire the off_event_name to, this has to be set to fire the off event

--- types of events: this is set on the object configData in HF for the receiving the event. 
----
-- FORMAT: this is for the name_activated_event sent to the group_activated_event from above
-- event1 --> 0:activate
----
-- activate			-- use this variable name to put the spinner into the active state
-- deactivate		-- use this variable name to put the spinner into the inactive state
-- toggle_active	-- use this variable name to put the spinner into it's other active state
-- interact			-- use this variable name to put the spinner into the interactive state
-- noninteract		-- use this variable name to put the spinner into the noninactive state
-- toggle_interact	-- use this variable name to put the spinner into it's other interactive state
---------------------------------------------
-- green switch: 16195
-- red switch: 16196
---------------------------------------------
-- default variables incase there is no HF configdata; defaults listed
local defaultSpinDistance = 3.5		-- config data variable = spin_distance -> 1:3.5 
local defaultDamageRadius = 8		-- config data variable = damage_radius -> 1:10 
local defaultDamageHeight = -4		-- config data variable = damage_height -> 1:-4 
local defaultDamageVertOffset = -2	-- config data variable = damage_offset -> 1:-2
local defaultPulseTime = 1			-- config data variable = skill_pulse_time -> 1:1 
local defaultResetTime = 0			-- config data variable = reset_time -> 1:1 
local defaultSpawnFXType = "spawner_activate"

-- animations on use for player
local startAnim = "spinjitzu-staff-windup"
local runAnim = "spinjitzu-staff-loop"
local endAnim = "spinjitzu-staff-end"
local downAnimModifier = "-down"

-- spinner animation names
local upAnim = "up"
local downAnim = "down"
local idleDownAnim = "idle"
local idleUpAnim = "idle-up"

-- audio GUIDs
local audioMovementBeginGUID = "{5c30c263-00ae-42a2-80a3-2ae33c8f13fe}"
local audioMovementEndGUID = "{40e86d71-084c-4149-884e-ab9b45b694dc}"
local audioMovementGUID = "{b91d2f01-1998-4ca3-bb5c-c25cf36c7a24}"
local audioSpinningGUID = "{8dcf670f-9fe9-4f14-b5ba-0a8e0943c2f6}"

---------------------------------------------
-- type skills
local skills = 
{ 
	blade = 971,
	arrow = 972,
}
---------------------------------------------
-- element settings 
--TODO: make sure the staff lots are correct
local elements = 
--fire, earth, ice, lightning, collision, imagination
{ 
	imagination = {capFX = "spinner_interaction", precondition = 143, staffLOT = 11195}, --default
	fire = {capFX = "spinner_interaction", precondition = 144, staffLOT = 12656},
	earth = {capFX = "spinner_interaction", precondition = 145, staffLOT = 12657},
	ice = {capFX = "spinner_interaction", precondition = 146, staffLOT = 12658},
	lightning = {capFX = "spinner_interaction", precondition = 147, staffLOT = 12659},
	collision = {capFX = "green-switch", precondition = 143, staffLOT = 11195},
	collision_off = {capFX = "red-switch", precondition = 143, staffLOT = 11195},
}

local damageStartDelay = 1.0 -- how long to wait after the spinner reaches the active position to start the damage proximity
---------------------------------------------

-- print function that only works in an internal build
function debugPrint(self, text)	
	if self:GetVersioningInfo().bIsInternal then
		print(text)
	end
end

function onStartup(self, msg)
	spinStartup(self, msg)
end

function spinStartup(self, msg)    
    -- get the path attached to this object
	local pathName = self:GetVar("attached_path")
	
	-- if we dont have a path print a message to the log
	if (not pathName) and (not self:GetVar("platformIsSimpleMover")) then
		local pos = self:GetPosition().pos
		
		debugPrint(self, self:GetName().name .. " located at x:" .. pos.x .. " y:" .. pos.y .. " z:" .. pos.z .. "  is missing an attached_path")
		
		return
	end
	
	-- get the spin_distance from the config data or use the default
	local spinDist = self:GetVar("spin_distance") or defaultSpinDistance
	
	-- set up the prox radius for where the player needs to be to use the skill
	self:SetProximityRadius{radius = spinDist, shapeType = "CYLINDER", height = 5, name = "spin_distance"}
	
	-- stop the mover
	self:StopPathing()
	
	-- get the initial start node for the path
	local startNode = self:GetVar("attached_path_start")
	
	self:SetVar("stoppedNode", startNode)
	
	if self:GetVar("element_type") ~= "collision" and not self:GetVar("static") and not self:GetVar("noninteract") then
		self:SetNetworkVar("bInteractive", true)
		setCapFX(self, true)
	elseif not self:GetNetworkVar("bInteractive") or self:GetVar("noninteract") then
		self:SetNetworkVar("bInteractive", false)
		setCapFX(self, false)
	end
	
	self:SetNetworkVar("element_precondition_ID", getElementData(self).precondition)
	
	if self:GetVar("spawnNw1") then
		local tSpawners = {}
		local count = 1
		
		while self:GetVar("spawnNw"..count) do
			table.insert(tSpawners, self:GetVar("spawnNw"..count))
			count = count + 1
		end
		
		self:SetVar("tSpawners", tSpawners)
	end
	
	-- based on the start node set if it's active or not, set the spinNode (where it moves to when the skill is cast)
	if startNode == 1 then
		-- activate spinner
		toggleActive(self)
		-- play the up idle anim
		self:SetNetworkVar("current_anim", idleUpAnim)
		-- start the damage proximity
		toggleDamageProx(self, true)
		-- check for spawner network
		toggleSpawnerNetwork(self, true)
		self:SetVar("movingUp", false)
	else
		self:SetVar("movingUp", true)
	end	
end
function getElementData(self)
	local elementType = self:GetVar("element_type") or false
	
	if elementType then
		if elements[elementType] then
			return elements[elementType]
		end
	end
	
	return elements.imagination
end

function setCapFX(self, bTurnOn)	
	if self:GetVar("static") then return end
	
	local cap = getElementData(self)
	
	if bTurnOn then
		self:PlayFXEffect{name = "element_" .. cap.capFX, effectType = cap.capFX}
		self:SetVar("bCapShown", true)
	else		
		self:StopFXEffect{name = "element_" .. cap.capFX}
		self:SetVar("bCapShown", false)
	end
end

function playAnim(self, player, animName)
	-- see if this object has an animation on it by getting the time
	local animTime = player:GetAnimationTime{animationID = animName}.time
	
	if not animTime then return end
	
	-- if the time isn't more than 0 we dont want to do anything
	if animTime > 0 then
		local tempAnimName = animName
		
		if not self:GetVar("movingUp") then
			tempAnimName = animName .. downAnimModifier
		end
		
		-- play the interact animation
		player:PlayAnimation{ animationID = tempAnimName, fPriority = 2.0}
		-- start up the anim done timer
		self:ActivityTimerSet{name = "AnimDone_" .. animName, duration = animTime}
	end
end

function onCheckUseRequirements(self, msg)
	spinCheckUseRequirements(self, msg)
end

function spinCheckUseRequirements(self, msg)
    if self:GetNetworkVar('bIsInUse') then 
        msg.bCanUse = false
        
        return msg
    end
    
    local preConVar = self:GetVar("CheckPrecondition")
    
    if preConVar and preConVar ~= "" then             
        local check = msg.objIDUser:CheckListOfPreconditionsFromLua{PreconditionsToCheck = preConVar, requestingID = self}
        
        if not check.bPass then 
            msg.bCanUse = false
            
            return msg
        end
    end
    
    local preconID = getElementData(self).precondition    
    
    if preconID ~= -1 then
		local check = msg.objIDUser:CheckPrecondition{PreconditionID = preconID}

		if not check.bPass then 
			msg.bCanUse = false
		end
	end
	
	return msg
end

function onUse(self, msg)
	spinUse(self, msg)
end

function spinUse(self, msg)
	if not self:GetVar("bCapShown") or self:GetNetworkVar("bIsInUse") then return end
	
	self:SetNetworkVar("bFreezePlayer_" .. msg.user:GetID(), true)
	self:SetNetworkVar("bIsInUse", true)
	-- start playing the effects for the staff interaction
	msg.user:PlayFXEffect{name = "tornado", effectType = "on-anim", effectID = 5499}
	msg.user:PlayFXEffect{name = "staff", effectType = "on-anim", effectID = 5502}
	
    self:SetVar("userID", msg.user:GetID())
	playAnim(self, msg.user, startAnim)	
end


-- custom function that toggles the active state of the spinner based on it's current state
function setActiveState(self, bActive, bPlayerTriggered)		
	self:SetVar("bActive", bActive)
	
	--debugPrint(self, '2 ' .. tostring(bActive))
		
	if bPlayerTriggered then
		playCinematic(self, bActive)
	end
		
	if bActive then
		-- what is the type of the spinner, default = elevator 
		local type = self:GetVar("type")
		
		-- if arrow then start pulsing skill
		if type == "arrow" then
			local pulseTime = self:GetVar("skill_pulse_time") or defaultPulseTime
			
			-- start activity timer with update time and no duration to pulse the skill
			self:ActivityTimerSet{name = "Pulse_Skill", updateInterval = pulseTime}
		end
		
		self:SetVar("movingUp", true)
		-- play the up animation
		--self:PlayAnimation{ animationID = upAnim, fPriority = 2.0}
		self:SetNetworkVar("current_anim", upAnim)
	else
		self:SetVar("movingUp", false)
		-- play the down animation
		--self:PlayAnimation{ animationID = downAnim, fPriority = 2.0}
		self:SetNetworkVar("current_anim", downAnim)		
	end
	
	
end

-- custom function that toggles the active state of the spinner based on it's current state
function toggleActive(self, bPlayerTriggered)
	local bActive = self:GetVar("bActive") or false
	
	--debugPrint(self, '1 ' .. tostring(bActive))
	
	-- get the inverse bool value
	bActive = not bActive
		
	setActiveState(self, bActive, bPlayerTriggered)
end

function toggleSpawnerNetwork(self, bActive)
	local tSpawners = self:GetVar("tSpawners") or false
	
	if not tSpawners then return end
		
	if bActive and not self:GetVar("NoSpawnerFX") then
		local spawnFXType = self:GetVar("spawnFXType") or defaultSpawnFXType
		
		self:PlayFXEffect{name = "spawnFX", effectType = spawnFXType}			
	end
	
	for k, spawnerNetworkName in ipairs(tSpawners) do
		local spawner = LEVEL:GetSpawnerByName(spawnerNetworkName)
		
		if spawner and spawner:Exists() then			
			if bActive then
				spawner:SpawnerActivate()
				
				local totalToSpawn = self:GetVar("TotalSpawnedAlive") or 0
				totalToSpawn = totalToSpawn + spawner:SpawnerGetMaxToSpawn().iNum
				self:SetVar("TotalSpawnedAlive",totalToSpawn)
				
				self:SendLuaNotificationRequest{requestTarget = spawner, messageName = "NotifySpawnerOfDeath"}
			else
				spawner:SpawnerDestroyObjects{bDieSilent = false}
				spawner:SpawnerDeactivate()
			end
		else
			local loc = self:GetPosition().pos
			
			debugPrint(self, "Warning!! Spawner Network " .. spawnerNetworkName .. " doesn't exist on spinner at location " .. tostring(loc.x) .. ", " .. tostring(loc.y) .. ", " .. tostring(loc.z))
		end
	end
end

function notifyNotifySpawnerOfDeath(self,spawner,msg)
	local totalStillAlive = self:GetVar("TotalSpawnedAlive")
	if not totalStillAlive then return end
	
	totalStillAlive = totalStillAlive - 1
	
	if totalStillAlive < 0 then
		debugPrint(self, "Warning!! More enemies killed on Spawner Network " .. spawner:GetName().name .. " than were spawned. Probably something wrong with the script")
		return
	end
	
	self:SetVar("TotalSpawnedAlive",totalStillAlive)
	
	if spawner:SpawnerGetCurrentSpawned().iSpawned == 0 then
		self:SendLuaNotificationCancel{requestTarget = spawner, messageName = "NotifySpawnerOfDeath"}
		spawner:SpawnerDeactivate()
		spawner:SpawnerReset()
	end

	if totalStillAlive > 0 then return end
	
	-- fire deactivated event
	--sendEvent(self, false)
	activateSpinner(self, false)
end

-- custom function to playCinematic
function playCinematic(self, bPlayOn)			
	local player = GAMEOBJ:GetObjectByID(self:GetVar("userID"))
	
	if not player:Exists() then return end
	
	local cine = nil
	
	if bPlayOn then
		cine = self:GetVar("on_cinematic")
	else
		cine = self:GetVar("off_cinematic")
	end
	
	if not cine then return end
	
	player:RemoveBuff{uiBuffID = 60}
	player:PlayCinematic{pathName = cine}
end

-- custom function to find the skill type and cast it
function spinCastSkill(self)
	local type = self:GetVar("type")
	
	-- return out if we dont want to cast the skill
	if not type or type == "elevator" or not self:GetVar("bActive") then return end	
	
	local skill = skills[type]
	
	self:CastSkill{skillID = skill}
end

function toggleSpinner(self, bPlayerTriggered)		
	local bActivate = true
	
	if self:GetVar("stoppedNode") == 1  then
		bActivate = false
	end	
	
	activateSpinner(self, bActivate, bPlayerTriggered)	
end

function activateSpinner(self, bActivate, bPlayerTriggered)	
	-- get the node to move to
	local gotoNode = 0
	local newSpinNode = 1

	if bActivate then
		gotoNode = 1
		newSpinNode = 0
	end
	
	if gotoNode == self:GetVar("stoppedNode") then return end	
	
	-- stop all timers
	self:ActivityTimerStopAllTimers()
	
	-- set flag to true so this wont happen twice
	self:SetNetworkVar("bIsInUse", true)
	
	-- set to true because we dont want to castSkill while moving
	self:SetVar("bTraveling", true)	
	
	if bPlayerTriggered then
		-- get the time to reset, 0 means not to reset
		local resetTime = self:GetVar("reset_time") or defaultResetTime	
		
		if self:GetVar("once_only") then
			setCapFX(self, false)	
		elseif resetTime > 0 then
			self:SetVar("startResetOnArrived", true)
		else
			-- this will put the spinner in a waiting state when it arrives
			self:SetVar("resetOnArrived", true)
		end
	else
		-- this will put the spinner in a waiting state when it arrives
		self:SetVar("resetOnArrived", true)
	end
		
	if self:GetVar("element_type") == "collision" and self:GetVar("bCapShown") then	
		setCapFX(self, false)
		self:SetVar("element_type", "collision_off")
		setCapFX(self, true)
	end
	
	-- move the spinner
	self:GoToWaypoint{ iPathIndex = gotoNode, bStopAtWaypoint = true }
	
	self:SetVar("stoppedNode", gotoNode)
	
	-- Play the movement oneshot audio.
	local audioMovementOneshotGUID = self:GetVar("audioMovementBeginGUID") or audioMovementBeginGUID	
	self:PlayNDAudioEmitter{m_NDAudioEventGUID = audioMovementOneshotGUID}
	
	-- Play the movement loop audio.  Use a network var so that state is communicated upon ghosting.
	local audioMovementLoopGUID = self:GetVar("audioMovementGUID") or audioMovementGUID	
	self:SetNetworkVar("StopAudio", nil)	
	self:SetNetworkVar("PlayAudio", audioMovementLoopGUID)		
	
	-- toggleActive based on current state
	setActiveState(self, bActivate, bPlayerTriggered)
end

function toggleDamageProx(self, bOn)
	-- what is the type of the spinner, default = elevator 
	local type = self:GetVar("type")	
	
	-- blade uses a proximity radius for casting the skill, so set it
	if type ~= "blade" then return end	
	
		
	-- set the default up audio
	local audioGUID = self:GetVar("audioSpinningGUID") or audioSpinningGUID
			
	if bOn then
		-- get config data or use defaults
		local damageRaduis = self:GetVar("damage_radius") or defaultDamageRadius	
		local damageHeight = self:GetVar("damage_height") or defaultDamageHeight
		local heightOffset = self:GetVar("damage_offset") or defaultDamageVertOffset
		
		self:SetProximityRadius{name = "damage", radius = damageRaduis, height = damageHeight, shapeType = "CYLINDER", heightOffset = defaultDamageVertOffset}
		
		self:SetNetworkVar("StopAudio2", nil)				
		self:SetNetworkVar("PlayAudio2", audioGUID)				
	else
		self:UnsetProximityRadius{name = "damage"}
				
		self:SetNetworkVar("PlayAudio2", nil)				
		self:SetNetworkVar("StopAudio2", audioGUID)				
	end
end

--function onFireEventServerSide(self, msg)
--	spinFireEventServerSide(self, msg)
--end

---- TODO: Change this to setnetworkvar and play animations on the client
--function spinFireEventServerSide(self, msg)
--	if msg.args ~= "startAnim" then return end
	
--	local node = self:GetVar("stoppedNode") or 0
	
--	-- based on the start node set if it's active or not, set the spinNode (where it moves to when the skill is cast)
--	if node == 0 then return end
	
--	-- play the up animation
--	self:PlayAnimation{ animationID = idleUpAnim, fPriority = 2.0}
--end

function onFireEvent(self, msg)
	spinFireEvent(self, msg)
end

function spinFireEvent(self, msg)
--- types of events: this is set on the object configData in HF for the receiving the event. 
----
-- FORMAT: this is for the name_activated_event sent to the group_activated_event from above
-- event1 --> 0:activate
----
-- activate			-- use this variable name to put the spinner into the active state
-- deactivate		-- use this variable name to put the spinner into the inactive state
-- toggle_activate	-- use this variable name to put the spinner into it's other active state
-- interact			-- use this variable name to put the spinner into the interactive state
-- noninteract		-- use this variable name to put the spinner into the noninactive state
-- toggle_interact	-- use this variable name to put the spinner into it's other interactive state
	local eventType = self:GetVar(msg.args)
	
	if not eventType then return end
	
	if eventType == "activate" then
		activateSpinner(self, true)
	elseif eventType == "deactivate" then
		activateSpinner(self, false)
	elseif eventType == "toggle_activate" then
		toggleSpinner(self)
	elseif eventType == "interact" then
		if self:GetVar("element_type") ~= "collision" and not self:GetVar("static") then
			self:SetNetworkVar("bInteractive", true)
		end
		
		setCapFX(self, true)
	elseif eventType == "noninteract" then
		if self:GetVar("element_type") ~= "collision" and not self:GetVar("static") then
			self:SetNetworkVar("bInteractive", false)
		end
		
		setCapFX(self, false)
	elseif eventType == "toggle_interact" then
		local bInteractive = true
		
		if self:GetNetworkVar("bInteractive") then
			bInteractive = false
		end
		
		if self:GetVar("element_type") ~= "collision" and not self:GetVar("static") then
			self:SetNetworkVar("bInteractive", bInteractive)
		end
		
		setCapFX(self, bInteractive)
	end
	
	local playerID = self:GetVar("userID") or 0

	if playerID ~= 0 then		
		local player = self:GetObjectByID(playerID)
		
		if player:Exists() then
			playAnim(self, player, endAnim)
		end
	end
end

function sendEvent(self, bFireOn)
	local eventName = false
	local eventGroup = false
	
	if bFireOn then
		eventName = self:GetVar("name_activated_event") or false
		eventGroup = self:GetVar("group_activated_event") or false
	else
		eventName = self:GetVar("name_deactivated_event") or false
		eventGroup = self:GetVar("group_deactivated_event") or false	
	end
	
	if not eventName or not eventGroup then return end
	
	--debugPrint(self, 'name = ' .. eventName .. " group = " .. eventGroup)
	
	local groupObjs = self:GetObjectsInGroup{group = eventGroup, ignoreSpawners = true}.objects
	
	for k,obj in ipairs(groupObjs) do
		if obj:Exists() then
			obj:FireEvent{args = eventName, senderID = self}
		end
	end

end

function onArrived(self, msg)
	spinArrived(self, msg)
end

function spinArrived(self, msg)
	-- done traveleing so set this to false
	self:SetVar("bTraveling", false)
	
	if msg.wayPoint == self:GetVar("stoppedNode") and self:GetNetworkVar("bIsInUse") then
		if self:GetVar("resetOnArrived") then
			-- toggle to waiting state 
			self:SetNetworkVar("bIsInUse", false)
			self:SetVar("resetOnArrived", false)
			
			-- TODO: collision cap not working correctly
			if self:GetVar("element_type") == "collision_off" then
				setCapFX(self,false)
				self:SetVar("element_type", "collision")
			end
			
			setCapFX(self, true)
		elseif self:GetVar("startResetOnArrived") then
			-- get the time to reset, 0 means not to reset
			local resetTime = self:GetVar("reset_time") or defaultResetTime
			
			-- set the reset activity timer, no update only duration
			self:ActivityTimerSet{name = "Reset", duration = resetTime}
		end
	end
	
	local activeState = self:GetVar("bActive") or false	
	
	if activeState then		
		-- start a timer to delay when the player can be hit by the proximity, 
		-- this should prevent players getting hit when the move time is really short
		self:ActivityTimerSet{name = "Start_Damage", duration = damageStartDelay}
		
		-- check to see if we need to activate the spanwer network
		toggleSpawnerNetwork(self, true)
		-- play the animation
		self:SetNetworkVar("current_anim", idleUpAnim)
	else
		-- turn off the damage proximity
		toggleDamageProx(self, false)
		-- check to see if we need to deactivate the spanwer network
		toggleSpawnerNetwork(self, false)
		-- play the animation	
		self:SetNetworkVar("current_anim", idleDownAnim)
	end		
	
	-- Play the movement oneshot audio.
	local audioMovementOneshotGUID = self:GetVar("audioMovementEndGUID") or audioMovementEndGUID	
	self:PlayNDAudioEmitter{m_NDAudioEventGUID = audioMovementOneshotGUID}
	
	-- Stop the movement loop audio.  Use a network var so that state is communicated upon ghosting.
	local audioMovementLoopGUID = self:GetVar("audioMovementGUID") or audioMovementGUID	
	self:SetNetworkVar("PlayAudio", nil)	
	self:SetNetworkVar("StopAudio", audioMovementLoopGUID)		
	
	local player = GAMEOBJ:GetObjectByID(self:GetVar("userID"))
	
	if player:Exists() then
		playAnim(self, player, endAnim)
	end
	
	sendEvent(self, activeState)
	--debugPrint(self, 'Arrived @ ' .. msg.wayPoint)
end

function onProximityUpdate(self, msg)
	spinProximityUpdate(self, msg)
end

function spinProximityUpdate(self, msg)	
	-- cast skill if the player entered into the damage radius
	if msg.name == "damage" and self:GetVar("bActive") then
		if msg.status == "ENTER" then			
			-- if we're inUse then cast the skill
			local type = self:GetVar("type")
			
			if type == "blade" then
				spinCastSkill(self)
				self:ActivityTimerSet{name = "Pulse_Skill", updateInterval = 0.5}
			end
		elseif msg.status == "LEAVE" then
			-- get the number of players in the damage radus
			local numPlayers = #self:GetProximityObjects{name = "damage"}.objects or 0
			
			if numPlayers < 1 then
				self:ActivityTimerStop{name = "Pulse_Skill"}
			end
		end	
	elseif msg.name == "spin_distance" then
		if msg.status == "LEAVE" then
			local playerID = self:GetVar("userID") or 0
			
			if playerID ~= 0 then	
				if playerID == msg.objId:GetID() then 
					local player = GAMEOBJ:GetObjectByID(self:GetVar("userID"))
					
					if player:Exists() then
						playAnim(self, player, endAnim)
						
						if self:GetNetworkVar('bIsInUse') and not self:GetVar("bTraveling") then
							self:SetNetworkVar("bIsInUse", false)
						end
					end
				end
			end		
		elseif (msg.status == "ENTER" and 
				self:GetVar("element_type") == "collision" and 
				not self:GetVar("bTraveling") and 
				self:GetVar("bCapShown")) then				
			toggleSpinner(self, true)
		end
	end
end

function onActivityTimerUpdate(self, msg)
	spinActivityTimerUpdate(self, msg)
end

function spinActivityTimerUpdate(self, msg)
	-- if we are supposed to be pulsing the skill thnen do it
	if msg.name == "Pulse_Skill" and self:GetVar("bActive") and not self:GetVar("bTraveling") then
		-- if not arrow pulse the skill
		spinCastSkill(self)
	end
end

function onActivityTimerDone(self, msg)
	spinActivityTimerDone(self,msg)
end

function spinActivityTimerDone(self, msg)
	if msg.name == "Reset" then
		toggleSpinner(self)
    elseif string.starts(msg.name, "AnimDone") then
		local msgData = split(msg.name, "_")
		local animName = msgData[2] or false
		
        local player = GAMEOBJ:GetObjectByID(self:GetVar("userID"))
		
		if player:Exists() and animName then
			if animName == startAnim then				
				toggleSpinner(self, true) -- triggerSpinner(self, player)
				-- set inuse to false and update pick type
				player:PlayAnimation{ animationID = runAnim, fPriority = 2.0}
			elseif animName == runAnim then
				-- set inuse to false and update pick type
				playAnim(self, player, endAnim)
			elseif animName == endAnim then
				self:SetNetworkVar("bFreezePlayer_" .. self:GetVar("userID"), false)
				
				-- clear the user and reequip any items that need it
				self:SetVar("userID", 0)			
				
				-- stop the staff interaction fx
				player:StopFXEffect{name = "tornado"}
				player:StopFXEffect{name = "staff"}	
				
				local movingUp = not self:GetVar("movingUp")
				
				self:SetVar("movingUp", movingUp)
			end
		end
	elseif msg.name == "Start_Damage" then
		toggleDamageProx(self, true)
    end
end 

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

---------------------------------------------
-- Server script on the skullkin drill
--
-- created by brandi... 10/13/10
-- updated by mrb... 7/21/11 - only one drill bit will spawn when the player uses spinjitu
-- updated abeechler ... 10/24/11 - don't allow bit smashes until the drill is fully raised.
---------------------------------------------
-- *** putting cinematic --> 0:cinematicName in the config data of the drill mover 
-- will play a cinematic for the player when the drill is used. ***

-- nj animations on use for the staff interactionlocal startAnim = "spinjitzu-staff-windup"
local runAnim = "spinjitzu-staff-loop"
local endAnim = "spinjitzu-staff-end"
local resetTime = 10						-- how long to wait before resetting the drill
local missionsToUpdate = {972, 1305, 1308}	-- these are the missionID's to update when the drill is smashed

function onStartup(self,msg)    
    -- stop the drill from pathing
	self:StopPathing()
	-- set variables to false
	self:SetNetworkVar("bIsInUse", false)
	self:SetVar("bActive", true)
	-- play the spinning fx
	self:PlayFXEffect{name = "active", effectType = "spin"}
	
	-- get the stand object
	local standObj = getStandObj(self) 
	
	if standObj then
		-- notify the stand object to activate the knockback
		standObj:NotifyObject{ObjIDSender = self, name = "activate"}		
	end
	
	-- set up the prox radius for where the player needs to be to use the skill
	self:SetProximityRadius{radius = self:GetInteractionDistance().fDistance, name = "spin_distance"}
end

----------------------------------------------
-- sent when the local player interacts with the
-- object before ClientUse
----------------------------------------------
function onCheckUseRequirements(self, msg)
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
    
    local preconditionID = 143 -- staff of imagination
    local check = {}
    
    if preconditionID then
		check = msg.objIDUser:CheckPrecondition{PreconditionID = preconditionID}
	end		
		
	if not check.bPass then 
		
		msg.bCanUse = false
	end
	
	return msg
end

-- function to get this drills stand object
function getStandObj(self)
	local myGroup = self:GetVar("groupID")
	
	if not myGroup then return false end
	
	-- get the objects the correct group set in HF
	local standObjs = self:GetObjectsInGroup{group = "Drill_Stand_" .. string.sub(string.gsub(myGroup,"%;",""), -1), ignoreSpawners = true }.objects

	for k,obj in ipairs(standObjs) do
		if obj:Exists() then
			-- if the object exists return it
			return obj
		end
	end	
	
	-- didn't find any objects so return false
	return false
end

function onSkillEventFired(self,msg)
    -- catch the spinjitzu charge up skill
	if msg.wsHandle ~= "NinjagoSpinEvent" or not isInProximity(self, msg.casterID) or self:GetNetworkVar("bIsInUse") then return end	
	
	-- set flag to true so this wont happen twice
	self:SetNetworkVar("bIsInUse", true) 
	toggleDrill(self)
end

-- custom function to check and see if the player is within the skill cast proximity
function isInProximity(self, player)
    -- see if the player is within the proximity
    for k,v in ipairs(self:GetProximityObjects{name = "spin_distance"}.objects) do
        if v:GetID() == player:GetID() then            
            return true
        end
    end
    
    return false
end

function toggleDrill(self)
	-- raise the drill up to expose the drill bit
	self:GoToWaypoint{iPathIndex = 1; bStopAtWaypoint = true}
	self:PlayAnimation{animationID = "slowdown", fPriority = 2.0} 
end

----------------------------------------------
-- Receive waypoint messages to determine when we 
-- have reached the raised stop position
----------------------------------------------
function onArrivedAtDesiredWaypoint(self, msg)
    if msg.iPathIndex == 1 then
        -- Get the position of the drill
	    local oPos = { pos = "", rot = ""}
	
	    oPos.pos = self:GetPosition().pos
	    -- Set the position where the smashable is supposed to spawn in, had to put the pivot of the drill at the top so it could see the skill
	    oPos.pos.y = oPos.pos.y - 21
	    oPos.rot = self:GetRotation()
	    -- Spawn the smashable the drill bit, so it look like the player smashed the drill bit
	    RESMGR:LoadObject { objectTemplate = 12346, x= oPos.pos.x, y= oPos.pos.y, z= oPos.pos.z, rw = oPos.rot.w, rx = oPos.rot.x, ry = oPos.rot.y, rz = oPos.rot.z, owner = self, configData = config}
    end
end

function onUse(self, msg)	
	-- make sure the skill hasnt been caught before
	if not self:GetNetworkVar("bIsInUse") then
		-- set flag to true so this wont happen twice
		self:SetNetworkVar("bIsInUse", true) 
	
		-- start playing the effects for the staff interaction
		msg.user:PlayFXEffect{name = "tornado", effectType = "on-anim", effectID = 5499}
		msg.user:PlayFXEffect{name = "staff", effectType = "on-anim", effectID = 5502}
		-- set the userID for later
		local userID = msg.user:GetID()
		
		self:SetVar("userID", userID)
		self:SetVar("activaterID", userID)
		-- play the startAnim on the player
		playAnim(self, msg.user, startAnim)	
		playCinematic(self)
		
		freezePlayer(self, msg.user, true)
	end
end

function freezePlayer(self, player, bFreeze)    
    local eChangeType = "POP"
    
    if bFreeze then
        if player:IsDead().bDead then            
            return
        end

        eChangeType = "PUSH"
    else	
        if player:IsDead().bDead then
            GAMEOBJ:GetTimer():AddTimerWithCancel( 0.1 , "TryUnFreezeAgain_" .. player:GetID(), self )
            
            return
        end
	end
    
    player:SetStunned{ StateChangeType =	eChangeType,
											bCantMove = true,
											bCantAttack = true,
											bCantInteract = true,
											bCantUseItem = true}
end

function onArrived(self, msg)	
	-- get the stand object
	local standObj = getStandObj(self) 
	
	-- mover is in the up position so turn it off
	if msg.wayPoint == 1 then
		-- do the stop anims and fx
		self:PlayAnimation{ animationID = "no-spin", fPriority = 2.0}
		self:StopFXEffect{name = "active"}
		self:PlayFXEffect{name = "indicator", effectType = "indicator"}		
		-- set to inactive
		self:SetVar("bActive", false)
		
		local player = GAMEOBJ:GetObjectByID(self:GetVar("userID"))
		
		if player:Exists() then
			-- play cinematics and stop player animations
			playAnim(self, player, endAnim)
		end	
	
		if standObj then
			-- notify the stand object to deactivate the knockback
			standObj:NotifyObject{ObjIDSender = self, name = "deactivate"}		
		end
	else		
		-- set the animations and fx to the active state
		self:PlayAnimation{ animationID = "idle", fPriority = 2.0}
		self:PlayFXEffect{name = "active", effectType = "spin"}
		-- stop the indicator fx
		self:StopFXEffect{name = "indicator"}
		
		if standObj then
			-- notify the stand object to activate the knockback
			standObj:NotifyObject{ObjIDSender = self, name = "activate"}		
		end
	end		
end
	
-- custom function to playCinematic
function playCinematic(self)			
	local player = GAMEOBJ:GetObjectByID(self:GetVar("userID"))
	
	if not player:Exists() then return end
	
	local cine = self:GetVar("cinematic")
	
	if not cine then return end
	
	-- we found a cinematic so play it
	player:PlayCinematic{pathName = cine}
end

function playAnim(self, player, animName)
	-- see if this object has an animation on it by getting the time
	local animTime = player:GetAnimationTime{animationID = animName}.time
	
	if not animTime then return end
	
	-- if the time isn't more than 0 we dont want to do anything
	if animTime > 0 then		
		-- play the interact animation
		player:PlayAnimation{ animationID = animName, fPriority = 2.0}
		-- start up the anim done timer
		GAMEOBJ:GetTimer():AddTimerWithCancel( animTime , "AnimDone_" .. animName, self )
	end
end

function onChildLoaded(self,msg)
    -- start timer to reset drill if player doesnt kill the drill bit
    GAMEOBJ:GetTimer():AddTimerWithCancel( resetTime, "killDrill", self )
    -- set child to setvar
    self:SetVar("ChildSmash", msg.childID:GetID() )
    -- we need to know when the child dies
    self:SendLuaNotificationRequest{requestTarget = msg.childID, messageName = "HitOrHealResult"}
end

function notifyHitOrHealResult(self, other, msg)
	-- check if the drill is active
    if not self:GetVar("bActive") and msg.diedAsResult then		
		-- check if the killer was a player
		if msg.dealer:IsCharacter().isChar then
			-- update the missions for the killer			
			for k,missionID in ipairs(missionsToUpdate) do
				msg.dealer:UpdateMissionTask{taskType = "complete", value = missionID, value2 = 1, target = self}
			end
			
			local activatorID = self:GetVar("activaterID") or 0
			
			-- check if we have an activator
			if activatorID ~= 0 then
				-- check if the activator is the killer
				if activatorID ~= msg.dealer:GetID() then
					local activator = GAMEOBJ:GetObjectByID(activatorID)
					
					-- update the activators mission if they still exist
					if activator:Exists() then
						for k,missionID in ipairs(missionsToUpdate) do
							activator:UpdateMissionTask{taskType = "complete", value = missionID, value2 = 1, target = self}
						end					
					end
				end
			end
		end
		
        -- when the invisible smashable is kill, kill the drill bit
        self:RequestDie{ killerID = self, killType = "SILENT" }
        GAMEOBJ:GetTimer():CancelTimer( "killDrill", self )
        
		local standObj = getStandObj(self)
		
		if standObj then
			-- play the explode fx
			standObj:PlayFXEffect{name = "explode", effectType = "explode", effectID = 4946}
		end
    end
end

function onTimerDone(self, msg)
    if msg.name == "killDrill" then
        -- get the drilll bit
        local bit = GAMEOBJ:GetObjectByID(self:GetVar("ChildSmash"))
        
        if bit:Exists() then
            -- *** add check that shaft still exists
            -- set the flag back to false
            self:SetNetworkVar("bIsInUse", false)
			self:SetVar("bActive", true)
			self:SetVar("activaterID", 0)
            --kill the drill bit
            bit:RequestDie{ killerID = self, killType = "SILENT" }
            -- set the drill shaft back to starting position
            self:GoToWaypoint{ iPathIndex = 0; bStopAtWaypoint = true }
        end
    elseif string.starts(msg.name, "AnimDone") then
		local msgData = split(msg.name, "_")
		local animName = msgData[2] or false		
        local player = GAMEOBJ:GetObjectByID(self:GetVar("userID"))
		
		if player:Exists() and animName then
			if animName == startAnim then				
				toggleDrill(self)
				-- set inuse to false and update pick type
				player:PlayAnimation{ animationID = runAnim, fPriority = 2.0}
			elseif animName == endAnim then
				freezePlayer(self, player, false)
				-- clear the user and reequip any items that need it
				self:SetVar("userID", 0)			
				
				-- stop the staff interaction fx
				player:StopFXEffect{name = "tornado"}
				player:StopFXEffect{name = "staff"}
			end
		end
	elseif string.starts(msg.name, "TryUnFreezeAgain") then    
		local playerID = split(msg.name, "_")[2] or 0
		local player = GAMEOBJ:GetObjectByID(playerID)
		
		if player:Exists() then		
			freezePlayer(self, player, false)
		end
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
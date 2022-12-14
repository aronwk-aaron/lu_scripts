--------------------------------------------------------------

-- L_NT_ASSEMBLYTUBE_SERVER.lua

-- Handles processing of Assembly Teleporter events
-- including player teleports and mission updatess
-- updated abeechler ... 3/7/11 - refactored scripts and simplified functionality
-- updated abeechler ... 4/14/11 - removed flag setting for scripted mission updates
-- updated mrb... 5/5/11 - added interact sound option
-- updated abeechler ... 5/17/11 - fixed teleport locking bug for logging out players
-- updated abeechler ... 10/5/11 - fixed teleport ignore bug for character switch players
--------------------------------------------------------------
--
-- add configData on the object in HF to play audio on interact
-- sound1 -> 0:{GUID}
--
--------------------------------------------------------------

local defaultTransportSendAnim = "tube-sucker"			-- Transport send animation
local transportReceiveAnim = "tube-resurrect"			-- Transport receive animation

local missionsToUpdate = {1047, 1330, 1331, 1332}	    -- MissionID's to update when the tube is used

----------------------------------------------
-- Process start-up events
----------------------------------------------
function onStartup(self,msg)
	-- Subscribe to a zone control object notification alerting the script
    -- when a local player is loaded
    self:SendLuaNotificationRequest{requestTarget = GAMEOBJ:GetZoneControlID(), messageName="PlayerLoaded"}
end

----------------------------------------------
-- The zone control object says when the player is loaded
----------------------------------------------
function notifyPlayerLoaded(self, zoneObj, msg)
    -- Get the player ID
    local player = msg.playerID
    local playerID = player:GetID()
    -- A data structure containing players being teleported
	local teleportingPlayerTable = self:GetVar("teleportingPlayerTable") or {}
	
    -- Is the player a holdover from a previous failed teleport?
    if(teleportingPlayerTable[playerID] == true) then
        teleportingPlayerTable[playerID] = nil
		self:SetVar("teleportingPlayerTable", teleportingPlayerTable)
    end
    
    -- Is the player currently inside the teleport volume?
    local playersInMe = self:GetObjectsInPhysicsBounds().objects
    -- Iterate through the players in the volume
    for i, pRef in ipairs(playersInMe) do
        if(playerID == pRef:GetID()) then
            -- The loaded player is currently inside the teleporter
            -- run the teleporter
            runAssemblyTube(self, player)
        end
    end
    
end

----------------------------------------------
-- Catch player teleporter collisions and process 
-- functions when applicable
----------------------------------------------			
function onCollisionPhantom(self, msg)
	local player = msg.senderID
	runAssemblyTube(self, player)
end

----------------------------------------------
-- Initiates assembly tube functionality 
----------------------------------------------
function runAssemblyTube(self, player)
    local playerID = player:GetID()
	
	-- A data structure containing players being teleported
	local teleportingPlayerTable = self:GetVar("teleportingPlayerTable") or {}
	-- Process the colliding player against the teleporting table to see if they are eligible for teleport
    local bPlayerBeingTeleported = teleportingPlayerTable[playerID]
	
	-- Do we have a valid player?
	if((player:IsCharacter().isChar) and (not bPlayerBeingTeleported)) then
		-- Check HF object config data for a cinematic path to play on teleport
		local teleCinematic = self:GetVar("Cinematic") or false
			
		if(teleCinematic) then
			-- Mark the currently colliding player as
			-- being teleported
			teleportingPlayerTable[playerID] = true
			self:SetVar("teleportingPlayerTable", teleportingPlayerTable)
	
			-- Lock player interaction
			player:SetStunned{StateChangeType = "PUSH",
									bCantMove = true,
									bCantTurn = true,
								  bCantAttack = true,
								 bCantUseItem = true,
								   bCantEquip = true,
								bCantInteract = true}
							
			local transportSendAnim = self:GetVar("OverrideAnim") or defaultTransportSendAnim
			-- Determine the length of the player transport send anim
			local sendAnimTime = player:GetAnimationTime{animationID = transportSendAnim}.time or 3
		
		
			-- Play the transmission cinematic
			player:PlayCinematic{pathName = teleCinematic, lockPlayer = false, bSendServerNotify = true}
			-- Play the transmission anim
			player:PlayAnimation{animationID = transportSendAnim, bPlayImmediate = true, fPriority = 4.0}
			
			-- play custom audio sound
			local useSound = self:GetVar("sound1") or false		
			
			if useSound then
				-- play the start audio
				player:PlayNDAudioEmitter{m_NDAudioEventGUID = useSound}	
			end
			
			-- Request for notification upon cinematic conclusion for player reception and interaction unlocking
			self:SendLuaNotificationRequest{requestTarget = player, messageName = "CinematicUpdate"}
			
			-- Set a timer for player teleportation
			GAMEOBJ:GetTimer():AddTimerWithCancel(sendAnimTime, "TeleportPlayer_" .. playerID, self)
			
			-- Update the missions for the user			
		    for k,missionID in ipairs(missionsToUpdate) do
			    -- Update the task
			    player:UpdateMissionTask{taskType = "complete", value = missionID, value2 = 1, target = self}
		    end
			
		else
			-- Generate warning about missing necessary config data
			local tubePos = self:GetPosition().pos
			WarningPrint(self, "WARNING: No Cinematic found for NT Assembly Tube located at: X = " .. tubePos.x .. ", Y = " .. tubePos.y .. ", Z = " .. tubePos.z)
		end
    end
end

----------------------------------------------
-- Receive cinematic update events to initiate
-- teleportation upon transition cinematic conclusion
----------------------------------------------
function notifyCinematicUpdate(self, player, msg)
	local eventType = msg.event
	local playerID = player:GetID()
	
	-- Our player exists and is ready for transport reception?
	if(not player:Exists()) then return end
	
	-- Process the nature of the update and process
	-- on cinematic conclusions
	if(eventType == "ENDED") then
		-- Teleport the player
		-- teleportPlayerToDest(self, player)
		-- Play the player reception anim
		player:PlayAnimation{animationID = transportReceiveAnim, bPlayImmediate = true, fPriority = 4.0}
		
		-- Prepare to unlock the Player ability to interact after we 
		-- pause for the animation
		local animTime = player:GetAnimationTime{animationID = transportReceiveAnim}.time or 4
		GAMEOBJ:GetTimer():AddTimerWithCancel(animTime, "UnlockPlayer_" .. playerID, self)
		
		self:SendLuaNotificationCancel{requestTarget = player, messageName = "CinematicUpdate"}
	end
end

----------------------------------------------
-- Determine teleport destination location and rotation 
-- and orient a target accordingly
----------------------------------------------
function teleportPlayerToDest(self, player)
	-- Determine where to send the player
	local destinationGroup = self:GetVar("teleGroup") or false
	local destination = self
	if destinationGroup then 
		-- We have a target destination group within the object config data
		local groupObjs = self:GetObjectsInGroup{group = destinationGroup, ignoreSpawners = true}.objects
			
		-- Iterate through the destination group and catch the first valid destination object
		for k,obj in ipairs(groupObjs) do
			if obj:Exists() then
				destination = obj
				break
			end
		end
	end
		
	-- Take the determined destination object and process its 
	-- location/rotation values
	local destPosition = destination:GetPosition().pos
	local destRotation = destination:GetRotation()
	
	-- Teleport the player
	player:Teleport {pos = destPosition, x = destRotation.x, y = destRotation.y, z = destRotation.z, w = destRotation.w, bIgnoreY = false, bSetRotation = true}

end

----------------------------------------------
-- Process timer events to finalize triggered teleports
----------------------------------------------
function onTimerDone(self, msg)
	-- Split out the timer
	local tTimer = split(msg.name, "_")
	
	-- Is our player timer for a teleportation event?
	if tTimer[1] == "TeleportPlayer" then
		local playerID = tTimer[2] or 0
		local player = GAMEOBJ:GetObjectByID(playerID)
		
		-- Our player exists and is ready for transport reception?
		if(not player:Exists()) then return end
		
		-- Teleport the player
		teleportPlayerToDest(self, player)
						     
	-- Time to unlock the player?
	elseif tTimer[1] == "UnlockPlayer" then
		local playerID = tTimer[2] or 0
		local player = GAMEOBJ:GetObjectByID(playerID)
		
		local teleportingPlayerTable = self:GetVar("teleportingPlayerTable")
		if(teleportingPlayerTable) then
			-- Remove the target player from the teleporting table and process
			teleportingPlayerTable[playerID] = nil
			self:SetVar("teleportingPlayerTable", teleportingPlayerTable)
		end
		
		-- Our player exists and is ready for interact unlock?
		if(not player:Exists()) then return end
		
		--Return interact control to the player
		player:SetStunned{StateChangeType = "POP",
								bCantMove = true,
								bCantTurn = true,
							  bCantAttack = true,
							 bCantUseItem = true,
							   bCantEquip = true,
							bCantInteract = true}
	end
end

function split(str, pat)
    local t = {}
    -- Creates a table of strings based on the passed in pattern   
    string.gsub(str .. pat, "(.-)" .. pat, function(result) table.insert(t, result) end)

    return t
end

----------------------------------------------------------------
-- print custom function to keep prints from showing up externally
----------------------------------------------------------------
function WarningPrint(self, msg)
    if(self:GetVersioningInfo().bIsInternal) then       
        print(self,msg)
    end
end

--------------------------------------------------------------

-- L_NT_PARADOXTELE_SERVER.lua

-- Handles processing of Paradox Teleporter events
-- including player teleports and mission updatess
-- updated abeechler ... 2/14/11 - refactored scripts and simplified functionality
-- updated abeechler ... 2/17/11 - removed flag functionality for script mission updates
-- updated mrb... 5/5/11 - added interact sound option
-- updated abeechler ... 5/17/11 - fixed teleport locking bug for logging out players
--------------------------------------------------------------
--
-- add configData on the object in HF to play audio on interact
-- sound1 -> 0:{GUID}
--
--------------------------------------------------------------

local transportSendAnim = "teledeath"					-- Transport send animation
local transportReceiveAnim = "paradox-teleport-in"			-- Transport receive animation
local missionsToUpdate = {1047, 1330, 1331, 1332}	-- These are the missionID's to update when the teleporter is used

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
end

----------------------------------------------
-- Catch player teleporter collisions and process 
-- functions when applicable
----------------------------------------------			
function onCollisionPhantom(self, msg)
	local player = msg.senderID
	local playerID = player:GetID()
	
	-- A data structure containing players being teleported
	local teleportingPlayerTable = self:GetVar("teleportingPlayerTable") or {}
	-- Process the colliding player against the teleporting table to see if they are eligible for teleport
    local bPlayerBeingTeleported = teleportingPlayerTable[playerID]
	
	-- Do we have a valid player?
	if((player:IsCharacter().isChar) and (not bPlayerBeingTeleported)) then
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
	
		-- Play the transmission anim
		player:PlayAnimation{animationID = transportSendAnim, bPlayImmediate = true, fPriority = 4.0}
	
		-- Determine the length of the player transport send anim and 
		-- set a timer to process a teleport and receive anim on completion
		local animTime = player:GetAnimationTime{animationID = transportSendAnim}.time or 2
		GAMEOBJ:GetTimer():AddTimerWithCancel(animTime, "TeleportPlayer_" .. playerID, self)

		-- Update the missions for the user			
		for k,missionID in ipairs(missionsToUpdate) do
			-- Update the task
			player:UpdateMissionTask{taskType = "complete", value = missionID, value2 = 1, target = self}
		end
	end
end

----------------------------------------------
-- Process timer events to finalize triggered teleports
----------------------------------------------
function onTimerDone(self, msg)
	-- Split out the timer
	local tTimer = split(msg.name, "_")
	
	-- Is our player timer for a teleport event?
	if tTimer[1] == "TeleportPlayer" then
		local playerID = tTimer[2] or 0
		local player = GAMEOBJ:GetObjectByID(playerID)
		
		-- Our player exists and is ready for transport reception?
		if(not player:Exists()) then return end
			
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
		
		-- Check HF object config data for a cinematic path to play on teleport
		local teleCinematic = self:GetVar("Cinematic") or false
		if(teleCinematic) then
			player:PlayCinematic{pathName = teleCinematic, lockPlayer = false}
		end
		
		-- Teleport the player
		player:Teleport {pos = destPosition, x = destRotation.x, y = destRotation.y, z = destRotation.z, w = destRotation.w, bIgnoreY = false, bSetRotation = true}
		
		-- Play the player reception anim
		player:PlayAnimation{animationID = transportReceiveAnim, bPlayImmediate = true, fPriority = 4.0}
		-- Prepare to unlock the Player ability to interact after we 
		-- pause for the animation
		local animTime = player:GetAnimationTime{animationID = transportReceiveAnim}.time or 4
		GAMEOBJ:GetTimer():AddTimerWithCancel(animTime, "UnlockPlayer_" .. playerID, self)						     
	
		local useSound = self:GetVar("sound1") or false		
		if useSound then
			-- play the start audio
			player:PlayNDAudioEmitter{m_NDAudioEventGUID = useSound}	
		end
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
		
		-- Check HF object config data for a cinematic path to end
		local teleCinematic = self:GetVar("Cinematic") or false
		if(teleCinematic) then
			player:EndCinematic{pathName = teleCinematic}
		end
	end
end

function split(str, pat)
    local t = {}
    -- Creates a table of strings based on the passed in pattern   
    string.gsub(str .. pat, "(.-)" .. pat, function(result) table.insert(t, result) end)

    return t
end 
--------------------------------------------------------------

-- L_NT_VENTURE_CANNON_SERVER.lua

-- Server side NT Venture Cannon interact processing
-- created abeechler ... 3/23/11

--------------------------------------------------------------

------------------------------------------------------
-- This script requires that configData is set on the object in HF
-- EnterCinematic -> 0:cine_name
-- ExitCinematic  -> 0:cine_name
-- teleGroup      -> 0:teleport_loc_group_name
------------------------------------------------------

local transportSendAnim = "scale-down"						-- Transport send animation
local transportReceiveAnim = "venture-cannon-out"			-- Transport receive animation
local useSound = "{e8bf79ce-7453-4a7d-b872-fee65e97ff15}"

local unlockCannnonCatchTime = 3                            -- Time in seconds needed to ensure the cannon gets unlocked on player interrupt

----------------------------------------------
-- Check to see if the player can use cannon
----------------------------------------------
function onCheckUseRequirements(self,msg)
	local bIsInUse = self:GetNetworkVar('bIsInUse')
	if bIsInUse then
		-- If the interact is in use, we can break immediately and report failure
		msg.bCanUse = false
	else
		-- Obtain preconditions
		local preConVar = self:GetVar("CheckPrecondition")
    
		if preConVar and preConVar ~= "" then
			-- We have a valid list of preconditions to check
			local check = msg.objIDUser:CheckListOfPreconditionsFromLua{PreconditionsToCheck = preConVar, requestingID = self}
        
			if not check.bPass then 
			    msg.bCanUse = false
			end
		end
    end
    
    return msg
end

----------------------------------------------
-- Capture the cannon use and process accordingly
----------------------------------------------
function onUse(self, msg)
	local player = msg.user
	local playerID = player:GetID()
	self:SetVar("userID", playerID)
	
	-- Test for the presence of a desired entry cinematic
	-- if one exists, process Player cannon entry
	local enterCinematic = self:GetVar("EnterCinematic") or false
	
	if(enterCinematic) then
		-- Mark the cannon as in use
		self:SetNetworkVar("bIsInUse", true)
		-- Set a timer for catch cannon unlock
	    GAMEOBJ:GetTimer():AddTimerWithCancel(unlockCannnonCatchTime, "CatchCannonUnlock", self)
	
		-- Lock player interaction
		player:SetStunned{ StateChangeType = "PUSH",
								 bCantMove = true,
								 bCantTurn = true,
							   bCantAttack = true,
							  bCantUseItem = true,
								bCantEquip = true,
							 bCantInteract = true}
	
		-- Teleport them to the desired entry location
		local destPosition = self:GetPosition().pos
		destPosition.y = destPosition.y + 5
		local destRotation = self:GetRotation()
		player:Teleport{pos = destPosition, x = destRotation.x, y = destRotation.y - 1.57, z = destRotation.z, w = destRotation.w, bIgnoreY = false, bSetRotation = true}
	
		-- Play the into cannon animation
		player:PlayAnimation{animationID = transportSendAnim, bPlayImmediate = true, fPriority = 4.0}
		
		-- Play the enter cannon cinematic
		player:PlayCinematic{pathName = enterCinematic, leadIn = 0, lockPlayer = false, bSendServerNotify = true}
		-- Request for notification upon cinematic conclusion for progresion into the exit cinematic
		self:SendLuaNotificationRequest{requestTarget = player, messageName = "CinematicUpdate"}
		
		-- play the start audio
		self:PlayNDAudioEmitter{m_NDAudioEventGUID = useSound}
	end
end

----------------------------------------------------------------
-- Server notification of cinematic events firing
----------------------------------------------------------------
function notifyCinematicUpdate(self, player, msg)
	local pathName = msg.pathName
	local eventType = msg.event
	local playerID = player:GetID()
	
	-- Determine the nature of the update and process
	-- on cinematic conclusions
	if(pathName == "EnterCannon") then
		-- We are progressing to the player exit cinematic, if one exists
		if(eventType == "ENDED") then
			-- Play the cannon shot particle FX 
			-- and player camera shake effect for all minifigs around the cannon
			local CannonEffectGroup = self:GetObjectsInGroup{group = "cannonEffect", ignoreSpawners = true}.objects
			local CannonEffect = false
			-- Iterate through the effect group and catch the first valid object
			for k,obj in ipairs(CannonEffectGroup) do
				if obj:Exists() then
					CannonEffect = obj
					break
				end
			end
			
			if(CannonEffect) then 
				CannonEffect:PlayFXEffect{name = "cannon_blast", effectType = "create", effectID = 6036}
				CannonEffect:PlayEmbeddedEffectOnAllClientsNearObject{radius = 100, fromObjectID = CannonEffect, effectName = "camshake-bridge"}
			end
			
			-- Launch the player out of the cannon
			FirePlayer(self, msg)
			
			-- Test for the presence of a desired exit cinematic
			-- if one exists, process Player cannon exit
			local exitCinematic = self:GetVar("ExitCinematic") or false
			if(exitCinematic) then
				-- Play the exit cannon cinematic
				player:PlayCinematic{pathName = exitCinematic, leadIn = 0, lockPlayer = false, bSendServerNotify = true}
		
			else
				-- Ensure the player can resume proper interaction
				UnlockCannonPlayer(self, player)
			end
		end
		
	elseif(pathName == "ExitCannon") then
        -- We are exiting the ExitCannon cinematic
        if(eventType == "ENDED") then
            -- Ensure the player can resume proper interaction
		    UnlockCannonPlayer(self, player)
		    -- Cancel the catch timer
	        GAMEOBJ:GetTimer():CancelTimer("CatchCannonUnlock", self)
        end
	end
end

----------------------------------------------
-- Process timer events 
----------------------------------------------
function onTimerDone(self, msg)
	-- Is our timer for a catch unlock event?
	if msg.name == "CatchCannonUnlock" then
	    -- Mark the interaction as no longer in use and process
	    self:SetNetworkVar('bIsInUse', false)
	end
end

----------------------------------------------------------------
-- Unlock the player and cannon objects 
----------------------------------------------------------------
function UnlockCannonPlayer(self, player)
	--Return interact control to the player
	player:SetStunned{ StateChangeType = "POP",
							 bCantMove = true,
							 bCantTurn = true,
						   bCantAttack = true,
						  bCantUseItem = true,
							bCantEquip = true,
						 bCantInteract = true}
		
	-- Mark the interaction as no longer in use and process
	self:SetNetworkVar('bIsInUse', false)
	
	-- Terminate the interaction
	player:TerminateInteraction{type = 'fromInteraction', ObjIDTerminator = self}
	
	self:SendLuaNotificationCancel{requestTarget = player, messageName = "CinematicUpdate"}
end

----------------------------------------------
-- Fire the player out of the cannon
-- coordinates teleport and animation
----------------------------------------------
function FirePlayer(self, msg)
	local player = GAMEOBJ:GetObjectByID(self:GetVar("userID"))
	
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
	
	-- Teleport the player
	player:Teleport {pos = destPosition, x = destRotation.x, y = destRotation.y, z = destRotation.z, w = destRotation.w, bSetRotation = true}

	-- Play the fire animation
	player:PlayAnimation{animationID = transportReceiveAnim, bPlayImmediate = true, fPriority = 4.0}
	
end

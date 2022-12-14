--------------------------------------------------------------
-- L_BASE_CONSOLE_TELEPORT_SERVER.lua

-- Server Script for the a Teleport Console interact
-- Created abeechler... 3/22/11
-- updated mrb... 4/15/11 - added zone summary and new functionality
--------------------------------------------------------------

local baseTeleportString = "This is a BUG, it needs a localization string!!!"	-- Localized string token for teleport confirmation

----------------------------------------------
-- Check to see if the player can use the console
----------------------------------------------
function onCheckUseRequirements(self, msg)	
	return baseCheckUseRequirements(self, msg)
end

function baseCheckUseRequirements(self,msg)
	local player = msg.objIDUser
	-- Obtain preconditions
	local preConVar = self:GetVar("CheckPrecondition")
    
    if preConVar and preConVar ~= "" then
		-- We have a valid list of preconditions to check
		local check = player:CheckListOfPreconditionsFromLua{PreconditionsToCheck = preConVar, requestingID = self}
        
		if not check.bPass then 
			-- We have failed our precondition check
			msg.bCanUse = false
		end
	end
    
    return msg
end

----------------------------------------------
-- When the player interacts with the console
----------------------------------------------
function onUse(self, msg)
	baseUse(self, msg)
end

function baseUse(self,msg)
	local player = msg.user
	-- Bring up the UI confirmation widget
	local teleportLocString = self:GetVar("teleportString") or baseTeleportString
	
	-- show the appropriate message box
    player:DisplayMessageBox{bShow = true, identifier = "TransferBox", callbackClient = self, text = teleportLocString}
end

----------------------------------------------
-- When the player interacts with the UI confirmation widget
----------------------------------------------
function onMessageBoxRespond(self, msg)
	baseMessageBoxRespond(self, msg)
end

function baseMessageBoxRespond(self, msg)
    local player = msg.sender
    
    if not player:Exists() or msg.identifier ~= "TransferBox" then return end
    
    if msg.iButton == 1 then
		-- The player has affirmed the confirmation widget, begin teleport processing
		-- Lock player interaction
		player:SetStunned{StateChangeType = "PUSH",
								bCantMove = true,
								bCantTurn = true,
								bCantAttack = true,
								bCantUseItem = true,
								bCantEquip = true,
								bCantInteract = true}
				
		-- Play Teleport Effects
		local teleportFXID = self:GetVar("teleportEffectID")
		
		-- if we have fx play them
		if teleportFXID then		
            local teleportFXs = self:GetVar("teleportEffectTypes") or {}
            
			for k, type in ipairs(teleportFXs) do		        
				player:PlayFXEffect{name = "FX"..type, effectType = type, effectID = teleportFXID}
			end
		end
		
		-- Play Teleport Intro Anim
		local teleIntroAnim = self:GetVar("teleportAnim")
		
		-- if we have animations play them
		if teleIntroAnim then
		    player:PlayAnimation{animationID = teleIntroAnim, bPlayImmediate = true, fPriority = 4.0}
		end
				
		-- Establish a timer the length of the teleport intro anim
		-- to mark when to end the necessary effects
		-- NOTE - Current proxy animation reduced by 1 second for effect, final animation 
		-- should need no such adjustment
		local animTime = player:GetAnimationTime{animationID = teleIntroAnim}.time
		
		if animTime <= 0 then
			animTime = 1
		end
		
		-- add the player to the transferingPlayer table
		updatePlayerTable(self, player, true)
		
		-- start the animation timer
		GAMEOBJ:GetTimer():AddTimerWithCancel(animTime, "TransferPlayer_" .. player:GetID(), self)		
    elseif msg.iButton == -1 or msg.iButton == 0 then
		-- The player has denied the confirmation widget
        -- Be sure to terminate the interaction so the shift icon comes up again.
        player:TerminateInteraction{type = "fromInteraction", ObjIDTerminator = self}
    end
end

function updatePlayerTable(self, player, bAdd)
	if not player:Exists() then return end
	
	-- get the transferingPlayers table or an empty table
	local tPlayers = self:GetVar("transferingPlayers") or {}
	
	-- update the table based on bAdd
	if bAdd then
		tPlayers[player:GetID()] = true
	else
		tPlayers[player:GetID()] = nil
	end
	
	-- update transferingPlayers table
	self:SetVar("transferingPlayers", tPlayers)
end

function checkPlayerTable(self, player)
	if not player:Exists() then return false end
	
	-- get the transferingPlayers table or an empty table
	local tPlayers = self:GetVar("transferingPlayers") or {}
	
	-- return whether or not the player is in the table
	if tPlayers[player:GetID()] then
		return true
	end
	
	return false
end

function onFireEventServerSide(self, msg)
	baseFireEventServerSide(self, msg)
end

function baseFireEventServerSide(self, msg)
	if msg.args == "summaryComplete" then
		-- the summary is complete so transfer the player to the correct zone
		transferPlayer(self, msg.senderID)
	end
end

function transferPlayer(self, player, altMapID)
	-- if the player doesn't exist or is not in the player table return out of the function
	if not player:Exists() or not checkPlayerTable(self, player) then return end
	
	-- Play Teleport Effects
	local teleportFXID = self:GetVar("teleportEffectID")
	
	-- if we have FX stop them
	if teleportFXID then
		local teleportFXs = self:GetVar("teleportEffectTypes") or {}
		
		for k, type in ipairs(teleportFXs) do		        
			player:StopFXEffect{name = "FX"..type}
		end
	end
	
	--Return interact control to the player
	player:SetStunned{	StateChangeType = "POP",
						bCantMove = true,
						bCantTurn = true,
						bCantAttack = true,
						bCantUseItem = true,
						bCantEquip = true,
						bCantInteract = true}
					
	-- Be sure to terminate the interaction so the shift icon comes up again.
	player:TerminateInteraction{type = "fromInteraction", ObjIDTerminator = self}
	
	-- Send to target zone if one exists
	local teleportZone = self:GetVar("transferZoneID")
	
	if teleportZone then
		local teleSpawnPoint = self:GetVar("spawnPoint")
		
		if teleSpawnPoint then
			player:TransferToZone{zoneID = teleportZone, spawnPoint = teleSpawnPoint}
			--print(teleSpawnPoint)
		else
			player:TransferToZone{zoneID = teleportZone}
		end
	else
		local pos = self:GetPosition().pos
		
		-- somebody set something up wrong so throw an assert
		print("Warning, missing transferZoneID in config data for " .. self:GetName().name .. " @ x: " .. pos.x .. ", y: " .. pos.y .. ", z: " .. pos.z)
	end
	
	-- remove the player from the transferingPlayers table
	updatePlayerTable(self, player, false)
end

----------------------------------------------
-- Manages teleportation state transitions
----------------------------------------------
function onTimerDone(self, msg)
	baseTimerDone(self, msg)
end

function baseTimerDone(self, msg)		
	if startsWith(msg.name, "TransferPlayer") then
		-- We are post outro state, un-stun the player and transition to Nexus Tower
		local msgData = split(msg.name, "_")
		local playerID = msgData[2] or 0		
        local player = GAMEOBJ:GetObjectByID(playerID)
        
        -- if the player exist show the zone summary
        if player:Exists() then
			player:DisplayZoneSummary{sender = self}
        end
	end
end 

function split(str, pat)
    local t = {}
    -- creates a table of strings based on the passed in pattern   
    string.gsub(str .. pat, "(.-)" .. pat, function(result) table.insert(t, result) end)

    return t
end 

function startsWith(String,Start)
    -- finds if a string starts with a giving string.
   return string.sub(String,1,string.len(Start))==Start
end 
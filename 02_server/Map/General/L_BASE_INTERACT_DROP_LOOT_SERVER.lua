--------------------------------------------------------------
-- Base Server side interact loot spawner script, uses 
-- scripts\02_client\Map\General\L_SET_INTERACT_WITH_VAR_CHECK.lua for client side script
-- 
-- updated mrb... 2/17/11 - made interaction work correctly
-- updated brandi... 6/13/11 - added ability to specify loot matrix through config data
--------------------------------------------------------------
--
-- add configData on the object in HF to play audio on interact
-- sound1 -> 0:{GUID}
--
--------------------------------------------------------------
local defaultCooldownTime = 5

function onCheckUseRequirements(self, msg)
	return baseCheckUseRequirements(self, msg)
end

function baseCheckUseRequirements(self, msg)
	-- if this is currently inUse dont spawn anything
    if self:GetNetworkVar("bInUse") then 
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

function onUse(self, msg)    
	baseUse(self, msg)
end

function baseUse(self, msg)        
	local cooldownTime = self:GetVar("cooldownTime") or defaultCooldownTime
	local lootMatrix = self:GetVar("UseLootMatrix") or self:GetCurrentLootMatrix().iMatrix
	local useSound = self:GetVar("sound1") or false
	
	if useSound then
		-- play the start audio
		self:PlayNDAudioEmitter{m_NDAudioEventGUID = useSound}	
	end
	
    -- tell the client to make the object unpickable
    self:SetNetworkVar("bInUse", true) 
    
    -- spawn loot    
	self:DropItems{iLootMatrixID = lootMatrix, owner = msg.user, sourceObj = self, bUseTeam = true}
	
	-- start the cooldown timer
    GAMEOBJ:GetTimer():AddTimerWithCancel( cooldownTime , "InteractionCooldown", self )
end

function onTimerDone(self, msg)
	baseTimerDone(self, msg)
end 

function baseTimerDone(self, msg)
	if msg.name == "InteractionCooldown" then
		-- tell the client to make the object pickable again
		self:SetNetworkVar("bInUse", false) 
	end
end 
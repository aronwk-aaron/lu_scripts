--------------------------------------------------------------
-- Server side script for tiki torches that spawn imagination

-- updated mrb... 11/13/10 - updated to setnetworkvar so torch would 
-- only get counted once per use, and updated to DropItems for performance
-- updated by brandi... 4/28/11 - added a table of missions to update
--------------------------------------------------------------
local lootLOT = 935     -- LOT of the loot object to spawn
local numToSpawn = 3    -- number of loot objects to spawn
local missions = {472,1429, 1527, 1564, 1601}

function onStartup(self)
    lightTorch(self)
end

function lightTorch(self)   
    self:PlayFXEffect{name = "tikitorch", effectID = 611, effectType = "fire"}
    self:SetVar("isBurning",true)
end

function onCheckUseRequirements(self, msg)
    if self:GetNetworkVar('bIsInUse') then 
        msg.bCanUse = false
        
        return msg
    end        
end

function onUse(self, msg)	    
	local cooldownTime = self:GetAnimationTime{ animationID = "interact" }.time
	
    self:PlayAnimation{ animationID = "interact" }
    self:SetNetworkVar('bIsInUse', true) 
    self:SetVar("userID", msg.user:GetID())
    
	self:DropItems{owner = msg.user, itemTemplate = lootLOT, iAmount = numToSpawn, bUseTeam = true}        
    
    GAMEOBJ:GetTimer():AddTimerWithCancel( cooldownTime , "InteractionCooldown", self )
end

function onSkillEventFired( self, msg )
	if not self:GetVar("isBurning") then return end
	
    if msg.wsHandle == "waterspray" then
		local cooldownTime = self:GetAnimationTime{ animationID = "water" }.time
		
		self:PlayAnimation{ animationID = "water" }
		self:StopFXEffect{name = "tikitorch"}
		self:PlayFXEffect{effectID = 611, effectType = "water"}
		self:PlayFXEffect{effectID = 611, effectType = "steam"}
		for k,missionID in ipairs(missions) do
			msg.casterID:UpdateMissionTask{taskType = "complete", value = missionID, value2 = 1, target = self}
		end

		GAMEOBJ:GetTimer():AddTimerWithCancel( cooldownTime, "Relight",self )
		self:SetVar("isBurning",false)
    end
end

function onTimerDone(self, msg)
    if msg.name == "Relight" then
        lightTorch(self)
    elseif msg.name == "InteractionCooldown" then
        local player = GAMEOBJ:GetObjectByID(self:GetVar("userID"))
        
        if player then
            player:TerminateInteraction{type = 'fromInteraction', ObjIDTerminator = self}
        end
        
        self:SetNetworkVar('bIsInUse', false)
        self:SetVar("userID", false)
    end
end

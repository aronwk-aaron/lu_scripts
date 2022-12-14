local normalShot = 1655
local normalShotTemplateID = 16646
local superShot = 1653
local superShotTemplateID = 16645

local cannonballObjID = 16748

local ejectDelay = 8

function onRenderComponentReady(self,msg)
	self:SetOverheadIconOffset{horizOffset = 0, vertOffset = 5, depthOffset = 2}
end

function onCheckUseRequirements(self, msg)

	-- Obtain preconditions
	local preConVar = self:GetVar("CheckPrecondition")

	if preConVar and preConVar ~= "" then
		-- We have a valid list of preconditions to check
		local check = msg.objIDUser:CheckListOfPreconditionsFromLua{PreconditionsToCheck = preConVar, requestingID = self}
	
		if not check.bPass then 
			-- Failed the precondition check
			if msg.isFromUI then
				msg.HasReasonFromScript = true
				msg.Script_IconID = check.IconID
				msg.Script_Reason = check.FailedReason
				msg.Script_Failed_Requirement = true
			end
		
			msg.bCanUse = false
		end
	end
    

    return msg
end

function onClientUse(self, msg)
    -- Track the player/cannon state
    self:SetVar("bInCannon", true)
end

function onActivityExit(self, msg)
    if(self:GetVar("bInCannon")) then
        GAMEOBJ:GetZoneControlID():FireEvent{senderID=self, args="ProvideExitX"}
        -- Track the player/cannon state
        self:SetVar("bInCannon", false)
    end
end

function onShootingGalleryFire(self, msg)
    -- Obtain a reference to the player
    local player = GAMEOBJ:GetObjectByID(GAMEOBJ:GetLocalCharID())
    -- Take a cannonball from the player
    player:RemoveItemFromInventory{iObjTemplate = cannonballObjID, iStackCount = 1}
    -- Test for super shot removal
    self:FireEventServerSide{senderID = player, args = "superShotCheck"}
    -- Start a timer
    GAMEOBJ:GetTimer():AddTimerWithCancel(ejectDelay, "forceCannonEject", self)
end

function onChildRemoved(self, msg)
    -- Our cannonball is dead
    if(not msg.childID:GetComponentTemplateID{iComponent = 18}.bFailed) then
        GAMEOBJ:GetTimer():CancelTimer("forceCannonEject", self)
        -- Exit interaction
        -- Obtain a reference to the player
        local player = GAMEOBJ:GetObjectByID(GAMEOBJ:GetLocalCharID())
	    self:RequestActivityExit{userID = player, bUserCancel = true}
    end
end

----------------------------------------------------------------
-- Timer completion event
----------------------------------------------------------------
function onTimerDone(self, msg)
    if msg.name == "forceCannonEject" then        
        -- Exit interaction
        -- Obtain a reference to the player
        local player = GAMEOBJ:GetObjectByID(GAMEOBJ:GetLocalCharID())
	    self:RequestActivityExit{userID = player, bUserCancel = true}       
    end
end

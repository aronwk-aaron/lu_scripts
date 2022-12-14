--------------------------------------------------------------
-- Client side script for the lootable chest for the dragon fight.
--
-- updated by abeechler... 8/10/11 - remove object hiding and physics toggle, add new anims 
--------------------------------------------------------------

-- local constants
local sOpenFX = "glow"
local sIdleFX = "idiot"

local sOpenAnim = "open"
local sOpenedAnim = "opened"
local sCloseAnim = "close"

local openTime = 60

function onRenderComponentReady(self, msg)      
    -- play the idle fx    
    self:PlayFXEffect{name = "onCreate", effectType = sIdleFX}
end

function onCheckUseRequirements(self, msg)

	-- Obtain preconditions
	local preConVar = self:GetVar("CheckPrecondition")

	if preConVar and preConVar ~= "" then
		-- We have a valid list of preconditions to check
		local check = msg.objIDUser:CheckListOfPreconditionsFromLua{PreconditionsToCheck = preConVar, requestingID = self}
	
		if not check.bPass then 
			-- Failed the precondition check
			msg.bCanUse = false
			self:SetVar('bAlreadyUsed',true)
		end
	end
    
    self:RequestPickTypeUpdate()
    return msg

end



function onClientUse(self,msg)
    -- get the animation time for the timers
    local animTime = self:GetAnimationTime{animationID = sOpenAnim}.time or 1.5
        
    
    self:SetVar('bAlreadyUsed',true)
	self:RequestPickTypeUpdate()
    
    -- play the open fx/animation
    self:PlayFXEffect{name = "openFX", effectType = sOpenFX}
    self:PlayAnimation{animationID = sOpenAnim, bPlayImmediate = true}
        
    -- add in timers to stop fx and remove the chest
    GAMEOBJ:GetTimer():AddTimerWithCancel(animTime, "openedChest", self)
    GAMEOBJ:GetTimer():AddTimerWithCancel(2, "StopFX", self)    
end

function onTimerDone(self, msg)
	if msg.name == "openedChest" then
        -- keep the chest open for a set time
        self:PlayAnimation{animationID = sOpenedAnim, bPlayImmediate = true}

		local player = GAMEOBJ:GetControlledID()
		player:TerminateInteraction{type = 'fromInteraction', ObjIDTerminator = self} 
    elseif msg.name == "StopFX" then
        -- stop the open fx
        self:StopFXEffect{name = "openFX"}        
    end
end 

----------------------------------------------
-- sent when the object checks it's pick type
----------------------------------------------
function onGetPriorityPickListType(self, msg)  
    local myPriority = 0.8
  
    if ( myPriority > msg.fCurrentPickTypePriority ) then    
        msg.fCurrentPickTypePriority = myPriority 
 
        if self:GetVar('bAlreadyUsed') then -- dont show the icon if it's in use
            msg.ePickType = -1
        else
            msg.ePickType = 14    -- Interactive pick type     
        end
    end  
  
    return msg      
end 
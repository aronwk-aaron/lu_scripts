function onStartup(self,msg)
end

function onCheckUseRequirements( self, msg )
    if self:GetVar("onCooldown")  then	
		msg.bCanUse = false		
	end
	return msg
end

function onRenderComponentReady(self,msg)
	GAMEOBJ:GetTimer():AddTimerWithCancel(3, "interact_icon", self)
end

function onShootingGalleryFire(self, msg)
    local numShots = self:GetVar("numShots") or 0
    numShots = numShots + 1
    self:SetVar("numShots", numShots)
    
    if(numShots >= 6) then
        -- Obtain a reference to the player
        local player = GAMEOBJ:GetLocalCharID()
	    
        -- Exit interaction
	    self:RequestActivityExit{userID = GAMEOBJ:GetObjectByID(player), bUserCancel = true}
	    
	    self:SetVar("numShots", 0)
        
    end
    
end

----------------------------------------------
-- Process server-sent messages
----------------------------------------------
function onFireEventClientSide(self,msg)
	if msg.args == "exitCannon" then	
	    self:SetVar("onCooldown", true) 
		-- update the use icon
	    self:RequestPickTypeUpdate()
	    GAMEOBJ:GetTimer():AddTimerWithCancel(10, "endCooldown", self)
	end
end

----------------------------------------------
-- Process timer events
----------------------------------------------
function onTimerDone (self,msg)
    -- Obtain a reference to the player
    local player = GAMEOBJ:GetControlledID()
    
    if (msg.name == "endCooldown" ) then	
		self:SetVar("onCooldown", false) 
		-- update the use icon
	    self:RequestPickTypeUpdate()
	
	elseif msg.name == "interact_icon" then
		self:SetOverheadIconOffset{horizOffset = 0, vertOffset = 50, depthOffset = 0}
	end	
	
end

----------------------------------------------
-- Sent when the object checks its pick type
----------------------------------------------
function onGetPriorityPickListType(self, msg)  
	if(self:GetVar("onCooldown")) then
		msg.ePickType = -1
    else
		local myPriority = 0.8
		
		if ( myPriority > msg.fCurrentPickTypePriority ) then    
			msg.fCurrentPickTypePriority = myPriority 
 
			msg.ePickType = 14    -- Interactive pick type
		end
    end  
  
    return msg
      
end 

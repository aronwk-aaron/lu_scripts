local target = ''

function onCollisionPhantom(self, msg)
	target = msg.objectID  
		
    isColliding = self:GetVar("isColliding") 
    if isColliding == true or target:IsDead().bDead then
        return
    end        
    if isColliding == nil then
        self:SetVar("isColliding", true)
    end  
      
    local scoreObj = self:GetObjectsInGroup{ group = "RespawnPoints" }.objects
    
    -- freeze the players movement
    target:SetUserCtrlCompPause{bPaused = true}    
    --LookCameraAtObject(target)
    
    -- start respawn timer
    local animTime = target:GetAnimationTime{animationID = "rebuild-celebrate"}    
    GAMEOBJ:GetTimer():AddTimerWithCancel( animTime.time + 2 , "FreezeTimer", self )

    return msg
end

function LookCameraAtObject(object)
	local config = { {"objectID", "|" .. object}, {"leadIn", 5}, {"leadOut", 5}, {"lag", 0.9} }
	GAMEOBJ:GetObjectByID(GAMEOBJ:GetLocalCharID()):AddCameraEffect{ effectType = "lookAt", effectID = "lookitMe!!", duration = 30, configData = config }
end

function onTimerDone(self, msg)        
    if msg.name == "FreezeTimer" then
        target:SetUserCtrlCompPause{bPaused = false}
        self:SetVar("isColliding", false)
        return
    end   
end

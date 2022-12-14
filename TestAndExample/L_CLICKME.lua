-- OnEnter in HF Trigger system
function onCollisionPhantom(self, msg)    
    if msg.objectID:CheckPrecondition{PreconditionID = 33}.bPass == false ) then return end
    
    local buildObj = self:GetObjectsInGroup{ group = "Build_Activator" }.objects[1]  
    
    buildObj:PlayAnimation{animationID = "Activator_to_ClickMe", bPlayImmediate = true}
    GAMEOBJ:GetTimer():CancelAllTimers( self )
    
    --local animTime = self:GetAnimationTime{animationID = "Activator_to_ClickMe"}        
    GAMEOBJ:GetTimer():AddTimerWithCancel( 0.417, "Idle2", self )    
end

-- OnExit in HF Trigger system
function onOffCollisionPhantom(self, msg )
    if msg.objectID:CheckPrecondition{PreconditionID = 33}.bPass == false ) then return end
    
    local buildObj = self:GetObjectsInGroup{ group = "Build_Activator" }.objects[1]   
    
    buildObj:PlayAnimation{animationID = "ClickMe_to_Activator", bPlayImmediate = true}
    
    GAMEOBJ:GetTimer():CancelAllTimers( self )
    
    --local animTime = self:GetAnimationTime{animationID = "ClickMe_to_Activator"}        
    GAMEOBJ:GetTimer():AddTimerWithCancel( 0.417, "Idle1", self )    
end

-- timers...
function onTimerDone(self, msg)
    if msg.name == "Idle1" then    
        local buildObj = self:GetObjectsInGroup{ group = "Build_Activator" }.objects[1]   
        
        buildObj:PlayAnimation{animationID = "Build_Activator", bPlayImmediate = true}
    elseif msg.name == "Idle2" then    
        local buildObj = self:GetObjectsInGroup{ group = "Build_Activator" }.objects[1]   
        
        buildObj:PlayAnimation{animationID = "ClickMe", bPlayImmediate = true}
    end

end
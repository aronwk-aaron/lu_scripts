--------------------------------------------------------------
-- Client side script for the GF tiki torches
--
-- updated mrb... 11/13/10 -- made so it could only be used when not inuse
--------------------------------------------------------------
----------------------------------------------
-- sent when the local player interacts with the
-- object before ClientUse
----------------------------------------------
function onCheckUseRequirements(self, msg)
    if self:GetNetworkVar('bIsInUse') then 
        msg.bCanUse = false
        
        return msg
    end        
end
function onScriptNetworkVarUpdate(self, msg)
    local player = GAMEOBJ:GetControlledID()    
    -- check to see if we have the correct message and deal with it
    if msg.tableOfVars["bIsInUse"] ~= nil then 
        self:RequestPickTypeUpdate()    
        if not msg.tableOfVars["bIsInUse"] then            player:TerminateInteraction{type = 'fromInteraction', ObjIDTerminator = self}        end    end
end
----------------------------------------------
-- sent when the object checks it's pick type
----------------------------------------------
function onGetPriorityPickListType(self, msg)  
    local myPriority = 0.8  
    if ( myPriority > msg.fCurrentPickTypePriority ) then    
        msg.fCurrentPickTypePriority = myPriority  
        if self:GetNetworkVar('bIsInUse') then
            msg.ePickType = -1
        else
            msg.ePickType = 14    -- Interactive pick type     
        end
    end    
    return msg
end 
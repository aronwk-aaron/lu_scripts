--function onCollisionPhantom(self, msg)
--    target = msg.objectID 
--    if msg.objectID then 
--        self:PlayEmbeddedEffectOnAllClientsNearObject{ radius = 100.0, fromObjectID = self, effectName = "camshake" }
--        target:SetUserCtrlCompPause{bPaused = true} 
--    end        
--end

--function onOffCollisionPhantom(self, msg )
--    target = msg.objectID 
--    if msg.objectID then 
--        target:SetUserCtrlCompPause{bPaused = false} 
--    end     
--end

function onFireEvent( self, msg )
    -- check to make sure there is a message associated with the FireEvent
    if msg.args == "shake" then
        local fxName = "camshake-bridge" -- "camshake" -- this one works 
        self:PlayEmbeddedEffectOnAllClientsNearObject{ radius = 100.0, fromObjectID = self, effectName = fxName }
    end
end
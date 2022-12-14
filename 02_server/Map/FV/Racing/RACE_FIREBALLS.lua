------------------------------------------------------------
--fires a skill on the FV race object that launches fireballs from the sky
------------------------------------------------------------



function onStartup(self, msg)
    
    local startTime = math.random(3,10)
    
    GAMEOBJ:GetTimer():AddTimerWithCancel(startTime, "fire", self)
end


function onTimerDone(self, msg)
    
    if msg.name == "fire" then
        
        local fireTime = math.random(3,10)
        
        self:CastSkill{skillID = 894}
        GAMEOBJ:GetTimer():AddTimerWithCancel(fireTime, "fire", self)
    end    
end

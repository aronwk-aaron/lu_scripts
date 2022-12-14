--------------------------------------------------------------
--Toggles the geiser FX on and off with a couple of running timers
--Also kills the player while the geiser is going off
--Created by SY 8-25-2010
--------------------------------------------------------------


local buildUpTime = 1.0
local killTime = 1.5
local downTime = 3.0


function onStartup(self)
    -------------------------------------------------------------------
    --The geiser is inactive at the start, but will activate once the timer finishes
    --"startTime" is defined in the config data on the object in HF
    -------------------------------------------------------------------

    self:SetVar("AmFiring", false)
	if self:GetVar("startTime") then
		GAMEOBJ:GetTimer():AddTimerWithCancel(self:GetVar("startTime"), "downTime", self)
	end
end



function onCollisionPhantom(self, msg)
	--print ("Car collided with DeathPlane")
	
	-------------------------------------------------------------------
    --If the geiser if firing, then kill the player
    -------------------------------------------------------------------
    
	if self:GetVar("AmFiring") == true then

        local target = msg.objectID

        -- If a player collided with me, then do our stuff
        if target:BelongsToFaction{factionID = 113}.bIsInFaction then
            target:RequestDie{killerID = self}
        end
    end    
end




function onTimerDone(self, msg)

    -------------------------------------------------------------------
    --If the down timer is completed, then begin to play the FX
    -------------------------------------------------------------------

    if msg.name == "downTime" then
            
        self:PlayFXEffect{name = "geiser", effectID = 4048, effectType = "rebuild_medium"}
        GAMEOBJ:GetTimer():AddTimerWithCancel(buildUpTime, "buildUpTime", self)
    
    -------------------------------------------------------------------
    --If the build up timer is completed, then begin to fire/kill the player
    -------------------------------------------------------------------

    elseif msg.name == "buildUpTime" then
     
        --local players = self:GetObjectsInPhysicsBounds().objects

        self:SetVar("AmFiring", true)
        
        -- At the moment we fire we need to check if anything is already in the volume
        for k,v in ipairs(self:GetObjectsInPhysicsBounds().objects) do
			
			local target = v

			-- Destroy the target			
			if target:BelongsToFaction{factionID = 113}.bIsInFaction then
				target:RequestDie{killerID = self}
			end
		end
        
        GAMEOBJ:GetTimer():AddTimerWithCancel(killTime, "killTime", self)         

    -------------------------------------------------------------------
    --If the kill timer has completed, then begin the down timer and start over again
    -------------------------------------------------------------------
    
    elseif msg.name == "killTime" then

        self:StopFXEffect{name = "geiser"}
        self:SetVar("AmFiring", false)
        GAMEOBJ:GetTimer():AddTimerWithCancel(downTime, "downTime", self)
    end    
end

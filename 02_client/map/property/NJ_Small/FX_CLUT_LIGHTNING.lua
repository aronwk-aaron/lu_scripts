-- We start our effect when we hit the collision phantom
function onStartup(self, msg)
    GAMEOBJ:GetTimer():AddTimerWithCancel( 0.1, "StartCLUTLightning", self )
end

-- We also disable the effect if the script component is shut down for any reason
function onShutdown(self) 
   GAMEOBJ:GetTimer():CancelAllTimers(self)
   -- Reset our rendering back to untinted / unCLUT'ed
    LEVEL:CLUTEffect( "(none)", 0.0, 1.0, 0.0, false )
    LEVEL:FadeEffect( 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false )
end

-- Timers control every aspect of the lightning; this is where the effect itself lives
function onTimerDone(self, msg)
    if (msg.name == "StartCLUTLightning") then  
        LEVEL:CLUTEffect( "GF_LightningLUT.dds", 0.2, 0.0, 1.0, false )
        GAMEOBJ:GetTimer():AddTimerWithCancel( 0.1, "StartFlash", self )
    end

    if (msg.name == "StartFlash") then
        LEVEL:FadeEffect( 1.0, 1.0, 1.0, 0.4, 1.0, 1.0, 1.0, 0.1, 0.1, false )
        GAMEOBJ:GetTimer():AddTimerWithCancel( 0.1, "EndFlash", self )
    end

    if (msg.name == "EndFlash") then  
        LEVEL:CLUTEffect( "(none)", 0.1, 1.0, 0.0, false )
        LEVEL:FadeEffect( 1.0, 1.0, 1.0, 0.1, 1.0, 1.0, 1.0, 0.05, 0.1, false )
        GAMEOBJ:GetTimer():AddTimerWithCancel( 0.2, "EyeFlashAdjustment", self )
    end

    if (msg.name == "EyeFlashAdjustment") then  
        LEVEL:FadeEffect( 1.0, 1.0, 1.0, 0.05, 0.0, 0.0, 0.0, 0.0, 0.5, false )

        -- We do this because random can't output a floating point value
        local randVal = math.random(0, 1000) / 1000.0;

        -- Start another flash some random period of time in the future, but we want "epic" times only.  A short flash, a medium flash, and a long flash.
        -- (if we just set this as 0.1 to 10.0, double flashes would almost never happen)
        local chanceVal = math.random(0, 3)
        if (chanceVal <= 1) then
            -- With that <=1, quick flashes are twice as likely as the othe flashes, for extra epicness
            GAMEOBJ:GetTimer():AddTimerWithCancel( 0.1 + (randVal * 0.1), "StartCLUTLightning", self )
        elseif (chanceVal == 2) then
            GAMEOBJ:GetTimer():AddTimerWithCancel( 2.0 + (randVal * 3.0), "StartCLUTLightning", self )
        else
            GAMEOBJ:GetTimer():AddTimerWithCancel( 5.0 + (randVal * 10.0), "StartCLUTLightning", self )
        end
    end
end
--------------------------------------------------------------
-- Server side for lightning puzzle in the lighting dungeon
-- 
-- created by brandi... 2/10/11
--------------------------------------------------------------

local lightningTime = 10
local initalTime = 5
local shakeCam = 5

function onStartup(self,msg)

	
    debugPrint(self,"** This a Prototype Script attached to " .. self:GetName().name .. ". **")
    debugPrint(self,"** This script needs to be completed by Someone. **")
    debugPrint(self,"** This file is located at <res/scripts/02_server/map/LD>. **")

end

-- Helper function that disables all of the CLUT timers and resets all effects back to a neutral state
function DoDisableCLUTLightning(self)
    GAMEOBJ:GetTimer():CancelAllTimers( self )
end


-- We start our effect when we hit the collision phantom
function onCollisionPhantom(self, msg)
	if table.maxn(self:GetObjectsInPhysicsBounds().objects) == 1 then
		GAMEOBJ:GetTimer():AddTimerWithCancel( initalTime, "StartCLUTLightning", self )
	end
end

-- We disable our effect when we leave the collision phantom
function onOffCollisionPhantom(self, msg)
	if table.maxn(self:GetObjectsInPhysicsBounds().objects) == 0 then
		DoDisableCLUTLightning(self)
	end
end

-- We also disable the effect if the script component is shut down for any reason
function onShutdown(self)
    DoDisableCLUTLightning(self)
end

-- Timers control every aspect of the lightning; this is where the effect itself lives
function onTimerDone(self, msg)
    if (msg.name == "StartCLUTLightning") then  
		for k,v in ipairs(self:GetObjectsInPhysicsBounds().objects) do
			self:NotifyClientObject{name = "StartCLUTLightning", rerouteID = v}
		end
        GAMEOBJ:GetTimer():AddTimerWithCancel( 0.1, "StartFlash", self )
    elseif (msg.name == "StartFlash") then
		for k,v in ipairs(self:GetObjectsInPhysicsBounds().objects) do
			self:NotifyClientObject{name = "StartFlash", rerouteID = v}
		end        
		GAMEOBJ:GetTimer():AddTimerWithCancel( 0.1, "EndFlash", self )
		GAMEOBJ:GetTimer():AddTimerWithCancel( shakeCam, "ShakeCam", self )
    elseif (msg.name == "EndFlash") then  
		for k,v in ipairs(self:GetObjectsInPhysicsBounds().objects) do
			self:NotifyClientObject{name = "EndFlash", rerouteID = v}
		end        
		GAMEOBJ:GetTimer():AddTimerWithCancel( 0.2, "EyeFlashAdjustment", self )
    elseif (msg.name == "EyeFlashAdjustment") then  
		for k,v in ipairs(self:GetObjectsInPhysicsBounds().objects) do
			self:NotifyClientObject{name = "EyeFlashAdjustment", rerouteID = v}
		end
        GAMEOBJ:GetTimer():AddTimerWithCancel( lightningTime, "StartCLUTLightning", self )
    elseif msg.name == "ShakeCam" then
		for k,v in ipairs(self:GetObjectsInPhysicsBounds().objects) do
			self:NotifyClientObject{name = "CamShake", rerouteID = v, paramObj = v}
		end
	end
end

-- print function that only works in an internal build
function debugPrint(self, text)	
	if self:GetVersioningInfo().bIsInternal then
		print(text)
	end
end
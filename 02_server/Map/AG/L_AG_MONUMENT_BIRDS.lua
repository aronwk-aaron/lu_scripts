--------------------------------------------------------------
-- Makes the ag birds fly away when you get close and smashes them.
-- 
-- created mrb... 6/3/11
--------------------------------------------------------------

local sOnProximityAnim = "fly1"
local flyRadius = 5

--------------------------------------------------------------
-- Sent when the script is started.
--------------------------------------------------------------
function onStartup(self,msg)
    -- set up the proximity radius, and pulse the proximity
    self:SetProximityRadius{radius = flyRadius, name = "MonumentBirds", collisionGroup = 1}
    self:GetProximityObjects{name = "MonumentBirds"}
end

--------------------------------------------------------------
-- Sent when a player enter/leave a Proximity Radius
--------------------------------------------------------------
function onProximityUpdate(self, msg)
	if self:GetVar("bAnimating") then return end
	
    -- is this the correct proximity
    if msg.name == "MonumentBirds" and msg.status == "ENTER" then    
		self:SetVar("bAnimating", true)
		
		local animTime = self:GetAnimationTime{animationID = sOnProximityAnim}.time
		
		if animTime == 0 then
			animTime = 1
		end
		
		GAMEOBJ:GetTimer():AddTimerWithCancel( animTime, msg.objId:GetID(), self )

		self:PlayAnimation{animationID = sOnProximityAnim, fPriority = 4.0, bPlayImmediate = true}
    end    
end 

function onTimerDone (self, msg)
	local player = GAMEOBJ:GetObjectByID(msg.name) or 0
	
	self:RequestDie{killerID = player}
end 
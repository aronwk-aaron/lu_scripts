--------------------------------------------------------------
-- Server side Script on the platforms that fall and come back up in the monastery attics
-- 
-- created by brandi... 6/9/11
--------------------------------------------------------------

local timeToFall = .75
local timeToBackUp = 2

--GUIDs
local startSound	= "{b7b848ad-7db0-4d51-a664-e38b386607dc}"
local endSound 		= "{7665b557-a611-4718-8bb1-9bb1fb0f8f0f}"
local travelSound 	= "{6f07abbd-1710-4047-8d54-e772c22a970f}"

function onCollisionPhantom(self, msg)
	-- make sure the tile isnt already set to go down
	if table.maxn(self:GetObjectsInPhysicsBounds().objects) >= 1 and not self:GetVar("AboutToFall") then
		GAMEOBJ:GetTimer():AddTimerWithCancel(timeToFall, "flipTime", self)
		-- tell the client to start the blink effect
		self:SetNetworkVar("startEffect", 2)
		self:SetVar("AboutToFall", true)
		self:PlayNDAudioEmitter{m_NDAudioEventGUID = startSound}
	end
end

function onArrivedAtDesiredWaypoint(self,msg)

	if msg.iPathIndex == 1 then
		self:StopNDAudioEmitter{m_NDAudioEventGUID = startSound}
		self:PlayNDAudioEmitter{m_NDAudioEventGUID = endSound}
	elseif msg.iPathIndex == 0 then
		self:StopNDAudioEmitter{m_NDAudioEventGUID = travelSound}
	end
end

function onTimerDone(self,msg)
	
	if msg.name == "flipTime" then
		--self:RotateObject{rotation = {x = -math.rad(90), y = 0, z = 0 } }
		self:GoToWaypoint{ iPathIndex  = 1 }
		GAMEOBJ:GetTimer():AddTimerWithCancel(timeToBackUp, "flipBack", self)
		self:PlayFXEffect{ name = "down" , effectType = "down" }
		-- turn off the blink effct
		self:SetNetworkVar("stopEffect", 3)
	elseif msg.name == "flipBack" then
		--self:RotateObject{rotation = {x = math.rad(90), y = 0, z = 0 } }
		self:GoToWaypoint{ iPathIndex  = 0 }
		self:PlayFXEffect{ name = "up" , effectType = "up" }
		self:SetVar("AboutToFall", false)
		self:PlayNDAudioEmitter{m_NDAudioEventGUID = travelSound}
	end
end
		
		

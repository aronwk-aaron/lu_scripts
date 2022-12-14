----------------------------------------
-- Server side script on the manager for the rocks in the fire transition of the monastery
--
-- created by brandi... 6/16/11
----------------------------------------

local rockManagerDefault = "FireTransRocksManager"
	

function onStartup(self)

	if not self:GetVar("RockManagerGroup") then
		self:SetVar("RockManagerGroup",rockManagerDefault)
	end
end

function onArrivedAtDesiredWaypoint(self,msg)
	-- when the rock is at the top way point, start a timer for holding at the top
	if msg.iPathIndex == 1 then
		GAMEOBJ:GetTimer():AddTimerWithCancel(3.5, "PlatHold", self)
	-- when the rock is at the down point, tell the manager
	else
		local manager = self:GetObjectsInGroup{ group = self:GetVar("RockManagerGroup"), ignoreSpawners = true }.objects
		for k,v in ipairs(manager) do
			if v:Exists() then
				v:NotifyObject{name = "PlatformDown", ObjIDSender = self}
				break
			end
		end
		
	end
end

-- after waiting, send the rock back down to start point
function onTimerDone(self,msg)
	if msg.name == "PlatHold" then
		self:GoToWaypoint{iPathIndex = 0}
	end
end

--

require('TestAndExample/MessageNotification/cagedGuy_common')

function onCageDied(self,savior)
	self:FollowWaypoints{ bUseNewPath=true, newPathName="LeaveCage" }
end

function onBridgeBuilt(self,builder)
	self:FollowWaypoints{ bUseNewPath=true, newPathName="CrossBridge" }
end

function onBbqBuilt(self,builder)
	GAMEOBJ:GetTimer():AddTimerWithCancel(4, "bbqReact", self)
end

function onBbqReact(self)
	self:Die{killerID=self, directionRelative_Force = 20}
end

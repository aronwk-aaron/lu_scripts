function onStartup(self,msg)
	math.randomseed( os.time() )
end

function onUse(self,msg)
	local coinFlip = math.random(1,2)
	local player = msg.user
	if coinFlip == 1 then
		player:StartRailMovement{pathName="EarthRail1", pathStart=0, pathGoForward=true, railActivatorComponentID=3, railActivatorObjID=self}
	elseif coinFlip == 2 then
		player:StartRailMovement{pathName="EarthRail1", pathStart=0, pathGoForward=true, railActivatorComponentID=3, railActivatorObjID=self}
	end
	self:SendLuaNotificationRequest{requestTarget= player, messageName="ArrivedAtDesiredWaypoint"} 
end
	
	
function notifyArrivedAtDesiredWaypoint(self,player,msg)
	print(" Woohoo, i've arrived!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
end

function onArrived(self,msg)
	print(" Woohoo, i've arrived!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
end
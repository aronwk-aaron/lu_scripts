function onStartup(self,msg)
	self:StopPathing()
	self:SetVar("StartingPoint",1)
	self:SetProximityRadius{radius = 5, name="PlatProx", collisionGroup = 8, shapeType = "CYLINDER", height = 15 }

end

function onProximityUpdate(self, msg)
	if not msg.name == "PlatProx" then return end
	if msg.status == "ENTER" and table.maxn(self:GetProximityObjects{name = "PlatProx"}.objects) == 1 then
		local waypoint = self:GetVar("StartingPoint")
		GAMEOBJ:GetTimer():AddTimerWithCancel(5, "flipTime_"..waypoint, self)
		--if waypoint == 1 then
		--	waypoint = 3
		--else
		--	waypoint = 1
		--end
		--self:SetVar("StartingPoint",waypoint)
	elseif msg.status == "LEAVE" and table.maxn(self:GetProximityObjects{name = "PlatProx"}.objects) == 0 then
		GAMEOBJ:GetTimer():CancelTimer("flipTime",self)
	end
end


function onTimerDone(self,msg)
	local var = split(msg.name,"_")
	
	if var[1] == "flipTime" then
		--local nextwaypoint = var[2] + 1
		self:RotateObject{rotation = {x = math.rad(90), y = 0, z = 0 } }
		--self:GoToWaypoint{iPathIndex = nextwaypoint}
		local nextwaypoint = var[2] + 1
		GAMEOBJ:GetTimer():AddTimerWithCancel(2, "flipBack_"..nextwaypoint, self)
	elseif var[1] == "flipBack" then
		local nextwaypoint = var[2] + 1
		if nextwaypoint == 4 then
			nextwaypoint = 1
		end
		self:RotateObject{rotation = {x = math.rad(90), y = 0, z = 0 } }
	end
end
		
		
-- splits a string based on the pattern passed in
function split(str, pat)
   local t = {}
   
   -- splits a string based on the given pattern and returns a table
   string.gsub(str .. pat, "(.-)" .. pat, function(result) table.insert(t, result) end)
   
   return t
end  
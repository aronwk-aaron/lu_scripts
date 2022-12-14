function onStartup(self,msg)
	self:StopPathing()
	self:SetVar("StartingPoint",1)
	self:SetProximityRadius{radius = 5, name="PlatProx", collisionGroup = 8, shapeType = "CYLINDER", height = 15 }

end

function onProximityUpdate(self, msg)
	if not msg.name == "PlatProx" then return end
	if msg.status == "ENTER" and table.maxn(self:GetProximityObjects{name = "PlatProx"}.objects) == 1 then
		local waypoint = self:GetVar("StartingPoint")
		GAMEOBJ:GetTimer():AddTimerWithCancel(5, "SmashTile", self)
		self:PlayFXEffect{name = "dust", effectType = "break"}
		--if waypoint == 1 then
		--	waypoint = 3
		--else
		--	waypoint = 1
		--end
		--self:SetVar("StartingPoint",waypoint)
	elseif msg.status == "LEAVE" and table.maxn(self:GetProximityObjects{name = "PlatProx"}.objects) == 0 then
		--GAMEOBJ:GetTimer():CancelTimer("SmashTile",self)
	end
end


function onTimerDone(self,msg)

	
	if msg.name == "SmashTile" then
		self:RequestDie{ killerID = self, killtype = "VIOLENT" }

	end
end
		
		

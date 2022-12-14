function onStartup(self,msg)
	ResetEverything(self)
end

function notifyDie(self,other,msg)
	self:SendLuaNotificationCancel{requestTarget=other, messageName="Die"}
	local smasher = msg.killerID:GetID()
	self:SetVar("Smasher",smasher)
	local orb = self:GetVar("OrbSpawner")
	orb = LEVEL:GetSpawnerByName(orb)
	orb:SpawnerReset()
	orb:SpawnerActivate()
	GAMEOBJ:GetTimer():AddTimerWithCancel(1, "GetOrbs", self )
	
end

function onNotifyObject(self,msg)
	if msg.name == "OrbPickup" then
		local PickedUpOrbs = self:GetVar("OrbsPickedUp")
		PickedUpOrbs = PickedUpOrbs + 1
		self:SetVar("OrbsPickedUp",PickedUpOrbs)
		local smasher = GAMEOBJ:GetObjectByID(self:GetVar("Smasher"))
		if PickedUpOrbs >= self:GetVar("TotalOrbs") then
			msg.ObjIDSender:RequestDie{killType = "VIOLENT", killerID = smasher}
			self:NotifyClientObject{name = "LastOrbPickedUp", param1 = 15, paramObj = player , rerouteID = player}
			
			ResetEverything(self)
			return
		end
		msg.ObjIDSender:RequestDie{killType = "SILENT"}
		GAMEOBJ:GetTimer():CancelTimer("TimeToOrb", self) 
		GAMEOBJ:GetTimer():AddTimerWithCancel(15, "TimeToOrb", self )
		self:NotifyClientObject{name = "OrbPickedUp", param1 = 15, paramObj = player , rerouteID = player}
	end
end

function ResetEverything(self)
	self:SetVar("Smasher",nil)
	local smashableSpawner = self:GetVar("SmashSpawner")
	smashableSpawner = LEVEL:GetSpawnerByName(smashableSpawner)
	smashableSpawner:SpawnerReset()
	smashableSpawner:SpawnerActivate()
	GAMEOBJ:GetTimer():AddTimerWithCancel(1, "GetSmashable", self )
	self:SetVar("OrbsPickedUp",0)
end
	

function onTimerDone(self,msg)
	if msg.name == "GetSmashable" then
		local smashableSpawner = self:GetVar("SmashSpawner")
		smashableSpawner = LEVEL:GetSpawnerByName(smashableSpawner)
		local crystal = smashableSpawner:SpawnerGetAllObjectIDsSpawned().objects
		if #crystal == 0 then return end
		for k,v in ipairs(crystal) do
			if v:Exists() then
				crystal = v
				break
			end
		end
		self:SendLuaNotificationRequest{requestTarget = crystal , messageName="Die"}
	elseif msg.name == "GetOrbs" then
		local smasher = self:GetVar("Smasher")
		local orb = self:GetVar("OrbSpawner")
		orb = LEVEL:GetSpawnerByName(orb)
		self:SetVar("TotalOrbs",orb:SpawnerGetNumNodes().uiNum)
		local orbs = orb:SpawnerGetAllObjectIDsSpawned().objects
		if #orbs == 0 then return end
		for k,v in ipairs(orbs) do
			v:SetNetworkVar("Smasher","|"..smasher)
			v:SetVar("Smasher","|"..smasher)
			v:SetVar("Manager",self:GetID())
		end
		self:NotifyClientObject{name = "TurnTimerOn", param1 = 15, paramObj = player , rerouteID = player}
		GAMEOBJ:GetTimer():AddTimerWithCancel(15, "TimeToOrb", self )
	elseif msg.name == "TimeToOrb" then
		self:NotifyClientObject{name = "OrbPickUpFailed", param1 = 15, paramObj = player , rerouteID = player}
		local orb = self:GetVar("OrbSpawner")
		orb = LEVEL:GetSpawnerByName(orb)
		orb:SpawnerDestroyObjects()
		ResetEverything(self)
	end
end
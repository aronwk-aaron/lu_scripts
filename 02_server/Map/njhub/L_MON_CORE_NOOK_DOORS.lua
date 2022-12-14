--------------------------------------------------------------
-- Server side Script on the triggers in the nooks in the monastery

-- 
-- created by brandi... 6/10/11
--------------------------------------------------------------

--dont spawn the door if a player is in  the trigger
function onStartup(self,msg)
	if table.maxn(self:GetObjectsInPhysicsBounds().objects) > 0 then return end
	
	SpawnDoor(self)
		
end

-- start the spawner network to spawn the door
function SpawnDoor(self)
	local doorNum = self:GetVar("number")
	if not doorNum then return end
	
	local spawner = LEVEL:GetSpawnerByName("MonCoreNookDoor0"..doorNum)
	
	if not spawner:Exists() then return end
	
	spawner:SpawnerReset()
	spawner:SpawnerActivate()
end

-- the door tells the trigger it died
function onFireEvent(self,msg)
	if msg.args == "DoorSmashed" then
		GAMEOBJ:GetTimer():AddTimerWithCancel(30, "RespawnDoor", self)
	end
end

-- before respawning the door, check to see if players are in the volume, if so, wait and check again
function onTimerDone(self,msg)
	if msg.name == "RespawnDoor" then
		if table.maxn(self:GetObjectsInPhysicsBounds().objects) > 0 then 
			GAMEOBJ:GetTimer():AddTimerWithCancel(10, "RespawnDoor", self)
		else
			SpawnDoor(self)
		end
	end
end
				
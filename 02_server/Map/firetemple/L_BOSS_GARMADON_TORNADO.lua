-- path name
local pathString = "BossTornadoPath_"

local proxRadius = 12
local elementalOrder = { "earth","ice","lightning","fire"}
local bombDelay = { earth = 40, ice = 36, lightning = 32, fire = 28 }
local bombLOT = 16891

-- Groups
local gameSpaceVolume = "BossGameSpace"

function onStartup(self)
	
	self:SetProximityRadius{radius = proxRadius, name="TornadoProx", collisionGroup = 1, shapeType = "CYLINDER", height = 30, type = "ACTIVE" }
	
	if GAMEOBJ:GetZoneControlID():GetVar("initialPlayerCount") > 2 then
		self:SetVar("LargeTeam",true)
	end
end

function onNotifyObject(self,msg)
	if msg.name == "FindAPath" then
	
		PickPath(self)
		self:SetVar("CurrentElement",elementalOrder[1])
		StartBombTimer(self)
		
	elseif msg.name == "NewElement" then
	
		if not msg.param1 then return end
		
		self:SetVar("CurrentElement",elementalOrder[msg.param1])
		
	elseif msg.name == "StopPathing" then
	
		self:StopPathing()
		GAMEOBJ:GetTimer():CancelTimer("BombPlayer",self)
		
	end
end

function onPlatformAtLastWaypoint(self,msg)
	PickPath(self)
end

function onProximityUpdate(self, msg)	
	-- do knockback if the player entered into the radius
	if msg.name == "TornadoProx" and msg.status == "ENTER" then
		for k,faction in ipairs(msg.objId:GetFaction().factionList) do
			if faction == 130 and ( msg.objId:GetRebuildState{}.iState == 2 or msg.objId:GetRebuildState{}.iState == 6 ) then
				print("i smashed with "..msg.objId:GetName().name)
				msg.objId:RequestDie{killType = "VIOLENT"} 
				break
			elseif faction == 1 then

				if not msg.objId then return end
				print("i collided with "..msg.objId:GetName().name)
				
				self:CastSkill{skillID = 1741, optionalTargetID = msg.objId}
				break
			end
		end
	end
end 

function onTimerDone(self,msg)

	if msg.name == "BombPlayer" then
		PickAPlayer(self)
	end

end


function PickPath(self)

	local totalPaths = self:GetVar("TotalPaths")
	local nextPath = math.random(1,totalPaths)
	--self:FollowWaypoints{ bUseNewPath = true, newPathName = pathString..nextPath, newStartingPoint = 0 }
	self:SetCurrentPath{pathName = pathString..nextPath, startPoint = 0}
	self:StartPathing()
	self:SetVar("CurrentPath",pathString..nextPath)

	print("tornado now pathing on "..pathString..nextPath)
	
end

function StartBombTimer(self)

	local elementTimer = bombDelay[self:GetVar("CurrentElement")]
	--if not self:GetVar("LargeTeam") then
		--elementTimer = elementTimer * 2
	--end
	local timeToNextBomb = math.random((elementTimer/2),elementTimer)
	GAMEOBJ:GetTimer():AddTimerWithCancel(timeToNextBomb, "BombPlayer", self)
		
end

function PickAPlayer(self)
 	local TriggerVolume = self:GetObjectsInGroup{ group = gameSpaceVolume, ignoreSpawners = true }.objects
	if #TriggerVolume == 0 then return end
	for k,trigger in ipairs(TriggerVolume) do
		if trigger:Exists() then
		
			StartBombTimer(self)
						
			local playersT = trigger:GetObjectsInPhysicsBounds().objects
			if #playersT == 0 then return end
			
			local numb = math.random(1,#playersT)
			if ( not playersT[numb]:Exists() ) or playersT[numb]:IsDead().bDead then return end
			
			local pos = playersT[numb]:GetPosition().pos
			
			print("spawn projecile at "..playersT[numb]:GetName().name)
			
			RESMGR:LoadObject { objectTemplate =  bombLOT, x = pos.x , y = pos.y , z = pos.z, owner = self, configData = config }
			
			self:PlayAnimation{ animationID = "attack" }
			break
		end
	end
end

			
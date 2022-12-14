----------------------------------------
-- Server side script on the the prison cages in the caves
--
-- created by brandi... 6/28/11
----------------------------------------


-- lots of the villagers, in the correct order
local villagers = {15851, -- villager 1
					15866,15922,15924,15927,15929}
					
local missions = {1801,2039}

-- cage loading controls the counterweight and npc spawning
function onStartup(self,msg)
	
	-- get the config data of the number for this prison set up
	local myNum = self:GetVar("myNumber")
	if not myNum then return end
	
	-- use that number to find the spawner network for the counterweight for this prison
	local CWspawner = LEVEL:GetSpawnerByName("PrisonCounterweight_0"..myNum)
	-- save out the spawner network for later use
	self:SetVar("CWSpawner",CWspawner)
	-- go to a custom function to set up the prison, pass the name of the spawner network
	SetUp(self,CWspawner)
end

-- CUSTOM FUNCTION : this function sets up the prison, and resets it after a villager has been freed once
--		name of the spawner network has been passed in
function SetUp(self,CWspawner)

	SpawnCounterweight(self,CWspawner)

	-- get the position and rotation of the jail
	local mypos = self:GetPosition().pos
	mypos.y = mypos.y + 1.5
	mypos.z = mypos.z - .5
	local myrot = self:GetRotation()
	
	-- Spawn the villager inside the jail
	RESMGR:LoadObject {objectTemplate =  villagers[tonumber(self:GetVar("myNumber"))], x = mypos.x , y = mypos.y , z = mypos.z , rw = myrot.w, rx = myrot.x, ry = myrot.y , rz = myrot.z, owner = self}

end

-- the spawner network notified that it spawned something
function notifySpawnedObjectLoaded(self, other, msg)
	
	-- check to make sure its the correct spawner network that notified
	if not self:GetVar("CWSpawner"):GetID() == other:GetID() then return end
	
	local counterweight = msg.objectID
	-- tell the counterweight to notify the script when it reaches the end of it path
	self:SendLuaNotificationRequest{requestTarget = counterweight, messageName = "PlatformAtLastWaypoint"}
	self:SendLuaNotificationRequest{requestTarget = counterweight, messageName = "RebuildNotifyState"}
	-- save out the counterweight for later use
	self:SetVar("Counterweight",counterweight)
	
	-- if the button isnt already set, get it now
	if self:GetVar("Button") then return end
	GetButton(self)
end

----------------------------------------------------------------
-- the counterweights quickbuild pile has been interacted with
----------------------------------------------------------------
function notifyRebuildNotifyState(self,counterweight,msg)

	-- quickbuild was started but not finished, so it died and it needs to respawn
	if msg.iState == 4 and msg.iPrevState == 6 then
		local CWspawner = self:GetVar("CWSpawner")
		CWspawner:SpawnerDestroyObjects()
		SpawnCounterweight(self,CWspawner)
	end
		
end

function SpawnCounterweight(self,CWspawner)

	CWspawner:SpawnerReset()
	CWspawner:SpawnerActivate()
	-- tell the spawner network to notify the script when it spawns something
	self:SendLuaNotificationRequest{requestTarget = CWspawner, messageName="SpawnedObjectLoaded"}
end

function GetButton(self)
	local button = self:GetObjectsInGroup{ group = "PrisonButton_0"..self:GetVar("myNumber"), ignoreSpawners = true }.objects
	if table.maxn(button) == 0 then
		GAMEOBJ:GetTimer():AddTimerWithCancel(.5, "FindButton", self)
		return
	end
	for k,v in ipairs(button) do
		if v:Exists() then
			button = v
			break
		end
	end
	--save out the button for later use
	self:SetVar("Button",button)
	-- preload the down animation on the button
	button:PreloadAnimation{animationID = "down", respondObjID = self }
end

-- the counterweight notified that it reached it last end point
function notifyPlatformAtLastWaypoint(self,counterWeight,msg)
	local user = counterWeight:GetAllActivityUsers().objects[1]
	if user:Exists() then
		self:SetVar("Builder",user)
	end
	
	-- get the button and make sure it still exists
	local button  = self:GetVar("Button")
	if not button:Exists() then return end
	-- get the anim time of the button going down and start a timer
	local animTime = button:GetAnimationTime{animationID = "down"}.time
	GAMEOBJ:GetTimer():AddTimerWithCancel(animTime, "buttonGoingDown", self)
	-- play the anim of the button going down
	button:PlayAnimation{animationID = "down", bPlayImmediate = true}
end

-- a villager loaded
function onChildLoaded(self,msg)
	if not ( msg.childID:GetLOT().objtemplate == villagers[tonumber(self:GetVar("myNumber"))] ) then return end
	-- save out the villager
	self:SetVar("villager",msg.childID)
end

function onTimerDone(self,msg)

	if msg.name == "FindButton" then
		if self:GetVar("Button") then return end
		GetButton(self) 
	-- the anim of the button down is over
	elseif msg.name == "buttonGoingDown" then
	
		-- get the button and make sure it still exists
		local button = self:GetVar("Button")
		if not button:Exists() then return end
		-- freeze the button in the down position of the animation
		button:FreezeAnimation{doFreeze = true}
		
		-- get the time of the cage open anim on the cage and set a timer for it
		local animTime = self:GetAnimationTime{animationID = "up"}.time
		GAMEOBJ:GetTimer():AddTimerWithCancel(animTime, "CageOpen", self)
		-- play th cage open anim
		self:PlayAnimation{animationID = "up", bPlayImmediate = true}
	
	-- the cage is open
	elseif msg.name == "CageOpen" then
		
		-- play the idle open anim
		self:PlayAnimation{animationID = "idle-up", bPlayImmediate = true}
		
		-- get the villager
		local villager = self:GetVar("villager")
		if not villager:Exists() then return end
		-- tell the villager to chat
		villager:NotifyClientObject{ name = "TimeToChat" }
		
		-- create the player flag number
		local flagNum = 2020 + tonumber(self:GetVar("myNumber"))
		
		-- get builder
		local builder = self:GetVar("Builder")
		
		--	-- get everyone on builders team
		local teamMembers = builder:TeamGetLootMembers().vMembers 
		
		-- find out if player is on a team
		if #teamMembers > 0 then
			
			for k,player in ipairs(teamMembers) do
				if player:Exists() then
					for k,missionID in ipairs(missions) do
						if player:GetMissionState{missionID = missionID}.missionState == 2 or
							player:GetMissionState{missionID = missionID}.missionState == 10 then
								player:SetFlag{iFlagID = flagNum, bFlag = true}
						end
					end
				end
			end
			
		else
			-- set player flag to true
			builder:SetFlag{iFlagID = flagNum, bFlag = true}
		end
		
		-- start a timer for the villager to be done chating
		GAMEOBJ:GetTimer():AddTimerWithCancel(5, "VillagerEscape", self)
		
	--the villager is done chatting and ready to disappaear
	elseif msg.name == "VillagerEscape" then
	
		-- get the villager and then tell it to die
		local villager = self:GetVar("villager")
		if not villager then return end
		villager:RequestDie{killType = "SILENT"}
		-- start a timer to smash the counterweight and close the jail
		GAMEOBJ:GetTimer():AddTimerWithCancel(2, "SmashCounterweight", self)
	
	-- the villager has successfully escaped, we can now start the process to close the jail 
	elseif msg.name == "SmashCounterweight" then
	
		-- get the counterweight and kill it
		local counterweight = self:GetVar("Counterweight")
		if not counterweight:Exists() then return end
		counterweight:RequestDie{killType = "VIOLENT"}
		
		-- get the button and make sure it still exists
		local button  = self:GetVar("Button")
		if not button:Exists() then return end
		-- unfreeze the animations on the button
		button:FreezeAnimation{doFreeze = false}
		-- get the time of the up anim on the button and start a timer
		local animTime = button:GetAnimationTime{animationID = "up"}.time
		GAMEOBJ:GetTimer():AddTimerWithCancel(animTime, "ResetButton", self)
		-- play the up animation
		button:PlayAnimation{animationID = "up", bPlayImmediate = true}
		
	-- the button has gone up again, need to lower the cage
	elseif msg.name == "ResetButton" then
		
		-- get the button and make sure it still exists
		local button = self:GetVar("Button")
		if not button:Exists() then return end
		-- freeze the button in the down position of the animation
		button:PlayAnimation{animationID = "idle", bPlayImmediate = true}
		
		-- get the time of the close anim on the cage and start a timer
		local animTime = self:GetAnimationTime{animationID = "down"}.time
		GAMEOBJ:GetTimer():AddTimerWithCancel(animTime, "CageClosed", self)
		-- play the down anim to close the cage
		self:PlayAnimation{animationID = "down", bPlayImmediate = true}
	
	-- the cage has been closed
	elseif msg.name == "CageClosed" then
	
		-- play the idle anim on the cage and start a timer
		self:PlayAnimation{animationID = "idle", bPlayImmediate = true}
		GAMEOBJ:GetTimer():AddTimerWithCancel(10, "ResetPrison", self)
		
	-- run set up again
	elseif msg.name == "ResetPrison" then
		
		SetUp(self,self:GetVar("CWSpawner"))
		
	end
end
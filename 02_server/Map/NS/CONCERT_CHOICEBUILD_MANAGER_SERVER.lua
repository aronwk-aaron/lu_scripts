--------------------------------------------------------------
-- Server script for the Concert choicebuild, chooses which crate
-- to spawn in and makes sure that the crate/qb is spawned in.
--
-- created mrb... 11/12/10 - moved logic from the crate to this manager object.
--------------------------------------------------------------
-- constants
--------------------------------------------------------------

local respawnDelayTime = 1.0	-- how long to wait after the QB dies to respawn a crate
-- names of spawner networks from hf and the time each box will take to switch
local crates ={	{name = "laser", lot = 11203, time = 5.0, groupID = "Concert_Laser_QB_"},
				{name = "rocket", lot = 11204, time = 3.0, groupID = "Concert_Rocket_QB_"},
				{name = "speaker", lot = 11205, time = 5.0, groupID = "Concert_Speaker_QB_"},
				{name = "spotlight", lot = 11206, time = 5.0, groupID = "Concert_Spotlight_QB_"}}
                           
--------------------------------------------------------------

function onStartup(self)	
	-- spawn the initial crates
	spawnCrate(self)		
end

-- something died that we were listening for
function notifyDie(self, other, msg)
	-- cancel the notification for the manager when the object dies
	self:SendLuaNotificationCancel{requestTarget = other, messageName = "Die"}
	
	-- loop through the crates table and find out if it was a crate that died
	for k, crateData in ipairs(crates) do
		if crateData.lot == other:GetLOT().objtemplate then
			-- clear the active crate since it died
			self:SetVar("CurrentCrate", "0")
			
			-- clear the timers
			GAMEOBJ:GetTimer():CancelAllTimers( self )
						
			-- if the QB hasn't loaded yet, which it should have
			if not self:GetVar("QB_Loaded") then
				-- start a timer to spawn another crate if the QB doesn't notify before 30 sec
				GAMEOBJ:GetTimer():AddTimerWithCancel( 30.0 , "QBNotLoaded", self )
			end
			
			return
		end
	end
	
	-- it was a QB that died, so clear the QB loaded bool
	self:SetVar("QB_Loaded", false)
	-- start the delay timer to spawn another crate
	GAMEOBJ:GetTimer():AddTimerWithCancel( respawnDelayTime , "SpawnCrateDelay", self )
end

function onNotifyObject(self, msg)
	-- make sure this notification is coming from the QB
	if msg.name == "QB_Shown" then
		-- clear the timers
		GAMEOBJ:GetTimer():CancelAllTimers( self )
		-- QB is loaded bool
		self:SetVar("QB_Loaded", true)
	end
end

-- this function spawns the next crate in the cycle
function spawnCrate(self)
	local spawnNum = self:GetVar("spawnNum") or 0 -- get the current spawn number or use 0
	
	-- increment the spawn number
	spawnNum = spawnNum + 1
	
	-- if it's over the # of crates then set back to 1
	if spawnNum > #crates then
		spawnNum = 1
	end
	
	-- set the spawnNum var on the object
	self:SetVar("spawnNum", spawnNum)
	
	-- get the crate info based on the spawnNum
	local spawnTable = crates[spawnNum]	
	-- get managers pos/rot to pass to the crate
	local myPos = self:GetPosition().pos
	local myRot = self:GetRotation()
	-- get the group and number to pass tot he crate
    local groupName = self:GetVar("groupID") or ""    
    local myGroup = string.gsub(groupName,"%;","")
	local myGroupNum = tonumber(string.sub(myGroup, -1))
	
	-- data to pass to the crate when it's loaded
	local config = { {"startsQBActivator", true}, {"grpNameQBShowBricks", spawnTable.groupID .. myGroupNum}, {"groupID", "Crate_" .. myGroup}, {"crateTime", spawnTable.time} }
	
	-- spawn a crate
	RESMGR:LoadObject { objectTemplate = spawnTable.lot , x = myPos.x , y = myPos.y , z = myPos.z , rw = myRot.w, rx = myRot.x, ry = myRot.y, rz = myRot.z, owner = self, configData = config }
	-- set a timer to make sure that the crate spawns into the world
	GAMEOBJ:GetTimer():AddTimerWithCancel( 30.0 , "CrateNotLoaded", self )
end

-- crate spawned into the world
function onChildLoaded(self, msg)	
	-- loop through the crates table and find which crate spawned in
	for k,crateData in ipairs(crates) do
	    if crateData.lot == msg.templateID then
			-- set the CurrentCrate variable to the spawned in crates objectID
			self:SetVar("CurrentCrate", "|" .. msg.childID:GetID())
			-- set listener for when the crate dies
			self:SendLuaNotificationRequest{requestTarget = msg.childID, messageName = "Die"}
			
			-- clear timers and start the switch crate timer
			GAMEOBJ:GetTimer():CancelAllTimers( self )			
			GAMEOBJ:GetTimer():AddTimerWithCancel( crateData.time , "SwitchToNextBox", self )
			
			-- we're done here
			break
		end
	end
end

--------------------------------------------------------------
-- timers
--------------------------------------------------------------
function onTimerDone(self, msg)
	if msg.name == "SwitchToNextBox" then
		-- get the CurrentCrate ID and find it's proxObj
		local crateID = self:GetVar("CurrentCrate") or 0
		
		if crateID ~= 0 then
			local crateObj = GAMEOBJ:GetObjectByID(crateID)
			
			-- if we have a crate delete it
			if crateObj:Exists() then
				self:SendLuaNotificationCancel{requestTarget = crateObj, messageName = "Die"}
				GAMEOBJ:DeleteObject(crateObj)
			end
			
			self:SetVar("CurrentCrate", 0)
		end
		
		-- clear timers and spawn the next crate
		GAMEOBJ:GetTimer():CancelAllTimers( self )
		spawnCrate(self)
    elseif msg.name == "CrateNotLoaded"  or msg.name == "QBNotLoaded" or msg.name == "SpawnCrateDelay" then
		-- get teh crate ID
		local currentCrate = self:GetVar("CurrentCrate") or 0
		
		-- if we dont have a crate and a QB isn't loaded then clear timers and spawn a crate
		if currentCrate == 0 and not self:GetVar("QB_Loaded") then
			GAMEOBJ:GetTimer():CancelAllTimers( self )
			spawnCrate(self)
		end
    end
end

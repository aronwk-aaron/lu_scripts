--------------------------------------------------------------

-- L_QB_SPAWNER.lua

-- Works in tandem with objects requesting mob spawns where the 
-- requesting object is set to be the immediate target of the
-- resulting group of enemies
-- Created abeechler... 1/31/11

-------------------------------------------------------------

local defaultMobNum = 3				-- The maximum size of the enemy mob to maintain
local defaultSpawnDist = 25			-- How far away should we spawn the enemy mob?
local defaultMobTemplate = 4712		-- What object template comprises the mob?
local defaultSpawnTime = 2			-- How long to delay (if at all) until the mob is spawned

function onStartup(self)
	-- Establish initial object state
	local mobNum = self:GetVar("mobNum") or defaultMobNum
	local spawnDist = self:GetVar("spawnDist") or defaultSpawnDist
	local mobTemplate = self:GetVar("mobTemplate") or defaultMobTemplate
	local spawnTime = self:GetVar("spawnTime") or defaultSpawnTime
	
	self:SetVar("mobNum", mobNum)
	self:SetVar("spawnDist", spawnDist)
	self:SetVar("mobTemplate", mobTemplate)
	self:SetVar("spawnTime", spawnTime)
end

----------------------------------------------
-- Received an event call to process
----------------------------------------------
function onFireEvent(self, msg)

	-- Have we been sent a valid event type to process?
	local eventType = msg.args
	if not eventType then return end

	-- A call has been made to update the enemy mob
	if eventType == "spawnMobs" then
		if not msg.senderID then return end
		-- Set the object ID that requested the mob update
		local gateObj = msg.senderID
		self:SetVar("gateObj", gateObj)
		
		local spawnTime = self:GetVar("spawnTime")
		GAMEOBJ:GetTimer():AddTimerWithCancel(spawnTime, "SpawnMobEnemies", self )
	end

end

function onTimerDone(self, msg)
    if msg.name == "SpawnMobEnemies" then
		-- Grab the current mobTable, or build a new one if it doesn't exist
		local mobTable = self:GetVar("mobTable") or {}
		-- Grab mob stats
		local mobNum = self:GetVar("mobNum")
		local mobTemplate = self:GetVar("mobTemplate")
		local spawnDist = self:GetVar("spawnDist")
		-- Grab the object ID that requested the mob update
		local gateObj = self:GetVar("gateObj")
		
		-- Calculate the mob base destination and orientation based 
		-- on the valid senderID object
		local oPos = {pos = gateObj:GetPosition().pos}
		local oDir = gateObj:GetObjectDirectionVectors()
		local newPos = {x = oPos.pos.x + (oDir.forward.x * spawnDist), y = oPos.pos.y, z = oPos.pos.z + (oDir.forward.z * spawnDist)} --+ (oDir.forward.y * posOffset)
        
		oPos.rot = gateObj:GetRotation()
        
        -- Build the base mob creature config data table
		local config = { {"no_timed_spawn", true}, {"aggroRadius", 70}, {"softtetherRadius", 80}, {"tetherRadius", 90}, {"wanderRadius", 5} }
         
		-- Iterate through the mobTable (scaled to the desired mob size)
		-- and load a new AI for every available open mob slot
		for i=1, mobNum do
			local posOffset = -10
			if(not mobTable[i]) then
				-- We have found an open mob slot
				-- Identify his mob slot in the config data
				table.insert(config, {"mobTableLoc", i})
				-- Created a new mob entity at the desired offset loc
				posOffset = posOffset + 5 * i 
				local newOffset = {x = newPos.x, y = newPos.y, z = newPos.z + posOffset}
				RESMGR:LoadObject{ objectTemplate = mobTemplate, x= newPos.x, y= newPos.y , z= newPos.z + posOffset, rw = oPos.rot.w, rx = -oPos.rot.x, ry = -oPos.rot.y, rz = -oPos.rot.z, owner = self, configData = config}
			else
				-- There is an existing mob object - set it to aggro
				-- the requesting spawn object
				aggroTargetObj(self, mobTable[i])
			end
		end  
    end
end

----------------------------------------------
-- Called on successful load of a spawned entity
----------------------------------------------
function onChildLoaded(self, msg)
	-- Identify the spawned mob creature
    local spawnedMob = msg.childID
    
    -- Add the spawned entity to the mobTable at the appropriate slot
    local mobTable = self:GetVar("mobTable") or {}
    local tableLoc = spawnedMob:GetVar("mobTableLoc")
    mobTable[tableLoc] = spawnedMob
    self:SetVar("mobTable", mobTable)
    
    -- Set mob object to aggro the spawning object
    aggroTargetObj(self, spawnedMob)
end

----------------------------------------------
-- Notifcation of child death for processing
----------------------------------------------
function onChildRemoved(self, msg)
	-- Remove the dead mob object from the mobTable
	local mobTable = self:GetVar("mobTable") or {}
	local tableLoc = msg.childID:GetVar("mobTableLoc")
	mobTable[tableLoc] = nil
	self:SetVar("mobTable", mobTable)
end

----------------------------------------------
-- Sets aggro on a target child to a specified target
----------------------------------------------
function aggroTargetObj(self, enemy)
	-- Identify the obj that called for mob spawn
	local gateObj = self:GetVar("gateObj")
	
	-- Set the enemy to follow and aggro the target
	if(gateObj:Exists()) then
		enemy:FollowTarget{targetID = gateObj}    
		enemy:AddThreatRating{newThreatObjID = gateObj, ThreatToAdd = 1000}
    end
    
    -- Place secondary focus on the player that caused the mob spawn call
    local player = self:GetVar("player")
    if(player:Exists()) then
		enemy:AddThreatRating{newThreatObjID = player, ThreatToAdd = 100}
    end
end

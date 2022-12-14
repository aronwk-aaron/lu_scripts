--------------------------------------------------------------
-- Base Server side Script for a smashable that spawns an enemy on player proxmity
-- this is a generic script, and should be required by another script that sets up any of the settings

-- currently used on the ronin in fv and the coffins in the monastery
-- 
-- created Brandi... 6/7/11
--------------------------------------------------------------

local SmashableVariables = {
								enemyLOTtoSpawn = nil,
								playerDetectionRadius = 15,	-- size for the proximity monitor
								hatchTime = 2,					-- time from the smashable detecting the player until an enemy smashes
								wakeUpSkill = 305,				-- skill cast to wake up other smashables around this one
								wakeUpFX = { {[2260] = "rebuild_medium"} },	--fx to play when the smashable is about to hatch
								burstFX = { {[644] = "create"} }			-- fx to play when the smashable breaks and the enemy spawns
							}
--  all below are for the enemy that spawns
local EnemyVariables = {
							serverScript = '',				
							clientScript = '',			
							tetherRadius = 120,
							softtetherRadius = 110,
							aggroRadius = 100,
							wanderRadius = 70,
							suicideTimer = 60
						}

--------------------------------------------------------------
-- if a script is attached, call SetVariables
--------------------------------------------------------------
function onStartup(self,msg)
	baseStartup(self,msg)
end

function baseStartup(self,msg)
	-- if an enemy lot isnt defined, cancel the script
	if not SmashableVariables.enemyLOTtoSpawn then return end
	-- whether the enemy is hatching or not
	self:SetVar("hatching", false)
	-- if there is player radius, set the proximity monitor
	if SmashableVariables.playerDetectionRadius > 0 then
		self:SetProximityRadius { radius = SmashableVariables.playerDetectionRadius, collisionGroup = 1 }
	end
end

--------------------------------------------------------------
-- get variables from the setup scripts
--------------------------------------------------------------
function SetVariables(self,passedSmashableVariables,passedEnemyVariables)
	
	-- if a variable isnt passed in, set it to the defaults
	for k,v in pairs(passedSmashableVariables) do
		SmashableVariables[k] = v
	end
	
	for k,v in pairs(passedEnemyVariables) do
		EnemyVariables[k] = v
	end
	
end

--------------------------------------------------------------
-- When a human player enters the proximity of the statue, 
--------------------------------------------------------------
function onProximityUpdate(self, msg)
	-- someone entered and the smashable isnt already hatching
	if (msg.status == "ENTER") and (not self:GetVar("hatching")) then
		-- custom script to hatch
		StartHatching(self)
		-- cast the wake up skill to take up other smashables around
		self:CastSkill{skillID = SmashableVariables.wakeUpSkill}
   end
end

--------------------------------------------------------------
-- if another smashable hits, start the hatching process 
--------------------------------------------------------------
function onOnHit(self,msg)
	if self:GetVar("hatching") then return end
	
	if msg.attacker:GetLOT().objtemplate == self:GetLOT().objtemplate then 
		StartHatching(self)
	end
	
end

--------------------------------------------------------------
-- start a timer and cast a skill to have nearby statues start to spawn too
--------------------------------------------------------------
function StartHatching(self)
	self:SetVar("hatching", true)
	for k,fxTable in ipairs(SmashableVariables.wakeUpFX) do
		for fxNumber,fxType in pairs(fxTable) do
			self:PlayFXEffect{name = "WakeUpFX"..k, effectID = fxNumber, effectType = fxType}
		end
	end
	GAMEOBJ:GetTimer():AddTimerWithCancel(SmashableVariables.hatchTime, "hatchTime", self)
end

--------------------------------------------------------------
--play an effect, kill the statue, and spawn a ronin at statue location
--------------------------------------------------------------
function onTimerDone(self, msg)
    if msg.name == "hatchTime" then
		for k,fxTable in ipairs(SmashableVariables.burstFX) do
			for fxNumber,fxType in pairs(fxTable) do
				self:PlayFXEffect{name = "BurstFX"..k, effectID = fxNumber, effectType = fxType}
			end
		end
		local pos = self:GetPosition().pos
		local config = {{"tetherRadius", EnemyVariables.tetherRadius}, 
						{"softtetherRadius", EnemyVariables.softtetherRadius}, 
						{"aggroRadius", EnemyVariables.aggroRadius}, 
						{"wanderRadius", EnemyVariables.wanderRadius}, 
						{"suicideTimer", EnemyVariables.suicideTimer}}
		if EnemyVariables.serverScript then
			table.insert(config, {"custom_script_server",EnemyVariables.serverScript} )
		end
		
		if EnemyVariables.clientScript then
			table.insert(config, {"custom_script_client",EnemyVariables.clientScript} )
		end
		
		local enemyToSpawn =  SmashableVariables.enemyLOTtoSpawn
		
		if self:GetVar("LotToSpawn") then
			enemyToSpawn = self:GetVar("LotToSpawn")
		end
		
		RESMGR:LoadObject{objectTemplate = enemyToSpawn  , x = pos.x , y =  pos.y , z = pos.z , owner = self, configData = config}
		self:RequestDie()
	end
end

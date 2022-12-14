------------------------------------------------------

-- L_ENEMY_SPIDER_SPAWNER.lua

-- Spawns a spider from the egg
-- created abeechler... 5/11/11

------------------------------------------------------

local hatchTime = 2.0       -- How long after full wave preparation will it take to hatch an egg?
local spawnTime = 2.0       -- Once spawning begins, how long until we create Spiderlings?

----------------------------------------------
-- Initiate egg hatching on call
----------------------------------------------
function onFireEvent(self, msg)
	-- Receive the sending object ID and the message to parse
	local eventType = msg.args
	local sendObj = msg.senderID
	
	-- Missing a valid event type?
	if not eventType then return end
	
	if eventType == "prepEgg" then
	     -- Highlight eggs about to hatch with Maelstrom effect
	     self:PlayFXEffect{name = "test", effectID = 2856, effectType = "maelstrom"}
	     
	     -- Make indestructible
	     self:SetFaction{faction = -1}
	     
	     -- Keep track of who prepped me
	     self:SetVar("SpawnOwner", sendObj)
	     
	elseif eventType == "hatchEgg" then
	    -- Final countdown to pop
        GAMEOBJ:GetTimer():AddTimerWithCancel(hatchTime, "StartSpawnTime", self)
        
	end
end

----------------------------------------------------------------
-- Called when it is finally time to release the Spiderlings
----------------------------------------------------------------
function spawnSpiderling(self)
    -- Initiate the actual spawning
	self:PlayFXEffect{name = "dropdustmedium", effectID = 2260, effectType = "rebuild_medium"}
    GAMEOBJ:GetTimer():AddTimerWithCancel(spawnTime, "SpawnSpiderling", self)
end

----------------------------------------------------------------
-- Called when timers are done
----------------------------------------------------------------
function onTimerDone(self,msg)
    
    if msg.name == "StartSpawnTime" then
        spawnSpiderling(self)
        
	elseif msg.name == "SpawnSpiderling" then
	    self:PlayFXEffect{name = "egg_puff_b", effectID = 644, effectType = "create"}
        local pos = self:GetPosition().pos
        
        -- Who spawned me?
        local SpawnOwner = self:GetVar("SpawnOwner")
					
        local config = {{"custom_script_server", "scripts/02_server/Enemy/General/L_BASE_ENEMY_SPIDERLING.lua"},
                        {"custom_script_client", "scripts/02_client/Enemy/General/L_REGISTER_FOR_UI.lua"},
					    {"tetherRadius", 101}, 
					    {"softtetherRadius", 95}, 
					    {"aggroRadius", 110}, 
					    {"wanderRadius", 15}}
					    
        RESMGR:LoadObject{objectTemplate = 16197  , x = pos.x , y =  pos.y , z = pos.z , owner = SpawnOwner, configData = config} 
	    self:Die()
    end
	
end

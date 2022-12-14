------------------------------------------------------
-- Spawns a skeleton from the coffin

-- updated Austin Randall
------------------------------------------------------

local interactRadius = 15
local hatchTime = 2.0

function onStartup(self)
    self:SetVar("hatching", false)
	self:SetProximityRadius { radius = interactRadius }
  
end

function onProximityUpdate(self, msg)
	local isHuman = msg.objId:IsCharacter().isChar
	local player = msg.objId
	
	if (msg.status == "ENTER") and (isHuman) and self:GetVar("hatching") == false then
      --------------------------------------------------------------
      -- When a human player enters the proximity of the statue, start
      -- a timer and cast a skill to have nearby statues start to spawn too
      --------------------------------------------------------------

      player:UpdateMissionTask{taskType = "complete", value = 845, value2 = 1, target = self}
      self:SetVar("hatching", true)
      self:PlayFXEffect{name = "dropdustmedium", effectID = 2260, effectType = "rebuild_medium"}
      self:CastSkill{skillID = 305}
      GAMEOBJ:GetTimer():AddTimerWithCancel(hatchTime, "hatchTime", self)
   end
   
end

function onOnHit(self, msg)
    if self:GetVar("hatching") == false then
        --------------------------------------------------------------
        --if the statue isn't hatching already, then begin the hatching
        --timer on hit
        --------------------------------------------------------------
        
        self:SetVar("hatching", true)
        self:PlayFXEffect{name = "dropdustmedium", effectID = 2260, effectType = "rebuild_medium"}
        GAMEOBJ:GetTimer():AddTimerWithCancel(hatchTime, "hatchTime", self)
        if msg.attacker:GetLOT().objtemplate ~= 14421 then
            self:CastSkill{skillID = 305}
        end
    end
    
end

function onTimerDone(self, msg)
    --------------------------------------------------------------
    --play an effect, kill the statue, and spawn a ronin at statue location
    --------------------------------------------------------------
    
    self:PlayFXEffect{name = "egg_puff_b", effectID = 644, effectType = "create"}
    local pos = self:GetPosition().pos
    self:Die()

    local config = {{"custom_script_server", "scripts/02_server/Enemy/General/L_COUNTDOWN_DESTROY_AI.lua"},
					{"tetherRadius", 120}, 
					{"softtetherRadius", 110}, 
					{"aggroRadius", 100}, 
					{"wanderRadius", 70}, 
					{"suicideTimer", 60}}
    RESMGR:LoadObject{objectTemplate = 14024  , x = pos.x , y =  pos.y , z = pos.z , owner = self, configData = config}
   
end

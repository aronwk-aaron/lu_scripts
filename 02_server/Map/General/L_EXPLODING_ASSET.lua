------------------------------------------------
-- Server script for a smashable asset that blows the player up if the player melee's it.
-- also, on smash kills all enemies in close proximity
-- copied from bomb script created by MEdwards, and generized to use in more cases

-- created by Brandi... 11/15/10
-- Updated By Medwards... 8/25/11 -- Added team mission updated to the Update mission message
------------------------------------------------

--*******************************************************
-- for a mission assicaited with this asset, in the config data put
-- missionID 1:####
-- for achievements associated with this assest (can have multiples), in the config data put
-- achieveID 0:####_####_####_####_#### (put an _ between each achievement number)
--*******************************************************

function onStartup(self) 
    self:SetProximityRadius { radius = 20 }
    self:SetVar("playersNearChest", 0)
    self:SetProximityRadius { radius = 10 ,name = "crateHitters" }
end

function onOnHit(self, msg)
    local player = msg.attacker
    if not self:GetVar("bIsHit") then
    ------------------------------
    -- Used to make the smasher of the crate be killed if they are too close
        local foundObj = self:GetProximityObjects{ name = "crateHitters" }.objects
        for i = 1, table.maxn (foundObj) do  
                if foundObj[i]:GetID() == player:GetID() then
                    player:RequestDie()
                   --break 
                end
        end
    --------------------------------
        self:SetVar("bIsHit" , true)
        --self:CastSkill{skillID = 147, optionalOriginatorID =  player} --self:GetSkills().skills[1] }  -- has skill 147 (aoe that deals 2 damage)
        self:CastSkill{skillID = self:GetSkills().skills[1], optionalOriginatorID =  player}
        self:PlayEmbeddedEffectOnAllClientsNearObject{ radius = 16.0, fromObjectID = self, effectName = "camshake" }
        self:Die()
  
		local missionID = self:GetVar("missionID")
		if missionID then
			--update the mission related to the crates
			player:UpdateMissionTask {taskType = "complete", value = missionID, value2 = 1, target = self, bUpdateTeam = true} 
		end
		
		local achieveIDs = self:GetVar("achieveID") 
		if achieveIDs then
			achieveIDs = split(achieveIDs, "_") 
			--update the achievements related to the crates
			for k,v in ipairs(achieveIDs) do
				v = tonumber(v)
				player:UpdateMissionTask{taskType = "complete", value = v, value2 = 1, target = self, bUpdateTeam = true}
			end
		end
    end
end

-- Plays a shake when a player is close
function onProximityUpdate(self, msg)
	if msg.objId:BelongsToFaction{factionID = 1}.bIsInFaction then
		if (msg.status == "ENTER") then
			self:PlayAnimation{ animationID = "bounce" }
			self:PlayFXEffect{ name = "bouncin", effectType = "anim" }
			self:SetVar("playersNearChest", (self:GetVar("playersNearChest") + 1 ))
		elseif (msg.status == "LEAVE") then
			self:SetVar("playersNearChest", (self:GetVar("playersNearChest") - 1 ))
			if self:GetVar("playersNearChest") < 1 then
				self:PlayAnimation{ animationID = "idle" }
				self:StopFXEffect{ name = "bouncin" }
				self:SetVar("playersNearChest", 0)
			end
		end
	end
end

function split(str, pat)
    local t = {}
    -- Creates a table of strings based on the passed in pattern   
    string.gsub(str .. pat, "(.-)" .. pat, function(result) table.insert(t, result) end)

    return t
end
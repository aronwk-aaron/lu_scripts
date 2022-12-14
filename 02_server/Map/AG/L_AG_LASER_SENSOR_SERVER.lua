--------------------------------------------------------------

-- L_AG_LASER_SENSOR_SERVER.lua

-- Server side script for the monument laser beam sensors
-- created abeechler ... 7/18/11

--------------------------------------------------------------

local defaultRepelForce = -25      -- Amount to push the touch player away
local defaultSkillCastID = 163     -- Skill to cast on the touch player

----------------------------------------------------------------
-- On Startup, process necessary instantiation events
----------------------------------------------------------------
function onStartup(self)
    -- Obtain a config data repel value, or use the object default
    local repel = self:GetVar("repelForce") or defaultRepelForce
    -- Set-up a basic push force effect
    self:SetPhysicsVolumeEffect{EffectType = 'REPULSE', amount = repel}
end

----------------------------------------------------------------
-- Catch collision events and process for skill casts
----------------------------------------------------------------
function onCollisionPhantom(self, msg)
    -- Obtain a config data skill to cast, or use the object default
    local skillCastID = self:GetVar("skillCastID") or defaultSkillCastID
    -- Cast the skill on the colliding player
    local bCast = self:CastSkill{skillID = skillCastID, optionalTargetID = msg.objectID}.succeeded
end

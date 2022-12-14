--------------------------------------------------------------

-- L_AG_MONUMENT_LASER_SERVER.lua

-- Server side script for the monument laser beams
-- created abeechler ... 7/18/11

--------------------------------------------------------------

----------------------------------------------
-- Object instantiation catch
----------------------------------------------
function onPhysicsComponentReady(self, msg)
    -- Obtain a group to process for sensor volumes
    local volGroup = self:GetVar("volGroup") or false

    if(volGroup) then 
	    -- Turn ON every volume object from a config data defined group
	    activateGroup(self, volGroup, true)
	end
end

----------------------------------------------
-- Catch object destruction
----------------------------------------------
function onDie(self, msg)
    -- Obtain a group to process for sensor volumes
    local volGroup = self:GetVar("volGroup") or false
    
    if(volGroup) then
        -- Turn OFF every volume object from a config data defined group
	    activateGroup(self, volGroup, false)
	end
end

----------------------------------------------
-- Process group object activatation based on 
-- parameter status
----------------------------------------------
function activateGroup(self, group, bOn)
    -- Obtain the objects within the desired group
    local groupObjects = self:GetObjectsInGroup{group = group, ignoreSpawners = true}.objects
    -- Iterate through the objects and process for desired activation type
    for i, obj in ipairs(groupObjects) do
        local exists = obj:Exists()
	    if exists then
	        -- Activate/deactivate object triggers and physics
	       obj:ActivatePhysics{bActivate = bOn}
	    end
	end
end

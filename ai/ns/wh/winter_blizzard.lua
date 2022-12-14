--------------------------------------------------------------
-- Adds blizzard effects while in this volume.
--
-- created pml... 11/10/10
-- updated abeechler ... 10/20/11 
--------------------------------------------------------------


function onCollisionPhantom(self, msg)
	local player = GAMEOBJ:GetControlledID()
	if(msg.objectID:GetID() == player:GetID()) then
	    -- We are the instigating player, fire up the snow
        LEVEL:AttachCameraParticles("environment/frostburgh_blizzard/frostburgh_blizzard", { x = 0, y = 0, z = 3 })
    end
end


function onOffCollisionPhantom(self, msg)
    local player = GAMEOBJ:GetControlledID()
	if(msg.objectID:GetID() == player:GetID()) then
	    -- We are the instigating player, stop the snow
	    LEVEL:DetachCameraParticles("environment/frostburgh_blizzard/frostburgh_blizzard")
	end
end 
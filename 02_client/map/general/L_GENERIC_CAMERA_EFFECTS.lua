--------------------------------------------------------------
-- Generic client-side script for a camera fx
-- 
-- created austin... 10/21/11
--------------------------------------------------------------


-- We start our effect when we hit the collision phantom
function onCollisionPhantom(self, msg)
	local player = GAMEOBJ:GetControlledID()
	if msg.objectID:GetID() == player:GetID() then
		--print("onCollisionPhantom")
		LEVEL:AttachCameraParticles( self:GetVar("camera_effect"), { x = 0, y = 0, z = 3 } )
	end
end

-- We disable our effect when we leave the collision phantom
function onOffCollisionPhantom(self, msg)
	local player = GAMEOBJ:GetControlledID()
	if msg.objectID:GetID() == player:GetID() then
		--print("offCollisionPhantom")
		LEVEL:DetachCameraParticles( self:GetVar("camera_effect") )
		
	end
end 
--------------------------------------------------------------
-- Changes the gravity on smashable bricks back to normal
-- created seraas... 8/24/10
--------------------------------------------------------------


function onCollisionPhantom(self, msg)
	--print("onCollisionPhantom")
	local vehicle = msg.objectID
	
    vehicle:SetSmashableGravityFactor{fGravityFactor = 1.0}

end


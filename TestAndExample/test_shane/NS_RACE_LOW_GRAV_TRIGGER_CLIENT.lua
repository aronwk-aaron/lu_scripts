--------------------------------------------------------------
-- Changes the gravity on smashable bricks back to normal
-- created seraas... 8/24/10
--------------------------------------------------------------


function onCollisionPhantom(self, msg)
	local vehicle = msg.objectID

	-- do your normal "make things icy" stuff here
	
	-- set the surface type to SurfaceType_Ice, aka 11
	-- you can do this same thing in snowbanks using 10 for Type_Snow
    vehicle:VehicleSetSurfaceTypeOverride{iSurfaceType = 11}

end


function onOffCollisionPhantom(self, msg)
	local vehicle = msg.objectID

	-- do your normal "make things normal" stuff here
	
	-- setting the override back to "none" so the vehicle does normal surface detection again
    vehicle:VehicleSetSurfaceTypeOverride{iSurfaceType = 0}

end

-----------------------------------------------------------
-- server-side script for the skateboard mount rail
-----------------------------------------------------------

function onCollisionPhantom(self, msg)
   
	print("hit rail phantom")
   
    local target = msg.objectID
   
	target:StartRailMovement{pathName="Truck_rail_1", pathStart=0, pathGoForward=false, railActivatorComponentID=11, railActivatorObjID=self, collisionEnabled=false}

end
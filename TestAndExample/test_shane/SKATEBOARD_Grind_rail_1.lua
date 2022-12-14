-----------------------------------------------------------
-- server-side script for the skateboard mount rail
-----------------------------------------------------------

function onCollisionPhantom(self, msg)
   
	print("hit rail phantom")
   
    local target = msg.objectID
   
	if target:GetIsOnRail().bIsOnRail == false then
		target:StartRailMovement{pathName="Grind_rail_1", pathStart=0, pathGoForward=true, railActivatorComponentID=10, railActivatorObjID=self, collisionEnabled=false}
	end

end
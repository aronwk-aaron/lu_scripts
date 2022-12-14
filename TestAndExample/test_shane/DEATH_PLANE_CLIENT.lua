-----------------------------------------------------------
-- client-side script for the Gnarled Forest death plane
-----------------------------------------------------------

function onCollisionPhantom(self, msg)
   
	--print("hit death phantom")
   
    local target = msg.objectID
   
	if ( target:GetID() == GAMEOBJ:GetControlledID():GetID() ) then

		--print("calling cinematic")
		local player = GAMEOBJ:GetObjectByID(GAMEOBJ:GetLocalCharID())
		player:PlayCinematic { pathName = "DeathVol1" }
		
	end

end
--------------------------------------------------------------
-- Adding new animation name for lava death trigger
-- arandall... 8/25/11


--------------------------------------------------------------

local deathAnimation = "drown" 

function onCollisionPhantom(self, msg)

	local obj = msg.objectID
    
	if obj:BelongsToFaction{factionID = 1}.bIsInFaction then
	
		obj:RequestDie{killerID = self, deathType = deathAnimation}
		
	else
	
		obj:RequestDie{killerID = self}
		
	end
	
end
--------------------------------------------------------------

-- L_NT_IMAGIMETER_VISIBILITY_SERVER.lua

-- Server side NT Imagimeter Plinth script
-- Process character flag updates, rebuild status, and static object visibility
-- created abeechler ... 4/14/11

--------------------------------------------------------------

local plinthRebuiltFlag = 1919      -- Player flag representing the rebuild state of the Imagineter Plinth

----------------------------------------------
-- Check to see if the player has rebuilt the plinth
----------------------------------------------
function onRebuildComplete(self, msg)
	-- Set the player flag to true
	local player = msg.userID
	
	player:SetFlag{iFlagID = plinthRebuiltFlag, bFlag = true}
	
	-- Tell the client script that the plinth was built
	self:NotifyClientObject{name = "PlinthBuilt",  rerouteID = player}
end

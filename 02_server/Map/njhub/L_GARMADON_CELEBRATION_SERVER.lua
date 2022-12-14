--------------------------------------------------------------
-- server side script to play the Lord Garmadon reveal
-- 
-- updated abeechler ... 8/11/11 - factored in new play celebration method
--------------------------------------------------------------

local garmadonCFlagID = 125     -- Flag designating player celebration view status
local garmadonCelebID = 23      -- ID value for the Garmadon celebration

function onCollisionPhantom(self,msg)
	local player = msg.objectID 
	-- make sure the player hasnt already seen the celebration
	if player:GetFlag{iFlagID = garmadonCFlagID}.bFlag then return end
	-- set player flag to the variable
	player:SetFlag{iFlagID = garmadonCFlagID, bFlag = true} 
	
	-- start the celebration!
	player:StartCelebrationEffect{celebrationID = garmadonCelebID, rerouteID = player}
end

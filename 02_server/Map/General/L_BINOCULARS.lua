--------------------------------------------------------------
-- Server side Script on the Binoculars
-- updates the achievement
-- 
-- updated abeechler ... 7/27/11 - refactored scripts and added onHit exit interact functionality
--------------------------------------------------------------

----------------------------------------------
-- Called on successful use
----------------------------------------------			 
function onUse(self, msg)
    -- Get number off the binoculars asset, this should be set in HF
	local number = self:GetVar('number') or false
	-- Only proceed if the player actually set the number in happy flower
	if(not number) then return end
	
	-- Get the map number and the player
	local map = LEVEL:GetCurrentZoneID()
	local player = msg.user
	local possessor = msg.user:GetPossessor().possessorID
	if possessor:Exists() then
		player = possessor
	end
	-- Split the map number to just get the first 2 digits
	local newmap =string.sub(map,0,2)
	
	-- Take the first 2 digits of the map number and put it with 
	-- the number on the binoc in HF to create the flag number
	local flagNumber = tonumber(newmap .. number)
		
	-- Check to see if the player has used this binocular before
	if(not player:GetFlag{iFlagID = flagNumber}.bFlag) then  
		-- Set flag to true so we know the player has alread done this, turn off the effect
		player:SetFlag{iFlagID = flagNumber, bFlag = true} 
		-- Tell the client to stop the fx on the binocular
		self:FireEventClientSide{args = 'achieve', rerouteID = player}
	end

end

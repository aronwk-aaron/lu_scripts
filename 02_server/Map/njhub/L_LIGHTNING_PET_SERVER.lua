--------------------------------------------------------------
-- Server side script on the earth pet, sets a precondition to taming it

-- created by Brandi... 3/2/11
--------------------------------------------------------------

require('02_server/Pets/L_PET_FROM_OBJECT_SERVER')

function onStartup(self,msg)
	-- doing this because SetNetworkVar is busted and unserialized 
	if not self:IsPetWild{}.bIsPetWild then return	end	
	-- add the precondition so the player need shocko taco to tame the lightning pet
	self:SetPreconditions{ Preconditions = "357" }
	baseOnStartup(self)
end
--------------------------------------------------------------
-- Client side script on the lightning pet, sets a precondition to taming it

-- created by Brandi... 3/2/11
--------------------------------------------------------------

require('02_client/Pets/L_PET_FROM_DIG_CLIENT')

function onStartup(self,msg)
	-- doing this because SetNetworkVar is busted and unserialized 
	if not self:IsPetWild{}.bIsPetWild then return	end	
	-- add the precondition so the player need shocko taco bar to tame the lightning pet
	self:SetPreconditions{ Preconditions = "357" }
end
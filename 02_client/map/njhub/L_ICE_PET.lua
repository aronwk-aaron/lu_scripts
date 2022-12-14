--------------------------------------------------------------
-- Client side script on the ice pet, sets a precondition to taming it

-- created by Brandi... 3/2/11
--------------------------------------------------------------

require('02_client/Pets/L_PET_FROM_DIG_CLIENT')

function onStartup(self,msg)
	-- doing this because SetNetworkVar is busted and unserialized 
	if not self:IsPetWild{}.bIsPetWild then return	end	
	-- add the precondition so the player need cold pizza to tame the ice pet
	self:SetPreconditions{ Preconditions = "358" }
end
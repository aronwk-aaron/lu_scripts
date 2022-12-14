--------------------------------------------------------------

-- L_PRECON_INTERACT_CHECK_SERVER.lua

-- Generic interact utility script adding server-side use requirement 
-- precondition checks to an object.
-- created abeechler ... 2/17/11

--------------------------------------------------------------

----------------------------------------------
-- Check to see if the player can use the hook-swing
----------------------------------------------
function onCheckUseRequirements(self,msg)
	local player = msg.objIDUser
	-- Obtain preconditions
	local preConVar = self:GetVar("CheckPrecondition")
    
    if preConVar and preConVar ~= "" then
		-- We have a valid list of preconditions to check
		local check = player:CheckListOfPreconditionsFromLua{PreconditionsToCheck = preConVar, requestingID = self}
        
		if not check.bPass then 
			msg.bCanUse = false
		end
	end
    
    return msg
end

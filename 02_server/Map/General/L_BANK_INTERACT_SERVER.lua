--------------------------------------------------------------

-- L_BANK_INTERACT_SERVER.lua

-- Script that adds interactive bank UI functionality to an object
-- created abeechler ... 3/2/11

--------------------------------------------------------------

----------------------------------------------
-- Check to see if the player can use bank
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

----------------------------------------------
-- Sent when the local player interacts with the
-- object
----------------------------------------------
function onUse(self, msg) 
	local player = msg.user
    
    player:UIMessageServerToSingleClient{strMessageName = "pushGameState",  args = {{"state", "bank"}}}
    self:NotifyClientObject{name = "OpenBank", rerouteID = player}
end 

----------------------------------------------
-- Sent when the local bank interaction
-- is terminated
----------------------------------------------
function onFireEventServerSide(self, msg) 
	local player = msg.user
	
    if msg.args == "ToggleBank" then
        -- Turn OFF Bank UI
        msg.senderID:UIMessageServerToSingleClient{strMessageName = "ToggleBank",  args = {{"visible", false}}}
        self:NotifyClientObject{name = "CloseBank", rerouteID = player}
    end
end

--------------------------------------------------------------

-- L_MAIL_BOX_SERVER.lua

-- Server script for the Mail Box
-- Created abeechler... 3/3/11

--------------------------------------------------------------

----------------------------------------------
-- Sent when the local player interacts with the
-- object
----------------------------------------------
function onUse(self, msg) 
	local player = msg.user
    
    player:UIMessageServerToSingleClient{strMessageName = "pushGameState",  args = {{"state", "Mail"}}}
    self:NotifyClientObject{name = "OpenMail", rerouteID = player}
end 

----------------------------------------------
-- Sent when the local mailbox interaction
-- is terminated
----------------------------------------------
function onFireEventServerSide(self, msg)  
	local player = msg.user
	
    if msg.args == "toggleMail" then
        -- Turn OFF Mail UI
        msg.senderID:UIMessageServerToSingleClient{strMessageName = "ToggleMail",  args = {{"visible", false}}}
        self:NotifyClientObject{name = "CloseMail", rerouteID = player}
    end
end

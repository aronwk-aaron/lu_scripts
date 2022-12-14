----------------------------------------
-- Server side script on the door indicators in the fire temple. 
-- They only ever turn on, but could turn on for activated or deactived, depending on the puzzle
--
-- created by brandi... 10/4/11
----------------------------------------


-- to work with spinners
function onFireEvent(self,msg)
    if msg.args == self:GetVar("name_deactivated_event") then
		self:SetNetworkVar("FlameOn",true)
    elseif msg.args == self:GetVar("name_activated_event") then
		self:SetNetworkVar("FlameOn",true)
    end
end
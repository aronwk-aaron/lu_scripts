---------------------------------------------
-- script on the ninjago rail switch
--
-- created by mrb... 11/30/10
---------------------------------------------

function onObjectActivated(self, msg)
	local path = self:GetRailInfo{}
	
	-- if we have path info then start the player moving on it
	if path then
		msg.activatorID:SetRailMovement{pathName=path.pathName, pathStart=path.pathStart, pathGoForward=path.pathGoForward}
	end
	
	local cineName = self:GetVar("cinematic")
	
	-- if we have a cinematic in the config data then play it
	if cineName then 
		msg.activatorID:PlayCinematic{pathName = cineName}
	end
end 
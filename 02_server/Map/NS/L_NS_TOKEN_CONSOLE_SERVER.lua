--------------------------------------------------------------
-- server side script for the paradox faction token console in NS
-- relies on the general token console script 

-- created by Brandi... 4/14/11
--------------------------------------------------------------

require('02_server/Map/General/L_TOKEN_CONSOLE_SERVER')

-- set the mision to update for this console
local MissionID = {863}

function onStartup(self,msg)
	-- because this is a quickbuild, the preconddition has to be set in script, otherwise it would apply to the quickbuild itself
	self:SetVar("CheckPrecondition","47;187;185")
	-- send the variables to the base script
	setVariables(MissionID)
end


function onCheckUseRequirements(self,msg)
	-- to make sure the player isn't interacting with the object just to quickbuild it
	-- state 2 means the quickbuild is complete
	if self:GetRebuildState{}.iState == 2 then
		baseCheckUseRequirements(self,msg)
		
		return msg
	end
end

function onUse(self,msg)
	-- to make sure the player isn't interacting with the object just to quickbuild it
	-- state 2 means the quickbuild is complete
	if self:GetRebuildState{}.iState == 2 then
		baseUse(self,msg)
	end
end
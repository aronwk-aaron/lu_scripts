--------------------------------------------------------------

-- L_FV_DRAGON_RONIN.lua

-- Custom functionality necessary for dragon spawned Ronin
-- Created abeechler... 2/7/11

-------------------------------------------------------------

require('02_server/Enemy/General/L_COUNTDOWN_DESTROY_AI')

function onStartup(self)
	-- Set the suicide timer to the appropriate value to circumvent the default
	self:SetVar("suicideTimer", 40)
	
	countdownStartup(self)
end

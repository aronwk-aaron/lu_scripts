----------------------------------------
-- Server side script on the enemies in the coffins in the siege field, 
-- they need both base scripts on them
--
-- created by brandi... 6/8/11
-------------------------------------------------------------


require('02_server/Enemy/General/L_COUNTDOWN_DESTROY_AI')
require('02_server/Enemy/General/L_ENEMY_NJ_BUFF')

function onStartup(self,msg)
	baseStartup(self)
	countdownStartup(self)
end
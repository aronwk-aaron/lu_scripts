--------------------------------------------------------------
-- server side script on the dirt clouds in NT
--
-- created by Brandi - 4/1/11... need to add daily missions when they get created
--------------------------------------------------------------
require('02_server/Map/General/L_VIS_TOGGLE_NOTIFIER_SERVER')

-- Table mapping mission IDs to spawner network names
local VisibilityMissionTable = {[1253] = {"Dirt_Clouds_Sent"},
                                [1276] = {"Dirt_Clouds_Assem"},
                                [1277] = {"Dirt_Clouds_Para"},
                                [1283] = {"Dirt_Clouds_Halls"}}

----------------------------------------------------------------
-- Catch object instantiation
----------------------------------------------------------------                   
function onStartup(self)

	setGameVariables(self, VisibilityMissionTable)
	
end 
			
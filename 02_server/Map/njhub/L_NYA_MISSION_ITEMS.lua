----------------------------------------
-- Server side script on Nya that removes an item on mission completion
--
-- created by brandi... 6/16/11
----------------------------------------

require('02_server/Map/General/L_NPC_MISSION_ADD_REMOVE_ITEM')
-- Associate inventory items to dispense on keyed mission ID values.
local MissionItemTable = 	{
								[1821] = 	{{items = {14500}, add = false, remove = true}},
								[1809] = 	{{items = {14472}, add = true, remove = false}}
							}					
--------------------------------------------------------------
---- Catch object instantiation
--------------------------------------------------------------                  
function onStartup(self)
	setMissionVariables(self, MissionItemTable)	
end 
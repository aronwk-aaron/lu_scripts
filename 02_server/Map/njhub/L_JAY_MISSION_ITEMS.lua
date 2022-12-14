----------------------------------------
-- Server side script on Nya that removes an item on mission completion
--
-- created by brandi... 6/16/11
----------------------------------------

require('02_server/Map/General/L_NPC_MISSION_ADD_REMOVE_ITEM')
require('02_server/Map/njhub/L_NPC_MISSION_SPINJITZU_SERVER')

-- Associate inventory items to dispense on keyed mission ID values.
local MissionItemTable = 	{
								[1789] = 	{{items = {14474}, add = false, remove = true}},	-- only add on accept
								[1927] =	{{items = {14493}, add = false, remove = true}}  
							}					
--------------------------------------------------------------
---- Catch object instantiation
--------------------------------------------------------------                  
function onStartup(self)
	setMissionVariables(self, MissionItemTable)	
end 

function onMissionDialogueOK(self,msg)
	spinMissionDialogueOK(self,msg)
	baseMissionDialogueOK(self, msg)
end
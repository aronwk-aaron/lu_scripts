--------------------------------------------------------------
-- Server side script on the pet dig for the dragon bone
--
-- updated mrb... 1/17/11 - call baseStartup
--------------------------------------------------------------
require('02_server/Map/General/PET_DIG_SERVER')

local specificPetLOTs = { 13067 }        

local missionRequirements = {
								{ 	
									ID	 	= 1299,
									state 	= 4
								},
								{
									ID	 	= 1299,
									state 	= 1
								},
								{
									ID	 	= 1299,
									state 	= 0
								}
							}

function onStartup(self,msg)
	setPetVariables(specificPetLOTs,missionRequirements)
	baseStartup(self)
end 
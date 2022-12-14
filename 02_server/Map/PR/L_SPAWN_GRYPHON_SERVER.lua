--------------------------------------------------------------
-- Server side script to spawn a gryphon

-- created by Brandi... 3/2/11
--------------------------------------------------------------

require('02_server/Map/General/L_SPAWN_PET_BASE_SERVER')

--------------------------------------------------------------
-- set up all the variables needed
--------------------------------------------------------------
local petLOT = 12433 -- lot number of the pet to be spawned
local petType = "gryphon"	-- name of the type of pet to be spawned
local maxPets = 2 -- number of the maximun number of pets to be spawned at one time
local spawnAnim = "spawn"
local spawnCinematic = "SentinelPet"
local missionItem = 12483

--------------------------------------------------------------
-- on startup, put all variables to set vars
--------------------------------------------------------------
function onStartup(self,msg)
	self:SetVar("petLOT",petLOT)
	self:SetVar("petType",petType)
	self:SetVar("maxPets",maxPets)
	self:SetVar("spawnAnim",spawnAnim)
	self:SetVar("spawnCinematic",spawnCinematic)
	baseStartup(self,msg)
end

function onUse(self,msg)
	local player = msg.user
	
	if player:GetMissionState{missionID = 1391}.missionState == 2 then
		if (player:GetInvItemCount{ iObjTemplate = missionItem}.itemCount >= 1) then 
            player:RemoveItemFromInventory{iObjTemplate = missionItem}
        end
		player:TerminateInteraction{type = 'fromInteraction', ObjIDTerminator = self}
		return
	end
	
	baseUse(self,msg)
end



--------------------------------------------------------------
-- Server side script to spawn a sabercat

-- created by Brandi...  3/2/11
--------------------------------------------------------------

require('02_server/Map/General/L_SPAWN_PET_BASE_SERVER')

--------------------------------------------------------------
-- set up all the variables needed
--------------------------------------------------------------
local petLOT = 12432 -- lot number of the pet to be spawned
local petType = "sabercat"	-- name of the type of pet to be spawned
local maxPets = 3 -- number of the maximun number of pets to be spawned at one time
local spawnAnim = "pq_m_drop-down"
local spawnCinematic = "AssemblyPet"

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


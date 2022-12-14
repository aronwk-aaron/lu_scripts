--------------------------------------------------------------
-- Server side script to spawn a sabercat

-- created by Brandi...  3/2/11
--------------------------------------------------------------

require('02_server/Map/General/L_SPAWN_PET_BASE_SERVER')

local petLOT = 3520 -- lot number of the pet to be spawned
local petType = "lion"	-- name of the type of pet to be spawned
local maxPets = 5 -- number of the maximun number of pets to be spawned at one time
local spawnAnim = "spawn-lion"
local spawnCinematic = "Lion_spawn"

function onStartup(self,msg)
	self:SetVar("petLOT",petLOT)
	self:SetVar("petType",petType)
	self:SetVar("maxPets",maxPets)
	self:SetVar("spawnAnim",spawnAnim)
	self:SetVar("spawnCinematic",spawnCinematic)
	baseStartup(self,msg)
end


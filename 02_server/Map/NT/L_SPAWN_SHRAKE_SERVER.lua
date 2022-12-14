--------------------------------------------------------------
-- Server side script to spawn a shrake

-- created by Brandi...  3/2/11
--------------------------------------------------------------

require('02_server/Map/General/L_SPAWN_PET_BASE_SERVER')

--------------------------------------------------------------
-- set up all the variables needed
--------------------------------------------------------------
local petLOT = 12434 -- lot number of the pet to be spawned
local petType = "shrake"	-- name of the type of pet to be spawned
local maxPets = 3 -- number of the maximun number of pets to be spawned at one time
local spawnAnim = "mf_u_g_TT_spawn-1"
local spawnCinematic = "ParadoxPet"

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


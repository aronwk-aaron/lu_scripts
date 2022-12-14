--------------------------------------------------------------
-- Server side script to spawn a sabercat

-- created by Brandi...  3/2/11
-- modified by Austin... 10/12/11
-- added cinematic name
--------------------------------------------------------------

require('02_server/Map/njhub/L_NINJAGO_PETS_SPAWNER')

--------------------------------------------------------------
-- set up all the variables needed
--------------------------------------------------------------
local petLOT = 16741 -- lot number of the pet to be spawned
local petType = "firepet"	-- name of the type of pet to be spawned
local maxPets = 3 -- number of the maximun number of pets to be spawned at one time
--local spawnAnim = "spawn" -- animation name for the pet to spawn in with
local spawnCinematic = 'FirePetSpawn'  -- name of camera path for the spawn in
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
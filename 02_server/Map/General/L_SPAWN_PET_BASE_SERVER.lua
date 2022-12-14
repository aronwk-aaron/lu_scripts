--------------------------------------------------------------
-- Server side script on the object to spawn the lion pet
-- lion has to be spawned for a server side script because the lion is a pet to be tamed
-- pet taming minigame runs on the server as well as the client

-- created by Brandi... 2/17/10
--------------------------------------------------------------

local petLOT = 0 -- lot number of the pet to be spawned
local petType = ''	-- name of the type of pet to be spawned
local maxPets = 1 -- number of the maximun number of pets to be spawned at one time
local spawnAnim = "spawn" -- animation name for the pet to spawn in with
local spawnCinematic = ''  -- name of camera path for the spawn in

--------------------------------------------------------------
-- if a script is attached, call SetVariables
--------------------------------------------------------------
function baseStartup(self,msg)
	SetVariables(self)
end

--------------------------------------------------------------
-- called when the physics  component is done loading
--------------------------------------------------------------
function onPhysicsComponentReady(self,msg)
	-- check one of the variables, to see if SetVariables run yet
	if not self:GetVar("PetsSpawned") then
		SetVariables(self)
	end
end

--------------------------------------------------------------
-- Custom Function: pull in variables either from the script on the pet, or they can be set has config data on the object
-- the player interacts with to spawn in the pet
--------------------------------------------------------------
function SetVariables(self)
	petLOT = self:GetVar("petLOT")
	if not petLOT then
		debugPrint(self,"You need a pet lot defined. Please add a pet lot to spawn to either config data, or the script")
		return
	end
	petType = self:GetVar("petType") or self:GetLOT().objtemplate
	maxPets = self:GetVar("maxPets") or 2
	spawnAnim = self:GetVar("spawnAnim") or "spawn"
	spawnCinematic = self:GetVar("spawnCinematic")
	-- keep track of how many pets are spawned from this object
	self:SetVar("PetsSpawned",0)
end

--------------------------------------------------------------
-- make sure the player is really allowed to interact with the object
--------------------------------------------------------------
function CheckUseRequirements(self,msg)

	-- get preconditions set on the object through the db
	local preConVar = self:GetVar("CheckPrecondition")

	-- if there is a precondition and it isnt blank
	if preConVar and preConVar ~= "" then
		-- We have a valid list of preconditions to check
		local check = msg.objIDUser:CheckListOfPreconditionsFromLua{PreconditionsToCheck = preConVar, requestingID = self}
		-- the the player didnt pass the precondition, then they cant use the object
		if not check.bPass then 
					
			msg.bCanUse = false
			return msg
		end
	end
	
	-- get the player
	local player = msg.objIDUser
	-- get all pets spawned by this object
	local pets = self:GetObjectsInGroup{ group = petType.."s", ignoreSpawners = true }.objects
	-- get a player pet if one exists
	local playerPet = self:GetObjectsInGroup{ group = petType..player:GetID(), ignoreSpawners = true }.objects
	
	-- check to see if the player already has a pet out, or there are more pets out than pets allowed
	if #playerPet > 0 or #pets > maxPets then 
		msg.bCanUse = false
	end
			
	return msg 

end

function onUse(self,msg)
	baseUse(self,msg)
end

--------------------------------------------------------------
-- when the players uses the object
--------------------------------------------------------------
function baseUse(self,msg)
	-- custom function to spawn the pet
	SpawnPet(self,msg)
	-- terminate the interaction for the player
	msg.user:TerminateInteraction{type = 'fromInteraction', ObjIDTerminator = self}
end

--------------------------------------------------------------
-- Custom Function: spawns the pet
--------------------------------------------------------------
function SpawnPet(self,msg)
	
	-- get the object placed where the pet is supposed to spawn
	local ToSpawnLoc = self:GetObjectsInGroup{ group = petType.."Spawner", ignoreSpawners = true}.objects[1]
	-- if there is not object, then cancel out
	if not ToSpawnLoc then 
		debugPrint(self,"Cant find your spawner object. Either you dont have one in HF, or your pet Type and the group name don't match")
		return
	end
	
	-- get the location and the rotation of the spawner object
	local mypos = ToSpawnLoc:GetPosition().pos
	local myrot = ToSpawnLoc:GetRotation()
	
	-- get the player
	local player = msg.user
	
	--set the tamer as the player to check that only this player can tame that lion
	-- and set the group id to include the player id to make sure this player can only spawn one lion at a time
	-- set the spawn animation so the pet will play a different animation when it spawns in
	local config = { { "tamer", player:GetID() } , { "groupID", petType..player:GetID()..";"..petType.."s" }, {"spawnAnim", spawnAnim}, {"spawnTimer", 1.0}}
	
	-- spawn the new pet
	RESMGR:LoadObject { objectTemplate =  petLOT, x = mypos.x , y = mypos.y , z = mypos.z , rw = myrot.w, rx = myrot.x, ry = myrot.y , rz = myrot.z, owner = self, configData = config }
    
    -- play the cinematic showing the new pet spawn
    if spawnCinematic then
		player:PlayCinematic { pathName = spawnCinematic }
	end
	
end

--------------------------------------------------------------
-- when a pet has loaded into the world, call custom function to talk to the client
--------------------------------------------------------------
function onChildLoaded(self,msg)
	baseChildLoaded(self,msg)
end

function baseChildLoaded(self,msg)
	TalkToClient(self,msg,true,1)
end

--------------------------------------------------------------
-- when a pet has left the world, call custom function to talk to the client
--------------------------------------------------------------
function onChildRemoved(self,msg)
	baseChildRemoved(self,msg)
end

function baseChildRemoved(self,msg)
	TalkToClient(self,msg,false,-1)
end

--------------------------------------------------------------
-- when a pet has been tamed, call custom function to talk to the client
--------------------------------------------------------------
function onChildDetached(self,msg)
	baseChildDetached(self,msg)
end

function baseChildDetached(self,msg)
	TalkToClient(self,msg,false,-1)
end

--------------------------------------------------------------
-- Custom Function: tells the client script that a pet has spawned
--------------------------------------------------------------
function TalkToClient(self,msg,bAdded,numToAdd)

	-- get how many pets have been spawned
	local petsSpawned = self:GetVar("PetsSpawned")
	
	
	petsSpawned = petsSpawned + numToAdd
	self:SetVar("PetsSpawned", petsSpawned)
	
	local child = msg.childID
	local player = GAMEOBJ:GetObjectByID(child:GetVar("tamer"))
	
	if bAdded then
		self:NotifyClientObject{name = "tooManyPets", param1 = 1, rerouteID = player}
		
		if petsSpawned >= maxPets then
			self:SetNetworkVar("TooManyPets",true)
		end
	elseif not bAdded then
		self:NotifyClientObject{name = "tooManyPets", param1 = 0, rerouteID = player}
		
		if petsSpawned < maxPets then
			self:SetNetworkVar("TooManyPets",false)
		end
	end

end

--------------------------------------------------------------
-- Custom Function: print function that only works in an internal build
--------------------------------------------------------------
function debugPrint(self, text)	
	if self:GetVersioningInfo().bIsInternal then
		print(text)
	end
end
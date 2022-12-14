--------------------------------------------------------------
-- Universal server script for all pet digs. 
-- 
-- created by brandi 3/2/10
-- updated abeechler ... 6/30/11 - free trial pre-con check
--------------------------------------------------------------

local digData = 
{ 	-- FORMAT: PD_Normal = 	{digLOT = LOT # of this object, 
	--						 spawnLOT = LOT # of thing to spawn(-1 = dont use), 
	--						 spawnMission = MissionID needed to spawn an object from this dig(-1 = dont use), 
	--						 bSpecificPet = bool if this uses a specific pet, 
	-- 						 bXBuild = bool if this is an X build, 
	--						 bBouncer = bool if this spawns a bouncer, 
	--						 bBuilderOnly = bool if the person who build the pet dig is the only one who can use it},
	PD_Normal = 	{digLOT = 3495, spawnLOT = -1, spawnMission = -1, bSpecificPet = false, bXBuild = false, bBouncer = false, bBuilderOnly = false},
	PD_PetCove = 	{digLOT = 7612, spawnLOT = -1, spawnMission = -1,  bSpecificPet = false, bXBuild = false, bBouncer = false, bBuilderOnly = false},
	PD_GF_Flag = 	{digLOT = 7410, spawnLOT = -1, spawnMission = -1,  bSpecificPet = false, bXBuild = true, bBouncer = false, bBuilderOnly = false},
	PD_GF_Crab = 	{digLOT = 9308, spawnLOT = 7694, spawnMission = -1,  bSpecificPet = false, bXBuild = false, bBouncer = false, bBuilderOnly = false},
	PD_AG_Mis = 	{digLOT = 9307, spawnLOT = -1, spawnMission = -1,  bSpecificPet = false, bXBuild = true, bBouncer = false, bBuilderOnly = true},
	PD_AG_Bouncer = {digLOT = 7559, spawnLOT = -1, spawnMission = -1,  bSpecificPet = false, bXBuild = false, bBouncer = true, bBuilderOnly = false},
	PD_CP_Dragon = 	{digLOT = 13098, spawnLOT = 13067, spawnMission = 1298,  bSpecificPet = false, bXBuild = false, bBouncer = false, bBuilderOnly = false},
	PD_CP_Bone = 	{digLOT = 12192, spawnLOT = -1, spawnMission = -1,  bSpecificPet = true, bXBuild = false, bBouncer = false, bBuilderOnly = false},
}
				
local specificPetLOTs = {}
local missionRequirements = {}

function setPetVariables(passedspecificPetLOTs,passedmissionRequirements)
	specificPetLOTs = passedspecificPetLOTs
	missionRequirements = passedmissionRequirements	
end

function onStartup(self)
	baseStartup(self)
end

function baseStartup(self, newMsg)	
	local objLot = self:GetLOT().objtemplate
	local digInfo = {}
	
	-- set the digType for later use
	for type, data in pairs(digData) do
		if data.digLOT == objLot then
			self:SetVar("digType", type)
			digInfo = data
			
			break
		end
	end
	
	if not digInfo.digLOT  then
		digInfo = digData.PD_Normal
	end
	
	if digInfo.bBouncer then -- if the treause node is one that digs up a pet bouncer 
		local bouncerNumber = self:GetVar("BouncerNumber") -- set in HF
		local petbouncer = LEVEL:GetSpawnerByName("PetBouncer"..bouncerNumber)
		local petbouncerswitch = LEVEL:GetSpawnerByName("PetBouncerSwitch"..bouncerNumber)

		-- on startup, deactivate and reset the spawner networks for the pet bouncer and pet switch
		petbouncer:SpawnerDeactivate()
		petbouncerswitch:SpawnerDeactivate()
		petbouncer:SpawnerReset()
		petbouncerswitch:SpawnerReset()			
	end	
end 

function onCheckUseRequirements( self, msg )
	local player = msg.objIDUser
	local pet = player:GetPetID().objID
	local digInfo = digData[self:GetVar("digType")] or digData.PD_Normal
	
	-- Free trial status check
    local preConVar = self:GetVar("CheckPrecondition")
    
    if preConVar and preConVar ~= "" then
        local check = msg.objIDUser:CheckListOfPreconditionsFromLua{PreconditionsToCheck = preConVar, requestingID = self}
        
        if not check.bPass then 
            msg.bCanUse = false
            return msg
        end
    end

	-- We don't need to report most of this information unless this check is coming from the UI -- UI_PET_WAIT_MESSAGE
	if player:GetMissionState{missionID = 842}.missionState < 8 then --check mission
		msg.bCanUse = false
	elseif not pet or not pet:Exists() then
		msg.bCanUse = false
	elseif digInfo.bSpecificPet then
		local petLOT = pet:GetLOT().objtemplate
		local IsPet = false
		
		for k,v in ipairs(specificPetLOTs) do
			if v == petLOT then
				IsPet = true
				
				break
			end
		end
				
		if IsPet then
			for k,v in ipairs(missionRequirements) do
				if player:GetMissionState{missionID = v.ID}.missionState == v.state then --check mission
					msg.bCanUse = false
					
					break
				end
			end
		else
			msg.bCanUse = false
		end
	end
	
	-- if the pet isn't on the dig then wait for them.
	if msg.bCanUse and not pet:GetPetHasState{iStateType = 6}.bHasState then
		msg.bCanUse = false		
	end
	
	return msg
end

function onUse(self, msg)
	local petObj = msg.user:GetPetID().objID
	
	-- tell the pet to use the pet dig
	if petObj:Exists() then
		petObj:Use()
	end
end

function notifyChildLoaded(self, other, msg)
	local petObj = msg.childID
	
	-- make sure this is a pet
	if not petObj:GetIsPet().bIsPet then return end
	
	-- make sure this pet is valid for this dig
	if not CheckIsPetOk(self,petObj,other) then return end
	
	-- notify the pet that the player is on a dig
	petObj:NotifyPet{ ObjIDSource = other , ObjToNotifyPetAbout = self , iPetNotificationType = 12 }	
end

function onCollisionPhantom(self, msg)
	-- target is the pet or player or npc that collided with the node volume
	local target = msg.senderID

	if not target:Exists() then return end

	-- when something enters the collision of the node, see if the node has already been claimed and that it is actually alive
	if self:IsDead().bDead == true then return end

	-- check to see if target Is a player, if so notify pet to go to switch
	if target:IsCharacter().isChar == true then
		-- make sure we know if the player brings out a pet
		self:SendLuaNotificationRequest{requestTarget = target, messageName = "ChildLoaded"}
		
		-- see if player has a pet
		local petObj = target:GetPetID().objID
		
		if not petObj or not petObj:Exists() then return end
	
		-- make sure this pet is valid for this dig
		if not CheckIsPetOk(self,petObj,target) then return end

		-- notify the pet that the player is on a dig
		petObj:NotifyPet{ ObjIDSource = target , ObjToNotifyPetAbout = self , iPetNotificationType = 12 }		
	else
	   -- get if the target is a pet
		local isPet = target:GetIsPet()

		-- check to see if the target is a pet and if its is a wild pet
		if ( not isPet.bIsPet or isPet.bIsWild ) then return end
		
		-- already made sure that target is a pet, so get the pets owner
		local petOwner = target:GetParentObj().objIDParent

		-- make sure this pet is valid for this dig
		if not CheckIsPetOk(self,target,petOwner) then return end
		
		-- checks to see if this node was spawned by a X build
		if self:GetVar("builder") then	-- set on load from the X build			
			local petOwnerID = petOwner:GetID()

			-- this is the player that built the Xbuild that spawned the pet node
			local playerID = self:GetVar("builder")

			-- if the pet owner isn't the player who built the X build, their pet can't dig the pet dig, and therefore cant claim the node
			if (petOwnerID ~= playerID) then return end
		end

		-- notify pet that they can dig here
		target:NotifyPet{ ObjIDSource = target , ObjToNotifyPetAbout = self , iPetNotificationType = 6 }
		--set the pet ID as the pet who activated this node
		self:SetVar("activator", target:GetID())
	end	
end

function CheckIsPetOk(self,petObj,petOwner)	
	-- i think this checks to see if the pet is already using an ability
	local petAbility = petObj:GetPetAbilityObject{}

	local digInfo = digData[self:GetVar("digType")] or digData.PD_Normal

	-- check to see if this dig needs a specific pet
	if digInfo.bSpecificPet then			
		local petLOT = petObj:GetLOT().objtemplate
		local bPass = false
		
		-- run through the list of pets and see if this pet is one of them
		for k, lot in ipairs(specificPetLOTs) do
			if petLOT == lot then 
				bPass = true

				break
			end	
		end		
		
		if not bPass then
			return false
		end
		
		-- run through the table of missions and see if the player has completed the correct ones
		for k,v in ipairs(missionRequirements) do
			if petOwner:GetMissionState{missionID = v.ID}.missionState == v.state then --check mission
				return false
			end
		end				
	end
	
	-- this pet is OK
	return true
end

function onOffCollisionPhantom(self, msg)	
	-- target is the pet or player or npc that un-collided with the node volume
	local target = msg.senderID

	if not target:Exists() then return end
	
	-- check if owner needs to notify pet that he/she is not on dig anymore
	if (target:IsCharacter().isChar == true) then
		-- see if player has a pet
		local petObj = target:GetPetID().objID

		if( petObj and petObj:Exists() ) then
			-- if the character stepped off the dig, notify the player's pet
			-- iPetNotification type 15 is PET_NOTIFY_OWNER_OFF_DIG
			petObj:NotifyPet{ ObjIDSource = target , ObjToNotifyPetAbout = self , iPetNotificationType = 15 }
		end
		
		-- dont listen for the player to spawn a pet anymore
		self:SendLuaNotificationCancel{requestTarget= other, messageName="ChildLoaded"}
	end

	-- get if the target is a pet
	local isPet = target:GetIsPet()		
	
	-- check to see if the target is a pet and if its is a wild pet AND if the node was already claimed
	if (not isPet.bIsPet or isPet.bIsWild )  then return end
	
	-- activator is the pet that claimed the node in onCollision
	local activatorID = self:GetVar("activator")
	
	-- check to see if a pet was set as activator and if that pet is the pet that just un- collided with the node
	if ( not activatorID or ( target:GetID() ~= activatorID ) ) then return end
	
	-- Notify pet they've left the pet node and set their state back to normal
	target:NotifyPet{ ObjIDSource = target, ObjToNotifyPetAbout = self, iPetNotificationType = 7 }
end

function onNotifyObject(self, msg)
	-- If treasure node receives notification a pet is digging it up
	if  not ( msg.name == "petdughere" ) then return end

	local petObj = msg.ObjIDSender
	
	if petObj:Exists() then
		local digTime = petObj:GetAnimationTime{animationID = "dig"}.time or 2
		
		-- Ability is done being used, remove using-ability state from pet
		petObj:RemovePetState{iStateType = 9}
		
		-- create a timer for half the animation time to spawn the loot
		GAMEOBJ:GetTimer():AddTimerWithCancel( digTime/2, "dig_" .. petObj:GetID(), self ) 		
	end
end

function CompleteDig(self, petObj)
	-- convoluted way of getting the pet owner based on the message sender
	local petOwner = petObj:GetParentObj().objIDParent	
	-- get the object LOT of the treasure node
	local lot = self:GetLOT().objtemplate

	local digInfo = digData[self:GetVar("digType")] or digData.PD_Normal
	
	-- if the lot is the pet cove pet dig node, go to the achievement function	
	if self:GetVar("PetDig") then	
		PetDigAchievement(self,petOwner)
	end
	
	if digInfo.spawnLOT ~= -1 then
		SpawnPet(self,petOwner)
	-- if the lot is the AG Xbuild
	elseif digInfo.bBuilderOnly then	
		-- get the ID of the player who built the X
		local player = self:GetVar("builder")
		
		-- if the player that tried to dig up the pet dig is not the player who built the X, skip the rest of the script
		if (petOwner:GetID() ~= player) then return	end	
	-- if the lot is the lot of the flag digs in GF, go to the X build function
	elseif digInfo.bXBuild then 
		Xbuild(self,petOwner)
		
		return -- skip the rest of this function		
	-- if the lot is one of the pet bouncer digs, then go to the bouncer dig function
	elseif digInfo.bBouncer then	
		BouncerDig(self,petOwner)	
	end
	
	-- check to see if the player has completed with pet dig acheivement
	local DigMissionState = petOwner:GetMissionState{ missionID = 843 }.missionState

	-- if the player has not completed with mission
	if (DigMissionState == 2) then	
		petOwner:UpdateMissionTask{taskType = "complete", value = 843, value2 = 1, target = self}
	end
	
	petOwner:TerminateInteraction{type = 'user', ObjIDTerminator = petOwner}	
	-- killing the treasure node with violent is what spits out the loot, and the loot shows up for the pet owner
	self:RequestDie{ killType = "VIOLENT" , killerID = petOwner, lootOwnerID = petOwner }
	--tells the client side script that the treasure was dug up
	self:SetNetworkVar("treasure_dug", true)	
	
	local otherPets = self:GetObjectsInPhysicsBounds().objects
	
	if table.maxn(otherPets) == 0 then return end
	
	-- loop through the list of pets in the proximity and tell them to reset their states
	for k,v in ipairs(otherPets) do
		if v:GetIsPet().bIsPet then
			v:RemovePetState{iStateType = 9}
			v:NotifyPet{ ObjIDSource = v, ObjToNotifyPetAbout = self, iPetNotificationType = 7 }
			-- if the character stepped off the dig, notify the player's pet
			-- iPetNotification type 15 is PET_NOTIFY_OWNER_OFF_DIG
			v:NotifyPet{ ObjIDSource = target , ObjToNotifyPetAbout = self , iPetNotificationType = 15 }
		end
	end	
		
	local X = self:GetVar("X") or 0
	
	-- check to see if their is a quick build X, and kills it too
	if X == 0 then return end
	
	GAMEOBJ:GetObjectByID(X):RequestDie{ killType = "VIOLENT" }
end

-- function to spawn a pet on pet dig
function SpawnPet(self,petOwner)	
	local digInfo = digData[self:GetVar("digType")] or digData.PD_Normal
	
	-- if we have a spawn mission but aren't currently on it then dont spawn the pet
	if digInfo.spawnMission ~= -1 and petOwner:GetMissionState{ missionID = digInfo.spawnMission }.missionState < 2 then return end
	
	-- get the location of the pet dig to spawn the pet there
	local mypos = self:GetPosition().pos
	local myRot = self:GetRotation()	
	-- set the config data with the tamer as the pet Owner so only the person who dug the crab can tame it, and add it to a group 
	-- with the pet tamer's ID built in to the name of the group so the pet can be found through script
	local config = { { "tamer", petOwner:GetID() } , { "groupID", "pet"..petOwner:GetID()}, {"spawnAnim", "spawn-pet"}, {"spawnTimer", 1.0}}
	
	-- spawn a pet
	RESMGR:LoadObject { objectTemplate = digInfo.spawnLOT , x = mypos.x , y = mypos.y , z = mypos.z , rw= myRot.w, rx= myRot.x, ry= myRot.y, rz = myRot.z, owner = self, configData = config }
end

-- function to update achievements for doing all the pet digs in Pet Cove
function PetDigAchievement(self,petOwner)
	-- check to see if the player has completed with pet dig acheivement
	local AchievementState = petOwner:GetMissionState{ missionID = 505 }.missionState
	
	-- if the player has not completed with mission
	if (AchievementState == 4) then return end

	local digNum = self:GetVar('PetDig') -- set in HF
	-- use the number of the pet dig to get the player flag number for that pet dig
	local flagNumber = tonumber("126"..digNum)
	
	-- check to see if the player has already dug that particular pet dig before
	if (petOwner:GetFlag{iFlagID = flagNumber}.bFlag == false ) then 	
		--set flag to true so we know the player has alread done this  
		petOwner:SetFlag{iFlagID = flagNumber, bFlag = true} 
		-- update the player's achievement for digging a new pet dig
		petOwner:UpdateMissionTask{taskType = "complete", value = 505, value2 = 1, target = self}	
	end
end

-- function for the flag pet digs in GF
function Xbuild(self,petOwner)
	local playerID = self:GetVar("builder") or 0
	
	if playerID == 0 then return end
	
	local player = GAMEOBJ:GetObjectByID(playerID)

	-- check to make sure the pet owner is still the player who built the X, just another check
	if (petOwner:GetID() ~= player:GetID()) then return end
		
	-- set variable for player flag num
	local PlayerFlagNum = 0
	local groupID = self:GetVar("groupID") -- set in HF
	
	--set the flag number to check/set on the player based on which flag in GF it is. 
	--player flag number set in the database
	if (groupID == "Flag1") then	
		PlayerFlagNum = 61		
	elseif (groupID == "Flag2") then	
		PlayerFlagNum = 62		
	elseif (groupID == "Flag3") then	
		PlayerFlagNum = 63		
	end
	
	--check to see if they player has dug the flag up before
	if not petOwner:GetFlag{iFlagID = PlayerFlagNum}.bFlag then
		-- Ability is done being used, remove using-ability state from pet
		player:GetPetID().objID:RemovePetState{iStateType = 9}
		
		--get the flag based on the group, to change the collision group and visiblity on those scripts
		--assume only one object in group
		local flag = self:GetObjectsInGroup{ group = groupID, ignoreSpawners = true }.objects[1]
		
		--notifies script on the flag L_GF_DUG_FLAG_CLIENT
		flag:NotifyClientObject{ name = "changePhysics" , paramObj = player , rerouteID = player }		
		--set the player flag for this collectible flag so next time the player digs it, he'll get generic pet loot instead
		petOwner:SetFlag{iFlagID = PlayerFlagNum, bFlag = true}  		
		-- it's ok to use Deleteobject because we know this node was spawned through script, and this is a server script
		GAMEOBJ:DeleteObject(self)	
	-- if the player has already gotten this flag, then have the pet dig drop normal pet dig loot
	else	
		--remove the dig state from the pet
		petOwner:GetPetID().objID:RemovePetState{iStateType = 9}		
		-- killing the treasure node with violent is what spits out the loot, and the loot shows up for the pet owner
		self:RequestDie{ killType = "VIOLENT", killerID = petOwner }		
		-- delete this chest immediately so it will not have to wait for the 
		-- RequestDie->Die->Client message chain to complete before disappearing
		-- loot will be generated correctly in the RequestDie call above because 
		-- all the server-side loot generation occurs when Die is handled in the 
		-- call to RequestDie which will complete before we send DeleteObject
		-- it's ok to use Deleteobject because we know this node was spawned through script, and this is a server script
		GAMEOBJ:DeleteObject(self)
	end
	
	local X = self:GetVar("X") or 0
	
	-- check to see if their is a quick build X, and kills it too
	if X == 0 then return end
	
	GAMEOBJ:GetObjectByID(X):RequestDie{ killType = "VIOLENT" }
end

-- function for the pet dig that digs up a pet bouncer and switch
function BouncerDig(self,petOwner)
	local bouncerNumber = self:GetVar("BouncerNumber") -- set in HF
	
	-- check so script doesnt crash because there's no config data set
	if not bouncerNumber then return end
	
	-- spawner networks for the bouncer and switch must be set up like this to work
	local bouncerSpawner = LEVEL:GetSpawnerByName("PetBouncer"..bouncerNumber)
	local switchSpawner = LEVEL:GetSpawnerByName("PetBouncerSwitch"..bouncerNumber)
	
	-- check that there is a spawner network with that name before activating it
	if bouncerSpawner then	
		-- activating the spawner network spawns the bouncer
		--bouncerSpawner:SpawnerReset()
		bouncerSpawner:SpawnerActivate()		
	end
	
	-- check that there is a spawner network with that name before activating it
	if switchSpawner then
		-- activating the spawner network spawns the switch
		--switchSpawner:SpawnerReset()
		switchSpawner:SpawnerActivate()
	end	
end

function onTimerDone(self, msg)
	-- split out the timer
	local tTimer = split(msg.name, "_")
	
	-- if this is the dig timer then check the pet and have the do CompleteDig
	if tTimer[1] == "dig" then
		local petID = tTimer[2] or 0
		
		if petID == 0 then return end
		
		local petObj = GAMEOBJ:GetObjectByID(petID)
		
		if petObj:Exists() then
			CompleteDig(self, petObj)
		end
	end
end

function split(str, pat)
    local t = {}
    
    -- creates a table of strings based on the passed in pattern   
    string.gsub(str .. pat, "(.-)" .. pat, function(result) table.insert(t, result) end)

    return t
end 
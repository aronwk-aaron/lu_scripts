--------------------------------------------------------------

-- L_NT_FACTION_SPY_SERVER.lua

-- Catch and process Spy Mission events, including formatting
-- the dialogue script data.
-- Created abeechler ... 4/8/11

--------------------------------------------------------------

------------------------------------------------------
-- L_NT_FACTION_SPY_SERVER script configData SpyCinematic requirements:
--
-- Cinematics are to be chained in Happy Flower using a naming convention
-- where transtions can equal dialogue displays.  Structure cinematics with
--
-- [[ 'cinema_core_name' AND/OR '_' +  'number' ]]
-- 'cinema_core_name' = A shared name leading each chained cinematic tag, for spy dialogue to play
--                      this MUST be the same across all chained cinematics initiated by the spyObject 
--                      SpyCinematic config data.
-- '_' +  'number'    = If the core name is followed by a number in this structure, then when the cinematic 
--                      begins a chat bubble will be displayed with dialogue corresponding to the dialogue 
--                      table location defined by the spy object.  
--
-- NOTE: Cinemas can be played throughout the chain by not providing '_' +  'number' data
------------------------------------------------------

----------------------------------------------------------------
-- Define empty tables that will be set from the 
-- spy object specific script
----------------------------------------------------------------
local SpyDialogueTable = {}
local SpyDialogueObjTable = {}
local SpyDataTable = {}
local SpyDialogueTableLength = 0

----------------------------------------------------------------
-- Variables passed from the object specific script that are used throughout the base script
----------------------------------------------------------------
function setGameVariables(self, passedSpyDialogueTable, passedSpyDialogueObjTable, passedSpyDataTable, passedSpyProxRadius)

	SpyDialogueTable = passedSpyDialogueTable
	SpyDialogueObjTable = passedSpyDialogueObjTable
	SpyDataTable = passedSpyDataTable
	
	SpyDialogueTableLength = table.maxn(SpyDialogueTable)
	
	-- If we have a valid SpyProxRadius, set a proximity radius sense trigger
	if(passedSpyProxRadius) then
	    -- Establish a sense radius for spy missions
        self:SetProximityRadius{radius = passedSpyProxRadius, name = "SpyDistance", collisionGroup = 1} 
	end
	
end

----------------------------------------------
-- Check to see if we have a valid spy
-- returns: true or false depending on spy validity
----------------------------------------------
function spyCheck(checkObject)

	-- Grab the necessary precondition objects from the passed in check table
	-- if we are missing any relevant data, return a false check result
    local spyFlagID = SpyDataTable.spyFlagID
    local spyItemID = SpyDataTable.spyItemID
    local spyMissionID = SpyDataTable.spyMissionID
	if((not spyFlagID) or (not spyItemID) or (not spyMissionID)) then return false end
	
	-- Is the checkObject on the right mission?
    -- Is the checkObject wearing the correct spy gear?
    -- Has the checkObject's flag been set?
    if((checkObject:GetMissionState{missionID = spyMissionID}.missionState ~= 2) or
       (not checkObject:GetIsItemEquippedByLOT{ItemID = spyItemID}.bEquipped) or
       (checkObject:GetFlag{iFlagID = flag}.bFlag)) then
        -- Immediately return false on 'true' to any of the queries
        return false
	else
		-- We have found a spy!
		return true
    end
	
end 

----------------------------------------------
-- Initiate the spy cinematic, and process dialog events in time
-- with the camera transitions
----------------------------------------------
function  playSpyDialogue(self, spyDialogueCinematic, spyObjID, senseObjID)
    
    local senseObj = GAMEOBJ:GetObjectByID(senseObjID)
	
    -- Stun lock the spy
	spyObjID:SetStunned{StateChangeType = "PUSH",
							bCantMove = true,
						    bCantTurn = true,
					      bCantAttack = true,
					     bCantUseItem = true,
						   bCantEquip = true,
					    bCantInteract = true}
						
	-- Initiate the dialogue cinematic
	spyObjID:PlayCinematic{pathName = spyDialogueCinematic, lockPlayer = false, bSendServerNotify = true}
	
	local cineName = split(spyDialogueCinematic, "_")
	local cineRoot = cineName[1] or false
	self:SetVar("CinematicRootName", cineRoot)
	
    -- Request for notification upon cinematic conclusion for dialogue event processing
	self:SendLuaNotificationRequest{requestTarget = spyObjID, messageName = "CinematicUpdate"}
	
end

----------------------------------------------
-- Catch and process proximity awareness events for spies
----------------------------------------------
function onProximityUpdate(self, msg)
    baseOnProximityUpdate(self, msg)
end

function baseOnProximityUpdate(self, msg)

    local msgName = msg.name
    local proxObjID = msg.objId
    local senseObjID = msg.ownerId

    -- Is this the Spy Distance?
    if((msgName == "SpyDistance")  and (msg.status == "ENTER"))then    
		
	    -- proxObjID is in spy distance - are they a valid spy object?
		local bIsSpyObj = spyCheck(proxObjID)
			
		if(bIsSpyObj)then
			-- We have a valid spy, check for a valid spy dialogue cinematic
			local spyDialogueCinematic = self:GetVar("SpyCinematic") or false
			if(spyDialogueCinematic) then
				-- We have a valid spy dialogue cinematic
				playSpyDialogue(self, spyDialogueCinematic, proxObjID, senseObjID)
			end
		end
    end
	
end

----------------------------------------------------------------
-- Server notification of cinematic events firing
----------------------------------------------------------------
function notifyCinematicUpdate(self, player, msg)
    baseNotifyCinematicUpdate(self, player, msg)
end

function baseNotifyCinematicUpdate(self, player, msg)

	local eventType = msg.event
	
	local cineRoot = self:GetVar("CinematicRootName")
	
	local tPathName = split(msg.pathName, "_")
	local tPathRoot = tPathName[1] or false
	local tPathExtension = tPathName[2] or 0
	local dialogueIndex = tonumber(tPathExtension)
	
	if((tPathRoot) and (tPathRoot == cineRoot)) then
		if(eventType == "STARTED") then
			-- We are initiating a camera transition to a dialogue display segment
			-- We have a valid indexed cinematic cam sequence starting
			if((dialogueIndex) and (dialogueIndex > 0) and (dialogueIndex <= SpyDialogueTableLength)) then
				-- Send the spy dialogue line for display
				self:NotifyClientObject{name ="displayDialogueLine", paramStr = SpyDialogueTable[dialogueIndex].dialogueToken, paramObj = SpyDialogueObjTable[SpyDialogueTable[dialogueIndex].convoID]}
			end
			
		elseif(eventType == "ENDED") then
		    if((dialogueIndex) and (dialogueIndex >= SpyDialogueTableLength)) then
			    -- We are ending a camera sequence that marks the end of a dialogue camera chain:
			    -- Unlock player
			    player:SetStunned{ StateChangeType = "POP",
									     bCantMove = true,
									     bCantTurn = true,
								       bCantAttack = true,
								      bCantUseItem = true,
								        bCantEquip = true,
								     bCantInteract = true}
								     
				-- Prepare for mission completion by marking the associated flag
				player:SetFlag{iFlagID = SpyDataTable.spyFlagID, bFlag = true}
				
				-- Unsubscribe from the scipt notification
		        self:SendLuaNotificationCancel{requestTarget = player, messageName = "CinematicUpdate"}
		    end
		end
	end
	
end

----------------------------------------------
-- Utility function usable by spy objects to construct their dialogue objects table
-- returns: an organized table of dialogue participants
----------------------------------------------
function buildSpyDialogueObjTable(spyObject, secondaryObjGroupTable)
	
	-- Declare the spy dialogue object table
	local spyDialogueObjectTable = {}
	
	-- spyObject is always the first element - it is the primary dialogue object
	table.insert(spyDialogueObjectTable, spyObject)
	
	-- Iterate through the secondaryObjGroupTable, if one exists,
	-- and retrieve the first object from each group for addition to
	-- the dialogue object table
	if(secondaryObjGroupTable) then
		-- We have received a table
		for k, groupNom in ipairs(secondaryObjGroupTable) do
			-- Retrieve the first object from each group and add it to the spyDialogueObjectTable
			local dialogObject = returnFirstGroupObject(spyObject, groupNom)
			table.insert(spyDialogueObjectTable, dialogObject)
		end
	end
	
	-- Return the compiled table of dialog objects
	return spyDialogueObjectTable
	
end

----------------------------------------------
-- Utility function to return a valid object from a group
----------------------------------------------
function returnFirstGroupObject(self, groupName)

    if(groupName) then
	    -- We have a target group to proces
	    local groupObjs = self:GetObjectsInGroup{group = groupName, ignoreSpawners = true}.objects
			
	    -- Iterate through the group and catch the first valid object
	    for k,obj in ipairs(groupObjs) do
		    if obj:Exists() then
			    return obj
		    end
	    end
	end
	
	-- Catch for missing objects or empty group
	return false
	
end

----------------------------------------------
-- Utility function to process tokenized strings
----------------------------------------------
function split(str, pat)
    local t = {}
    -- Creates a table of strings based on the passed in pattern   
    string.gsub(str .. pat, "(.-)" .. pat, function(result) table.insert(t, result) end)

    return t
end

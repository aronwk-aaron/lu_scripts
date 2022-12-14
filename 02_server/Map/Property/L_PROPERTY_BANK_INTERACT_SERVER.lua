--------------------------------------------------------------

-- L_PROPERTY_BANK_INTERACT_SERVER.lua

-- Adds further check requirements to property bank interacts
-- created abeechler ... 2/16/11
-- updated abeechler ... 10/4/11 - Added self ownership check functionality

--------------------------------------------------------------

----------------------------------------------
-- Object initialization
----------------------------------------------
function onStartup(self)
	-- Query our containing property for the ID of its owner
	--
	-- RESULT: The Object now has a network variable set called "PropertyOwnerID" 
	-- 		   that contains the property owner ID
	--
	local propPlaqueGroup = self:GetVar("plaqueGroup") or false
	
	if(propPlaqueGroup) then
	    -- We can request the identity of the property owner directly
	    checkForOwner(self)
        
	else
	    -- We will rely on the zone script to deliver the identity
	    -- of the property owner
	    GAMEOBJ:GetZoneControlID():FireEvent{senderID=self, args="CheckForPropertyOwner"}
	end
	
end

----------------------------------------------------------------
-- Catches updates from the zone object that the property has
-- just been rented
----------------------------------------------------------------
function notifyZonePropertyRented(self, zoneID, msg)
    -- Update the safe's record of who owns the property
    self:SetNetworkVar("PropertyOwnerID", msg.playerID:GetID())
    -- Cancels notification from the zone control object
    self:SendLuaNotificationCancel{requestTarget = zoneID, messageName = "ZonePropertyRented"}
end

----------------------------------------------------------------
-- Used by the safe to process a config data plaqueGroup to 
-- ascertain property ownership
----------------------------------------------------------------
function checkForOwner(self)
	-- Get the property plaque by group set in happy flower, the property plaque is coded to share certain information with LUA
	local propPlaqueGroup = self:GetVar("plaqueGroup") or false
    if(not propPlaqueGroup) then return end
    local propertyPlaques = self:GetObjectsInGroup{ group = propPlaqueGroup, ignoreSpawners = true }.objects
    
    if not propertyPlaques or #propertyPlaques == 0 then 
        GAMEOBJ:GetTimer():AddTimerWithCancel( 0.5, "runCheckForOwnerAgain", self ) 
        return
    end
	
	-- Table for property data to be filled out by the for loop below
    for i = 1, table.maxn(propertyPlaques) do
		-- Check to see if there is more than on object in the property plaque group, if there is, it can seriously break stuff
        if i > 1 then
			WarningPrint(self,"WARNING --  YOU HAVE TO MANY PROPERTY PLAQUES IN THIS LEVEL. Please make sure you only have 1!")
			break
		end
		
		-- Retrieve property data from the referenced plaque
		local propertyData = propertyPlaques[i]:PropertyGetState{}
		
		-- Is the property rented? - parse accordingly
		if(propertyData.rented) then
            self:SetNetworkVar("PropertyOwnerID", propertyData.ownerID:GetID())
        else
            self:SendLuaNotificationRequest{requestTarget = GAMEOBJ:GetZoneControlID(), messageName = "ZonePropertyRented"}
        end
    end
    
end

----------------------------------------------------------------
-- Check to see if the player can use the bank
----------------------------------------------------------------
function onCheckUseRequirements(self, msg)
	-- Check for property placement ownership as a requirement for interaction
	local player = msg.objIDUser
	local playerID = player:GetID()
	local propertyOwnerID = self:GetNetworkVar("PropertyOwnerID") or 0
	
	-- Obtain preconditions
    local preConVar = self:GetVar("CheckPrecondition")
	
	if(playerID ~= propertyOwnerID) then
		-- We can't interact with the property bank safe
		-- if it isn't on our own property
		msg.bCanUse = false
	
	elseif preConVar and preConVar ~= "" then
		-- We have a valid list of preconditions to check
        local check = msg.objIDUser:CheckListOfPreconditionsFromLua{PreconditionsToCheck = preConVar, requestingID = self}
        
        if not check.bPass then 
			-- Failed the precondition check
            msg.bCanUse = false
        end
    end
	
    return msg
end

----------------------------------------------
-- Sent when the local player interacts with the
-- object
----------------------------------------------
function onUse(self, msg) 
	local player = msg.user
    
    player:UIMessageServerToSingleClient{strMessageName = "pushGameState",  args = {{"state", "bank"}}}
    self:NotifyClientObject{name = "OpenBank", rerouteID = player}
end 

----------------------------------------------
-- Sent when the local property bank interaction
-- is terminated
----------------------------------------------
function onFireEventServerSide(self, msg) 
	local player = msg.user
	
    if msg.args == "ToggleBank" then
        -- Turn OFF Bank UI
        msg.senderID:UIMessageServerToSingleClient{strMessageName = "ToggleBank",  args = {{"visible", false}}}
        self:NotifyClientObject{name = "CloseBank", rerouteID = player}
    end
end

----------------------------------------------------------------
-- Called when a timer is done
----------------------------------------------------------------
function onTimerDone(self,msg)
	if(msg.name == "runCheckForOwnerAgain") then
		checkForOwner(self)
    end
end

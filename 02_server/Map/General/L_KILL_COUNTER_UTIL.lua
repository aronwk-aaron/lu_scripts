--------------------------------------------------------------

-- L_KILL_COUNTER_UTIL.lua

-- Intermediary utility script for objects
-- Maintains an internal counter limited either by user definition, or associated network
-- max spawns.
-- Processes counter events sent through external sources, or received via 
-- personal notification subscriptions.
-- Initiates event firing to user defined target group/functions based on counter state.

-- Created abeechler... 9/20/11 

-------------------------------------------------------------

-------------------------------------------------------------

--- config data variables for HF; defaults listed. ** if nothing is set the counter defaults to counting from 0 to x
--- where 'x' is the max number of objects spawned throughout all associated networks **
-- max --> 1:x							-- the upper clamped limit the counter will increment to
-- min --> 1:0							-- the initial point for the counter to increment from

--- associated spawn networks
--- NOTE: you can include as many networks as you wish, HOWEVER the references MUST be numbered SEQUENTIALLY
--- (i.e. - spawnNw1, spawnNw2, spawnNw3, etc.) to be counted properly
-- spawnNw1 --> 0:networkName           -- string reference to a spawner network name
-- spawnNw2 --> 0:networkName           -- another network
-- ...                                  -- ...
-- spawnNwX --> 0:networkName           -- the last in a sequential reference list of desired spawner networks 

--- notification subsciption management
-- bManageNotifies --> 7:true/false     -- whether or not the counter should manage spawn network notifies automatically
--                                      -- (set to true by default)
-- bAutoStop --> 7:true/false           -- should we auto stop (unsubscribe) notification upon reching the max?
--                      

--- fire events
-- maxHit_event --> 0:event1			-- event name to fire when the couter reaches the upper limit
-- maxHit_group --> 0:group1			-- desired object group maxHit_event is fired on
-- minHit_event --> 0:event2			-- event name to fire when the counter reaches the lower limit
-- minHit_group --> 0:group2			-- desired object group minHit_event is fired on

--- types of events: this is set on the object configData in HF for the receiving the event. 
    ----
    -- FORMAT: this is for the name_activated_event sent to the group_activated_event from above
    -- event1 --> 0:activate
    ----
    -- increment		-- use this variable name to increment the count
    -- decrement		-- use this variable name to decrement the count

-------------------------------------------------------------

local defaultCounterMin = 0               -- Signifies where the counter should start incrementing from

----------------------------------------------------------------
-- Object functionality initialization 
----------------------------------------------------------------
function onStartup(self)
    -- Init the counter at either a default base value,
    -- or a value read in from the object config data
    local cntMin = self:GetVar('min') or defaultCounterMin
    self:SetVar("min", cntMin)
    self:SetVar("counter", cntMin)
    
    -- Build a table containing reference to all config data
    -- associated spawn networks
    local spawnNetworkTable = {}
    
    local cnt = 1
    local networkBuf = self:GetVar("spawnNw" .. cnt)
    while(networkBuf ~= nil) do
        -- Append the current found spawner network
        table.insert(spawnNetworkTable, networkBuf)
        -- Increment our count
        cnt = cnt + 1
        -- Obtain the next sequential network
        networkBuf = self:GetVar("spawnNw" .. cnt)
    end
    
    -- Save the results
    self:SetVar("spawnNetworkTable", spawnNetworkTable)
    
    -- Establish the counter upper limit, either through read in 
    -- object config data, or in its absence through associated
    -- spawner network max spawns
    local cntMax = self:GetVar('max')
    
    if(cntMax == nil) then
        -- We do not have an explicit user defined limit,
        -- obtain one based on associated spawn networks
        if(table.maxn(spawnNetworkTable) > 0)then
            local cntTally = 0
            -- Iterate through the networks and accumulate their spawn limits
            for i, spawnerNom in ipairs(spawnNetworkTable) do
                -- Get a ref to the network by name
                local spawner = LEVEL:GetSpawnerByName(spawnerNom)
                
                if((spawner) and (spawner:Exists())) then
                    local spawnLimit = spawner:SpawnerGetMaxToSpawn().iNum
                    -- Confirm it is not an unlimited spawner, and add to accumulation
                    if(spawnLimit ~= -1) then
                        cntTally = cntTally + spawnLimit
                    end
                end
            end
            
            -- If we have a count tally that remains zero at this point, the user has supplied
            -- solely infinite spawning networks - alert them to possibility.
            if(cntTally == 0) then
                cntMax = 1
                errorReport(self, 3)
            else
                -- Set our accumulated network max limit
                cntMax = cntTally
            end
            
            self:SetVar("max", cntMax)
            
        else
            -- We were not given an explicit limit, and the
            -- user does not have associated spawn networks - 
            -- set a simple default limit, and alert to the potential error
            cntMax = 1
            self:SetVar("max", cntMax)
            errorReport(self, 1)
        end
    
    else
        -- The user has defined a config data max limit
        self:SetVar("max", cntMax)
    end
    
    -- If bManageNotifies is set to true - iterate through the 
    -- associated networks, grab hooks to each network,
    -- and subscribe for event notification on each
    local bManageNotifies = self:GetVar("bManageNotifies")
    if((bManageNotifies ~= nil) and (bManageNotifies == false)) then return end
    
    if(table.maxn(spawnNetworkTable) > 0)then
        spawnerNotifies(self, true)
            
    else
        -- We were not provided any associated networks for
        -- object notification, alert the user to the potential error
        errorReport(self, 2)
    end
    
end

----------------------------------------------------------------
-- Handle spawner notification subscription and cancellation
----------------------------------------------------------------
function spawnerNotifies(self, bSubscribe)
    local spawnNetworkTable = self:GetVar("spawnNetworkTable")
    
    -- Iterate through the networks and subscribe for notifies on their elements
    for i, spawnerNom in ipairs(spawnNetworkTable) do
        -- Get a ref to the network by name
        local spawner = LEVEL:GetSpawnerByName(spawnerNom)
                
        if((spawner) and (spawner:Exists())) then
            if(bSubscribe) then
                -- Receive notification of death
                self:SendLuaNotificationRequest{requestTarget = spawner, messageName = "NotifySpawnerOfDeath"}
            else
                -- Cancel death notifies
                self:SendLuaNotificationCancel{requestTarget = spawner, messageName = "NotifySpawnerOfDeath"}
            end
        end
        
    end
end

----------------------------------------------------------------
-- Process event calls to this counter object
----------------------------------------------------------------
function onFireEvent(self, msg)
    --- types of events: this is set on the object configData in HF for the receiving the event. 
    ----
    -- FORMAT: this is for the name_activated_event sent to the group_activated_event from above
    -- event1 --> 0:activate
    ----
    -- increment		-- use this variable name to increment the count
    -- decrement		-- use this variable name to decrement the count
    -- stopNotifies     -- unsubscribe from current spawn network notifies
    -- startNotifies    -- subscribe to notifications for config data referenced spawner networks
    -- reset            -- forces the kill counter back to 0
    
	local eventType = self:GetVar(msg.args)
	
	if not eventType then return end
	
	if((eventType == "increment") or (eventType == "decrement")) then
	    modifyCounter(self, eventType)
	    
	elseif(eventType == "stopNotifies") then
	    spawnerNotifies(self, false)
	    
	elseif(eventType == "startNotifies") then
	    spawnerNotifies(self, true)
	    
	elseif(eventType == "reset") then
	    resetCounter(self)
	
	end
	
end

----------------------------------------------------------------
-- Reset the kill counter to an entry state
----------------------------------------------------------------
function resetCounter(self)
    -- Obtain the minimum counter value and reset out counter to it
    local cntMin = self:GetVar('min')
    self:SetVar("counter", cntMin)
    
    -- If we were set to manage notifies, ensure we are doing it again
    local spawnNetworkTable = self:GetVar("spawnNetworkTable")
    local bManageNotifies = self:GetVar("bManageNotifies")
    if((bManageNotifies ~= nil) and (bManageNotifies == false)) then 
        spawnerNotifies(self, false)
        return 
    end
    
    if(table.maxn(spawnNetworkTable) > 0)then
        spawnerNotifies(self, true)
            
    else
        -- We were not provided any associated networks for
        -- object notification, alert the user to the potential error
        errorReport(self, 2)
    end
    
end

----------------------------------------------------------------
-- Actual parsing of counter modification events
----------------------------------------------------------------
function modifyCounter(self, modType)
    local counter = self:GetVar("counter")
    local cntMax = self:GetVar("max")
    
    if modType == "increment" then
	    -- Increment the counter and limit check.
		counter = counter + 1
		if counter == cntMax then
		    sendEvent(self, true)
		    processEvent(self, true)
		    -- If bAutoShutoff is set to FALSE, keep operations
		    local bAutoShutoff = self:GetVar("bAutoShutoff")
            if((bAutoShutoff ~= nil) and (bAutoShutoff == false)) then return end
            spawnerNotifies(self, false)
            
		elseif counter > cntMax then
		    return
		end
		
		-- Set the counter
        self:SetVar("counter", counter)
		
	elseif modType == "decrement" then
	    -- Decrement the counter
		counter = counter - 1
		local cntMin = self:GetVar("min")
		
		if counter == cntMin then
		    sendEvent(self, false)
		    processEvent(self, false)
		elseif counter < cntMin then
		    return
		end
		
		-- Set the counter
        self:SetVar("counter", counter)
		
	end
end

----------------------------------------------------------------
-- Catch subscribed spawner loads
----------------------------------------------------------------
function notifyNotifySpawnerOfDeath(self, spawnerID, msg)
    -- Increment our kill counter
    modifyCounter(self, "increment")
    
end

----------------------------------------------------------------
-- Initiate a call to user defined objects
----------------------------------------------------------------
function sendEvent(self, bUpperLimitReached)
	local eventName = false
	local eventGroup = false
	
	if bUpperLimitReached then
		eventName = self:GetVar("maxHit_event") or false
		eventGroup = self:GetVar("maxHit_group") or false
	else
		eventName = self:GetVar("minHit_event") or false
		eventGroup = self:GetVar("minHit_group") or false	
	end
	
	if not eventName or not eventGroup then return end
	
	debugPrint(self, 'name = ' .. eventName .. " group = " .. eventGroup)
	
	local groupObjs = self:GetObjectsInGroup{group = eventGroup, ignoreSpawners = true}.objects
	
	for k,obj in ipairs(groupObjs) do
		if obj:Exists() then
			obj:FireEvent{args = eventName, senderID = self}
		end
	end

end

----------------------------------------------------------------
-- Enable an object extending kill counter functionality to 
-- process limit events
----------------------------------------------------------------
function processEvent(self, bUpperLimitReached)
    -- Generic counters don't process events:
    -- This is a template objects inheriting counter functionality 
    -- can uniquely define in order ro accomplish specific tasks
end

----------------------------------------------------------------
-- User error reporting utility function
----------------------------------------------------------------
function errorReport(self, iErrState)
    -- Our location
    local loc = self:GetPosition().pos
    
    -- Process iErrState for specific notification string
    local errString = "possible error found at loc: ("
    if(iErrState == 1) then
        -- We were not given an explicit limit, and the
        -- user does not have associated spawn networks
        errString = "there is a counter without a defined max limit AND without spawner network refs at loc: ("
    
    elseif(iErrState == 2) then
        -- We were not provided any associated networks for object notification
        errString = "there is a counter without spawn network refs with bManageNotifies set to TRUE at loc: ("
    
    elseif(iErrState == 3) then
        -- We are relying on the spawn network limits to set our max, and were only
        -- provided infinite networks.
        errString = "there is a counter trying to process a max value based only on infinite spawn networks at loc: ("
    end
    
    debugPrint(self, "***** L_KILL_COUNTER WARNING: " .. errString .. tostring(loc.x) .. ", " .. tostring(loc.y) .. ", " .. tostring(loc.z) .. ")")
end

----------------------------------------------------------------
-- Print function that only works in an internal build
----------------------------------------------------------------
function debugPrint(self, text)	
	if self:GetVersioningInfo().bIsInternal then
		print(text)
	end
end

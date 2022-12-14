--------------------------------------------------------------

-- L_EVENT_COUNTER_UTIL.lua

-- Intermediary utility script for objects
-- Maintains an internal counter (user limit defined) for groups that processes
-- remote event calls to user defined target group/functions
-- Created abeechler... 9/20/11 - Retitled to abstract from spinner specific terms

-------------------------------------------------------------

-------------------------------------------------------------

--- config data variables for HF; defaults listed. ** if nothing is set the counter defaults to counting from 0 to 1 **
-- max --> 1:1							-- the upper clamped limit the counter will increment to
-- min --> 1:0							-- the initial point for the counter to increment from

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
local defaultCounterMax = 1               -- Signifies a pre-defined counter max limit

function onStartup(self)
    -- Establish the counter upper limit, either through default property,
    -- or read in object config data
    local cntMax = self:GetVar('max') or defaultCounterMax
    self:SetVar("max", cntMax)
    -- Init the counter at either a default base value,
    -- or a value read in from the object config data
    local cntMin = self:GetVar('min') or defaultCounterMin
    self:SetVar("min", cntMin)
    self:SetVar("counter", cntMin)
end

function onFireEvent(self, msg)
    --- types of events: this is set on the object configData in HF for the receiving the event. 
    ----
    -- FORMAT: this is for the name_activated_event sent to the group_activated_event from above
    -- event1 --> 0:activate
    ----
    -- increment		-- use this variable name to increment the count
    -- decrement		-- use this variable name to decrement the count
    
    local counter = self:GetVar("counter")
    local cntMax = self:GetVar("max")
	local eventType = self:GetVar(msg.args)
	
	if not eventType then return end
	
	if eventType == "increment" then
	    -- Increment the counter and limit check.
		counter = counter + 1
		if counter == cntMax then
		    sendEvent(self, true)
		elseif counter > cntMax then
		    return
		end
		
		-- Set the counter
		self:SetVar("counter", counter)
	elseif eventType == "decrement" then
	    -- Decrement the counter
		counter = counter - 1
		local cntMin = self:GetVar("min")
		
		if counter == cntMin then
		    sendEvent(self, false)
		elseif counter < cntMin then
		    return
		end
		
		-- Set the counter
		self:SetVar("counter", counter)
	end
end

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

-- print function that only works in an internal build
function debugPrint(self, text)	
	if self:GetVersioningInfo().bIsInternal then
		print(text)
	end
end

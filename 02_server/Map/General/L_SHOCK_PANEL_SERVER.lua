--------------------------------------------------------------

-- L_SHOCK_PANEL_SERVER.lua

-- Server script for player damaging shock panel.
-- Players, on collision with the panel, will take damage or be smashed instantly
-- based on object config data.
-- Created abeechler... 1/17/11
-- Modified by abeechler... 1/27/11	-- Refactored script functionality and added spinner message parsing

-------------------------------------------------------------

-------------------------------------------------------------

--- config data variables for HF; defaults listed.
-- bPanelOn --> 7:1						-- the shock panel is on by default

--- types of events: this is set on the object configData in HF for the receiving the event. 
    ----
    -- FORMAT: this is for the name_activated_event sent to the group_activated_event from above
    -- event1 --> 0:activate
    ----
    -- turnOn		-- use this variable name to turn on the shock platform
    -- turnOff		-- use this variable name to turn off the shock platform
    -- toggle		-- use this variable name to toggle the platform to its complimentary state

-------------------------------------------------------------

local shockPanelSkillID = 1215        -- The ID of the skill cast by the platform to electrocute the player
local shockPanelSkillCooldown = 1.75  -- The time between firing the damage ability against offending players
local bPanelOnDefault = true		  -- The default status of the electrified platform.

function onStartup(self)
	-- Init object on status based on config data or default local values
    local bPanelOn = self:GetVar("bPanelOn") or bPanelOnDefault
    self:SetVar("bPanelOn", bPanelOn)
end

function onFireEventServerSide(self, msg)  
    if msg.args == 'renderReady' then
        -- Play Electric Platform effect here
        self:PlayFXEffect{name = "active", effectType = "zapOn"}
    end
end

--------------------------------------------------------------
-- onCollisionPhantom handles the player colliding with the
-- attached object via a data driven response.
--------------------------------------------------------------
function onCollisionPhantom(self, msg)
	local target = msg.objectID
	local touchingPlatTable = self:GetVar("touchingPlatTable") or {}
		
	-- Add the target to the touchingPlatTable
	touchingPlatTable[target:GetID()] = true
	-- Update tables
	self:SetVar("touchingPlatTable", touchingPlatTable)
	
	if(self:GetVar("bPanelOn")) then
		-- Platform is on
		local beingShockedTable = self:GetVar("beingShockedTable") or {}
		
		-- If the colliding player is already being shocked, skip them
		if (not beingShockedTable[target:GetID()]) then
			-- Shock the target player
			shockPlayer(self, target)
		end
	end
end

--------------------------------------------------------------
-- onOffCollisionPhantom handles the player colliding with the
-- attached object via a data driven response.
--------------------------------------------------------------
function onOffCollisionPhantom(self, msg)
	local target = msg.objectID
	local touchingPlatTable = self:GetVar("touchingPlatTable") or {}
   
	-- Remove the target to the touchingPlatTable
	touchingPlatTable[target:GetID()] = nil
	
	-- Update tables
	self:SetVar("touchingPlatTable", touchingPlatTable)
end

--------------------------------------------------------------
-- onFireEvent catches input from spinner objects.
--------------------------------------------------------------
function onFireEvent(self, msg)
    --- types of events: this is set on the object configData in HF for the receiving the event. 
    ----
    -- FORMAT: this is for the name_activated_event sent to the group_activated_event from above
    -- event1 --> 0:activate
    ----
    -- turnOn		-- use this variable name to turn the damage platform on
    -- turnOff		-- use this variable name to turn the damage platform off
	-- toggle		-- use this variable name to toggle the platform to its complimentary state
    
	local eventType = self:GetVar(msg.args)
	
	if not eventType then return end
	
	if eventType == "turnOn" then
		updatePlatformState(self, true)
	   
	elseif eventType == "turnOff" then
		updatePlatformState(self, false)
		
	elseif eventType == "toggle" then
		local panelOn = self:GetVar("bPanelOn")
		
		if(panelOn) then
			-- Currently on, toggle OFF
			updatePlatformState(self, false)
		else
			-- Currently off, toggle ON
			updatePlatformState(self, true)
		end
	end
end

function updatePlatformState(self, newOnState)
	if newOnState then
		-- Turn on the panel damage flag and effects
		self:SetVar("bPanelOn", true)
		self:PlayFXEffect{name = "active", effectType = "zapOn"}
		
		-- The panel has been turned on, find all the players currently
		-- touching it and shock them
		local touchingPlatTable = self:GetVar("touchingPlatTable") or {}
		for zapPlayerID, playerTouching in pairs(touchingPlatTable) do
			if(playerTouching) then
				-- Store the reference touching player object 
				local targetObj = GAMEOBJ:GetObjectByID(zapPlayerID)
				-- Shock the target player
				shockPlayer(self, targetObj)
			end
		end
	   
	else
		-- Turn off the panel damage flag and effects
		self:SetVar("bPanelOn", false)
		self:StopFXEffect{name = "active"}
		
		-- The panel has been turned off, find all the players currently in contact
		-- being shocked by it and stop zapping them
		local beingShockedTable = self:GetVar("beingShockedTable") or {}
		for zapPlayerID, playerBeingZapped in pairs(beingShockedTable) do
			if(playerBeingZapped) then
				beingShockedTable[zapPlayerID] = nil
			end
		end
		-- Update tables
		self:SetVar("beingShockedTable", beingShockedTable)
	end
end

--------------------------------------------------------------
-- onTimerDone catches input and processes reshock events.
--------------------------------------------------------------
function onTimerDone(self, msg)
	-- split out the timer
	local tTimer = split(msg.name, "_")
	
	if tTimer[1] == "reshock" then
		if(self:GetVar("bPanelOn")) then
			-- Platform is on
			local touchingPlatTable = self:GetVar("touchingPlatTable") or {}
			local targetID = tTimer[2] or 0
		
			if ((target ~= 0) and (touchingPlatTable[targetID])) then
				-- The firing reshock timer has a valid touching player
				-- Store the reference touching player object 
				local targetObj = GAMEOBJ:GetObjectByID(targetID)
			
				-- Shock the target player
				shockPlayer(self, targetObj)
			else
				local beingShockedTable = self:GetVar("beingShockedTable") or {}
				
				-- Remove touching player to the beingShockedTable
				beingShockedTable[targetID] = nil
				-- Update tables
				self:SetVar("beingShockedTable", beingShockedTable)
			end
		end
	end
end

--------------------------------------------------------------
-- shockPlayer applies shock damage and effects to target Players.
--------------------------------------------------------------
function shockPlayer(self, target)
	local beingShockedTable = self:GetVar("beingShockedTable") or {}
	
	-- Cast skill damage on target player and play the shocked effect
	self:CastSkill{skillID = shockPanelSkillID, optionalTargetID = target}
	target:PlayFXEffect{effectID = 6026, effectType = "shock"}
	-- Add the target to the beingShockedTable
	beingShockedTable[target:GetID()] = true
    
	-- Apply a touch timer to reapply the effect and damage should the target remain in contact
	GAMEOBJ:GetTimer():AddTimerWithCancel(shockPanelSkillCooldown, "reshock_" .. target:GetID(), self)
	-- Update tables
	self:SetVar("beingShockedTable", beingShockedTable)
end

function split(str, pat)
    local t = {}
    
    -- creates a table of strings based on the passed in pattern   
    string.gsub(str .. pat, "(.-)" .. pat, function(result) table.insert(t, result) end)

    return t
end 

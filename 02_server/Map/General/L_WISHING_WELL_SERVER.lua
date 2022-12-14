--------------------------------------------------------------

-- L_ACT_WISHING_WELL_SERVER.lua

-- Server side script for the Wishing Well
-- updated abeechler ... 2/8/11 - refactored script for proper client/server behavior

--------------------------------------------------------------

local wishPrecondition = 165		-- Interact precondition = player needs 1 red Imaginite
local interactCooldown = 10			-- Enforced allowable time between interaction

function onStartup(self)
    -- Seed the object randomization for activity
    -- rating calculations
    math.randomseed(os.time())
end

----------------------------------------------
-- Check to see if the player can use the wishing well
----------------------------------------------
function onCheckUseRequirements(self,msg)
	local player = msg.objIDUser
	local playerID = player:GetID()
	
	-- Process the check player against the cooldown table to see if they may use it again
	local cooldownPlayerTable = self:GetVar("cooldownPlayerTable") or {}
    local bPlayerOnCooldown = cooldownPlayerTable[playerID]
    
    if bPlayerOnCooldown then 
		-- If the interact isn't ready, we can break and report failure
		msg.bCanUse = false
    else
		-- We have set-up a precondition for this interaction (wishPrecondition)
		-- check it to ensure interaction viability
		if(player:CheckPrecondition{PreconditionID = wishPrecondition}.bPass == false) then
			msg.bCanUse = false
		end
    end
    
    return msg
end

----------------------------------------------
-- Process successful player wish interaction
----------------------------------------------
function onUse(self,msg)
	local player = msg.user
	local playerID = player:GetID()
	local useSound = self:GetVar("sound1") or false
	
	if useSound then
		-- play the start audio
		self:PlayNDAudioEmitter{m_NDAudioEventGUID = useSound}	
	end
	
	-- A data structure containing players currently waiting to use the 
	-- wishing well again
	local cooldownPlayerTable = self:GetVar("cooldownPlayerTable") or {}
	
	-- Mark the interaction as in cooldown for the 
	-- use player and process
	cooldownPlayerTable[playerID] = true
	self:SetVar("cooldownPlayerTable", cooldownPlayerTable)
	self:NotifyClientObject{name = "StartCooldown", rerouteID = player}
    
    -- Start the cooldown for the use player
    GAMEOBJ:GetTimer():AddTimerWithCancel(interactCooldown, "Cooldown_" .. playerID, self)
    
    -- Assess the activity cost and rewards
    self:AddActivityUser{userID = player}
    self:ChargeActivityCost{user = player}
    self:DistributeActivityRewards{userID = player, bAutoAddCurrency = false, bAutoAddItems = false}
	self:RemoveActivityUser{userID = player}
	
	-- End the interaction
	player:TerminateInteraction{type = "fromInteraction", ObjIDTerminator = self}
end

--------------------------------------------------------------
-- Process a random activity rating for this object 
--------------------------------------------------------------
function onDoCalculateActivityRating(self, msg)
	-- Grab a random value from our desired range of activity ratings
	-- and assign it for loot determinations
    local random = math.random(1,1000) 
    msg.outActivityRating = random
    return msg
end

----------------------------------------------
-- Catch and process timer completed events
----------------------------------------------
function onTimerDone(self,msg)
	-- Split out the timer
	local tTimer = split(msg.name, "_")
	
	-- Is our player timer for a cooldown event?
	if tTimer[1] == "Cooldown" then
		local playerID = tTimer[2] or 0
		local player = GAMEOBJ:GetObjectByID(playerID)
		
		local cooldownPlayerTable = self:GetVar("cooldownPlayerTable")
		
		if(cooldownPlayerTable) then
			-- Remove the target player from the cooldown table and process
			cooldownPlayerTable[playerID] = nil
			self:SetVar("cooldownPlayerTable", cooldownPlayerTable)
		end
		
		if(player:Exists())then
			self:NotifyClientObject{name = "StopCooldown", rerouteID = player}
		end
	end
end

----------------------------------------------
-- String parse utility function
----------------------------------------------
function split(str, pat)
    local t = {}
    
    -- Creates a table of strings based on the passed in pattern   
    string.gsub(str .. pat, "(.-)" .. pat, function(result) table.insert(t, result) end)

    return t
end 

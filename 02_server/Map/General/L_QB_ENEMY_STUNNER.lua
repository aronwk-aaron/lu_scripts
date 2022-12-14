--------------------------------------------------------------
-- Server Script to be used for generic quickbuild enemy stunners
-- this script casts a skill on the enemies to stun them

-- created brandi... 11/3/10 - used siren script and generalized it to be used anywhere
-- Edited Medwards... 1/3/11 - Changed the way the skill is cast by explicitely attaching the skill to the object in the DB. 
-- Supports on 1 skill per object.
--------------------------------------------------------------

-- ***************************************************
-- DO NOT DO THIS:the skill number must be set in happy flower in the config data on the quickbuild asset
-- DO NOT DO THIS:skillNum 1:###
-- Instead of the above, make sure the skill you want on the stunner is attached in the DB. Only 1 skill can be used per stunner.
--
-- make sure reset time on the quickbuild in happy flower is set to -1
--
-- client_script_name should be scripts\02_client\Map\General\L_QB_SMASH_EFFECT.lua
-- ***************************************************

local TICK_DELAY = 1		-- the amount of time between skill casts to stun enemies
local EFFECT_DELAY = 20		-- the amount of time before the flashing effect is started after the QB is completed
local DIE_DELAY = 5			-- the amount of time the siren will flash before being destroyed
--local DEFAULT_SKILL = 499 	-- this skill will be used if one is not set up right in happy flower, so the script will work, just not correctly

--------------------------------------------------------------------------------
-- onRebuildNotifyState
-- 
-- Notes: Whenever the rebuild state changes Update
--------------------------------------------------------------------------------
function onRebuildComplete( self, msg )
	     -- Set to Darkling hated smashable faction Using PLAYER faction for now.
	    self:SetFaction{ faction = 115}
	    -- get the skill number set in HF, or use the defautlt
	    --local skill = self:GetVar("skillNum") or DEFAULT_SKILL
	   
		-- Cast the stun skill
		--self:CastSkill{skillID = skill}
		self:CastSkill{skillID = self:GetSkills().skills[1] } 
		-- start timer to cast skill
		GAMEOBJ:GetTimer():AddTimerWithCancel( TICK_DELAY , "TickTime", self )
	    -- set a time to smash QB
        GAMEOBJ:GetTimer():AddTimerWithCancel( EFFECT_DELAY , "PlayEffect", self )
        
end

-----------------------
-- Check if the timer for self death is done.
-------------------------
function onTimerDone(self, msg)
    if msg.name == "DieTime" then
         self:RequestDie{killerID = self, killType = "VIOLENT"}
         GAMEOBJ:GetTimer():CancelAllTimers( self )
    elseif msg.name == "PlayEffect" then    
		-- tell the client side script to play the "i'm about to smash" effect
		self:SetNetworkVar("startEffect", DIE_DELAY)
        GAMEOBJ:GetTimer():AddTimerWithCancel( DIE_DELAY, "DieTime", self )
    elseif msg.name == "TickTime" then
		--local skill = self:GetVar("skillNum") or DEFAULT_SKILL
	    --self:CastSkill{skillID = skill}
	    self:CastSkill{skillID = self:GetSkills().skills[1] } 
		GAMEOBJ:GetTimer():AddTimerWithCancel( TICK_DELAY, "TickTime", self )
   end
end
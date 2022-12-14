----------------------------------------
-- Server side AM Ape
--
-- created mrb... 1/7/11
----------------------------------------
require('02_server/Enemy/General/L_BASE_ENEMY_APE')

local QuickbuildAnchorLOT = 12900 	-- anchor for boss
local GroundPoundSkill = 725
local reviveTime = 12
local AnchorDamageDelayTime = 0.5
local spawnQBTime = 5

function onStartup(self)
	-- set constant varibales for the ape
	self:SetVar("QuickbuildAnchorLOT", QuickbuildAnchorLOT)
	self:SetVar("GroundPoundSkill", GroundPoundSkill)
	self:SetVar("reviveTime", reviveTime)
	self:SetVar("AnchorDamageDelayTime", AnchorDamageDelayTime)
	self:SetVar("spawnQBTime", spawnQBTime)
	
    baseStartup(self)
end 

function onDie(self, msg)
    baseDie(self, msg)
end

--When this skill is cast, spawn the anchor QB
function onCastSkill(self, msg)
	baseCastSkill(self, msg)
end

--check if armor is depleted then start timer and change faction
function onOnHit(self, msg)
	baseOnHit(self, msg)
end

-- Check timer to revive
function onTimerDone(self, msg)
	baseTimerDone(self, msg)
end


--Notify the Ape when the rebuild state changes
function onNotifyObject( self, msg )
    baseNotifyObject(self, msg)
end

--Store the QB so we can use it to smash the ape
function onChildLoaded( self,msg )
	baseChildLoaded(self, msg)
end

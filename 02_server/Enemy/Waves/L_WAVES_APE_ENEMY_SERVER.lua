----------------------------------------
-- Generic Server side Waves Boss Ape
--
-- created mrb... 12/2/10 - combined waves 
-- updated abeechler... 1/8/11 - removed script wander and aggro settings
-- enemy script and the ape script
----------------------------------------
require('02_server/Enemy/Waves/L_BASE_WAVES_GENERIC_ENEMY_SERVER')
require('02_server/Enemy/General/L_BASE_ENEMY_APE')

local QuickbuildAnchorLOT = 12900 	-- anchor for boss
local GroundPoundSkill = 725
local reviveTime = 12
local AnchorDamageDelayTime = 0.5
local spawnQBTime = 5

function onStartup(self)
    baseWavesStartup(self, nil)
    
	-- set constant varibales for the ape
	self:SetVar("QuickbuildAnchorLOT", QuickbuildAnchorLOT)
	self:SetVar("GroundPoundSkill", GroundPoundSkill)
	self:SetVar("reviveTime", reviveTime)
	self:SetVar("AnchorDamageDelayTime", AnchorDamageDelayTime)
	self:SetVar("spawnQBTime", spawnQBTime)
	
    baseStartup(self)
end 

function onGetActivityPoints(self, msg)
    return baseWavesGetActivityPoints(self, msg, nil)
end

function onDie(self, msg)
    baseWavesDie(self, msg, nil)
    baseDie(self, msg)
end

--When this skill is cast, spawn the anchor QB
function onCastSkill(self, msg)
	baseCastSkill(self, msg)
end

--Notify the Ape when the rebuild state changes
function onNotifyObject( self, msg )    
	baseNotifyObject(self, msg)
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

--Store the QB so we can use it to smash the ape
function onChildLoaded( self,msg )
	baseChildLoaded(self, msg)
end 
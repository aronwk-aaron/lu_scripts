----------------------------------------
-- Base Server side Ape script
--
-- created mrb... 1/7/11 
-- updated abeechler... 2/2/11 - Local calls to base functions added
----------------------------------------
require('02_server/Enemy/General/L_SUSPEND_LUA_AI')

local defaultQuickbuildAnchorLOT = 7549 	-- anchor for boss
local defaultGroundPoundSkill = 725
local defaultReviveTime = 12
local defaultAnchorDamageDelayTime = 0.5 
local defaultSpawnQBTime = 5

function onStartup(self) 
	baseStartup(self)
end

function baseStartup(self)    	
    self:SetVar("timesStunned", 2)
    self:SetStunImmunity{StateChangeType = "PUSH", bImmuneToStunAttack = true,  bImmuneToStunMove = true, bImmuneToStunTurn = true, bImmuneToStunUseItem = true, bImmuneToStunEquip = true, bImmuneToStunInteract = true} -- Make immune to stuns
    self:SetStatusImmunity{ StateChangeType = "PUSH", bImmuneToPullToPoint = true, bImmuneToInterrupt = true, bImmuneToKnockback = true } -- Make immune to move/teleport behaviors
    self:SetVar("KnockedOut", false) -- make a var used to see if the ape has been knocked out
    
    -- turn off lua ai
    suspendLuaAI(self)
end 

function onDie(self, msg)
	baseDie(self, msg)
end 

function baseDie(self, msg)    
	--print("Ape died...")
	local qbIDs = self:GetVar("QB") or {}
	
	for objID, alive in pairs(qbIDs) do
		if alive then
			local obj = GAMEOBJ:GetObjectByID(objID)
			
			if obj:Exists() then
				obj:RequestDie{killType = "SILENT"}
			end
		end
	end
end

function onCastSkill(self, msg)
	baseCastSkill(self, msg)
end

function CheckQBsReady(self)	
	return not self:GetVar("QB") 
end

--When this skill is cast, spawn the anchor QB
function baseCastSkill(self, msg)
	local GroundPoundSkill = self:GetVar("GroundPoundSkill") or defaultGroundPoundSkill
	
    if msg.skillID == GroundPoundSkill and CheckQBsReady(self) then		
		local spawnQBTime = self:GetVar("spawnQBTime") or defaultSpawnQBTime
		
        GAMEOBJ:GetTimer():AddTimerWithCancel( spawnQBTime , "SpawnQBTime", self ) 
	end     
end

function onOnHit(self, msg)
	baseOnHit(self, msg)
end

--check if armor is depleted then start timer and change faction
function baseOnHit(self, msg)
    if self:GetArmor{}.armor < 1 and self:GetVar("KnockedOut") == false then
		-- disable AI
        self:EnableCombatAIComponent {bEnable = false}
        --self:ClearThreatList()
        self:CancelSkillCast()
        
		-- set stunned
        self:SetStunned{StateChangeType = "PUSH", bCantMove = true, bIgnoreImmunity = true, bCantTurn = true}
        self:SetVar("KnockedOut", true)
        
        -- clear qb timer and set revive timer
        GAMEOBJ:GetTimer():CancelTimer("SpawnQBTime", self) 
        
		local reviveTime = self:GetVar("reviveTime") or defaultReviveTime
        
        GAMEOBJ:GetTimer():AddTimerWithCancel( reviveTime , "ReviveTime", self )        
        
        -- set animation
        self:ChangeIdleFlags{off = 9}
        self:PlayAnimation{animationID = "disable",fPriority = 1.7}
    end
end

function onTimerDone(self, msg)
	baseTimerDone(self, msg)
end

-- Check timer to revive
function baseTimerDone(self, msg)
    if msg.name == "ReviveTime" then      
		-- set variables for revive
		local timesStunned = self:GetVar("timesStunned") or 1
		local reviveArmor = self:GetMaxArmor().armor / timesStunned
        
        self:SetArmor{armor = reviveArmor}
        self:SetVar("timesStunned", timesStunned + 1)
        
        -- set animations 
        self:ChangeIdleFlags{on = 9}
        
        -- unstun boss and start the AI
        self:SetStunned{StateChangeType = "POP", bCantMove = true, bIgnoreImmunity = true, bCantTurn = true}
        self:EnableCombatAIComponent {bEnable = true}
        self:SetVar("KnockedOut", false)
	elseif msg.name == "SpawnQBTime" and CheckQBsReady(self) then
		local mypos = self:GetPosition().pos
		local myRot = self:GetRotation()
		local parent = msg.killerID
		--put quick build on Apes look dir
		local oPos = { pos = "", rot = ""}
		local oDir = self:GetObjectDirectionVectors()
		
		oPos.pos = self:GetPosition().pos
		oPos.pos.y = oPos.pos.y
		oPos.pos.x = oPos.pos.x - (oDir.backward.x * 8) 
		oPos.pos.z = oPos.pos.z - (oDir.backward.z * 8) 

		local posString = self:CreatePositionString{ x = (oPos.pos.x), y = oPos.pos.y, z = (oPos.pos.z) }.string
		local lootTag = "|" .. self:GetEnemyLootTag().enemyID:GetID()
		local config = { {"rebuild_activators", posString }, {"no_timed_spawn", true}, {"lootTagOwner", lootTag} } --{"respawn", 100000 }, {"rebuild_reset_time", 1}, {"currentTime", 0}, 
		local QuickbuildAnchorLOT = self:GetVar("QuickbuildAnchorLOT") or defaultQuickbuildAnchorLOT
		
		-- load the QB
		RESMGR:LoadObject { objectTemplate = QuickbuildAnchorLOT, x= mypos.x, y= mypos.y + 13, z= mypos.z, rw= myRot.w, rx= myRot.x, ry= myRot.y , rz = myRot.z, configData = config, owner = self }
	elseif msg.name == "AnchorDamageTimer" then
		local player = GAMEOBJ:GetObjectByID(self:GetVar("Smasher"))
		
		self:CastSkill{skillID = 1273, optionalOriginatorID = player}
	end
end

function onNotifyObject(self, msg)
	baseNotifyObject( self, msg )
end

--Notify the Ape when the rebuild state changes
function baseNotifyObject( self, msg )
    -- if the rebuild is complete
	if ( msg.name == "rebuildDone" ) then
		--Getting the sender ID which we set as the player and storing it for the DIE call
		self:SetVar("Smasher", "|" .. msg.ObjIDSender:GetID())

		local AnchorDamageDelayTime = self:GetVar("AnchorDamageDelayTime") or defaultAnchorDamageDelayTime
		
		-- set the die delay time
		GAMEOBJ:GetTimer():AddTimerWithCancel( AnchorDamageDelayTime, "AnchorDamageTimer", self )
	end
end

function onChildLoaded(self, msg)
	baseChildLoaded( self,msg )
end

--Store the QB so we can use it to smash the ape
function baseChildLoaded( self,msg )
	local QuickbuildAnchorLOT = self:GetVar("QuickbuildAnchorLOT") or defaultQuickbuildAnchorLOT
	
	if msg.templateID ~= QuickbuildAnchorLOT then return end
	
	-- clear qb timer and set revive timer
	GAMEOBJ:GetTimer():CancelTimer("SpawnQBTime", self) 
	
	self:SetVar("QB."..msg.childID:GetID(), true)
end

function onChildRemoved(self, msg)
	baseChildRemoved(self, msg)
end

function baseChildRemoved(self, msg)
	local QuickbuildAnchorLOT = self:GetVar("QuickbuildAnchorLOT") or defaultQuickbuildAnchorLOT
	local childLOT = msg.childID:GetLOT().objtemplate or 0
	
	if childLOT ~= QuickbuildAnchorLOT then return end

	self:SetVar("QB."..msg.childID:GetID(), nil)
end 
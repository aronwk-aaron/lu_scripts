----------------------------------------
-- Server side Waves boss Hammerling script
--
-- created mrb... 12/2/10 
-- updated abeechler... 1/8/11 - removed script wander and aggro settings
----------------------------------------
require('02_server/Enemy/Waves/L_BASE_WAVES_GENERIC_ENEMY_SERVER')

local iPoints = 1000 -- global constant for the enemies point value
local knockbackSkill = 589
local animName = "taunt"

function onStartup(self)
    baseWavesStartup(self, nil)
    
    -- dissable AI component, the zone script will tell us to enable again
	self:EnableCombatAIComponent {bEnable = false}
    
     -- Make immune to move/teleport behaviors
    self:SetStunImmunity{StateChangeType = "PUSH", bImmuneToStunAttack = true, bImmuneToStunMove = true, bImmuneToStunTurn = true, bImmuneToStunUseItem = true, bImmuneToStunEquip = true, bImmuneToStunInteract = true} -- Make immune to stuns
    self:SetStatusImmunity{ StateChangeType = "PUSH", bImmuneToPullToPoint = true, bImmuneToKnockback = true, bImmuneToInterrupt = true} -- Make immune to knockbacks and pulls
	
	SetBossImmunity(self, true)
    
    --self:AddSkill{skillID = knockbackSkill, temporaryReplaceAttack = false, temporary = false}
    
    local kbHealth = self:GetMaxHealth().health
    local kbHealthTick = kbHealth/3
    
    self:SetVar("knockbackTickHealth", kbHealthTick)    
    self:SetVar("knockbackHealth", kbHealth - kbHealthTick)
    
    self:AddObjectToGroup{group = "boss"}
	
	self:SetVar("CurrentlyImmune", false) -- flag to prevent the enemy from becoming immune more than once. 
end 

function SetBossImmunity(self, bTurnOn)
	local state = "PUSH"
	local bImmunity = true  -- mark the enemy as immune to prevent multiple immunity pushes	
	
	if not bTurnOn then
		state = "POP"
		bImmunity = false -- Immunity will be removed, so remember the enemy is now vulnerable
	end
	
	self:SetVar("CurrentlyImmune", bImmunity)	
	self:SetStatusImmunity{ StateChangeType = state, bImmuneToSpeed = true, bImmuneToBasicAttack = true, bImmuneToDOT = true}
end

function onHitOrHealResult(self, msg)
	if msg.diedAsResult or msg.receiver:GetID() ~= self:GetID() then return end
	
	local bImmune = self:GetVar("CurrentlyImmune")
	if bImmune then return end -- the enemy is already immune and playing its special attack. Ignore further hits this frame.
	
	local knockbackHealth = self:GetVar("knockbackHealth")
	
    if self:GetHealth().health <= knockbackHealth then		
		self:SetVar("knockbackHealth", knockbackHealth - self:GetVar("knockbackTickHealth"))
		
		 -- Make immune to move/teleport behaviors
		SetBossImmunity(self, true)
		self:CancelSkillCast()
		
		local animTime = self:GetAnimationTime{animationID = animName}.time or 0
		
		if animTime > 0 then										
			self:QueueAISkill{skillID = knockbackSkill} --CastSkill{skillID = knockbackSkill, optionalOriginatorID = self}
			
			self:PlayFXEffect{name = "charge", effectID = 5467, effectType = "charge"} --3576
			self:PlayAnimation{animationID = animName, fPriority = 4, bPlayImmediate = true}
		end
    end
end

function onNotifyObject( self, msg )
	if ( msg.name == "startAI" ) then
		self:EnableCombatAIComponent {bEnable = true}		
		-- Pop immune
		SetBossImmunity(self, false)
	end
end

function onGetActivityPoints(self, msg)
    return baseWavesGetActivityPoints(self, msg, nil)
end

function onDie(self, msg)
    baseWavesDie(self, msg, nil)
end

function onCastSkill(self, msg)
	if msg.skillID == knockbackSkill then
		GAMEOBJ:GetTimer():AddTimerWithCancel( 0.5, "playFX", self )	
	end
end

function onTimerDone(self, msg)
    if msg.name == "playFX" then    		
		self:PlayFXEffect{name = "cast", effectID = 5467, effectType = "cast"} --953
		self:PlayFXEffect{name = "repulse", effectID = 5467, effectType = "repulse"}
		 -- Pop immune
		SetBossImmunity(self, false)
    end
end 
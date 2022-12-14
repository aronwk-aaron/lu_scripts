----------------------------------------
-- Server side Waves boss horesemen script
--
-- created mrb... 12/2/10 
-- updated abeechler... 1/8/11 - removed script wander and aggro settings
----------------------------------------
require('02_server/Enemy/Waves/L_BASE_WAVES_GENERIC_ENEMY_SERVER')

local iPoints = 5000 -- global constant for the enemies point value

function onStartup(self)
    baseWavesStartup(self, nil)
    
    -- dissable AI component, the zone script will tell us to enable again
	self:EnableCombatAIComponent {bEnable = false}
    
     -- Make immune to move/teleport behaviors
    self:SetStunImmunity{StateChangeType = "PUSH", bImmuneToStunAttack = true, bImmuneToStunMove = true, bImmuneToStunTurn = true, bImmuneToStunUseItem = true, bImmuneToStunEquip = true, bImmuneToStunInteract = true} -- Make immune to stuns
    self:SetStatusImmunity{ StateChangeType = "PUSH", bImmuneToPullToPoint = true, bImmuneToKnockback = true, bImmuneToInterrupt = true } -- Make immune to knockbacks and pulls
    
	SetBossImmunity(self, true)
	
    self:AddObjectToGroup{group = "boss"}
end 

function SetBossImmunity(self, bTurnOn)
	local state = "PUSH"
	
	if not bTurnOn then
		state = "POP"
	end
	
	self:SetStatusImmunity{ StateChangeType = state, bImmuneToSpeed = true, bImmuneToBasicAttack = true, bImmuneToDOT = true}

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
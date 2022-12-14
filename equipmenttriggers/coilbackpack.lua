--------------------------------------------------------------
-- Counts the number of times a player wearing a certain item gets hit and then casts a skill when they are hit enough.
-- Dcross 9/16/11

--------------------------------------------------------------

function onFactionTriggerItemEquipped (self)
     self:SendLuaNotificationRequest{requestTarget=self:GetItemOwner().ownerID, messageName="HitOrHealResult"}
     self:SetVar("hitCount", 0)
end

function notifyHitOrHealResult( self, other, msg )
    local player = self:GetItemOwner().ownerID  
    if player:GetID() == other:GetID() and player:GetID()== msg.receiver:GetID() then 
        if (msg.armorDamageDealt > 0) or (msg.lifeDamageDealt > 0) then                                  
            local hitCount = self:GetVar("hitCount")
			
            if hitCount >= 4 then
                player:CastSkill{skillID = 1001} 
				self:SetVar("hitCount", 0)
			else
				hitCount = hitCount + 1
				self:SetVar("hitCount", hitCount)
            end
        end    
    end
end

function onFactionTriggerItemUnequipped (self)
    self:SendLuaNotificationCancel{requestTarget=self:GetItemOwner().ownerID, messageName="HitOrHealResult"}
end

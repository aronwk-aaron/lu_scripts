--------------------------------------------------------------
-- Counts the number of times a player wearing a certain item gets hit and then casts a skill when they are hit enough.
-- MEdwards 9/29/11
--------------------------------------------------------------

-- Registers that the item with this script was equiped
function onFactionTriggerItemEquipped (self)
     self:SendLuaNotificationRequest{requestTarget=self:GetItemOwner().ownerID, messageName="HitOrHealResult"}
     self:SetVar("coilCount", 0)
end

-- Checks if a player was dealt damage and keeps count. When the count exceeds 4 a skill is fired and the count is reset.
function notifyHitOrHealResult( self, other, msg )
    local player = self:GetItemOwner().ownerID  
    if player:GetID() == msg.receiver:GetID() then 
        if (msg.armorDamageDealt > 0) or (msg.lifeDamageDealt > 0) then                                  
            self:SetVar("coilCount", self:GetVar("coilCount") + 1)
            if self:GetVar("coilCount") > 4 then
                player:CastSkill{skillID = 1750} 
                self:SetVar("coilCount", 0)
            end
        end    
    end
end

--Registers that the item was unequiped and cancels listening for the message
function onFactionTriggerItemUnequipped (self)
    self:SendLuaNotificationCancel{requestTarget=self:GetItemOwner().ownerID, messageName="HitOrHealResult"}
end
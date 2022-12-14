--------------------------------------------------------------
-- Server side script for the lootable chest for the dragon fight.
--
-- updated by mrb... 8/30/10 - added network var from server so 
-- that only one person can use the chest, but all clients get the animations
--------------------------------------------------------------

function onCheckUseRequirements(self, msg)

	local preConVar = self:GetVar("CheckPrecondition")
	local check = msg.objIDUser:CheckListOfPreconditionsFromLua{PreconditionsToCheck = preConVar, requestingID = self}
	
	-- dont let the playe use this if the minigame is active or they dont meet the precondition check.
	if not check.bPass  then
		msg.bCanUse = false
	end
    
    return msg
end

function onUse(self,msg)
    local player = msg.user
	local key = self:GetVar("KeyNum")
	
	--	the CheckUseRequirements, but just in case
	if (player:GetInvItemCount{ iObjTemplate = key}.itemCount == 1) then 
		--remove the bricks from the players inventory
		player:RemoveItemFromInventory{iObjTemplate = key, iStackCount = 1 }
	end
	
	local itemRewardID = self:GetVar("openItemID")
	player:AddItemToInventory{iObjTemplate = itemRewardID, itemCount = 1, bMailItemsIfInvFull = true}
end 



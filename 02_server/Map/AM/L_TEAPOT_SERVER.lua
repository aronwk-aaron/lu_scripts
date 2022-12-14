--------------------------------------------------------------
-- Server script for teapot in aura mar
-- give the player consumable tea for tea leaves

-- created by brandi.. 10/28/10
--------------------------------------------------------------

-- when the player interact with the teapot
function onUse(self,msg)

		local player = msg.user
		-- makes sure the player has the required amount of tea leaves, they shouldnt get past 
		--	the CheckUseRequirements, but just in case
		if player:GetInvItemCount{ iObjTemplate = 12317}.itemCount >= 10 then
			--remove the bricks from the players inventory
			player:RemoveItemFromInventory{iObjTemplate = 12317, iStackCount = 10 }
			player:AddItemToInventory{iObjTemplate = 12109, itemCount = 1}	
		end
		-- be sure to ternimate the interaction so the shift icon comes up again.
		player:TerminateInteraction{type = 'fromInteraction', ObjIDTerminator = self}
	
end
       

function onCollisionPhantom (self,msg)

	local player = msg.objectID
	 
	for i =1, player:GetInventorySize{inventoryType = 1 }.size  do
		if player:GetInventoryItemInSlot{slot = i }.itemID:Exists() then   
		    

			 player:RemoveItemFromInventory{ iObjTemplate = player:GetInventoryItemInSlot{slot = i}.itemID:GetLOT{}.objtemplate }  
		  
		end
	end

end

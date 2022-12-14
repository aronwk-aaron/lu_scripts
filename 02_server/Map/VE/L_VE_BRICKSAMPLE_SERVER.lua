
function onUse(self, msg)
	local player = msg.user

	local lootLOT = self:GetVar("Loot") --935     -- LOT of the loot object to spawn
	if player:GetMissionState{missionID = 1183}.missionState == 2 then
	
		if player:GetInvItemCount{ iObjTemplate = lootLOT}.itemCount == 0 then
			player:AddItemToInventory{iObjTemplate = lootLOT, itemCount = 1, bMailItemsIfInvFull = true}	
			notifyGroup(self, "Bricks")
		end
	end
end

function notifyGroup(self, groupName)
	local group = self:GetObjectsInGroup{group = groupName, ignoreSpawners = true}.objects
	for index, object in next, group do
		object:NotifyClientObject{name = "Pickedup"}
	end
end
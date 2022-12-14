------------------------------------------------------------------
--Script for Speedy Delivery missions 
--Shared by NPC "ONE-Eight-ONE and Vendrox in the Nexus tower Assembly store area"
--Script gives the Delivery Package when the player accepts the mission for Delivery
--the mission were changed to Gather missions due to the Delivery Task not working
--Created 2/9/11 by Ray
------------------------------------------------------------------------

function onMissionDialogueOK(self, msg) 

	if msg.iMissionState == 1 then
		msg.responder:AddItemToInventory{iObjTemplate = 13578, itemCount = 1, bMailItemsIfInvFull = true} --gives item for Sentinel Spy mission
	end
end
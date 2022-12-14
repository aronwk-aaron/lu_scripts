--------------------------------------------------------------
-- Server side script for Wisp
-- 
-- updated abeechler ... 7/13/11 - removed add item on first mission
--------------------------------------------------------------
require('02_server/Map/General/L_VIS_TOGGLE_NOTIFIER_SERVER')

-- Associate inventory items to dispense on keyed mission ID values					
local MissionItemTable = {[1849] = {{items = {14592}, add = false, remove = true}}, 
                          [1883] = {{items = {14592}, add = true, remove = true}}}

-- Table mapping mission IDs to spawner network names
local VisibilityMissionTable = {[1849] = {"MaelstromSamples"},
                                [1883] = {"MaelstromSamples", "MaelstromSamples2ndary1", "MaelstromSamples2ndary2"}}
                                
----------------------------------------------------------------
-- Catch object instantiation
----------------------------------------------------------------                   
function onStartup(self)

	setGameVariables(self, VisibilityMissionTable)
	
end 

----------------------------------------------
-- Catch and parse dialogue acceptance messages
----------------------------------------------
function onMissionDialogueOK(self, msg)
    local itemObjects = MissionItemTable[msg.missionID]
    
    -- dont do anything if this mission doesn't have an entry in the MissionItemTable
	if not itemObjects then return end
	
	local itemMissionState = msg.iMissionState
	local player = msg.responder
	
	-- loop through the tables for this mission
	for i,itemTable in pairs(itemObjects) do
		-- loop through the items to add or remove	
		for k, itemLOT in ipairs(itemTable.items) do
			if itemTable.add and itemMissionState == 1 or itemMissionState == 9 then
				-- Player has accepted item mission, add necessary items if they aren't there
				if(player:GetInvItemCount{iObjTemplate = val}.itemCount == 0) then
				    player:AddItemToInventory{iObjTemplate = itemLOT, itemCount = 1, bMailItemsIfInvFull = true}
				end
			elseif itemTable.remove and itemMissionState == 4 or itemMissionState == 12 then
				-- Player has turned in the mission, remove necessary items
				player:RemoveItemFromInventory{iObjTemplate = itemLOT, itemCount = 1}
			end
		end
	end
    
    baseMissionDialogueOK(self, msg) 
end 
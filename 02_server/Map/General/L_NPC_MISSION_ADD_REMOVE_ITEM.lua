--------------------------------------------------------------
-- Server side script for NPCs that will add/remove objects on mission
--
-- Created mrb ... 6/15/11
-- updated abeechler ... 6/23/11 - Removed bIsComplete checking for Mission State processing
--------------------------------------------------------------
--************************************************************
--------------------------------------------------------------

--************************************************************
-- **** add this to the script requiring this scripts and uncomment ****
--************************************************************

--[[
require('02_server/Map/General/L_NPC_MISSION_ADD_REMOVE_ITEM')
-- Associate inventory items to dispense on keyed mission ID values.
local MissionItemTable = {} -- should be formated: 	{[MissionID] = 	{items = {objectID_1,objectID_2,etc...}, add = true, remove = false},	-- only add on accept
--																	{items = {objectID_1,objectID_2,etc...}, add = false, remove = true}, 	-- only remove on complete
--																	{items = {objectID_1,objectID_2,etc...}, add = true, remove = true},	-- add on accept and remove on complete
													}, 
--													{[MissionID] =	{items = {objectID_1,objectID_2,etc...}, add = true, remove = false},	-- only add on accept
--																	{items = {objectID_1,objectID_2,etc...}, add = false, remove = true}, 	-- only remove on complete
--																	{items = {objectID_1,objectID_2,etc...}, add = true, remove = true},	-- add on accept and remove on complete
													} 
													
--------------------------------------------------------------
---- Catch object instantiation
--------------------------------------------------------------                  
function onStartup(self)
	setMissionVariables(self, MissionItemTable)	
end 
]]--

--------------------------------------------------------------
--************************************************************
--------------------------------------------------------------

local MissionItemTable = {}

--------------------------------------------------------------
-- variables passed of the level specific script that are used throughout the base script
--------------------------------------------------------------
function setMissionVariables(self, passedMissionItemTable)
	MissionItemTable = passedMissionItemTable
end

----------------------------------------------
-- Catch and parse dialogue acceptance messages
----------------------------------------------
function onMissionDialogueOK(self, msg)      
    baseMissionDialogueOK(self, msg) 
end

function baseMissionDialogueOK(self, msg)
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
				-- Player has accepted item mission, add necessary items
				player:AddItemToInventory{iObjTemplate = itemLOT, itemCount = 1, bMailItemsIfInvFull = true}
			elseif itemTable.remove and itemMissionState == 4 or itemMissionState == 12 then
				-- Player has turned in the mission, remove necessary items
				player:RemoveItemFromInventory{iObjTemplate = itemLOT, itemCount = 1}
			end
		end
	end
end 
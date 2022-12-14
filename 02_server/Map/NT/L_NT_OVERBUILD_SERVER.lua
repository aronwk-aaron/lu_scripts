--------------------------------------------------------------

-- L_NT_OVERBUILD_SERVER.lua

-- created by brandi.. 2/15/11
-- updated abeechler ... 3/4/11 - added generic guard behaviors
-- updated abeechler ... 4/21/11 - removed the add item logic

--------------------------------------------------------------
require('02_server/Map/NT/L_NT_BC_SUBMIT_SERVER')
require('02_server/Map/NT/L_NT_FACTION_SPY_SERVER')

local backpackMisID = 1399

local SpyProxRadius = 30			-- the radius for Overbuild proximity detection

------------------------------------------------------
-- The L_NT_FACTION_SPY_SERVER script configData set on the object in HF:
-- SpyCinematic				-> 0:cine_name
-- SpyConvo2Group		    -> 0:secondary_spy_convo_object_group_name
------------------------------------------------------

-- Spy dialogue table = formats required information for spying conversations
local SpyDialogueTable = { {dialogueToken = "OVERBUILD_NT_CONVO_1", convoID = 1},
                           {dialogueToken = "OVERBUILD_NT_CONVO_2", convoID = 2},
                           {dialogueToken = "OVERBUILD_NT_CONVO_3", convoID = 1},
                           {dialogueToken = "OVERBUILD_NT_CONVO_4", convoID = 2},
                           {dialogueToken = "OVERBUILD_NT_CONVO_5", convoID = 1},
                           {dialogueToken = "OVERBUILD_NT_CONVO_6", convoID = 2},
                           {dialogueToken = "OVERBUILD_NT_CONVO_7", convoID = 1} }

-- Spy data table = formats required information for each valid spy mission target                     
local SpyDataTable = {spyFlagID = 1976, spyItemID = 13891, spyMissionID = 1320}

function onStartup(self)
	-- Create a table of spy dialogue participants for Overbuild
	local secondaryObjGroupTable = {}
	-- Grab the object config data for the secondary target
    -- (if one exists)
    local secondaryObjGroup = self:GetVar("SpyConvo2Group") or false
	if(secondaryObjGroup) then
		 table.insert(secondaryObjGroupTable, secondaryObjGroup)
	end
	
	-- Use the utility function to build the spy dialogue object table
	local SpyDialogueObjTable =  buildSpyDialogueObjTable(self, secondaryObjGroupTable)
	
	setGameVariables(self, SpyDialogueTable, SpyDialogueObjTable, SpyDataTable, SpyProxRadius)	
end 
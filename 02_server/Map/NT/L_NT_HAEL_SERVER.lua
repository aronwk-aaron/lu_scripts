--------------------------------------------------------------

-- L_NT_HAEL_SERVER.lua

-- Server side Hael Storm script 
-- Created abeechler ... 4/12/11

--------------------------------------------------------------
require('02_server/Map/NT/L_NT_BC_SUBMIT_SERVER')
require('02_server/Map/NT/L_NT_FACTION_SPY_SERVER')

local SpyProxRadius = 25			-- the radius for Hael proximity detection

------------------------------------------------------
-- The L_NT_FACTION_SPY_SERVER script configData set on the object in HF:
-- SpyCinematic				-> 0:cine_name
------------------------------------------------------

-- Spy dialogue table = formats required information for spying conversations
local SpyDialogueTable = { {dialogueToken = "HAEL_NT_CONVO_1", convoID = 1},
                           {dialogueToken = "HAEL_NT_CONVO_2", convoID = 1},
                           {dialogueToken = "HAEL_NT_CONVO_3", convoID = 1},
                           {dialogueToken = "HAEL_NT_CONVO_4", convoID = 1} }

-- Spy data table = formats required information for each valid spy mission target                     
local SpyDataTable = {spyFlagID = 1977, spyItemID = 13892, spyMissionID = 1321}

----------------------------------------------
-- Process Startup events
----------------------------------------------
function onStartup(self)
	-- Create a table of spy dialogue participants for Duke
	local SpyDialogueObjTable = {self}
	
	setGameVariables(self, SpyDialogueTable, SpyDialogueObjTable, SpyDataTable, SpyProxRadius)
	
end

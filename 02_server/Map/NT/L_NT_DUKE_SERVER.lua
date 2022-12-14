--------------------------------------------------------------

-- L_NT_DUKE_SERVER.lua

-- Server side Duke Exeter script 
-- Created abeechler ... 4/12/11
-- Modified abeechler ... 5/9/11 - Added mission item dispensing to Duke

--------------------------------------------------------------
require('02_server/Map/NT/L_NT_BC_SUBMIT_SERVER')
require('02_server/Map/NT/L_NT_FACTION_SPY_SERVER')

local SpyProxRadius = 35			-- the radius for Overbuild proximity detection

------------------------------------------------------
-- The L_NT_FACTION_SPY_SERVER script configData set on the object in HF:
-- SpyCinematic				-> 0:cine_name
------------------------------------------------------

-- Spy dialogue table = formats required information for spying conversations
local SpyDialogueTable = { {dialogueToken = "DUKE_NT_CONVO_1", convoID = 1},
                           {dialogueToken = "DUKE_NT_CONVO_2", convoID = 1},
                           {dialogueToken = "DUKE_NT_CONVO_3", convoID = 1} }

-- Spy data table = formats required information for each valid spy mission target                     
local SpyDataTable = {spyFlagID = 1974, spyItemID = 13548, spyMissionID = 1319}

-- Associate inventory items to dispense on keyed mission ID values.
local MissionItemTable = {[1448] = {13777}}

----------------------------------------------
-- Process Startup events
----------------------------------------------
function onStartup(self)
	-- Create a table of spy dialogue participants for Duke
	local SpyDialogueObjTable = {self}
	
	setGameVariables(self, SpyDialogueTable, SpyDialogueObjTable, SpyDataTable, SpyProxRadius)
	
end

----------------------------------------------
-- Catch and parse dialogue acceptance messages
----------------------------------------------
function onMissionDialogueOK(self, msg)  
    
    local player = msg.responder
    local missionID = msg.missionID
    
    if(MissionItemTable[missionID]) then
    
        local itemMissionState = msg.iMissionState

        -- Adds/Removes mission associated items to the player's inventory
        -- based on the itemMissionState
        for i, val in ipairs(MissionItemTable[missionID]) do
            if(itemMissionState == 1) then
                -- Player has accepted item mission, add necessary items
                player:AddItemToInventory{iObjTemplate = val, itemCount = 1, bMailItemsIfInvFull = true}
            elseif(msg.bIsComplete) then
                -- Player has turned in the mission, remove necessary items
                player:RemoveItemFromInventory{iObjTemplate = val, itemCount = 1}
            end
        end
    end
    
    baseMissionDialogueOK(self, msg) 
end

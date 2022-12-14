--------------------------------------------------------------

-- L_VIS_TOGGLE_NOTIFIER_SERVER.lua

-- Runs notification for visibiltiy toggle objects based
-- on defined mission acceptance
-- created abeechler - 6/8/11
--------------------------------------------------------------

----------------------------------------------------------------
-- Define empty tables that will be set from the 
-- specific notification object
----------------------------------------------------------------
local VisibilityMissionTable = {}

----------------------------------------------------------------
-- Variables passed from the object specific script that are used throughout this utility script
----------------------------------------------------------------
function setGameVariables(self, passedVisibilityMissionTable)

	VisibilityMissionTable = passedVisibilityMissionTable
	
end

----------------------------------------------------------------
-- Provide base function for dialogue acceptance that catches 'OK' events 
-- and processes associated object visibility when necessary
----------------------------------------------------------------
function baseMissionDialogueOK(self, msg) 
	
	local player = msg.responder
    local missionID = msg.missionID
    
    -- Is this a mission that is defined to process
    -- the visibility state of associated object networks?
    if(VisibilityMissionTable[missionID]) then
    
        local bVisible = 1
        local itemMissionState = msg.iMissionState
        
        if(itemMissionState == 4 or itemMissionState == 12) then
            -- We have completed and are turning in a mission
            -- mark the visible state as false
            bVisible = 0
        end
        
        -- Iterate through the networks associated to the given mission
        -- via the mission visibility table and notify the objects spawned 
        -- on them of their current visibility state
        for i, sNetworkNom in ipairs(VisibilityMissionTable[missionID]) do
            -- Obtain a reference to the spawn network
            local sNetwork = LEVEL:GetSpawnerByName(sNetworkNom)
            -- Confirm the network's existence
            if((sNetwork) and (sNetwork:Exists())) then
                -- Get all the currently spawned objects on the spawner network
	            local sNetworkObjs = sNetwork:SpawnerGetAllObjectIDsSpawned().objects
                -- Loop through the network objects found and mark
                -- their appropriate visibility state
                for k, obj in ipairs(sNetworkObjs) do
		            obj:NotifyClientObject{name = "SetVisibility", param1 = bVisible, rerouteID = player}
	            end
            end
        end
        
    end
    
end

----------------------------------------------------------------
-- Default mission acceptance catch
----------------------------------------------------------------
function onMissionDialogueOK(self, msg) 

	baseMissionDialogueOK(self, msg) 
	
end

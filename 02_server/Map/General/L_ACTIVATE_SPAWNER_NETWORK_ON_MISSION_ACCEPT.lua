--------------------------------------------------------------
-- Generic script to put on an mission giver to activate a 
-- spawnerNetwork on mission accept.
--
-- Mission Giver needs to have config data added to HF to function:
-- missionID    ->  1:*mission ID number*
-- spawnerName  ->  0:*spawner network name*
--
-- created mrb... 10/26/10 
--------------------------------------------------------------

function onMissionDialogueOK(self,msg)    
    local missionID = self:GetVar("missionID")      -- get the mission id off the config data from HF
    local spawnerName = self:GetVar("spawnerName")  -- get the spawner name off the config data from HF
    
    -- check to see if the config data is set, if not send a message to the server log
    if not missionID or not spawnerName then
        -- only print if it is an internal build
        if self:GetVersioningInfo().bIsInternal then
            print("*** " .. self:GetName().name .. " is missing config data. ***")
            print("*** This needs to have missionID and spawnerName to work. ***")
        end
        
        return
    end
    
    -- check if it's the right mission and it has been accepted
    if msg.missionID == missionID and msg.iMissionState < 2 then
        local spawner = LEVEL:GetSpawnerByName(spawnerName)
        
        -- activate the spawner network if it is valid
        if spawner then
            spawner:SpawnerActivate()
        end
    end        
end 
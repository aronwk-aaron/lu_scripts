--------------------------------------------------------------

-- L_LS_INTRO_VOL.lua

-- Server script for the volume by the introductory landing pad allowing
-- for the catch and processing of every loaded character.

-- Created abeechler... 9/22/11 

-------------------------------------------------------------

----------------------------------------------
-- Initial object set-up
----------------------------------------------
function onStartup(self, msg)
    -- Enable this volume to receive updates when players are loaded
    self:SendLuaNotificationRequest{requestTarget = GAMEOBJ:GetZoneControlID(), messageName = "PlayerLoaded"}
end

----------------------------------------------
-- Catch incoming player to test for correct positioning
----------------------------------------------
function notifyPlayerLoaded(self, zoneID, msg)
    -- Obtain hooks to the loaded player and objects currently in the volume
    local player = msg.playerID
    local objectsInMe = self:GetObjectsInPhysicsBounds().objects
    
    -- Iterate through the objects in the volume
    for i, obj in ipairs(objectsInMe) do
        if(player:GetID() == obj:GetID()) then
            -- The loaded player is currently within me, play the intro cinematic for them
            player:PlayCinematic{pathName = "IntroCam_3", rerouteID = player} 
        end
    end
    
end

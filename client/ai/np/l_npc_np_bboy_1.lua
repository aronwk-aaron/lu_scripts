--------------------------------------------------------------
-- (CLIENT SIDE) Script for the BBoy mission giver in 
-- scene 3
--
-- Responsible for registering with the client side 
-- zone object to control actions and animations.
-- and passing data to the zone object when the local client
-- completes/accepts missions.
--------------------------------------------------------------

--------------------------------------------------------------
-- Includes
--------------------------------------------------------------
require('o_mis')
require('c_NimbusPark')
require('o_MissionHelp')

-- local table to hold mission data
MISSION_DATA = {}

--------------------------------------------------------------
-- Object specific constants
--------------------------------------------------------------


--------------------------------------------------------------
-- Called when object is loaded into the level
--------------------------------------------------------------
function onStartup(self) 

    -- register ourself to be instructed later
    registerWithZoneControlObject(self)

   -- load my help
    ---------------------
 
    -- Mission 4 (dance for me)
    AddMissionHelp(self, MISSION_DATA, CONSTANTS["SCENE_3_MISSION_4_ID"], MISSION_READY_TO_COMPLETE, function(self)
         self:DisplayChatBubble{wsText = CONSTANTS["SCENE_3_MISSION_4_READY_COMPLETE_TEXT"] }
         GAMEOBJ:GetZoneControlID():NotifyObject{ name="scene_3_mission_4_ready_to_complete" } 
    end)
    
end


--------------------------------------------------------------
-- Called when this object is ready to render
--------------------------------------------------------------
function onRenderComponentReady(self, msg)

	-- let the zone control object know we are ready to be instructed
	GAMEOBJ:GetZoneControlID():FireEvent{ senderID=self, args="SceneActorReady" }

end


--------------------------------------------------------------
-- Called when client clicks OK on a mission dialog
--------------------------------------------------------------
function onMissionDialogueOK(self, msg)

    -- on mission 1 accept (find sherland)
    if (msg.missionID == CONSTANTS["SCENE_3_MISSION_1_ID"] and msg.bIsComplete == false) then
    
        self:PlayAnimation{ animationID = "talk" }

    -- on mission 3 complete (get our cd back)
    elseif (msg.missionID == CONSTANTS["SCENE_3_MISSION_3_ID"] and msg.bIsComplete == true) then

        GAMEOBJ:GetZoneControlID():NotifyObject{ name="scene_3_mission_3_complete" }
    
    -- on mission 4 accept (dance for us)
    elseif (msg.missionID == CONSTANTS["SCENE_3_MISSION_4_ID"] and msg.bIsComplete == false) then
    
        GAMEOBJ:GetZoneControlID():NotifyObject{ name="scene_3_mission_4_accept" }
        
        -- start local watch timer for the dance
        GAMEOBJ:GetTimer():CancelAllTimers( self )
        GAMEOBJ:GetTimer():AddTimerWithCancel( 1, "CheckLocalCharacterMission",self )
        
    -- on mission 4 complete (dance for us)
    elseif (msg.missionID == CONSTANTS["SCENE_3_MISSION_4_ID"] and msg.bIsComplete == true) then
    
        GAMEOBJ:GetZoneControlID():NotifyObject{ name="scene_3_mission_4_complete" }

    end

end

--------------------------------------------------------------
-- Timers
--------------------------------------------------------------
onTimerDone = function(self, msg)
	
	-- check for the local character
    if (msg.name == "CheckLocalCharacterMission") then
	    
	    local player = GAMEOBJ:GetObjectByID(GAMEOBJ:GetLocalCharID())
	    
	    -- check for mission state help, if fail keep watching
        local m4 = player:GetMissionState{ missionID = CONSTANTS["SCENE_3_MISSION_4_ID"] }
        if (ActivateHelp(self, MISSION_DATA, CONSTANTS["SCENE_3_MISSION_4_ID"], m4.missionState) == false) then
			GAMEOBJ:GetTimer():CancelAllTimers( self )
			GAMEOBJ:GetTimer():AddTimerWithCancel( 1, "CheckLocalCharacterMission",self )
		end

    end
	
end
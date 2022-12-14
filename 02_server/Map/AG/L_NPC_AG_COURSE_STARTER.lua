--------------------------------------------------------------
-- (SERVER SIDE) Obstacle Course Starter NPC
-- Starts the course for the player and runs the logic
--
-- updated mrb... 6/9/11 - refactored
--------------------------------------------------------------

local MS_IN_SEC = 1000
local missionIDs = {1884}
----------------------------------------------------------------
-- Startup of the object
----------------------------------------------------------------
function onStartup(self) 
    -- set max users to something high
    self:SetActivityParams{ modifyActivityActive=true, activityActive = true, maxUsers = 9999, modifyMaxUsers = true }    
    self:SendLuaNotificationRequest{requestTarget=GAMEOBJ:GetZoneControlID(), messageName="PlayerExit"}    
    self:SetProximityRadius{radius = self:GetInteractionDistance().fDistance + 10, name = "Interaction_Distance"}
end

----------------------------------------------------------------
-- Returns true/false if a player is in the activity
-- takes SELF and a PLAYER object
----------------------------------------------------------------
function IsPlayerInActivity(self, player)
    -- check if player is in activity
    local existMsg = self:ActivityUserExists{ userID = player }
    
    if existMsg then
        return existMsg.bExists
    end
    
    return false
end

----------------------------------------------------------------
-- Happens on interaction for server
----------------------------------------------------------------
function onUse(self, msg)
    -- get player who clicked on us
	local player = msg.user
	
    if not checkInProximity(self,  player) then return end
       
    if player:GetFlag{iFlagID = 115}.bFlag then        
        player:DisplayMessageBox{bShow = true, imageID = 1, callbackClient = self, text = "FOOT_RACE_STOP_QUESTION", identifier = "FootRaceCancel"}
            
    else
        -- check if player is in course
        if IsPlayerInActivity(self, player) then
            -- offer exit
			self:NotifyClientObject{name = "exit", rerouteID = player}
            
        else
            -- offer start activity    
			self:NotifyClientObject{name = "start", rerouteID = player}
        end    
    end
end

function checkInProximity(self, player)
    local proxObjects = self:GetProximityObjects{name = "Interaction_Distance"}.objects

    for k,v in ipairs(proxObjects) do
        if v:GetID() == player:GetID() then
            return true
        end
    end
    
    return false
end

----------------------------------------------------------------
-- Sent from a player when responding from a messagebox
----------------------------------------------------------------
function onMessageBoxRespond(self, msg)
    -- Response to Exit activity dialog and user pressed OK
    if msg.identifier == "player_dialog_cancel_course" and msg.iButton == 1 then
        -- remove the user
        self:RemoveActivityUser{ userID = msg.sender }
        self:NotifyClientObject{name = "cancel_timer", rerouteID = msg.sender}
    -- Response to Start activity dialog and ok is pressed and player is not in activity
    elseif msg.identifier == "player_dialog_start_course" and msg.iButton == 1 and IsPlayerInActivity(self, msg.sender) == false then
        if not checkInProximity(self,  msg.sender) then 
            self:NotifyClientObject{name = "out_of_bounds", rerouteID = msg.sender}     
            return 
        end
                
        -- add the new user
        self:AddActivityUser{ userID = msg.sender }
        
        -- start the activity for the new user
        StartActivity(self, msg.sender)
    elseif msg.identifier == "FootRaceCancel" and msg.iButton == 1 then    
        local tFootRaceStarters = self:GetObjectsInGroup{ group = 'FootRaceStarter', ignoreSpawners = true }.objects
        
        for k,v in ipairs(tFootRaceStarters) do
            -- remove the user
            if IsPlayerInActivity(v, msg.sender) then
                v:NotifyClientObject{name = "stop_timer" , rerouteID = msg.sender}
                
                break
            end
        end
        
        -- check if player is in course
        if IsPlayerInActivity(self, msg.sender) == true then
            -- offer exit
			self:NotifyClientObject{name = "exit", rerouteID = msg.sender}
            
        else
            -- offer start activity    
			self:NotifyClientObject{name = "start", rerouteID = msg.sender}
        end   
        
                
        -- turn off the player flag for is player in foot race
        msg.sender:SetFlag{iFlagID = 115, bFlag = false}
    end
end

----------------------------------------------------------------
-- Stores the start time for the player in the activity and
-- sends messages to start it
----------------------------------------------------------------
function StartActivity(self, player)    
    -- get the current time in sec
    local startTime = (GAMEOBJ:GetSystemTime() / MS_IN_SEC) + 4
    
    self:NotifyClientObject{name = "start_timer" , rerouteID = player}
    self:SetActivityUserData{ userID = player, typeIndex = 1, value = tonumber(startTime) }
end

----------------------------------------------------------------
-- Handle FireEvent message
----------------------------------------------------------------
function onFireEvent(self, msg)
    -- user is trying to cancel
    if msg.args == "course_cancel" and IsPlayerInActivity(self, msg.senderID) then
        self:NotifyClientObject{name = "cancel_timer", rerouteID = msg.senderID}        
        -- remove the user from activity
        self:RemoveActivityUser{ userID = msg.senderID }        
    elseif msg.args == "course_finish" and IsPlayerInActivity(self, msg.senderID) then
        -- store the finish time in sec
        local endTime = GAMEOBJ:GetSystemTime() / MS_IN_SEC
    
        -- store the time as activity rating [1]
        self:SetActivityUserData{ userID = msg.senderID, typeIndex = 2, value = tonumber(endTime) }
        -- distribute rewards        
        self:DistributeActivityRewards{ userID = msg.senderID, bAutoAddCurrency = true, bAutoAddItems = true  }        
        -- do complete activity events
        self:CompleteActivity{ userID = msg.senderID}        
        -- remove the user from activity
        self:RemoveActivityUser{ userID = msg.senderID }            
    end
end

----------------------------------------------------------------
-- Player has exited the map
----------------------------------------------------------------
function notifyPlayerExit(self, other, msg)
    if IsPlayerInActivity(self, msg.playerID) then        
        -- remove the user from activity
        self:RemoveActivityUser{ userID = msg.playerID }
    end
end

--------------------------------------------------------------
-- Passes start/end time and gets the total time
--------------------------------------------------------------
function GetTotalTime(startTime, endTime)
    -- calculate total time (subtract countdown and cap at 0)
    local totalTime = tonumber(endTime) - tonumber(startTime)
    
    if totalTime < 0 then
        totalTime = 0
    end        

    return math.floor(totalTime)    
end

--------------------------------------------------------------
-- Called when the activity is trying to calculate final rating
--------------------------------------------------------------
function onDoCalculateActivityRating(self, msg)
    -- get the time for the player    
    local totalTime = GetTotalTime(msg.fValue2, msg.fValue3)
    
    msg.outActivityRating = totalTime
    
    return msg
end

--------------------------------------------------------------
-- Called when the activity is trying to complete
--------------------------------------------------------------
function onDoCompleteActivityEvents(self, msg)
    -- get the time for the player    
    local totalTime = GetTotalTime(msg.fValue2, msg.fValue3)

    self:SetActivityUserData{ userID = msg.userID, typeIndex = 1, value = tonumber(totalTime) }	    
    --total time has to be negative for perform activity task to function properly
    msg.userID:UpdateMissionTask{ taskType = "performact_time", value2 = self:GetActivityID().activityID, value = totalTime * -1 }    
    
    for k,mission in ipairs(missionIDs) do
		msg.userID:UpdateMissionTask{taskType = "complete", value = mission, value2 = 1, target = self}
	end

    -- Update Leaderboards for this user
    self:UpdateActivityLeaderboard{ userID = msg.userID }

    local actID = self:GetActivityID().activityID
    
    -- get the leaderboard data for the user and update summary screen if it exists
    msg.userID:RequestActivitySummaryLeaderboardData{target = self, queryType = 1, gameID = actID }
    self:NotifyClientObject{name = "ToggleLeaderBoard", param1 = actID, paramObj = msg.userID , rerouteID = msg.userID} 
    --print(msg.senderID:GetName().name .. ' finished the race')    
    self:NotifyClientObject{name = "stop_timer" , param1 = 1, param2 = totalTime, rerouteID = msg.userID}
end 
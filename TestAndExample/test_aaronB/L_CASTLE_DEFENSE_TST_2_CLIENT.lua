--------------------------------------------------------------

-- L_CASTLE_DEFENSE_TST_CLIENT.lua

-- Client side test script for Castle Defense prototyping.
-- created abeechler ... 8/5/11

--------------------------------------------------------------

--------------------------------------------------------------
-- Includes
--------------------------------------------------------------
require('ai/ACT/L_ACT_GENERIC_ACTIVITY_MGR')

---------------------------------------------------------------
-- Startup of the object
---------------------------------------------------------------

function playerInit(self)
    local player = GAMEOBJ:GetObjectByID(GAMEOBJ:GetLocalCharID())
                        
    UI:SendMessage( "pushGameState", {{"state", "Instance_Loading"}} )
    freezePlayer(self, true)
    
    UI:SendMessage( "ToggleActivityCloseButton", {  {"bShow", true}, 
                                            {"GameObject", self}, 
                                            {"MessageName", "toLua"}, 
                                            {"senderID", player} } )   
end


function onPlayerReady(self)
    local playerID = GAMEOBJ:GetObjectByID(GAMEOBJ:GetLocalCharID())
    
    if not playerID:GetPlayerReady().bIsReady then
        GAMEOBJ:GetTimer():AddTimerWithCancel( 0.1 , "Try_Ready_Again", self )    
    else
        playerInit(self)
        -- The client is ready, notify the server to check for the start count
        self:FireEventServerSide{senderID = playerID, args = "CheckPlayerCount"}
    end
end

function freezePlayer(self, bFreeze)
    local playerID = GAMEOBJ:GetObjectByID(GAMEOBJ:GetLocalCharID())  
    local eChangeType = "POP"
        
    if bFreeze then
        if playerID:IsDead().bDead then
            GAMEOBJ:GetTimer():AddTimerWithCancel( 0.1 , "Try_Freeze_Again", self )
            return
        
        elseif not playerID:GetStunned().bCanMove then 
            return
        end

        eChangeType = "PUSH"
    end
    
    playerID:SetStunned{ StateChangeType = eChangeType,
                        bCantMove = true, bCantAttack = true, bCantInteract = true }
                        
    
    if playerID:GetStunned().bCanMove and eChangeType == "PUSH" then
        GAMEOBJ:GetTimer():AddTimerWithCancel( 0.1, "Try_Freeze_Again", self )
    end
end

function onFireEvent(self, msg)
	-- Receive the sending object ID and the message to parse
	local eventType = msg.args
	local sendObj = msg.senderID
	
	-- Missing a valid event type?
	if not eventType then return end
	
	if eventType == "ProvideExitX" then
	    GAMEOBJ:GetTimer():AddTimerWithCancel(0.5, "ProvideExitX", self)
	    
	end
end

function onFireEventClientSide(self, msg)
    if(msg.args == "Show_Startup") then
        -- Start-up player lock
        UI:SendMessage( "pushGameState", {{"state", "Instance_Loading"}} )
        freezePlayer(self, true)
        
    elseif(msg.args == "StartCD_UI") then
        UI:SendMessage( "pushGameState", {{"state", "castledefense"}} )
        UI:SendMessage("UpdateInfo", {{"blueScore", "0%"}})
        UI:SendMessage("UpdateRedInfo", {{"redScore", "0%"}})
        
    elseif(msg.args == "StopCD_UI") then
        UI:SendMessage( "popGameState", {{"state", "castledefense"}} )
        
    elseif(msg.args == "Team1") then
        UI:SendMessage("UpdateInfo", {{"blueScore", tostring(msg.param2) .. "%"}})
    
    elseif(msg.args == "Team2") then
        UI:SendMessage("UpdateRedInfo", {{"redScore", tostring(msg.param2) .. "%"}})
        
    else
        -- Printing output messages
        if(msg.param2 == 1) then
            -- Client print test
            print("@@@ " .. msg.args)
    
        elseif(msg.param2 == 2) then
            if(tonumber(msg.args) > 0) then
                print("@@@ NEXT GAME STARTS - " .. msg.args)
            end
    
        end
    end
     
end

function onTimerDone(self, msg)
    if msg.name == "Try_Freeze_Again" then    
        freezePlayer(self, true)
    elseif msg.name == "Try_Ready_Again" then
        PlayerReady(self)
    elseif msg.name == "ProvideExitX" then
	    local player = GAMEOBJ:GetObjectByID(GAMEOBJ:GetLocalCharID())
	    
	    UI:SendMessage( "ToggleActivityCloseButton", {  {"bShow", true}, 
                                            {"GameObject", self}, 
                                            {"MessageName", "toLua"}, 
                                            {"senderID", player} } )
    end
end

----------------------------------------------------------------
-- Variables serialized from the server
----------------------------------------------------------------
function onScriptNetworkVarUpdate(self, msg)    
    local player = GAMEOBJ:GetObjectByID(GAMEOBJ:GetLocalCharID())
    
    for k,v in pairs(msg.tableOfVars) do
    
        if(k == "Pop_State") then
            UI:SendMessage( "popGameState", {{"state", "Instance_Loading"}} )
        
        elseif(k == "Show_Startup") then
            UI:SendMessage( "pushGameState", {{"state", "Instance_Loading"}} )
            freezePlayer(self, true)
            
        elseif(k == "Show_Countdown") then
            player:ShowActivityCountdown()
            
        elseif(k == "Start_Message") then
            freezePlayer(self)
            
        end
    end
end

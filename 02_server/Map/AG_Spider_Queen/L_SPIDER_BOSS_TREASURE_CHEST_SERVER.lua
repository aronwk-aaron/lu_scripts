--------------------------------------------------------------
-- Server side script for the lootable chest for the spider boss fight.
--
-- created by mrb... 7/6/11 
--------------------------------------------------------------

require('02_server/Minigame/General/L_MINIGAME_TREASURE_CHEST_SERVER')

---------------------------------------------------------
-- ON START UP
---------------------------------------------------------
function onStartup(self)
    -- set up the activity
    self:SetActivityParams{  modifyMaxUsers = true, maxUsers = 2, modifyActivityActive = true,  activityActive = true} 
end

--------------------------------------------------------------
-- Calculate an activity rating for this object 
--------------------------------------------------------------
function onDoCalculateActivityRating(self, msg)
    local iPlayers = msg.userID:TeamGetSize().size
    
    -- if the team size is 0 there's only one player in the instance
    if iPlayers == 0 then 
        iPlayers = 1
    end
    
    iPlayers = iPlayers * 100
    
    --print("# of players: " .. iPlayers)    
    msg.outActivityRating = iPlayers

    return msg
end

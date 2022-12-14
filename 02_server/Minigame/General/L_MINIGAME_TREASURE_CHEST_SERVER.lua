--------------------------------------------------------------
-- Server side script for the lootable chest for the dragon fight.
--
-- created by mrb... 10/25/10 - copied script from dragon treasure chest
--------------------------------------------------------------

---------------------------------------------------------
-- ON START UP
---------------------------------------------------------
function onStartup(self)
    -- set up the activity
    self:SetActivityParams{  modifyMaxUsers = true, maxUsers = 4, modifyActivityActive = true,  activityActive = true} 
end

function onCheckUseRequirements(self, msg)
    -- only let the player use the chest one time
    if self:GetNetworkVar("bUsed") then
        msg.bCanUse = false
    end
    
    return msg
end

function onUse(self,msg)
    local player = msg.user
    
    -- send network var down to the clients that the chest is used
	self:SetNetworkVar("bUsed", true)
    
    -- if the player isn't in the activity then add them
    if not self:ActivityUserExists{userID = player}.bExists then
        self:AddActivityUser{ userID = player }
    end               

    spawnLoot(self, player) 
    
    GAMEOBJ:GetZoneControlID():NotifyObject{ObjIDSender = self, name = "Survival_Update", param1 = 0}
end

function spawnLoot(self, player, matrix)    
    -- give out activity rewards
    self:DistributeActivityRewards{userID = player, bAutoAddCurrency = false, bAutoAddItems = false, bUseTeam = true}
    -- remove the player from the activity
    self:RemoveActivityUser{userID = player}
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
    
    --print("# of players: " .. iPlayers)    
    msg.outActivityRating = iPlayers

    return msg
end

--------------------------------------------------------------
-- Server side script for the lootable chest for the dragon fight.
--
-- updated by mrb... 8/30/10 - added network var from server so 
-- that only one person can use the chest, but all clients get the animations
--------------------------------------------------------------

---------------------------------------------------------
-- ON START UP
---------------------------------------------------------
function onStartup(self)
    -- set up the activity
    self:SetActivityParams{  modifyMaxUsers = true, maxUsers = 4, modifyActivityActive = true,  activityActive = true} 
    local parent_tag = self:GetVar("parent_tag") 
    
    if parent_tag and parent_tag:Exists() then
		self:SetNetworkVar("parent_tag", parent_tag)
	end
end

function onCheckUseRequirements(self, msg)
	local tagObj = self:GetVar("parent_tag") or false
	
	if tagObj and tagObj:Exists() then
		if tagObj:GetID() ~= msg.objIDUser:GetID() and not msg.objIDUser:TeamIsOnWorldMember{i64PlayerID = tagObj}.bResult then		
			msg.bCanUse = false
		end
	end
	
    -- only let the player use the chest one time
    if self:GetNetworkVar("bUsed") then
        msg.bCanUse = false
    end
    
    return msg
end

function onUse(self,msg)
    local player = msg.user
    
    -- send network var down to the clients that the chest is used
    if not self:GetNetworkVar("bUsed") then
        self:SetNetworkVar("bUsed", true)
    else
        return
    end
    
    -- if the player isn't in the activity then add them
    if not self:ActivityUserExists{userID = player}.bExists then
        self:AddActivityUser{ userID = player }
    end               

    spawnLoot(self, player) 
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

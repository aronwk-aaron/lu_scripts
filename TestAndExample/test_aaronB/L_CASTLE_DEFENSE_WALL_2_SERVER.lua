--------------------------------------------------------------

-- L_CASTLE_DEFENSE_WALL_SERVER.lua

-- Server side test script for Castle Defense wall prototyping.
-- updated abeechler ... 10/14/11

--------------------------------------------------------------

local defaulthealth = 5

function onStartup(self,msg)
    -- Get max health once, since the objects max health won't change 
    local wallHealth = self:GetMaxHealth().health or defaulthealth
    self:SetVar("maxHealth", wallHealth)
    
    -- Obtain team data for QB group inclusion
    local team = self:GetVar("team") or false
    if((team) and ((team == 1) or (team == 2))) then
        self:AddObjectToGroup{group = "Team" .. tostring(team)}
    end
    
end

function onRebuildComplete(self, msg)
    -- Send a message to the zone script to increment
    -- the Super Shot counter for the build player
    GAMEOBJ:GetZoneControlID():FireEvent{senderID=msg.userID, args="incSuperShotTbl"}
end

function onHitOrHealResult(self,msg)

    -- If we're dead, stop updating
    if (msg.diedAsResult) then return end
    
    -- Here's where we're defining visual damage states.
    -- Since a standard cannonball currently takes 5 hits to destroy a wall, I'm adding 5 visual states

    local health = self:GetHealth().health
    local maxhealth = self:GetVar("maxHealth")
    local healthpercent = health / maxhealth
    local FXname = "hit1"

    if healthpercent >= 0.8 then
        FXname = "hit1"
    elseif healthpercent >= 0.6 and healthpercent < 0.8 then
        FXname = "hit2"
    elseif healthpercent >= 0.4 and healthpercent < 0.6 then
        FXname = "hit3"
    elseif healthpercent >= 0.2 and healthpercent < 0.4 then
        FXname = "hit4"
    elseif healthpercent > 0 and healthpercent < 0.2 then
    end
        FXname = "hit5"

    self:StopFXEffect{name = "fx"}
    self:PlayFXEffect{name = "fx", effectID = 9223, effectType = FXname}
   
end

function onFireEvent(self, msg)
	-- Receive the sending object ID and the message to parse
	local eventType = msg.args
	local sendObj = msg.senderID
	
	-- Missing a valid event type?
	if not eventType then return end
	
	if eventType == "Rebuild" then
	    self:SetRebuildState{iState = 2}
	end
end

-- Modified from origional script L_SPECIAL_FIREPIT.lua, added in puzzle functionality
-- Plays effects, disables fire damage, opens door, pirate jumps down and goes back to swinging
-- Created: 4/09/09 mrb...

local skillid = 43
local ProxRadius = 4
local FIRE_COOLDOWN = 2
local isBurning = false
local oPos = { pos = "", rot = ""}
local player = ''

-- Gets everything setup correctly at startup
function onStartup(self)
    self:SetVar("counter", 0)
    self:SetProximityRadius{radius = ProxRadius} 
    -- starts fire
    doEffect(self, true)
    -- Gets correct pos/rot and spawns the swinging pirate
    oPos.pos = self:GetPosition().pos
    oPos.pos.y = oPos.pos.y + 8
    oPos.rot = self:GetRotation()
    swingPirate(self)
end

-- turns off fire when player uses the squirtgun
function onSquirtWithWatergun( self, msg )
    if isBurning then 
        doEffect(self, false)
        player = msg.shooterID
    end
end

-- turns fire on/off based on burn variable, needs: obj = LWOOBJID, burn = bool
function doEffect(obj, burn) 
    if burn then
        obj:StopFXEffect{ name = "Off" }
        obj:PlayFXEffect{ name  = "Burn", effectID = 295, effectType = "running"}
        isBurning = true
        return
    end
    if isBurning and not burn then
        obj:StopFXEffect{ name = "Burn" }
        --obj:PlayFXEffect{ name  = "Off", effectID = 295, effectType = "end"} -- could be a transitional effect
        obj:PlayFXEffect{ name  = "Off", effectID = 295, effectType = "idle"} 
        GAMEOBJ:GetTimer():AddTimerWithCancel( 28, "FireRestart", obj )
        GAMEOBJ:GetTimer():AddTimerWithCancel( 10, "FireIsOut", obj )
        isBurning = false   
        return
    end
    
end

-- makes the door move, needs: obj = LWOOBJID, goForward = bool
function moveDoor(obj, goForward)
    local doorObj = obj:GetObjectsInGroup{ group = "Fire_Puzzle_Mover" }.objects
    for k,v in ipairs(doorObj) do        
        v:StartPathing()
    end
end

-- spawns the pirate off the rope needs: obj = LWOOBJID
function walkPirate(obj)
    local pirateObj = obj:GetObjectsInGroup{ group = "Fire_Puzzle_Pirate" }.objects    
    for k,v in ipairs(pirateObj) do    
        GAMEOBJ:DeleteObject(v)
    end
    local config = { { "groupID" , "Fire_Puzzle_Pirate"} }
    RESMGR:LoadObject { objectTemplate = 2416, x= oPos.pos.x, y= oPos.pos.y , z= oPos.pos.z + 2, rw = oPos.rot.w, rx = oPos.rot.x, ry = oPos.rot.y, rz = oPos.rot.z, owner = obj, configData = config}
    --player = msg.shooterID
    
end

-- spawns the pirate swinging the rope needs: obj = LWOOBJID
function swingPirate(obj)
    local pirateObj = obj:GetObjectsInGroup{ group = "Fire_Puzzle_Pirate" }.objects  
    for k,v in ipairs(pirateObj) do    
        GAMEOBJ:DeleteObject(v)
    end    
    local config = { { "groupID" , "Fire_Puzzle_Pirate"} }
    RESMGR:LoadObject { objectTemplate = 2364, x= oPos.pos.x, y= oPos.pos.y , z= oPos.pos.z, rw = oPos.rot.w, rx = oPos.rot.x, ry = oPos.rot.y, rz = oPos.rot.z, owner = obj, configData = config}
end

function burnPirate(obj) 
    local pirateObj = obj:GetObjectsInGroup{ group = "Fire_Puzzle_Pirate" }.objects[1]
    
    pirateObj:SetAnimationSet{strSet = "111"}
    pirateObj:PlayFXEffect{ name  = "PirateBurn", effectID = 111, effectType = "onhit"}
    pirateObj:PlayAnimation{animationID = "onhit", bPlayImmediate = true}
    local animTime = obj:GetAnimationTime{animationID = "rebuild-celebrate"}    
    GAMEOBJ:GetTimer():AddTimerWithCancel( animTime.time - 1, "OuchTimer", obj )    
end

-- fire damage to player while active
function onProximityUpdate(self, msg)
    if not isBurning then return end
    
    if msg.status == "ENTER" then
        local target = msg.objId
        local faction = target:GetFaction()
        if faction.faction == 1 then        
            local counter = self:GetVar("counter")
            counter = counter + 1
            self:SetVar("counter", counter)
            if counter == 1 then
            	self:CastSkill{skillID = skillid }
            	GAMEOBJ:GetTimer():AddTimerWithCancel(FIRE_COOLDOWN, "TimeBetweenCast", self )
            	print "Set the timer" 
            end  -- end if counter == 1           
        end -- end if faction = 1
    else 
        local counter = self:GetVar("counter")
        if counter > 0 then
            counter = counter - 1
            self:SetVar("counter", counter)
            if counter == 0 then
            	-- cancelling the timer
            	GAMEOBJ:GetTimer():CancelAllTimers( self )
            end
        end 
    end -- end if msg.status == "ENTER"
end 

-- timers...
function onTimerDone(self, msg)
    if msg.name == "OuchTimer" then
        swingPirate(self)
        doEffect(self, true)
    end
    if msg.name == "FireIsOut" then
        moveDoor(self, true)
        walkPirate(self)
        --print("Misson Updateed *******************************************************************"..self:GetName().name)
        --print("Misson Updateed *******************************************************************"..player:GetName().name)
        player:UpdateMissionTask {target = self, value = 331, value2 = 1, taskType = "complete"}

    end
    if msg.name == "FireRestart" then
        if not isBurning then 
            moveDoor(self, false)
            burnPirate(self)
        end
    end
    if msg.name == "TimeBetweenCast" then
        GAMEOBJ:GetTimer():AddTimerWithCancel(FIRE_COOLDOWN, "TimeBetweenCast", self )
        self:CastSkill{skillID = skillid}
    end
end            
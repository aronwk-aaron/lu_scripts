-- Wandering and Following Creature AI for skill summoned creatures
-- Three proximity volumes created on an object:
-- 1 - StopFollow - On enter stops pet from following player
-- 2 - Wander - On enter starts pet's wandering AI, on exit starts pet following player
-- 3 - Teleport - On exit teleports pet to player 
-- Erik Beyer 5-3-11

-- Extent of proximity volumes
local StopFollowRadius = 5
local WanderRadius = 10
local TeleportRadius = 50

-- Min Max Time Delay while wandering 
local WanderDelayMin = 4
local WanderDelayMax = 9

-- What's the walk speed of the creature while wandering?  0.5 and below plays the walk animation instead of the run
local WanderSpeed = 0.5

function onStartup(self)

    math.randomseed( os.time() )
    -- Tell pet to not allow follow cancelling until it actually is following
    self:SetVar("follow",false)

    -- Create proximities
	self:SetProximityRadius{radius = StopFollowRadius, name = "StopFollow", collisionGroup = 1}
    self:SetProximityRadius{radius = WanderRadius + 5, name = "Wander", collisionGroup = 1}
	self:SetProximityRadius{radius = TeleportRadius, name = "Teleport", collisionGroup = 1}

    -- Start wandering to "fix" animation pausing bug and get the wander timer running
    Wander(self)

end

function onProximityUpdate(self, msg)

    local player = self:GetParentObj().objIDParent
    -- Is this the player that summoned the pet?
    if not player:Exists() and player:GetID() ~= msg.objID:GetID() then return end
    
    if (msg.name == "StopFollow") then
        if (msg.status == "ENTER") then
            --Only cancel follow if the pet's following
            if self:GetVar("follow") then
                -- Random value generated for wander timer
                local randwandtime = math.random (WanderDelayMin, WanderDelayMax)
                -- Start wander timer
                GAMEOBJ:GetTimer():AddTimerWithCancel(randwandtime, "StartWander", self)
                -- Stop following player
                self:StopPathing()
                --self:FollowTarget { targetID = player, radius = StopFollowRadius, speed = 2, keepFollowing = false, bRequireValidPath = true }
                -- Can't cancel follow until follow is reactivated
                self:SetVar("follow",false)
            end
        end

    elseif (msg.name == "Wander") then
        if (msg.status == "LEAVE") then
            -- Make sure the wander timer's cancelled when the pet's wandering
            GAMEOBJ:GetTimer():CancelAllTimers(self)
            -- Start following
            self:FollowTarget { targetID = player, radius = StopFollowRadius, speed = 2, keepFollowing = true, bRequireValidPath = true }
            -- Allow follow to be cancelled
            self:SetVar("follow",true)
        end

    elseif (msg.name == "Teleport") then
        if (msg.status == "LEAVE") then
            -- Get player and player's position--we know the player's the parent of the skill created object
            local ParentPos = player:GetPosition().pos
            -- Get position 5 units behind the player and teleport pet there
            local xSplit= {x= ParentPos.x, y= ParentPos.y, z= ParentPos.z + 5}
            self:Teleport{ pos = xSplit, useNavmesh = true}
            -- Also match pet's rotation to player's rotation, probably won't need this
            --local rot = player:GetRotation()
            --self:SetRotation{y=rot.y, x=rot.x, w=rot.w, z=rot.z}
        end
    end

end

-- Wander Function - Gets a random location around the Minifig (the parent) and goes there --

function Wander(self)

    -- Get player pos
    local wanderround = self:GetParentObj().objIDParent
    local playerpos = wanderround:GetPosition().pos
    -- Get a random point around the Minifig through the getRandomPos function
    local PoS = getRandomPos(self,playerpos)
    -- Go to random point
    self:GoTo {speed = WanderSpeed,
                target = {
                x = PoS.x,
                z = PoS.z,
                y = PoS.y,
                },
    }

    -- Random value generated for wander timer
    local randwandtime = math.random (WanderDelayMin, WanderDelayMax)
    -- Start another wander timer
    GAMEOBJ:GetTimer():AddTimerWithCancel( randwandtime, "StartWander", self )
    
end

function getRandomDist(seed)

    local dist = 0
 -- Generate a number that's > and < 1 and return to getRandomPos for a radial return
    while dist < 1 and dist > -1 do
        dist = math.random(-seed, seed)
    end
    
    return dist

end

function getRandomPos(self,ParentPOS)

    local myPos = self:GetPosition().pos 
    -- Call randomdist function on x,z pos
    local PoS = {   x = ParentPOS.x + getRandomDist(WanderRadius), 
                    y = ParentPOS.y, 
                    z = ParentPOS.z + getRandomDist(WanderRadius)   }
    
    return PoS

end

function onTimerDone(self, msg)

    if (msg.name == "StartWander") then
        Wander(self)
    end

end

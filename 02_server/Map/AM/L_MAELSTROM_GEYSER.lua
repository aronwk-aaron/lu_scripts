--------------------------------------------------------------
-- Toggles the geiser FX on and off randomly
-- damages the player

--Created by brandi... 11/18/10 
-- updated brandi... 11/29/10 - added player table so the player would only get damaged once
--------------------------------------------------------------

-- constants based on the time of the fx
local buildUpTime = 1.5
local killTime = 1.5

--------------------------------------------------------------
-- on startup, set variables and start the geysers
--------------------------------------------------------------
function onStartup(self)
	-- set the geyser to firing
    self:SetVar("AmFiring", false)
    -- get random numbers based off the time, to make them more random
    math.randomseed( os.time() )
    -- get time before the geyser goes off
	local downTime = math.random(1,7) 
	-- start a timer to start the geyser
	GAMEOBJ:GetTimer():AddTimerWithCancel(downTime, "downTime", self)
end

--------------------------------------------------------------
-- when the player collides and the geyser is on, damage the player
--------------------------------------------------------------
function onCollisionPhantom(self, msg)
	-- get the player and make sure it really exists
	local player = msg.objectID
	if not player:Exists() then return end
    
    -- if the geyser is firing, put the player in a table so it doesnt doesnt damage the player twice
	if self:GetVar("AmFiring") then
		--table containing players in the volume
		local players = self:GetVar("Players") 
   
		-- if the table doesnt already exist (no one is in it), create it
		if not players then 
			players = {}
		else
			-- if the table exists, parse through it and see if the player is already in it
			for k,v in ipairs(players) do
				if v == player:GetID() then 
					-- if it is, jump out of the function
					return
				end
			end
		end
		-- the player isnt already in the table, so put them there
		table.insert(players,player:GetID())
		--set the table back to the set var
		self:SetVar("Players",players) 
		
		-- cast a damage skill on the player
		self:CastSkill{skillID = 981, optionalTargetID = player}
    end    
end

--------------------------------------------------------------
-- when the timers are done
--------------------------------------------------------------
function onTimerDone(self, msg)
    --If the down timer is completed, then begin to play the FX
    if msg.name == "downTime" then
		-- player the geyser effect, it has a build up so the player has a second before the volume will hurt them
        self:PlayFXEffect{name = "geiser", effectID = 4822, effectType = "geyser-on"}
        -- start the timer for the start up time
        GAMEOBJ:GetTimer():AddTimerWithCancel(buildUpTime, "buildUpTime", self)
    --If the build up timer is completed, then begin to fire/kill the player
    elseif msg.name == "buildUpTime" then
		-- set the volume  to firing
        self:SetVar("AmFiring", true)
        -- start a timer for how long the geysers is firing
        GAMEOBJ:GetTimer():AddTimerWithCancel(killTime, "killTime", self)
    --If the kill timer has completed, then begin the down timer and start over again
    elseif msg.name == "killTime" then
		-- stop the effect
        self:StopFXEffect{name = "geiser"}
        -- set volume back to not firing
        self:SetVar("AmFiring", false)
        -- clear the player table
        self:SetVar("Players",{})
        -- start the timer for the next time the geyser starts
        local downTime = math.random(1,7) 
        GAMEOBJ:GetTimer():AddTimerWithCancel(downTime, "downTime", self)
    end    
end

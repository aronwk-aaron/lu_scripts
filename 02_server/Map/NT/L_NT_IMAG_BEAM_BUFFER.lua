--------------------------------------------------------------
-- Server side script on the small object inside the imagination beam

-- created by Brandi...  4/5/11
--------------------------------------------------------------

local ZoneSize = 85 -- the radius of the zone that players can stand in and be buffed
local BuffInterval = 2 -- the time between buffs
local ImagSkill = 1311 -- the skill that give the player 1 imagination

function onStartup(self,msg)
	
	-- set proximity monitor for players
	self:SetProximityRadius{name = "ImagZone", radius = ZoneSize, collisionGroup = 1, shapeType = "CYLINDER", height = 100} 
	-- make sure no players are already in the radius
	if table.maxn(self:GetProximityObjects{name = "ImagZone"}.objects) == 0 then
		-- set the player variable to false, and exit the function
		self:SetVar("PlayersInRange",false)
		return
	end
	-- there are players in the radius, set that variable to true
	self:SetVar("PlayersInRange",true)
	-- start a timer to buff the players
	GAMEOBJ:GetTimer():AddTimerWithCancel( BuffInterval, "BuffImag", self )
	
end

function onProximityUpdate(self,msg)
	-- player entered the beam's radius, make sure there isnt already players in the radius
    if msg.status == "ENTER" and not self:GetVar("PlayersInRange") then
		-- there are players in the radius, set that variable to true
		self:SetVar("PlayersInRange",true)
		-- start a timer to buff the players
		GAMEOBJ:GetTimer():AddTimerWithCancel( BuffInterval, "BuffImag", self )
	-- when a player exits, check to see if its the last player in the zone
	elseif msg.status == "LEAVE" and table.maxn(self:GetProximityObjects{name = "ImagZone"}.objects) == 0 then
		-- no players in the zone, set the variable to false
		self:SetVar("PlayersInRange",false)
		-- cancel the timer to buff the player
		GAMEOBJ:GetTimer():CancelTimer( "BuffImag", self )
	end
end

function onTimerDone(self,msg)
	-- timer to buff the player
	if msg.name == "BuffImag" then
		-- exit out if there are not longer any players in range
		if not self:GetVar("PlayersInRange") then return end
		
		-- get the players in the zone
		local players = self:GetProximityObjects{name = "ImagZone"}.objects
		-- parse through all the players
		for k,v in ipairs(players) do
			if v:Exists() then
				-- cast the buff skill on the player
				self:CastSkill{skillID = ImagSkill, optionalTargetID = v}
				-- print("buff "..v:GetName().name)
			end
		end
		-- start a timer to buff the player again
		GAMEOBJ:GetTimer():AddTimerWithCancel( BuffInterval, "BuffImag", self )
		
	end
end
			
		
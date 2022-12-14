---------------------------------------------
-- main script for the quickbuild shield generator
-- used old script and broke it up to work for either a qb sheild generator or a static one
--
-- created by brandi... 1/13/11
---------------------------------------------

require('02_server/Map/AM/L_SHIELD_GENERATOR_BASE')

--------------------------------------------------------------
-- on startup, set proximities
--------------------------------------------------------------
function onStartup(self,msg)
	baseStartup(self,msg)
end

--------------------------------------------------------------
-- qb completed, start the shield
--------------------------------------------------------------
function onRebuildComplete( self, msg )

	StartShield( self, msg )
	
	-- get the enemies with in the shield
    local enemies = self:GetProximityObjects{name = "shield"}.objects
    -- parse through the enemies and kill them
    for k,v in ipairs(enemies) do
		if v:GetID() ~= msg.rebuildID:GetID() then
			v:RequestDie{ killerID = self, killtype = "VIOLENT" }
		end
	end
	
	-- parse through the table of player that built the shield
	local players = self:GetVar("Players")
	if players then  
		-- parse through them and make sure they exist
		for k,v in ipairs(players) do 
			-- set the v from an object id to a game object
			v = GAMEOBJ:GetObjectByID(v)
			-- make sure the player still exists
			if v:Exists() then
				-- if the player is on the mission to build the shield generator, complete the mission
				if v:GetMissionState{missionID = 987}.missionState == 2 then
					v:UpdateMissionTask{taskType = "complete", value = 987, value2 = 1, target = self}
				end
			end
		end
	end
end

function onChildLoaded(self, msg)
	baseChildLoaded(self, msg)
end


--------------------------------------------------------------
-- when something enters the proximity
--------------------------------------------------------------
function onProximityUpdate(self,msg)

	-- enemies entered the shields radius
    if msg.status == "ENTER" and msg.name == "shield" then
    
			-- the shield is built
			if self:GetRebuildState().iState == 2 then
				EnemyEnteredShield(self,msg)
			end	
	elseif msg.name == "buffer" then	-- player enters/exits buffer proximity
		local player = msg.objId
		
		if self:GetRebuildState().iState ~= 2 then
			self:NotifyClientObject{name = msg.status, paramObj = player, rerouteID = player }
		elseif msg.status == "ENTER" then -- Rebuild is in state 2
			player:RemoveFromAllThreatLists()
		end
    end
    
end

--------------------------------------------------------------
-- when the shield smashs, stop the activity timer
--------------------------------------------------------------
function onDie(self, msg)
    baseDie(self, msg)
end

--------------------------------------------------------------
-- keep track of who help build the QB so they all can get credit for the mission
--------------------------------------------------------------
function onRebuildNotifyState(self,msg)
	-- when the quickbuild is being built
	if msg.iState == 5 then
		print("the builder is "..msg.player:GetName().name)
		-- find out who is building it
		local builder = msg.player
	 
		-- get the table of players who have helped build the shield
		local players = self:GetVar("Players") 
	   
		-- if the table doesnt already exist (no one is in it), create it
		if not players then 
			players = {}
		else
			-- if the table exists, parse through it and see if the player is already in it
			for k,v in ipairs(players) do
				if v == builder:GetID() then 
					-- if it is, jump out of the function
					return
				end
			end
		end
		-- the player isnt already in the table, so put them there
		table.insert(players,builder:GetID())
		--set the table back to the set var
		self:SetVar("Players",players) 
	-- if the quickbuild is resetting
	elseif msg.iState == 4 then
		-- clear out the players table
		self:SetVar("Players",{})
	end
	
end

function onActivityTimerUpdate(self, msg)
	baseActivityTimerUpdate(self, msg)
end


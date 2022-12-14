--------------------------------------------------------------
-- server side Script for the moving platforms in the earth transition of the monastery
-- 
-- created by brandi... 6/6/11 
-- updated by brandi... 8/25/11 - the pillar does a check to see if the players that were standing on it still exist
--------------------------------------------------------------

function onFireEventServerSide(self,msg)
	-- get the player
	local player = msg.senderID
	--Checking to see if the player still exists
	if not player:Exists() then return end
	
	-- sent when a player gets on a platform
	if msg.args == "PlayerOnPillar" then
		local ptable = self:GetVar("pTable") --table containing players in the volume
		if not ptable then -- if the table doesnt already exist (no one is in it), create it
			ptable = {}
		else
			for k,v in ipairs(ptable) do
				if v == player:GetID() then -- check to see if the player is already in the table
					return
				end
			end
		end
		-- the player isnt already in the table, so put them there
		table.insert(ptable,player:GetID())
		--set the table back to the set var
		self:SetVar("pTable",ptable)
		-- check to see if the platform is already moving
		if (not self:GetVar("Moving")) and self:GetVar("pTable") and table.maxn(self:GetVar("pTable")) >= 1 then
			-- move the platform down
			self:GoToWaypoint{iPathIndex = 1}
			-- set moving to true
			self:SetVar("Moving",true)
			
			GAMEOBJ:GetTimer():AddTimerWithCancel(5, "CheckOnPlayers", self)
		end
	-- sent when a player gets off a platform
	elseif msg.args == "PlayerOffPillar" then
		
		if self:GetVar("Moving") and self:GetVar("pTable") then
			local ptable = self:GetVar("pTable")
			local removeP = 0 -- create variable for the player
			for k,v in ipairs(ptable) do
				if v == player:GetID() then
					removeP = k
					break
				end
			end
			-- remove the player from the table
			table.remove(ptable,removeP)
			-- if there's still players in the table, set it back to set var, otherwise set it to nil
			self:SetVar("pTable",ptable)
			if #ptable ~= 0 then return end
		end
		MovePillarUp(self,msg)
	end
end

function MovePillarUp(self,msg)
	-- tell the platform to move up
	self:GoToWaypoint{iPathIndex = 0}
	-- set moving to false
	self:SetVar("Moving",false)
	
	GAMEOBJ:GetTimer():CancelTimer("CheckOnPlayers", self)
end


function onTimerDone(self,msg)
	if msg.name == "CheckOnPlayers" then
		if self:GetVar("Moving") and self:GetVar("pTable") then
			local ptable = self:GetVar("pTable")
			local removeP = 0 -- create variable for the player
			for k,playerID in ipairs(ptable) do
				if not GAMEOBJ:GetObjectByID(playerID):Exists() then
					removeP = k
					break
				end
			end
			-- remove the player from the table
			table.remove(ptable,removeP)
			-- if there's still players in the table, set it back to set var, otherwise set it to nil
			self:SetVar("pTable",ptable)
			if #ptable == 0 then 
				MovePillarUp(self,msg)
			else
				GAMEOBJ:GetTimer():AddTimerWithCancel(5, "CheckOnPlayers", self)
			end
		
		end
	end
end
		


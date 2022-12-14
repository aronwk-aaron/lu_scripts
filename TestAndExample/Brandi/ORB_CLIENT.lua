

function onScriptNetworkVarUpdate(self, msg)
    for k,v in pairs(msg.tableOfVars) do
		if k == "Smasher" and v then
			local playerID = GAMEOBJ:GetLocalCharID()
			if not (v == playerID) then
				self:SetVisible{visible = false, fadeTime = 0.0}
			end
		end
	end
	--CheckMissions(self)
end

function onScopeChanged(self,msg)
	-- if the player entered ghosting range
    if msg.bEnteredScope then  
	-- get the player
		local player = GAMEOBJ:GetObjectByID(GAMEOBJ:GetLocalCharID())
		if not player:Exists() then 
			-- tell the zone control object to tell the script when the local player is loaded
			self:SendLuaNotificationRequest{requestTarget = GAMEOBJ:GetZoneControlID() , messageName="PlayerReady"}
			return
		end
		-- custom function
		--CheckMissions(self,player)
	end
end

-- the zone control object says the player is loaded
function notifyPlayerReady(self,zoneObj,msg)
	-- get the player
	local player = GAMEOBJ:GetObjectByID(GAMEOBJ:GetLocalCharID())
	
	if not player:Exists() then return end
	-- custom function to see if the players flag is set
	--CheckMissions(self,player)
	-- cancel the notification request
	self:SendLuaNotificationCancel{requestTarget=player, messageName="PlayerReady"}
end

----------------------------------------------
-- decide to hide the X or not
----------------------------------------------
function CheckMissions(self,player)
	local playerID = GAMEOBJ:GetLocalCharID()
	local smasher = self:GetNetworkVar("Smasher")
	if not (playerID == smasher) then
		self:SetVisible{visible = false, fadeTime = 0.0}
	end
end
	

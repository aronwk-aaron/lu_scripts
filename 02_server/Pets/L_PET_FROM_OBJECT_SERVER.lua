--------------------------------------------------------------
-- Server side script on a pet
-- this script control the pets life before it is tamed by a player

-- created by Brandi... 3/2/11
--------------------------------------------------------------

--------------------------------------------------------------
-- when the pet loads
--------------------------------------------------------------
function onStartup(self)
		-- if the pet is someones tamed pet, ignore the rest of the script
	if not self:IsPetWild{}.bIsPetWild then	return end
	baseOnStartup(self)
end

function baseOnStartup(self)
	-- get the player who is allowed to tame the pet
	local player = self:GetVar("tamer")
	-- tell the client who that player is
	self:SetNetworkVar("pettamer", player)
	
	--kill the lion after 2 minutes if the player who spawned it doesn't tame it
	GAMEOBJ:GetTimer():AddTimerWithCancel( 45, "killSelf",self )
	
end

--------------------------------------------------------------
-- when events happen in the pet taming minigame
--------------------------------------------------------------
function onNotifyPetTamingMinigame(self,msg)

	--if the player begins the taming minigame, cancel the timer that kills the lion
	if msg.notifyType == "BEGIN" then
	
		GAMEOBJ:GetTimer():CancelTimer("killSelf",self)
		
	--if the player fails or quits the minigame, kill the lion
	elseif msg.notifyType == ("QUIT") or msg.notifyType == ("FAILED") then
	
		self:RequestDie{killerID = self, killType = "SILENT"}
		
		
	--if the player succeeds in the minigame, command the lion to go to the player, otherwise he could teleport off 
	-- because the minigame tells him to go to his spawn point, and he doesnt have one
	elseif  msg.notifyType == "SUCCESS" then	
		
		local player = msg.PlayerTamingID
		
		-- teleport the pet to the player (incase they ran off)
		self:CommandPet{iPetCommandType = 6}
		-- get the groups on the pet, and parse through them
		local groups = split(self:GetVar("groupID"), ";")
		-- found out the pet type from the group name
		local petType = string.sub(groups[2],1,-2)
		
		-- remove the pet from their groups
		self:RemoveObjectFromGroup{group = petType.."s"}
		self:RemoveObjectFromGroup{group = petType..player:GetID()}
		
		-- request a pick update for interaction removal
		self:NotifyClientObject{name = "UpdatePicking"}

	end
end

--------------------------------------------------------------
-- when the pet loads
--------------------------------------------------------------
function onTimerDone (self,msg)
    
    -- kill the lion if he's been alive for too long. Lions have a very short life span
    if (msg.name == "killSelf") then
		
		--double check not to kill a lion that is actually someones pet
		if self:IsPetWild{}.bIsPetWild == false then
			return
		end
		
		self:RequestDie{killerID = self, killType = "SILENT"}
	end
end

----------------------------------------------
-- splits a string based on the pattern passed in
----------------------------------------------
function split(str, pat)
    local t = {}
    -- creates a table of strings based on the passed in pattern   
    string.gsub(str .. pat, "(.-)" .. pat, function(result) table.insert(t, result) end)

    return t
end 

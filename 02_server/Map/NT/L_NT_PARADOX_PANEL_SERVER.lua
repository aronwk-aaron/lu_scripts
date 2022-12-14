------------------------------------------------------
-- Script for Paradox Panels
-- this script is for when player interact with the power panels
-- if the player isnt on the mission and they try to use the panels they'll get knocked back and see a spark fly from the panel
-- if the player is on the mission and the interact with the panel they'll play an animation and see the the idle sparks stop 
-- TODO: update fixAnim when we get the new animation of the player fixing the panel.
--
-- Made by Ray 1/18/11
-- Updated: mrb... 2/22/11
------------------------------------------------------

------------------------------------------------------
-- This script requires that configData is set on the object in HF
-- flag -> 1:#
------------------------------------------------------
local tPlayerOnMissions = {1278, 1279, 1280, 1281}
local fixAnim = "nexus-powerpanel"
local knockbackAnim = "knockback-recovery"
local forceMultiplier = 15

-- print function that only works in an internal build
function debugPrint(self, text)	
	if self:GetVersioningInfo().bIsInternal then
		print(text)
	end
end

function onStartup(self)
	if not self:GetVar("flag") then
		local loc = self:GetPosition().pos
		
		debugPrint(self, "missing configData 'flag' on " .. self:GetVar("name") .. " at x: " .. loc.x .. " y: " .. loc.y .. " z: " .. loc.z)
	end
end

function onCheckUseRequirements(self, msg)
	local flag = self:GetVar('flag')
	
	if msg.objIDUser:GetFlag{iFlagID = flag}.bFlag or self:GetVar("bActive."..msg.objIDUser:GetID()) then
		msg.bCanUse = false
	end --flag check
	
	return msg
end

function onUse(self,msg)	
	local player = msg.user
	--sets the active var to true so the player can reuse the panel till the effect is done	
	self:SetVar("bActive."..player:GetID(), true)
	
	-- rotate the player so they are facing the panel and stun them
	player:OrientToObject{objID = self}
	player:SetStunned{StateChangeType = "PUSH", bCantMove = true, bCantTurn = true, bCantInteract = true}
	
	--tell the client object to become unpickable
	self:NotifyClientObject{name = "bActive", param1 = 1, paramObj = player, rerouteID = player}
	
	-- if the player is on one of these missions then do the fix stuff and return
	for k, missionID in ipairs(tPlayerOnMissions) do
		if player:GetMissionState{missionID = missionID}.missionState == 2 then		
			-- get the animation time	
			local cooldownTime = player:GetAnimationTime{animationID = fixAnim}.time or 2		
			
			-- play the animation and start the cooldown timer
			player:PlayAnimation{animationID = fixAnim, bPlayImmediate = true, fPriority = 6.0}
			GAMEOBJ:GetTimer():AddTimerWithCancel(cooldownTime, "StopFXTick_"..player:GetID(), self )
			
			return
		end
	end	
	
	--direction to knockback the player is taken from config data on the activator
	local dir = self:GetObjectDirectionVectors().left
	
	-- Knockback the player
	player:Knockback{vector={x=dir.x * forceMultiplier, y=5, z=dir.z * forceMultiplier}}
	--play spark effect
	self:PlayFXEffect{name = "console_sparks", effectType = "create", effectID = 6432}		
	
	-- get the animation time
	local cooldownTime = player:GetAnimationTime{animationID = "knockback-recovery"}.time or 2		
	
	-- play the animation and start the cooldown timer
	player:PlayAnimation{animationID = "knockback-recovery", bPlayImmediate = true, fPriority = 6.0}		
	GAMEOBJ:GetTimer():AddTimerWithCancel(cooldownTime, "CooldownTick_"..player:GetID(), self )
end

function onTimerDone(self, msg) 
	if startsWith(msg.name, "CooldownTick") then
		local playerID = split(msg.name, "_")[2] or 0
		local player = GAMEOBJ:GetObjectByID(playerID)
		
		if player:Exists() then
			--when the effect is done set the bActive var back to false
			self:StopFXEffect{name = "console_sparks"}
			--tell the client objects to stop sparking
			self:NotifyClientObject{name = "bActive", param1 = 0, paramObj = player, rerouteID = player}
			-- unstun the player
			player:SetStunned{StateChangeType = "POP", bCantMove = true, bCantTurn = true, bCantInteract = true}
		end
		
		self:SetVar("bActive."..playerID, nil)		
	elseif startsWith(msg.name, "StopFXTick") then
		local playerID = split(msg.name, "_")[2] or 0
		local player = GAMEOBJ:GetObjectByID(playerID)
		
		if player:Exists() then
			local flag = self:GetVar('flag')
			
			-- do the player fix stuff
			player:SetFlag{iFlagID = flag, bFlag = true}
			--tell the client objects to stop sparking
			self:NotifyClientObject{name = "SparkStop", paramObj = player, rerouteID = player}
			-- unstun the player
			player:SetStunned{StateChangeType = "POP", bCantMove = true, bCantTurn = true, bCantInteract = true}
			player:PlayAnimation{animationID = "rebuild-celebrate", bPlayImmediate = true}
		end
		
		self:SetVar("bActive."..playerID, nil)		
	end
end 

function startsWith(String,Start)
	return string.sub(String,1,string.len(Start)) == Start
end 

function split(str, pat)
    local t = {}
    -- creates a table of strings based on the passed in pattern   
    string.gsub(str .. pat, "(.-)" .. pat, function(result) table.insert(t, result) end)

    return t
end 
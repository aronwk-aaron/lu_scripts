--------------------------------------------------
-- Nexus Tower Armory Combat Challenge Server script
--
-- updated - 8/11/11 - mrb... updated audio GUIDs
--------------------------------------------------

local currencyLOT = 3039
local currencyCost = 1
local gameTime = 30.0
local preConVar = "166"    
local startSound = "{a477f897-30da-4b15-8fce-895c6547adae}"
local stopSound = "{a832b9c5-b000-4c97-820a-2a7d1e68dd9d}"
local timerSound = "{79b38431-4fc7-403b-8ede-eaff700a7ab0}"
local timerLowSound = "{0e1f1284-e1c4-42ed-8ef9-93e8756948f8}"
local scoreSound = "{cfdade40-3d97-4cf5-b53c-862e0b84c1a1}"

-- target dummy lots
local tTargets = {	13556, 13556, 13764, 13764, 13765, 13765,  
					13766, 13766, 13767, 13767, 13768, 13768, 
					13830, 13769, 13769, 13770, 13830, 13770, 
					13771, 13771, 13830, 13772} -- bomb = 13830
-- update missions keep the dmg in order from lowest to highest
local tMissions = {	{mission = 1010, dmg = 25}, 
					{mission = 1340, dmg = 100}, 
					{mission = 1341, dmg = 240}, 
					{mission = 1342, dmg = 290}, }

-- print function that only works in an internal build
function debugPrint(self, text)	
	if self:GetVersioningInfo().bIsInternal then
		print(text)
	end
end

function onStartup(self, msg)
	self:SetVar("TargetNumber", 1)
end 

function notifyHitOrHealResult(self, other, msg) 
	if msg.receiver:GetID() ~= other:GetID() or msg.dealer:GetID() == self:GetID() then return end
	
    if self:GetVar('playerID') and self:GetNetworkVar("bInUse") then    
        local player = GAMEOBJ:GetObjectByID(self:GetVar('playerID'))
		local totalDmg = self:GetNetworkVar("totalDmg") or 0
        local dmg = msg.lifeDamageDealt + msg.armorDamageDealt
		
        totalDmg = totalDmg + dmg	
        self:SetNetworkVar("totalDmg", totalDmg)
		-- play the score audio
		self:PlayNDAudioEmitter{m_NDAudioEventGUID = scoreSound}
    end    
end 

function notifyDie(self, other, msg)
    -- if the target died as a result of the hit spawn a new one and cancel the lua notification
    if msg.killerID:GetID() ~= self:GetID() then
		self:SendLuaNotificationCancel{requestTarget = other, messageName = "HitOrHealResult"}
		self:SendLuaNotificationCancel{requestTarget = other, messageName = "Die"}
		SpawnTargetDummy(self)
    end
end

function onUse(self,msg)        	
    if not msg.user:GetFlag{iFlagID = 115}.bFlag then       
		-- tell the users client script that the UI is open
		self:NotifyClientObject{name = "UI_Open", paramObj = msg.user, rerouteID = msg.user}
	end
end

function onCheckUseRequirements(self, msg) 
	local check = msg.objIDUser:CheckListOfPreconditionsFromLua{PreconditionsToCheck = preConVar, requestingID = self}
	
	-- dont let the playe use this if the minigame is active or they dont meet the precondition check.
	if not check.bPass or self:GetNetworkVar("bInUse") then
		msg.bCanUse = false
	end
    
    return msg
end

function onMessageBoxRespond(self,msg)
	if msg.identifier == "PlayButton" and msg.iButton == 1 then	 
		-- player hit the yes button so start the minigame
		self:SetNetworkVar("bInUse", true)  			
		self:SetVar("playerID", "|" .. msg.sender:GetID())
		
		-- take the activity cost
		msg.sender:RemoveItemFromInventory{ iObjTemplate = currencyLOT, iStackCount = currencyCost}
		-- play the start audio
		self:PlayNDAudioEmitter{m_NDAudioEventGUID = startSound}
		-- add start delay timer
		self:ActivityTimerSet{name = "start_delay", updateInterval = 2, duration = 2}
		msg.sender:ShowActivityCountdown()
		-- tell the clients to start the ui
		self:SetNetworkVar("toggle", true)
	elseif msg.identifier == "CloseButton" then
		-- tell the client that the player closed the UI
		self:NotifyClientObject{name = "UI_Close", paramObj = msg.sender, rerouteID = msg.sender, param1 = 1}
	end
end

function onFireEventServerSide(self, msg)
    local player = GAMEOBJ:GetObjectByID(msg.args)
    
    if player:Exists() then
		-- tell the client that the messagebox is closed
		self:NotifyClientObject{name = "UI_Close", paramObj = player, rerouteID = player}
    end
end

function SpawnTargetDummy(self)
	if not self:GetVar("playerID") then return end
	
	-- get the lot of the next target object
	local dummyNum = self:GetVar("TargetNumber") or 1	
	-- if we're at the end of the list then spawn the last target again
	local dummyLOT = tTargets[dummyNum] or tTargets[table.maxn(tTargets)]
	-- get the rotation/position to place the target.
	local mypos = self:GetPosition().pos
	local myRot = self:GetRotation()
	local config = { }

	-- spawn the target
	RESMGR:LoadObject { objectTemplate = dummyLOT, x= mypos.x, y= mypos.y, z= mypos.z, rw= myRot.w, rx= myRot.x, ry= myRot.y , rz = myRot.z, configData = config, owner = self }
end

function SetAttackImmunity(objID, bTurnOn)
	local state = "PUSH"
	
	if not bTurnOn then
		state = "POP"
	end
	
	objID:SetStatusImmunity{ StateChangeType = state, bImmuneToSpeed = true, bImmuneToBasicAttack = true, bImmuneToDOT = true}

end

function onChildLoaded(self, msg)
	--get the current target number and increment it by 1
	local targetNum = self:GetVar("TargetNumber") or 1
	self:SetVar("TargetNumber", targetNum + 1)
	
	local animTime = msg.childID:GetAnimationTime{animationID = "spawn"}.time or 0
	
	if animTime > 0 then
		SetAttackImmunity(msg.childID, true)		
        -- add clear attack immunity timer
        self:ActivityTimerSet{name = "clear_" .. msg.childID:GetID(), updateInterval = animTime, duration = animTime}   
	end
	
     -- Make immune to move/teleport behaviors
    msg.childID:SetStatusImmunity{ StateChangeType = "PUSH", bImmuneToPullToPoint = true, bImmuneToKnockback = true} -- Make immune to knockbacks and pulls
	-- rotate the target to face the player
	msg.childID:RotateObject{rotation = {x = 0, y = math.rad(180), z = 0}}
	-- request lua notification of the child and set the child ID
	self:SendLuaNotificationRequest{requestTarget = msg.childID, messageName = "HitOrHealResult"}
	self:SendLuaNotificationRequest{requestTarget = msg.childID, messageName = "Die"}
	self:SetVar("currentTargetID", msg.childID)
	msg.childID:AddObjectToGroup{group = "targets_"..self:GetID()}
end

function resetGame(self)      
	local totalDmg = self:GetNetworkVar("totalDmg") or 0
	local playerID = self:GetVar("playerID") or 0
	local player = GAMEOBJ:GetObjectByID(playerID)
	
	for k, missionSet in ipairs(tMissions) do
		--Damage checks for quest and switching the dummies
		if totalDmg >= missionSet.dmg then
			player:UpdateMissionTask{taskType = "complete", value = missionSet.mission, value2 = 1, target = self}
			player:TeamNotifyUpdateMissionTask{originalUpdatee = player, taskType = "complete", value = missionSet.mission, value2 = 1, target = self}
		else
			break
		end
	end
	
	-- reset the game variables   
	self:SetVar("TargetNumber", 1)
    self:SetVar('playerID', false)  
    self:SetNetworkVar("totalDmg", false)
	self:SetNetworkVar("update_time", 0)
	
	local targetObjs = self:GetObjectsInGroup{ group = "targets_"..self:GetID(), ignoreSpawners = true }.objects
	
	for k, obj in ipairs(targetObjs) do
	-- kill the current target if one exists
		if obj:Exists() then
			obj:RequestDie{killerID = self, killType = "SILENT"}
		end
	end
end

function onActivityTimerUpdate(self, msg)
	if msg.name == "game_tick" then
		self:SetNetworkVar("update_time", math.ceil(msg.timeRemaining))
		
		local soundGUID = timerSound
		
		if msg.timeRemaining <= 3 then
			soundGUID = timerLowSound
		end
		
		-- play the timer audio
		self:PlayNDAudioEmitter{m_NDAudioEventGUID = soundGUID}
	end
end

function onActivityTimerDone(self, msg)
    if msg.name == "start_delay" then		     
        -- add start delay timer
        self:ActivityTimerSet{name = "game_tick", updateInterval = 1, duration = gameTime}      
		-- spawn the first target
		SpawnTargetDummy(self)
		-- set total time for the UI clock
		self:SetNetworkVar("totalTime", gameTime)
    elseif string.starts(msg.name, "clear_") then
		local targetID = split(msg.name, "_")[2] or 0
		local target = GAMEOBJ:GetObjectByID(targetID)
		
		if target:Exists() then
			SetAttackImmunity(target, false)
		end
    elseif msg.name == "game_tick" then
        --local player = GAMEOBJ:GetObjectByID(self:GetVar('playerID'))
        
   --     if player:Exists() then
			--local score = self:GetNetworkVar("totalDmg") or 0
			
   --         player:DisplayTooltip{strText = "You did " .. score .. " points of damage in " .. gameTime .. " seconds." , bShow = true, strImageName ="textures/ui/tooltips/NT_Armory_Dummy.dds"}    
   --     end
        
        resetGame(self)
        
		-- play the stop audio
		self:PlayNDAudioEmitter{m_NDAudioEventGUID = stopSound}
        -- add start delay timer
        self:ActivityTimerSet{name = "reset_tick", updateInterval = 5, duration = 5}   
    elseif msg.name == "reset_tick" then     
		-- turn off the 3dUI and make the minigame interactable again
		self:SetNetworkVar("toggle", false)      
		self:SetNetworkVar("bInUse", false)
    end
end

function split(str, pat)
    local t = {}
    -- creates a table of strings based on the passed in pattern   
    string.gsub(str .. pat, "(.-)" .. pat, function(result) table.insert(t, result) end)

    return t
end 

function string.starts(String,Start)
    -- finds if a string starts with a giving string.
   return string.sub(String,1,string.len(Start))==Start
end 
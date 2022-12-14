----------------------------------------
-- Base server script to make the dragon 
-- spawn in a QB on armor depletion to allow the player to smash the dragon
--
-- updated mrb... 3/10/11 - updated so that chest wont spawn by default
----------------------------------------
require('02_server/Enemy/General/L_SUSPEND_LUA_AI')

-- to get a treasure chest to spawn put self:SetVar("chestObject", chestObjectLOT) in the startup of the template script

local defaultDragonSmashingGolem = 8340 

function onStartup(self) 
	baseStartup(self)
end

function baseStartup(self) 
    self:SetVar("Trg.1", 0 ) -- This is used to keep track of child objects (quick builds) since there is no function to "get" children
    --Used to identify that the "weak spot" is vulnerable
    self:SetVar("weakspot",0)  -- 0 = not exposed, 1 = is exposed, 2 = not exposed but stunned
    self:SetStunImmunity{StateChangeType = "PUSH", bImmuneToStunAttack = true, bImmuneToInterrupt = true, bImmuneToStunMove = true, bImmuneToStunTurn = true, bImmuneToStunUseItem = true, bImmuneToStunEquip = true, bImmuneToStunInteract = true} -- Make immune to stuns
    self:SetStatusImmunity{ StateChangeType = "PUSH", bImmuneToPullToPoint = true, bImmuneToKnockback = true } -- Make immune to knockbacks and pulls
    
    -- turn off lua ai
    suspendLuaAI(self)
end

function onHitOrHealResult(self, msg)
	baseHitOrHealResult(self, msg)
end

--check if armor is depleted then start timer and make it immune to damage
function baseHitOrHealResult(self, msg)
	-- check to make sure the dragon took damage and didn't die
	if msg.receiver:GetID() ~= self:GetID() or msg.diedAsResult then return end
	
	self:PlayFXEffect{effectType = "gothit"}
	
	if msg.armorDamageDealt or msg.lifeDamageDealt then
		local weakspot = self:GetVar("weakspot") or -1
		
		if weakspot == 1 then -- if the dragon is struck while weakspot is exposed
			local lootTag = self:GetEnemyLootTag().enemyID
			local smasherID = self:GetVar("Smasher") or 0
			local smasherObj = GAMEOBJ:GetObjectByID(smasherID)		
			
			-- send the lootOwnerID with requestDie
			self:RequestDie{killerID = smasherObj, lootOwnerID = lootTag}
			
			return
		end
	end
	
	if msg.armorDamageDealt > 0 and self:GetArmor().armor < 1 then
		local weakspot = self:GetVar("weakspot") or -1
		
		if weakspot == 0 then -- weakspot is NOT exposed
			GAMEOBJ:GetTimer():AddTimerWithCancel( 12 , "ReviveTimer", self )-- Set a time to revive the dragon
			local lootTag = self:GetEnemyLootTag().enemyID
			-- disable AI
			self:EnableCombatAIComponent {bEnable = false}   
			--self:ClearThreatList() -- Clear out hate list so the enemy doesn't try to attack anyone
			self:CancelSkillCast()            
			
			self:SetStunned{StateChangeType = "PUSH", bCantMove = true, bIgnoreImmunity = true, bCantTurn = true} -- fully stun the dragon so it can't move or attack
			-- self:SetStatusImmunity{StateChangeType = "PUSH", bImmuneToBasicAttack = true, bImmuneToDOT = true} -- Make immune to damage until the "weakspot" is exposed
			self:SetVar("weakspot", 2) -- sets to an unchecked weakspot value to set up enough time for the troll to spawn in and let animations play         
			self:ChangeIdleFlags{off = 9}
			self:PlayAnimation{ animationID = "stunstart" , fPriority = 1.7}
			GAMEOBJ:GetTimer():AddTimerWithCancel( 1  , "timeToStunLoop", self )
			
			-- spawn in the QB to smash the dragon in front of the dragon
			local mypos = self:GetPosition().pos
			local spawnFwd = self:GetForwardVector().niForwardVector
			
			spawnFwd.x = spawnFwd.x * 10
			spawnFwd.z = spawnFwd.z * 10
			
			local myRot = self:GetRotation()
			--spawn quick build on dragon's look dir
			local oPos = { pos = "", rot = ""}
			local oDir = self:GetObjectDirectionVectors()
			
			oPos.pos = self:GetPosition().pos
			oPos.pos.y = oPos.pos.y
			oPos.pos.x = oPos.pos.x - (oDir.backward.x * 8) 
			oPos.pos.z = oPos.pos.z - (oDir.backward.z * 8) 
			
			local posString = self:CreatePositionString{ x = (oPos.pos.x+spawnFwd.x), y = oPos.pos.y, z = (oPos.pos.z+spawnFwd.z) }.string
			local config = { {"rebuild_activators", posString }, {"respawn", 100000 }, {"rebuild_reset_time", 15}, {"no_timed_spawn", true}, {"currentTime", 0}, {"lootTagOwner", lootTag} }
			local DragonSmashingGolem = self:GetVar("DragonSmashingGolem") or defaultDragonSmashingGolem
	
			RESMGR:LoadObject { objectTemplate = DragonSmashingGolem, x= mypos.x, y= mypos.y, z= mypos.z, rw= myRot.w, rx= myRot.x, ry= myRot.y , rz = myRot.z, configData = config, owner = self }
		end
    end    
end

function onTimerDone(self, msg)
	baseTimerDone(self, msg)
end

-- Check timer to revive
function baseTimerDone(self, msg)
    -- Is it time for the dragon to get up and fight again?
    if msg.name == "ReviveHeldTimer" then
        GAMEOBJ:GetTimer():AddTimerWithCancel( 2.5  , "backToAttack", self )
		-- Is it time to expose the dragon's weak spot?
    elseif msg.name == "ExposeWeakSpotTimer" then
        self:SetVar("weakspot", 1)   -- the weak spot is now exposed
    elseif msg.name == "timeToStunLoop" then
        self:PlayAnimation{ animationID = "stunloop" , fPriority = 1.8}
    elseif msg.name == "ReviveTimer" then
        self:PlayAnimation{ animationID = "stunend" , fPriority = 2.0}
        GAMEOBJ:GetTimer():AddTimerWithCancel( 1  , "backToAttack", self )
    elseif msg.name == "backToAttack" then
        self:SetStunned{StateChangeType = "POP", bCantMove = true, bIgnoreImmunity = true, bCantTurn = true, bCantEquip = true}
        self:EnableCombatAIComponent {bEnable = true} 
        self:ChangeIdleFlags{on = 9}
        --self:SetArmor{armor = 35}    -- give partial armor back
        self:SetVar("weakspot", -1)   -- turn off weakspot
        self:NotifyClientObject{name = "DragonRevive", param1 = 0}
    end
end

function onChildLoaded(self, msg)
	baseChildLoaded( self,msg )
end

--Store the QB so we can use it to smash the Dragon
function baseChildLoaded( self,msg )
	local DragonSmashingGolem = self:GetVar("DragonSmashingGolem") or defaultDragonSmashingGolem
	
     if ( msg.templateID  == DragonSmashingGolem)  then
        local t = self:GetVar("Trg")
        -- Save Target ID's/
        for i = 1, table.maxn( t ) do 
            if self:GetVar("Trg."..i) == nil or self:GetVar("Trg."..i) == 0  then
                storeChild(self,  msg.childID , i) 
				self:SetVar("Trg."..i+1, 0 )
            end
        end  
    end
end

function onNotifyObject(self, msg)
	baseNotifyObject( self, msg )
end

--Notify the Dragon when the rebuild state changes
function baseNotifyObject( self, msg )
	-- if the rebuild is complete
	if ( msg.name == "rebuildDone" ) then
        --Getting the sender ID which we set as the player and storing it for the DIE call
         self:SetVar("Smasher", "|" .. msg.ObjIDSender:GetID())
		 GAMEOBJ:GetTimer():AddTimerWithCancel( 3.8  , "ExposeWeakSpotTimer", self )
         GAMEOBJ:GetTimer():CancelTimer("ReviveTimer", self);      -- Cancel the revive timer to restart it   
         GAMEOBJ:GetTimer():AddTimerWithCancel( 10.5  , "ReviveHeldTimer", self )
         self:PlayAnimation{ animationID = "quickbuildhold" , fPriority = 1.9}	
	end
end

function onDie(self, msg)
	baseDie(self,msg)
end

function baseDie(self,msg)
	-- get the location of the pet dig to spawn the crab there
	local mypos = self:GetPosition().pos
    local myRot = self:GetRotation()
	-- incase something bad happens use the killerID
	local lootTag = msg.lootOwnerID or msg.killerID
	local config = { {"parent_tag", lootTag} }
	-- get chest object
	local chestObject = self:GetVar("chestObject") 
	
	-- check to see if we need to spawn a chest
	if chestObject then
		-- spawn a treasure chest
		RESMGR:LoadObject { objectTemplate = chestObject , x = mypos.x , y = mypos.y , z = mypos.z ,owner = self,
							rw= myRot.w, rx= myRot.x, ry= myRot.y , rz = myRot.z, configData = config}
	end
	
	for i = 1, table.maxn( self:GetVar("Trg")) do             
		local child = getChild(self, i)   

		if child:Exists() then
			child:RequestDie{killType = "VIOLENT"} 
		end             
    end 
end  

function getChild(self, num)
	targetID = self:GetVar("Trg."..num )
	
	return GAMEOBJ:GetObjectByID(targetID)
end

function storeChild(self, target, num)
	idString = target:GetID()
	finalID = "|" .. idString
	self:SetVar("Trg."..num , finalID)
end

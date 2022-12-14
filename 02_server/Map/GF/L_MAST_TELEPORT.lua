--------------------------------------------------------------
-- Server side script for the QB Pirate Mast
--
-- updated abeechler ... 1/24/11 - modified to allow for use without inventory hook equipped
-- updated abeechler ... 1/25/11 - refactored swing scripts to enforce server side functionality
--------------------------------------------------------------

local hookPreconditions = "154;44"

function onStartup(self)
    -- Player must have the hook in inventory
    self:SetNetworkVar("hookPreconditions", hookPreconditions)
end

----------------------------------------------
-- Check to see if the player can use the hook-swing
----------------------------------------------
function onCheckUseRequirements(self,msg)
	local player = msg.objIDUser
    
    -- We have set-up a precondition for this interaction (hookPrecondition)
    -- check it to ensure interaction viability
    if(player:CheckListOfPreconditionsFromLua{PreconditionsToCheck = hookPreconditions}.bPass == false) then
        msg.bCanUse = false
    end
    
    return msg
end

function onRebuildComplete(self, msg)

    local player = msg.userID
	
	self:SetVar("userID", player:GetID())
	
	-- Lock player interaction
	player:SetStunned{StateChangeType = "PUSH",
							bCantMove = true,
							bCantTurn = true,
						  bCantAttack = true,
						 bCantUseItem = true,
						   bCantEquip = true,
						bCantInteract = true}
	
	-- Prevent player damage during hook transition
	player:SetStatusImmunity{StateChangeType = "PUSH",
						  bImmuneToKnockback = true,
						  bImmuneToInterrupt = true,
							 bImmuneToSpeed  = true,
					   bImmuneToBasicAttack  = true,
							    bImmuneToDOT = true,
				bImmuneToQuickbuildInterrupt = true,
						bImmuneToPullToPoint = true}
						     
	

    GAMEOBJ:GetTimer():AddTimerWithCancel( 3.0, "Start", self )
    
end

function onTimerDone(self, msg)

    local player = GAMEOBJ:GetObjectByID(self:GetVar("userID"))
	
    if msg.name == "Start" then
		local oPos = { pos = "", rot = ""}

        oPos.pos = self:GetPosition().pos
		oPos.rot = self:GetRotation()
        
        player:Teleport{pos = oPos.pos, x=oPos.rot.x, y=oPos.rot.y, z=oPos.rot.z, w=oPos.rot.w, bSetRotation=true}
        
        -- Determine if there is an object config data defined cinematic to play
        local cine = self:GetVar("Cinematic")
        local leadIn = self:GetVar("LeadIn") or 0
        if cine then  
            player:PlayCinematic{pathName = cine, leadIn = leadIn} 
        end
        
        -- Play the hook item attach behavior effect
        player:PlayFXEffect{name = "hook", effectType = "hook", effectID = 6039}
        
        -- Play the swing animation for both interacting player and object
        player:PlayAnimation{ animationID = "crow-swing-no-equip", fPriority = 4.0 }
        self:PlayAnimation{ animationID = "swing" }
        
        -- Establish a timer the length of the hook swing player animation 
        -- to mark when to end the 'hook' effect
        local animTime = player:GetAnimationTime{animationID = "crow-swing-no-equip"}.time or 6.25
        GAMEOBJ:GetTimer():AddTimerWithCancel(animTime , "PlayerAnimDone", self)
        
    elseif msg.name == "PlayerAnimDone" then
        -- Remove the hook effect
        player:StopFXEffect{name = "hook"}
        
        -- Acquire the player projection vector
        local oPos = { pos = "", rot = ""}
        local oDir = self:GetObjectDirectionVectors()
        
        -- Defined our desired player destination rotation
		local degrees = -25
		local rads = degrees * math.pi/180
		local newPlayerRot = {x=0,y=rads,z=0}

		-- Calculate the desired player placement location
        oPos.pos = self:GetPosition().pos
        oPos.pos.x = oPos.pos.x + (oDir.forward.x * 20.5)
        oPos.pos.y = oPos.pos.y + 12
        oPos.pos.z = oPos.pos.z + (oDir.forward.z * 20.5)
		
		-- Place and orient the player
		player:OrientToAngle{fAngle = rads, bRelativeToCurrent = true}
		player:Teleport{pos = oPos.pos, bIgnoreY = false}
		
		--Return interact control to the player
		player:SetStunned{ StateChangeType = "POP",
								 bCantMove = true,
								 bCantTurn = true,
							   bCantAttack = true,
							  bCantUseItem = true,
							    bCantEquip = true,
						     bCantInteract = true}
						     
		-- Resume player damage post hook transition
		player:SetStatusImmunity{StateChangeType = "POP",
							  bImmuneToKnockback = true,
							  bImmuneToInterrupt = true,
							     bImmuneToSpeed  = true,
					       bImmuneToBasicAttack  = true,
							        bImmuneToDOT = true,
				    bImmuneToQuickbuildInterrupt = true,
						    bImmuneToPullToPoint = true}

						     
    end
end

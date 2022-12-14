--------------------------------------------------------------
-- Server side script for the Captain Jack Cannon
--
-- updated abeechler ... 1/25/11 - created a server side script to handle cannon processing porperly
--------------------------------------------------------------

local hookPreconditions = "154;44"
local sharkItemID = 7343

----------------------------------------------
-- Check to see if the player can use the cannon
----------------------------------------------
function onCheckUseRequirements(self,msg)

	local bIsInUse = self:GetNetworkVar('bIsInUse')
	if bIsInUse then
		-- If the interact is in use, we can break immediately and report failure
		msg.bCanUse = false
	else
		-- We have set-up a precondition for this interaction (hookPrecondition)
		-- check it to ensure interaction viability
		local player = msg.objIDUser
		local check = player:CheckListOfPreconditionsFromLua{PreconditionsToCheck = hookPreconditions}
		
		if(check.bPass == false) then
			msg.bCanUse = false
		end
    end
    
    return msg
end

----------------------------------------------
-- Capture the cannon use and process accordingly
----------------------------------------------
function onUse(self, msg)

	local player = msg.user
	self:SetVar("userID", player:GetID())
	
	-- Mark the interaction as in use and process
	self:SetNetworkVar('bIsInUse', true)
	
	-- Lock player interaction
	player:SetStunned{ StateChangeType = "PUSH",
							 bCantMove = true,
							 bCantTurn = true,
						   bCantAttack = true,
						  bCantUseItem = true,
							bCantEquip = true,
						 bCantInteract = true}
	
	-- Calculate the target player teleport location
	local oPos = { pos = "", rot = ""}
	local oDir = self:GetObjectDirectionVectors()
	oPos.pos = self:GetPosition().pos
	oPos.pos.x = oPos.pos.x + (oDir.forward.x * -3)
	oPos.pos.z = oPos.pos.z + (oDir.forward.z * -3)
	oPos.rot = self:GetRotation()

	-- Position the player, start the cannon animation, and play the appropriate hook effect
	player:Teleport{pos = oPos.pos, x=oPos.rot.x, y=oPos.rot.y, z=oPos.rot.z, w=oPos.rot.w, bSetRotation=true}
	player:PlayAnimation{ animationID = "cannon-strike-no-equip", bPlayImmediate = true }
    player:PlayFXEffect{name = "hook", effectType = "hook", effectID = 6039}
    
    -- Establish a timer the length of the cannon fire player animation 
    -- to mark when to end the 'hook' effect
    local animTime = player:GetAnimationTime{animationID = "cannon-strike-no-equip"}.time or 1.667
	GAMEOBJ:GetTimer():AddTimerWithCancel(animTime, "FireCannon", self)

end

function onTimerDone (self,msg)
	local player = GAMEOBJ:GetObjectByID(self:GetVar("userID"))
	if (not player:Exists()) then
		-- Catch the case where a timed interaction is initiated but the player has disappeared
		-- Mark the interaction as no longer in use and process
		self:SetNetworkVar('bIsInUse', false)
		return
	end
	
	if (msg.name == "FireCannon") then
		
		-- Start the camera cinematic
		local cineTime = tonumber(LEVEL:GetCinematicInfo("Cannon_Cam")) or 6.3
		GAMEOBJ:GetTimer():AddTimerWithCancel(cineTime, "cinematicTimer", self)
		player:PlayCinematic { pathName = "Cannon_Cam" }   
		
		-- Iterate through the group objects and find the shark to animate
		local sharkObjTable = self:GetObjectsInGroup{ group = "SharkCannon" , ignoreSpawners = true}.objects
		for i, sharkObj in ipairs(sharkObjTable) do
			-- The current iteration object exists
			if (sharkObj:Exists()) then
				-- the current iteration object is a target shark to animate
				if (sharkObj:GetLOT().objtemplate == sharkItemID) then
					sharkObj:PlayAnimation{ animationID = "cannon", bPlayImmediate = true }
					break
				end
			end
		end
		
		-- Play the appropriate sound FX
		player:PlayNDAudioEmitter{m_NDAudioEventGUID = "{7457d85c-4537-4317-ac9d-2f549219ea87}"}
	
	elseif (msg.name == "cinematicTimer") then
		--Return interact control to the player
		player:SetStunned{ StateChangeType = "POP",
								 bCantMove = true,
								 bCantTurn = true,
							   bCantAttack = true,
							  bCantUseItem = true,
							    bCantEquip = true,
						     bCantInteract = true}
		
		-- Mark the interaction as no longer in use and process
		self:SetNetworkVar('bIsInUse', false)
		
		-- Stop the hook display behavior effect
		player:StopFXEffect{name = "hook"}
		
		player:UpdateMissionTask{taskType = "complete", value = 601, value2 = 1, target = self}
		
		player:TerminateInteraction{type = 'fromInteraction', ObjIDTerminator = self}
	end
end

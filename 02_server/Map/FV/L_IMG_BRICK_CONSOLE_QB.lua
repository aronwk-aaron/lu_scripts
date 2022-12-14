--------------------------------------------------------------
--  Server script on the consoles that are built for the blue brick puzzle in FV
--  
-- created Brandi... 8/25/10
-- updated Brandi... 1/10/11 - added complete mission for a mission from CP
--------------------------------------------------------------

--------------------------------------------------------------
-- timers for console death based on the state it is in
--------------------------------------------------------------
local resetBricks = 30 -- unbuilt bricks
local resetConsole = 60 -- built console
local resetInteract = 45 -- console after it has been interacted with

local missionTable = { 	{misCheckID = 1302, objRemoveID = 13074, misUpdateID = 1302},
						{misCheckID = 1926, objRemoveID = 14472, objToGive = 16488, misUpdateID = 1926 }
					}

--------------------------------------------------------------
-- when the consoles load in
--------------------------------------------------------------
function onStartup(self,msg)
	-- set that the console hasnt been used
	self:SetNetworkVar("used", false)
	-- start a timer to kill if the player doesnt build in time
	GAMEOBJ:GetTimer():AddTimerWithCancel(resetBricks, "reset", self )	
end

--------------------------------------------------------------
-- when the player interacts with the console
--------------------------------------------------------------
function onUse(self,msg)
	
	-- to make sure the player isn't interacting with the object just to quickbuild it
	-- state 2 means the quickbuild is complete
	if self:GetRebuildState{}.iState == 2 then
		if not self:GetNetworkVar("used") then
		
			-- get call the consoles loaded
			local consoles = self:GetObjectsInGroup{group = "Console", ignoreSpawners = true}.objects
			local bothBuilt = false
			for k,v in ipairs(consoles) do
				-- make sure only to count consoles that have been built
				if v:Exists() and v:GetRebuildState().iState == 2 then
					-- cancel any reset timers they have
					GAMEOBJ:GetTimer():CancelAllTimers( v )
					-- check to see if the console as been used yet
					if v:GetNetworkVar("used") then
						bothBuilt = true
					end
				end
			end
			
			-- if both have been used go to function, or if only one has been used, go to a different function
			if bothBuilt == true then
				smashCanister(self)
			else
				spawnBrick(self)
			end
			-- add a timer to kill the console
			GAMEOBJ:GetTimer():AddTimerWithCancel(resetInteract, "Die", self )
			-- get the main tube console, and play fx on it
			local facility = self:GetObjectsInGroup{group = "FacilityPipes", ignoreSpawners = true}.objects[1]
			local onFX = 0
			local location = self:GetVar("console")
			if location == "Left" then -- if left console, play one fx, if right, play a different one
				onFX = 2776
			else
				onFX = 2779
			end
			if facility then
				facility:StopFXEffect{name = location.."PipeEnergy"}
				facility:PlayFXEffect{name = location.."PipeOn", effectID = onFX, effectType = "create"}
			end
        end
		
		-- get local player
		local player = msg.user
		
		for k,missionT in ipairs(missionTable) do
			-- see if they are on the mission to interact with the console and have the item needed
			if player:GetMissionState{missionID = missionT.misCheckID}.missionState == 2 and 
					player:GetInvItemCount{ iObjTemplate = missionT.objRemoveID}.itemCount >= 1 then
				-- take away said item and update the mission
				player:RemoveItemFromInventory{iObjTemplate = missionT.objRemoveID, iStackCount = 1 }
				if missionT.misUpdateID then
					player:UpdateMissionTask{taskType = "complete", value = missionT.misUpdateID, value2 = 1, target = self}
				end
				if missionT.objToGive then
					player:AddItemToInventory{iObjTemplate = missionT.objToGive, itemCount = 1, bMailItemsIfInvFull = true }
				end
			end
		end
        
        
        -- set that this console is used
		self:SetNetworkVar("used", true)
		
        player:TerminateInteraction{type = "fromInteraction", ObjIDTerminator = self}
	end
	
end

--------------------------------------------------------------
-- when only one console has been interacted with, delete the netdevil and spawn the brick
--------------------------------------------------------------		
function spawnBrick(self)
	-- delete the netdevil, deactivate and reset its spawner
	local netdevil = LEVEL:GetSpawnerByName("MaelstromBug")
	if netdevil then
		netdevil:SpawnerDestroyObjects()
		netdevil:SpawnerReset()
		netdevil:SpawnerDeactivate()
	end
	-- spawn the blue brick
	local brick = LEVEL:GetSpawnerByName("Imagination")
	if brick then
		brick:SpawnerActivate()
	end
end	

--------------------------------------------------------------
-- when both consoles have been interacted with, smash the canister so the player can get the brick
--------------------------------------------------------------	
function smashCanister(self)
	-- get the brick, and play fx on it
	local object = self:GetObjectsInGroup{group = "Brick", ignoreSpawners = true}.objects[1]
	if object then
	    object:PlayFXEffect{name = "bluebrick", effectID = 122, effectType = "create"}
		object:PlayFXEffect{name = "imaginationexplosion", effectID = 1034, effectType = "cast"}
	end
	-- get the canister and kill it violently
	local canister = self:GetObjectsInGroup{group = "Canister", ignoreSpawners = true}.objects
	for k,v in ipairs(canister) do
		if v:Exists() then
			v:RequestDie{killerID = v, killType = "VIOLENT"}
		end
	end
	-- get the canister spawner network and deactivate it and reset it
	local canister = LEVEL:GetSpawnerByName("BrickCanister")
	if canister then
		canister:SpawnerReset()
		canister:SpawnerDeactivate()
	end

end	

--------------------------------------------------------------
-- when the console quickbuild has been fully built
--------------------------------------------------------------		
function onRebuildComplete(self,msg)
	-- get the main tube console, and play fx on it
	local facility = self:GetObjectsInGroup{group = "FacilityPipes", ignoreSpawners = true}.objects[1]
	local energyFX = 0
	local location = self:GetVar("console")
	if location == "Left" then -- if left console, play one fx, if right, play a different one
		energyFX = 2775
	else
		energyFX = 2778
	end
	if facility then
        facility:StopFXEffect{name = location.."PipeOff"}
        facility:PlayFXEffect{name = location.."PipeEnergy", effectID = energyFX, effectType = "create"}
    end
	-- get the quick build consoles that are built, and cancel their timers
	local consoles = self:GetObjectsInGroup{group = "Console", ignoreSpawners = true}.objects
	for k,v in ipairs(consoles) do
		if v:Exists() and v:GetRebuildState().iState == 2 then
			GAMEOBJ:GetTimer():CancelAllTimers( v )
		end
	end
	-- set a timer to kill the console
	GAMEOBJ:GetTimer():AddTimerWithCancel(resetConsole, "Die", self )
end

--------------------------------------------------------------
-- when the console dies, no matter what state it is in
--------------------------------------------------------------					
function onDie(self,msg)
	if self:GetRebuildState().iState == 2 then
		local facility = self:GetObjectsInGroup{group = "FacilityPipes", ignoreSpawners = true}.objects[1]
		local offFX = 0
		local location = self:GetVar("console")
		if location == "Left" then
			offFX = 2774
		else
			offFX = 2777
		end
		if facility then
            facility:StopFXEffect{name = location.."PipeEnergy"}
            facility:StopFXEffect{name = location.."PipeOn"}
            facility:PlayFXEffect{name = location.."PipeOff", effectID = offFX, effectType = "create"}
            facility:PlayFXEffect{name = "imagination_canister", effectID = 2750, effectType = "create"}
        end
	end
	-- find the name of the spawner network
	local mygroup = tostring(self:GetVar("spawner_name"))
	local pipeGroup = string.sub(mygroup,1,10)
	local firstPipe = pipeGroup.."1"
	-- deactivate and reset current spawner network
	local SamePipeSpawner = LEVEL:GetSpawnerByName(mygroup)
	if SamePipeSpawner then
		SamePipeSpawner:SpawnerReset()
		SamePipeSpawner:SpawnerDeactivate()
	end
	-- activate the first smashable in the chain
	local FirstPipeSpawner = LEVEL:GetSpawnerByName(firstPipe)
	if FirstPipeSpawner then
		FirstPipeSpawner:SpawnerActivate()
	end
	-- deactivate and reset imagination brick spawner network
	local netdevil = LEVEL:GetSpawnerByName("Imagination")
	if netdevil then
		netdevil:SpawnerDestroyObjects()
		netdevil:SpawnerReset()
		netdevil:SpawnerDeactivate()
	end
	-- spawn the netdevil
	local brick = LEVEL:GetSpawnerByName("MaelstromBug")
	if brick then
		brick:SpawnerActivate()
	end	
	-- spawn the canister
	local canister = LEVEL:GetSpawnerByName("BrickCanister")
	if canister then
		canister:SpawnerActivate()
	end	
	-- set state of console back to false
	self:SetNetworkVar("used", false)
end

function onTimerDone(self, msg)

	if (msg.name == "reset") then
		-- check to see if the quickbuilt is still unbuilt, and kill it if it is
		if self:GetRebuildState{}.iState == 0 then
			self:RequestDie{killerID = self, killType = "SILENT"}
		end
	elseif msg.name == "Die" then
		-- find all the consoles and kill them
		local consoles = self:GetObjectsInGroup{group = "Console", ignoreSpawners = true}.objects
		for k,v in ipairs(consoles) do
			if v:Exists() then
				v:RequestDie{killerID = v, killType = "VIOLENT"}
			end
		end
    end

end
---------------------------------------------
-- PROTOTYPE: Server script on the drop ship computer
-- after rebuilding the computer, if the player is on the mission and interacts with it, the player gets the mission card
-- 
-- created by brandi... 11/9/10
---------------------------------------------

--------------------------------------------------------------
-- timer for the quickbuilds to reset if the player doesnt build them
--------------------------------------------------------------
local resetBricks = 45

--------------------------------------------------------------
-- when the object is loaded
--------------------------------------------------------------
function onStartup(self,msg)
	-- start a timer for the quickbuilds to reset if the player doesnt build them
	GAMEOBJ:GetTimer():AddTimerWithCancel(resetBricks, "reset", self )
end

-------------------------------------------
-- see if the plaque is in use before allowing the player from using it again
-------------------------------------------
function onCheckUseRequirements(self, msg)
	-- check to see if the quickbuild is built
	if self:GetRebuildState{}.iState == 2 then
		local player = msg.objIDUser
		if not player:Exists() then return end
		--check to make sure the player has at least accepted the  mission to the use the dropship computer
		if player:GetMissionState{missionID = 979}.missionState < 2 then  
			msg.bCanUse = false  
			return msg	
		end
	end
end

--------------------------------------------------------------
-- on use, give the player the inventory item
--------------------------------------------------------------
function onUse(self,msg)
	-- after the console has been rebuilt
	if self:GetRebuildState().iState == 2 then
		local player = msg.user
		-- check to see that the player is on the mission
		if player:GetMissionState{missionID = 979}.missionState == 2 then
			-- make sure the player doesnt already have the item
			if player:GetInvItemCount{ iObjTemplate = 12323}.itemCount == 0 then 
				-- give the player the mission item
				player:AddItemToInventory{iObjTemplate = 12323, itemCount = 1}	
			end
		end
		player:TerminateInteraction{ type="fromInteraction", ObjIDTerminator=self }
	end
end

--------------------------------------------------------------
-- when the object dies
--------------------------------------------------------------
function onDie(self,msg)
	-- get the name of the spawner network
	local mygroup = tostring(self:GetVar("spawner_name"))
	-- get the first part of the spawner network, without the number
	local pipeGroup = string.sub(mygroup,1,10)
		
	-- deactivate and reset current spawner network
	local SamePipeSpawner = LEVEL:GetSpawnerByName(mygroup)
	if SamePipeSpawner then
		SamePipeSpawner:SpawnerReset()
		SamePipeSpawner:SpawnerDeactivate()
	end
	
	-- create a string for the first spawner network
	local firstPipe = pipeGroup.."1"
	-- activate the first spawner network
	local FirstPipeSpawner = LEVEL:GetSpawnerByName(firstPipe)
	if FirstPipeSpawner then
		FirstPipeSpawner:SpawnerActivate()
	end
	
end

--------------------------------------------------------------
-- when a timer is done
--------------------------------------------------------------
function onTimerDone(self, msg)
	-- timer on quickbuild when it first starts up
	if (msg.name == "reset") then
		-- if the quickbuild hasnt been built yet, kill it
		if self:GetRebuildState{}.iState == 0 then
			self:RequestDie{killerID = self, killType = "SILENT"}
		end
	end
end

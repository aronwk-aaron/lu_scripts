--------------------------------------------------------------
-- Spawned object that destroys maelstrom samples
--
-- created mrb... 6/22/11
-- updated abeechler ... 8/30/11 - added client side proximity checking to incorporate visibility check
--------------------------------------------------------------

local failAnim = "idle_maelstrom"       -- Beginning opening anim
local collectAnim = "collect_maelstrom"	-- Animation to play when collected
local defaultTime = 4					-- Min time for the collectAnim to play

-- table to find the mission ID based on the spawner network name
local VisibilityObjectTable = {["MaelstromSamples"] = {1849, 1883},
                               ["MaelstromSamples2ndary1"] = {1883},
                               ["MaelstromSamples2ndary2"] = {1883}}

----------------------------------------------------------------
-- On beginning object instantiation, play the default animation
-- client side
----------------------------------------------------------------
function onStartup(self)
	self:SetNetworkVar("current_anim", failAnim)
end 

----------------------------------------------------------------
-- The client has verified a potential collection sample,
-- finalize the confirmation and collect if necessary
----------------------------------------------------------------
function onFireEventServerSide(self, msg)
	if(msg.args == "attemptCollection") then
	    -- Get the name of the spawn network the attempt object is on
	    local objSpawnerNom = msg.senderID:GetStoredConfigData().configData.spawner_name
	    
	    if(VisibilityObjectTable[objSpawnerNom]) then
	        -- We have a valid associated mission list to process
	        -- Obtain a reference to the player
	        local player = self:GetParentObj().objIDParent
	        
	        for i, missionID in ipairs(VisibilityObjectTable[objSpawnerNom]) do
	            local missionstate = player:GetMissionState{missionID = missionID}.missionState
	            -- Determine if the player is on the mission
		        if missionstate == 2 or missionstate == 10 then
			        -- The player is on the mission, collect the object
			        CollectSample(self, msg.senderID)
			        break
		        end
	        end
	    end
	    
	end
end

----------------------------------------------------------------
-- Process sample collection events
----------------------------------------------------------------
function CollectSample(self, sampleObj)	
	local player = self:GetParentObj().objIDParent
	
	-- Check if the parent exists
	if not player:Exists() then return end
	
	-- Get the anim time and play the animation
	local animTimer = playAnimAndReturnTime(self, collectAnim)
	
	-- Play the collect anim
	GAMEOBJ:GetTimer():AddTimerWithCancel( animTimer, "RemoveSample", self )
	-- Destroy the sample
	sampleObj:RequestDie{killerID = player, lootOwnerID = player}
end

----------------------------------------------------------------
-- Utility function that allows for object animation on the client
-- as well as returning the valid processed anim time
----------------------------------------------------------------
function playAnimAndReturnTime(self, animID)
	-- Get the anim time
	local animTimer = self:GetAnimationTime{animationID = animID}.time 
	
	-- If we have an animation play it
	if animTimer > 0 then 
		self:SetNetworkVar("current_anim", animID)
	end
	
	-- If the anim time is less than the the default time use default
	if animTimer < defaultTime then
		animTimer = defaultTime
	end
	
	return animTimer
end

----------------------------------------------------------------
-- Catch and process timer events
----------------------------------------------------------------
function onTimerDone(self, msg)
	if msg.name == "RemoveSample" then
		-- Delete the object
		GAMEOBJ:DeleteObject(self)
	end
end 
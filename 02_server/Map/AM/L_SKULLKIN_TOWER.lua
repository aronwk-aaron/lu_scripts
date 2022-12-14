
---------------------------------------------
-- PROTOTYPE: script on the skullkin tower
--
-- created by brandi... 10/13/10
-- updated brandi... 10/27/10 - account for not smashing all the legs so smashed ones respawn, and update the mission
-- updated abeechler... 1/11/11 - updates mission/achievement status based on a defined local table of applicable mission ids.
-- updated brandi.. 6/8/11 - made the script generic so it can be use on different assets
---------------------------------------------

-- to set up in HF add the following config data
-- missions 0:(list of missions separated by _)
-- legLOT 1:(lot of the leg to spawn)
-- enemyToSpawn 1:(lot of the 2 enemies that spawn as the tower is coming down)
-- vert_offset 1:(amount the leg should be up higher than the pivot from the tower)
-- hort_offset 1:(amount that each leg is away from the pivot of the tower)

function onStartup(self,msg)
    -- set the proximity for the player to be taken out of the list if they leave the tower
    self:SetProximityRadius{radius = 20, collisionGroup = 1}
end

function onPhysicsComponentReady(self,msg)
	-- stop the base from pathing
    self:StopPathing()
	-- function to spawn the three legs of the tower
	spawnLegs(self,"Left")
    spawnLegs(self,"Right")
    spawnLegs(self,"Rear")
end

function spawnLegs(self,loc)
	-- get the position and direction of the tower to use to spawn the legs
	local oPos = { pos = "", rot = ""}
	local oDir = self:GetObjectDirectionVectors()
	-- get which tower the tower is and put it as a group on the legs ** this isnt used right now, but be later
	--local group = "tower"..self:GetVar("number")
	
	oPos.pos = self:GetPosition().pos
	oPos.rot = self:GetRotation()
	-- move the legs up a little, they are all shorter than the tower
    oPos.pos.y = oPos.pos.y + (self:GetVar("vert_offset") or 0)
    
    local newRot = oPos.rot --rotateVector(oPos.rot, oDir.backward)
	--off set of the is 12 units from the base
    local offset = self:GetVar("hort_offset") or 0
    
    local legLOT = self:GetVar("legLOT") 
    if not legLOT then return end
    
    if loc == "Right" then
        -- spawn right leg
        local config = {  {"Leg", "Right"} }
        RESMGR:LoadObject { objectTemplate = legLOT, x= oPos.pos.x + (oDir.forward.x * offset) , y= oPos.pos.y, z= oPos.pos.z + (oDir.forward.z * offset), rw = newRot.w, rx = newRot.x, ry = newRot.y, rz = newRot.z, owner = self, configData = config} --rw = oPos.rot.w, rx = oPos.rot.x, ry = oPos.rot.y + 1, rz = oPos.rot.z, owner = self, configData = config}
    elseif loc == "Rear" then
        -- spawn rear leg
        local config = { {"Leg", "Rear"} }
        RESMGR:LoadObject { objectTemplate = legLOT, x= oPos.pos.x + (oDir.left.x * offset) , y= oPos.pos.y, z= oPos.pos.z + (oDir.left.z * offset), rw = newRot.w, rx = newRot.x, ry = newRot.y, rz = newRot.z, owner = self, configData = config} --rw = oPos.rot.w - 1, rx = oPos.rot.x, ry = oPos.rot.y + 1, rz = oPos.rot.z, owner = self, configData = config}
    elseif loc == "Left" then
        -- spawn left leg
        local config = { {"Leg", "Left"} }
        RESMGR:LoadObject { objectTemplate = legLOT, x= oPos.pos.x + (oDir.backward.x * offset), y= oPos.pos.y, z= oPos.pos.z + (oDir.backward.z * offset), rw = newRot.w, rx = newRot.x, ry = newRot.y, rz = newRot.z, owner = self, configData = config} --rw = oPos.rot.w - 1, rx = oPos.rot.x, ry = oPos.rot.y, rz = oPos.rot.z, owner = self, configData = config}
    end
end

-- when a leg is added
function onChildLoaded( self, msg ) 
    -- get the game object of the child
	local child = msg.childID
	local legLOT = self:GetVar("legLOT")
	--check to see if the child is a leg
	if child:GetLOT().objtemplate == legLOT then
		
		-- get the position of the tower
        local oPos = self:GetPosition().pos
        -- turn the legs to face the tower
        child:RotateToPoint{targetPos = oPos}
        
        -- get the table of legs
        local legtable = self:GetVar("legTable") --table containing players in the volume
		
		--create a table of the legs currently alive, by their ID
        if not legtable then -- if the table doesnt already exist (no one is in it), create it
            legtable = {}
        end
        
        for k,v in ipairs(legtable) do
            if v == child:GetID() then -- check to see if the leg is already in the table
                return
            end
        end
        
        -- the leg isnt already in the table, so put them there
        table.insert(legtable,child:GetID())
        --set the table back to the set var
        self:SetVar("legTable",legtable)
        self:SendLuaNotificationRequest{requestTarget=child, messageName="Die"}
        self:PlayAnimation{ animationID = "idle"}
        self:ChangeIdleFlags {on = 1}
    end
end

-- when a leg dies
function notifyDie(self,other,msg)
	-- find out who killed the leg
    local killer = msg.killerID
 
    -- get the table of players who have killed legs
    local players = self:GetVar("Players") --table containing players in the volume
   
	-- if the table doesnt already exist (no one is in it), create it
    if not players then 
        players = {}
    else
		-- if the table exists, parse through it and see if the player is already in it
        for k,v in ipairs(players) do
            if v == killer:GetID() then 
				-- if it is, jump out of the function
                return
            end
        end
    end
    -- the player isnt already in the table, so put them there
    table.insert(players,killer:GetID())
    --set the table back to the set var
    self:SetVar("Players",players) 
end

-- when a leg is removed
function onChildRemoved(self,msg)
	local legLOT = self:GetVar("legLOT")
	if not msg.childID:GetLOT().objtemplate == legLOT then return end
	
	-- number of legs that still exist in the level
	local legsAlive = 0 -- number of legs left alive
	-- get the leg table
	if self:GetVar("legTable") then
		-- gmae object of the leg that was removed
		local leg = msg.childID 
		-- get the leg table
		local legtable = self:GetVar("legTable")
		local removeLeg = 0 -- create variable for the Leg to be removed
		-- parse through all the legs in the table
		for k,v in ipairs(legtable) do
			-- if the leg in teh table matches the leg that was removed, set its key to be removed from the table
			if v == leg:GetID() then
				removeLeg = k
				break
			end
		end
		-- remove the leg from the table
		table.remove(legtable,removeLeg)
		-- if there's still legs in the table, set it back to set var, otherwise set it to nil
		if #legtable ~= 0 then
			self:SetVar("legTable",legtable)
		else 
			self:SetVar("legTable",false)
		end
		
		-- when one leg is down, play minor wobble animation
		if #legtable == 2 then
			self:ChangeIdleFlags {off = 1}
			self:PlayAnimation{ animationID = "wobble-1" }
		-- when two legs are done, play more wobble animation
		elseif #legtable == 1 then
			self:PlayAnimation{ animationID = "wobble-2" }
		end
		
		-- if there are no legs left in the table
		if not self:GetVar("legTable") then
			-- get the time for the fall animation
			local animTime = self:GetAnimationTime{ animationID = "fall" }.time
			-- play the fall animation
			self:PlayAnimation{ animationID = "fall" }
			-- set the collision to not collide with anything so the skeletons wont get stuck on top
			self:SetCollisionGroup{colGroup = 25}
			-- start a timer to spawn the 2 skeletons that spawn on top
			GAMEOBJ:GetTimer():AddTimerWithCancel(animTime - 0.2, "spawnGuys", self )
			-- start a timer to kill the tower
			GAMEOBJ:GetTimer():AddTimerWithCancel(animTime + 0.5, "killTower", self )
			-- cancel any timers started by the legs dying
			GAMEOBJ:GetTimer():CancelTimer( "RespawnLeg", self )
			
			if self:GetVar("missions") then
				local missionsToUpdate = split(self:GetVar("missions"),"_")
				-- get the list of all the players that have smashed a leg
				local players = self:GetVar("Players")
				if players then  
					-- parse through them and make sure they exist
					for k,v in ipairs(players) do 
						v = GAMEOBJ:GetObjectByID(v)
						if v:Exists() then
							for k,missionID in ipairs(missionsToUpdate) do
								-- if the player is on the currently iterated mission ID, then update the player mission status.
								v:UpdateMissionTask{taskType = "complete", value = missionID, value2 = 1, target = self}
							end
						end
					end
				end
			end
			-- no need to do the rest if the tower is done
			return
		end
		
		-- create a table to hold the location of legs that died
		local deadlegs = self:GetVar("DeadLegs")
		-- if a table already exists, check to see if the leg is already in the table, if so jump out, if not create a new table
		if deadlegs then    
		    for k,v in ipairs(deadlegs) do      
		        if v == removeLeg then  return end
		    end
		else   
		    deadlegs = {}
		end
		-- get the leg location off the config data on the leg
		local legLoc = leg:GetStoredConfigData{ optionalKey = "Leg" }.configData["Leg"]	
		-- put the leg into the table
        table.insert(deadlegs,legLoc)
		self:SetVar("DeadLegs",deadlegs)
		-- cancel any previous leg timers
		GAMEOBJ:GetTimer():CancelTimer( "RespawnLeg", self )
		-- start a new leg timer
		GAMEOBJ:GetTimer():AddTimerWithCancel( 20, "RespawnLeg", self )
	end
end

-- find out when a player leaves the proximity of the tower
function onProximityUpdate(self,msg)
	-- someone exited the towers's bubble
    if msg.status == "LEAVE" then
		-- get the player who left
        local exiter = msg.objId
		-- does the player really exist?
        if exiter:Exists() then 
            -- get the players table
            local players = self:GetVar("Players")
            -- if there aren't any players in the table, then jump out of the function
            if not players then return end
            -- create variable for the player to be removed
            local removePlayer = 0 
            -- parse through all the players in the table
            for k,v in ipairs(players) do
                -- if teh player in teh table matches the player that was removed, set its key to be removed from the table
                if v == exiter:GetID() then
                    removePlayer = k
                    break
                end
            end
            -- remove the player from the table
            table.remove(players,removePlayer)
            -- if there's still players in the table, set it back to set var, otherwise set it to nil
            if #players ~= 0 then
                self:SetVar("Players",players)
            else 
                self:SetVar("Players",{})
            end
        end
    end
end

-- when the legs timer is done
function onTimerDone(self, msg)
	if( msg.name == "RespawnLeg" ) then
        local legs = self:GetVar("DeadLegs")
        -- parse through all the legs in the table
        if legs then
            for k,v in ipairs(legs) do
				-- for every leg in the table, respawn that leg
                spawnLegs(self,v)
            end
		end
		-- clear the table out
        self:SetVar("DeadLegs",{})
	-- timer to spawn the guys at the top of the tower
	elseif msg.name == "spawnGuys" then
		-- get the position of the tower again
		local oPos = { pos = "", rot = ""}
		oPos.pos = self:GetPosition().pos
		-- increase the y so the skullkin spawn on top of the tower
		oPos.pos.y = oPos.pos.y + 7
		oPos.rot = self:GetRotation()
		local numEnemies = self:GetVar("numOfEnemies") or 2
		-- spawn two skullkin on top of the tower
		for i = 1,numEnemies do
			RESMGR:LoadObject { objectTemplate = self:GetVar("enemyToSpawn"), x= oPos.pos.x, y= oPos.pos.y, z= oPos.pos.z, rw = oPos.rot.w, rx = oPos.rot.x, ry = oPos.rot.y, rz = oPos.rot.z, owner = self} 
		end	
	-- timer to kill the tower
	elseif msg.name == "killTower" then
		-- kill it violently so if it had an lxfml, it would play it
		self:RequestDie{ killerID = self, killtype = "VIOLENT" }
    end
end

function split(str, pat)
    local t = {}
    -- Creates a table of strings based on the passed in pattern   
    string.gsub(str .. pat, "(.-)" .. pat, function(result) table.insert(t, result) end)

    return t
end

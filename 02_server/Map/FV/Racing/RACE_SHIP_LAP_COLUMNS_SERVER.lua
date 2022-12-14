-----------------------------------------------------------------
--tells the ramps and columns to move depending on the lap number
--
--created by Steve Y 8/10/10
-----------------------------------------------------------------


function onStartup(self)
    
    self:SetVar("Lap2Complete", false)
    self:SetVar("Lap3Complete", false)
end



function onCollisionPhantom(self, msg)
    
    local player = msg.objectID
    local lap = player:VehicleGetCurrentLap{}.uiCurLap
    
    if lap == 2 and self:GetVar("Lap2Complete") == false then
        self:SetVar("Lap2Complete", true)
        local lap2Columns = self:GetObjectsInGroup{group = "Lap2Column", ignoreSpawners = true}.objects[1]

        if lap2Columns then
			GAMEOBJ:AddObjectToAlwaysInScopeList( lap2Columns )
			lap2Columns:GoToWaypoint{iPathIndex = 1, bAllowPathingDirectionChange = true, bStopAtWaypoint = true}
        end

        local lap2Ramps = self:GetObjectsInGroup{group = "Lap2Ramp", ignoreSpawners = true}.objects[1]

        if lap2Ramps then
			GAMEOBJ:AddObjectToAlwaysInScopeList( lap2Ramps )
			lap2Ramps:GoToWaypoint{iPathIndex = 0, bAllowPathingDirectionChange = true, bStopAtWaypoint = true}
        end   

    elseif lap == 3 and self:GetVar("Lap3Complete") == false then
        self:SetVar("Lap3Complete", true)
        local lap3Columns = self:GetObjectsInGroup{group = "Lap3Column", ignoreSpawners = true}.objects[1]

        if lap3Columns then
			GAMEOBJ:AddObjectToAlwaysInScopeList( lap3Columns )
			lap3Columns:GoToWaypoint{iPathIndex = 1, bAllowPathingDirectionChange = true, bStopAtWaypoint = true}
       end

        local lap3Ramps = self:GetObjectsInGroup{group = "Lap3Ramp", ignoreSpawners = true}.objects[1]

        if lap3Ramps then
			GAMEOBJ:AddObjectToAlwaysInScopeList( lap3Ramps )
			lap3Ramps:GoToWaypoint{iPathIndex = 0, bAllowPathingDirectionChange = true, bStopAtWaypoint = true}
        end
    end        
end

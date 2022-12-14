function onStartup(self, msg)

    --[[debugPrint(self,"** This a Prototype Script attached to " .. self:GetName().name .. ". **")
    debugPrint(self,"** This script needs to be completed by Someone. **")
    debugPrint(self,"** This file is located at <res/scripts/02_server/Objects>. **")--]]
    self:SetVar("network1Finished", false)

end

function onCollisionPhantom(self, msg)
    print("--------- in the volume")
    for groupName in string.gmatch(self:GetVar("groupID"), "%w+;") do
      
        --------------------------------------------------------------
        --get the name of the group that the object is in and trim off the ';'s
        --------------------------------------------------------------
      
        groupName = string.sub(groupName, 1, -2)
        local mygroup = self:GetObjectsInGroup{group = groupName, ignoreSpawners = true}.objects
        local eSpawnerNumber = 1
        local lSpawnerNumber = 1
        
        while eSpawnerNumber>0 do
           
            local spawner = LEVEL:GetSpawnerByName("espawner" .. eSpawnerNumber .. "_" .. groupName)
            self:SendLuaNotificationRequest{requestTarget=spawner, messageName="NotifySpawnerOfDeath"}
            -- check that there is a spawner network with that name before activating it
            if spawner then	
                -- activating the spawner network spawns a group of enemies
                spawner:SpawnerActivate()
                spawner:SpawnerReset()
                eSpawnerNumber = eSpawnerNumber + 1
            else
                eSpawnerNumber = -1
            end
        end
        
        while lSpawnerNumber>0 do
           
            local spawner = LEVEL:GetSpawnerByName("lspawner" .. lSpawnerNumber .. "_" .. groupName)
            -- check that there is a spawner network with that name before activating it
            if spawner then	
                -- activating the spawner network spawns a group of loot
                spawner:SpawnerActivate()
                spawner:SpawnerReset()
                lSpawnerNumber = lSpawnerNumber + 1
            else
                lSpawnerNumber = -1
            end
        end
    end
end

function notifyNotifySpawnerOfDeath(self, other, msg)
    --print("-------------something died")
    local totalSpawned = other:SpawnerGetTotalSpawned().iSpawned
    local maxToSpawn = other:SpawnerGetMaxToSpawn().iNum
    --print("--------------------the total spawned is " .. totalSpawned)
    --print("--------------------the total to spawn is " .. maxToSpawn)
    if maxToSpawn == totalSpawned and self:GetVar("network1Finished") then
        --print("-------------------searching for group")
        other:SpawnerDeactivate()
        other:SpawnerDestroyObjects()
        self:SendLuaNotificationCancel{requestTarget=spawner, messageName="NotifySpawnerOfDeath"}
        for groupName in string.gmatch(self:GetVar("groupID"), "%w+;") do

            --------------------------------------------------------------
            --get the name of the group that the object is in and trim off the ';'s
            --------------------------------------------------------------
          
            groupName = string.sub(groupName, 1, -2)
            local mygroup = self:GetObjectsInGroup{group = groupName, ignoreSpawners = true}.objects
            
            --------------------------------------------------------------
            --for the object in my group with ID 13956, tell it die
            --------------------------------------------------------------
            print("-----------the group name is " .. groupName)
            for i, object in ipairs(mygroup) do
                print("------------searching for object 13956")
                if object and object:GetLOT().objtemplate == 13956 then
                    object:RequestDie{killerID = self, killType = "VIOLENT"}
                    print("--------------- found gate to smash")
                end
            end
        end
    elseif maxToSpawn == totalSpawned then
        print("------------------first group finished spawning")
        self:SetVar("network1Finished", true)
        other:SpawnerDeactivate()
        other:SpawnerDestroyObjects()
    end
end
function onPlayerLoaded(self, msg)
    local propertyPlaques = GAMEOBJ:GetObjectsByLOT(3315)
    for i = 1, table.maxn(propertyPlaques) do
        print("-------- SCRIPT: Property plaque " .. i .. ":" .. propertyPlaques[i]:GetName().name)
        
        local propertyData = propertyPlaques[i]:PropertyGetState{}
        print("---------- SCRIPT: Property ID: " .. propertyData.propertyID:GetID())
        print("---------- SCRIPT: Owner ID: " .. propertyData.ownerID:GetID())
        print("---------- SCRIPT: Rented: " .. tostring(propertyData.rented))
    end
end

function onZonePropertyRented(self, msg)
    print("----- SCRIPT: Zone property rented")
    print("-------- SCRIPT: playerID: " .. msg.playerID:GetID())
    print("-------- SCRIPT: propertyID: " .. msg.propertyID:GetID())
end

function onZonePropertyModelPlaced(self, msg)
    print("----- SCRIPT: Zone property model placed")
    print("-------- SCRIPT: playerID: " .. msg.playerID:GetID())
    print("-------- SCRIPT: propertyID: " .. msg.propertyID:GetID())
    print("-------- SCRIPT: modelLOT: " .. msg.modelLOT)
    print("-------- SCRIPT: position x: " .. msg.position.x)
    print("-------- SCRIPT: position y: " .. msg.position.y)
    print("-------- SCRIPT: position z: " .. msg.position.z)
end

function onZonePropertyModelPickedUp(self, msg)
    print("----- SCRIPT: Zone property model picked up")
    print("-------- SCRIPT: playerID: " .. msg.playerID:GetID())
    print("-------- SCRIPT: propertyID: " .. msg.propertyID:GetID())
    print("-------- SCRIPT: modelID: " .. msg.modelID:GetID())
    print("-------- SCRIPT: spawnerID: " .. msg.spawnerID:GetID())
end

function onZonePropertyModelRemoved(self, msg)
    print("----- SCRIPT: Zone property model removed")
    print("-------- SCRIPT: playerID: " .. msg.playerID:GetID())
    print("-------- SCRIPT: propertyID: " .. msg.propertyID:GetID())
    print("-------- SCRIPT: modelID: " .. msg.modelID:GetID())
    print("-------- SCRIPT: spawnerID: " .. msg.spawnerID:GetID())
end

function onZonePropertyEditBegin(self, msg)
    print("----- SCRIPT: Zone property edit begin")
    print("-------- SCRIPT: playerID: " .. msg.playerID:GetID())
    print("-------- SCRIPT: propertyID: " .. msg.propertyID:GetID())
    print("-------- SCRIPT: propertyObjectID: " .. msg.propertyObjectID:GetID())
end

function onZonePropertyEditEnd(self, msg)
    print("----- SCRIPT: Zone property edit end")
    print("-------- SCRIPT: playerID: " .. msg.playerID:GetID())
    print("-------- SCRIPT: propertyID: " .. msg.propertyID:GetID())
    print("-------- SCRIPT: propertyObjectID: " .. msg.propertyObjectID:GetID())
end

function onZonePropertyBehaviorAdded(self, msg)
    print("----- SCRIPT: Zone property behavior added")
    print("-------- SCRIPT: modelID: " .. msg.modelID:GetID())
    print("-------- SCRIPT: behaviorID: " .. msg.behaviorID:GetID())
    print("-------- SCRIPT: numStripsAdded: " .. msg.numStripsAdded)
end

function onZonePropertyBehaviorRemoved(self, msg)
    print("----- SCRIPT: Zone property behavior removed")
    print("-------- SCRIPT: modelID: " .. msg.modelID:GetID())
    print("-------- SCRIPT: behaviorID: " .. msg.behaviorID:GetID())
    print("-------- SCRIPT: numStripsRemoved: " .. msg.numStripsRemoved)
end

function onZonePropertyBehaviorAllRemoved(self, msg)
    print("----- SCRIPT: Zone property behavior all removed")
    print("-------- SCRIPT: modelID: " .. msg.modelID:GetID())
end

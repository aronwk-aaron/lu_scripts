
function onStartup(self,msg)
	print("Jetpack Cutoff Startup")
end

function onShutdown(self, msg)
	print("Jetpack Cutoff Shutdown")
end

function onCollisionPhantom(self, msg)
	print("onCollisionPhantom cutoff")
	
	if msg.objectID:GetID() ~= GAMEOBJ:GetLocalCharID() then return end	
	
	local playerID = msg.objectID
	playerID:TurnOffJetPack{bOn = false}
end

function onOffCollisionPhantom(self, msg)
	print("onOffCollisionPhantom cutoff")
	
	if msg.objectID:GetID() ~= GAMEOBJ:GetLocalCharID() then return end	
	
	local playerID = msg.objectID
	playerID:TurnOffJetPack{bOn = true}
end


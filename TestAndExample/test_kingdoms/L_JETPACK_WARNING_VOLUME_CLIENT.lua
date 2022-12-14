
function onStartup(self,msg)
	print("Jetpack Warning Startup")
end

function onShutdown(self, msg)
	print("Jetpack Warning Shutdown")
end

function onCollisionPhantom(self, msg)
	print("onCollisionPhantom")
	
	if msg.objectID:GetID() ~= GAMEOBJ:GetLocalCharID() then return end	
	
	local playerID = msg.objectID
	playerID:SetJetPackWarning{bOn = false}
end

function onOffCollisionPhantom(self, msg)
	print("onOffCollisionPhantom")
	
	if msg.objectID:GetID() ~= GAMEOBJ:GetLocalCharID() then return end	
	
	local playerID = msg.objectID
	playerID:SetJetPackWarning{bOn = true}
end


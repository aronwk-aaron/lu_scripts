
function onClientUse(self, msg)  

    local player = msg.user

    player:AttachCameraToRail{pathName = "EarthTestCamera3RAILED", positionPathName = "TestEarthRail3", leadIn = 0.3, alwaysFaceTarget = true, targetID = player, biasAmount = 0}
    
end

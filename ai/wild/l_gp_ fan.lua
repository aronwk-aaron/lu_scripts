require('o_mis')

function onStartup(self, msg)

    local BounceControlObject = self:GetObjectsInGroup{ group = "GP_Bounce"}.objects[1]

	GAMEOBJ:GetTimer():AddTimerWithCancel( 0.2, "BounceNotify",self )
    storeObjectByName(self, "BounceControlObject", BounceControlObject)

end

function onTimerDone(self, msg)

	if msg.name == "BounceNotify" then
        getObjectByName(self,"BounceControlObject"):NotifyObject{name = "bounceloaded", ObjIDSender = self}
    end

end 

function onCollisionPhantom(self, msg)

    local target = msg.objectID
    local playerVelx = target:GetLinearVelocity().linVelocity.x / 1.5
    local playerVely = target:GetLinearVelocity().linVelocity.y
    local playerVelz = target:GetLinearVelocity().linVelocity.z / 1.5
--  target:PlayAnimation{animationID = "floatpad"}

    msg.objectID:Knockback{vector={x=playerVelx, y=25,z=playerVelz}}

end
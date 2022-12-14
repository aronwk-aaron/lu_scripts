function onCollisionPhantom(self, msg)

         print("Hit Phantom")


--send message to player to start rail

       local target = msg.senderID
       --msg.activatorID:StartRailMovement{pathName=path.pathName, pathStart=path.pathStart, pathGoForward=path.pathGoForward}
       local myID = self:GetID()

       target:StartRailMovement{pathName="scriptPath", pathStart=0, pathGoForward=true, railActivatorComponentID=3, railActivatorObjID=msg.senderID}

       --, railActivatorLotID=11968, railActivatorObjID=myID}

end


function onCollisionPhantom(self,msg)
	local player = msg.objectID
	local smasher = self:GetNetworkVar("Smasher")
	if player:GetID() == smasher then
		local manager = GAMEOBJ:GetObjectByID(self:GetVar("Manager"))
		local myNode = self:GetVar("spawner_node_id")
		manager:NotifyObject{name = "OrbPickup", param1 = myNode, rerouteID = player, ObjIDSender = self}
	end
end
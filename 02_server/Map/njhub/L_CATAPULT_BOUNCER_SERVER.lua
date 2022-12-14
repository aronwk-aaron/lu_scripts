----------------------------------------
-- Server side script on the bouncer pad attached to the catapult
--
-- created by brandi... 6/23/11
----------------------------------------

function onRebuildComplete(self,msg)
	-- tell the client the pad is built
	self:NotifyClientObject{name = "Built"}
	self:SetNetworkVar("Built",true)
	-- get the base object, which is acting as the manager
	local base = self:GetObjectsInGroup{ group = self:GetVar("BaseGroup"), ignoreSpawners = true }.objects
	-- notifiy the base that the bouncer is built
	for k,obj in ipairs(base) do
		if obj:Exists() then
			obj:NotifyObject{name = "BouncerBuilt", ObjIDSender = self}
		end
	end
end
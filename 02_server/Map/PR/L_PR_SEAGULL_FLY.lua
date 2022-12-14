--------------------------------------------------------------
-- server side script on the seagull in Pet Cove
-- tell the client script when to animation the seagull

-- created by Brandi... 3/10/11
--------------------------------------------------------------

----------------------------------------------
-- when the bird loads
----------------------------------------------
function onStartup(self,msg)
	-- set the default state of the bird, which is down
	self:SetNetworkVar("BirdLanded",true)
end

----------------------------------------------
-- player enters the sphere around the bird
----------------------------------------------
function onCollisionPhantom(self,msg)
	-- if the bird is down, and there is someone in his range
	if self:GetNetworkVar("BirdLanded") and table.maxn(self:GetObjectsInPhysicsBounds().objects) >= 1 then
		-- tell the client to have the bird fly up
		self:SetNetworkVar("BirdLanded",false)
	end
end

----------------------------------------------
-- player leaves the sphere around the bird
----------------------------------------------
function onOffCollisionPhantom(self,msg)
	-- if the bird is up, and no one is left in his range
	if not self:GetVar("BirdLanded") and table.maxn(self:GetObjectsInPhysicsBounds().objects) == 0 then
		-- tell the client to have the bird land
		self:SetNetworkVar("BirdLanded",true)
	end
end




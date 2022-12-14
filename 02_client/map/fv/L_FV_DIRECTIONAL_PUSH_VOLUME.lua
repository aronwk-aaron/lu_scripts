-----------------------------------------------
-- Script for FV Directional Air Pushers
--
-- Created by Nic and Ray 10/17/2011
-----------------------------------------------

local defaultForce = 30
	
function onCollisionPhantom(self, msg)

	local playerPos = msg.objectID:GetPosition().pos
	local selfPos = self:GetPosition().pos

	local Diff = { x = (playerPos.x - selfPos.x), y = (playerPos.y - selfPos.y), z = (playerPos.z - selfPos.z) }
	
	local diffLength = math.sqrt( (Diff.x * Diff.x) + (Diff.y * Diff.y) + (Diff.z * Diff.z) )
	
	local UnitDiff = {x = (Diff.x / diffLength), y = (Diff.y / diffLength), z = (Diff.z / diffLength) }
	local fwd = self:GetForwardVector().niForwardVector
        
	local DotProduct = (UnitDiff.x * fwd.x) + (UnitDiff.y * fwd.y) + (UnitDiff.z * fwd.z);
	GetGroupFromDotProduct(self, playerPos, DotProduct)
	-- Calculating the players position in relation to the trigger volumes position and determining 
	-- which end of the trigger the player entered
end

function GetGroupFromDotProduct(self, playerPos, DotProduct)
	--using the dot produce to determin what end of the trigger the player entered and then setting the correct group
	-- so the trigger knows which way to push the player	
	local force = defaultForce
	local group = false
	if ( DotProduct > 0 ) then
		force = self:GetVar("forceFront") or defaultForce
		group = self:GetVar("FrontGroup") or false
	else
		force = self:GetVar("forceBack") or defaultForce
		group = self:GetVar("BackGroup") or false	
	end
	
	SetVelocityFromGroupAndForce(self, playerPos, group, force)
end

function SetVelocityFromGroupAndForce(self, playerPos, destinationGroup, Force)
-- We've found what end of the trigger the player ended, then we set the group to look for,
--now we need to find the respawn point in that group so we have a target to push the player towards
	local destination = self
	if destinationGroup then 
		-- We have a target destination group within the object config data
		local groupObjs = self:GetObjectsInGroup{group = destinationGroup, ignoreSpawners = true}.objects
			
		-- Iterate through the destination group and catch the first valid destination object
		for k,obj in ipairs(groupObjs) do
			if obj:Exists() then
				destination = obj
				break
			end
		end
	end
		
	-- Take the determined destination object and process its 
	-- location/rotation values
	local destPosition = destination:GetPosition().pos
	local VectorPoint = { x = (destPosition.x - playerPos.x), y = 0, z = (destPosition.z - playerPos.z) }
	local VectorLength = math.sqrt( (VectorPoint.x * VectorPoint.x) + (VectorPoint.z * VectorPoint.z) )

	local DirectionPoint = {x = (VectorPoint.x / VectorLength), y = 0, z = (VectorPoint.z / VectorLength) }

	self:SetPhysicsVolumeEffect{ EffectType = 'PUSH', amount = Force, direction = DirectionPoint }
end
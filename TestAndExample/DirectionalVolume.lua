function onCollisionPhantom(self, msg)

	local playerPos = msg.objectID:GetPosition().pos
	local selfPos = self:GetPosition().pos

	local Diff = { x = (playerPos.x - selfPos.x), y = (playerPos.y - selfPos.y), z = (playerPos.z - selfPos.z) }
	
	local diffLength = math.sqrt( (Diff.x * Diff.x) + (Diff.y * Diff.y) + (Diff.z * Diff.z) )
	
	local UnitDiff = {x = (Diff.x / diffLength), y = (Diff.y / diffLength), z = (Diff.z / diffLength) }
	local fwd = self:GetForwardVector().niForwardVector
        
	local DotProduct = (UnitDiff.x * fwd.x) + (UnitDiff.y * fwd.y) + (UnitDiff.z * fwd.z);

	if ( DotProduct > 0 ) then
	
		print( "ENTERED IN FRONT" )
	
	else

		print( "ENTERED IN BACK" )
		
	end

end
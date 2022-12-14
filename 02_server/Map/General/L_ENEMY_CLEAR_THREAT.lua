--------------------------------------------------------------
-- Generic script that clears an enemy's threat list when they hit the volume

-- created by brandi.. 1/14/11
--------------------------------------------------------------

function onCollisionPhantom(self,msg)
	local collider = msg.objectID

	if not collider:Exists() then return end

	local collGroup = collider:GetCollisionGroup().colGroup

	if collGroup == 12 then	-- 12 is enemy
		collider:ClearThreatList()
		collider:CombatAIForceTether()
	elseif collGroup == 10 then  -- 10 is player
		collider:RemoveFromAllThreatLists()
	end
end
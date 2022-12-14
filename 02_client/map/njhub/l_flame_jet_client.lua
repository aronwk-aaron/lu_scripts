function onRenderComponentReady(self,msg)
	
    if self:GetVar("NotActive") then 
		ToggleBlockingVolume(self,false)
		return 
	end
    
    self:PlayFXEffect{ name = "jetOn" , effectType = "jetOn" }
end

function onScriptNetworkVarUpdate(self,msg)

	-- parse through the table of network vars that were updated
	for k,v in pairs(msg.tableOfVars) do

		-- not not active, set notactive to false (its active)
		if k == "FlameOn" and not v then
			self:StopFXEffect{name = "jetOn"}
			ToggleBlockingVolume(self,false)
		elseif k == "FlameOn" and v then
			self:PlayFXEffect{ name = "jetOn" , effectType = "jetOn" }
			ToggleBlockingVolume(self,true)

		end
	end
end

function ToggleBlockingVolume(self,bColl)

	local gName = self:GetVar("blockingVolume")
	
	if not gName then return end
	
	local blockingVol = self:GetObjectsInGroup{ group = gName, ignoreSpawners = true }.objects
	for k,obj in ipairs(blockingVol) do
		if bColl then
			obj:SetCollisionGroupToOriginal()
		else
			obj:SetCollisionGroup{colGroup = 16}
		end
	end
end
				
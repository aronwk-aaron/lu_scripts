----------------------------------------
-- Client side script on the door indicators in the fire temple. 
-- They only ever turn on, but could turn on for activated or deactived, depending on the puzzle
--
-- created by brandi... 10/4/11
----------------------------------------

function onScriptNetworkVarUpdate(self,msg)
	-- parse through the table of network vars that were updated
	for k,v in pairs(msg.tableOfVars) do
		-- not not active, set notactive to false (its active)
		if k == "FlameOn" and v then
			self:PlayFXEffect{ name = "jetOn" , effectType = "jetOn" }
		end
	end
end

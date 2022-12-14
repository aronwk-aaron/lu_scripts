----------------------------------------
-- server side script on start rails for ninjago rails
--
-- created by brandi... 6/14/11
---------------------------------------------

---------------------------------------------
-- to set up in HF if this is a quickbuild start rail and you want to tell a end rail that you were built and died
-- put the end rail to connected to this start rail in a group, it should be the only thing in the group
-- add this config data to the end rail
-- 		NotActive 7:1  (this sets a bool to true)
-- add this config data to the start rail that is a quickbuild
-- 		EndRailGroup 0:name of the group you put the end rail in
---------------------------------------------

require('02_server/Map/General/Ninjago/L_RAIL_POST_SERVER')


-- make sure the player can use it
function onCheckUseRequirements(self, msg)
	-- if this is currently inUse dont spawn anything
    if self:HasComponentType{iComponent = 48}.bHasComponent and (self:GetRebuildState().iState == 2 ) and self:GetNetworkVar("NetworkNotActive") then 
		msg.bCanUse = false
		return msg
	end
	
end

function onUse(self,msg)

	if self:HasComponentType{iComponent = 48}.bHasComponent and not (self:GetRebuildState().iState == 2 ) then return end
	ActivatorUse(self,msg)

end

function ActivatorUse(self,msg)
	

	
	local player = msg.user

	-- remove the player from all threat lists
	player:RemoveFromAllThreatLists()
	
	local flagNum = self:GetVar("RailFlagNum")
	if not flagNum then return end
	
	player:SetFlag{ iFlagID = flagNum, bFlag = true }
	
end
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

require('02_server/Map/General/Ninjago/L_RAIL_ACTIVATORS_SERVER')

function onUse(self,msg)

	if self:HasComponentType{iComponent = 48}.bHasComponent and not (self:GetRebuildState().iState == 2 ) then return end
	ActivatorUse(self,msg)
	
	local fightManager = self:GetObjectsInGroup{ group = "BossManager", ignoreSpawners = true }.objects
	if #fightManager == 0 then return end
	for k,manager in ipairs(fightManager) do
		if manager:Exists() then
			manager:NotifyObject{name = "ActivatorUsed", ObjIDSender = self, param1 = self:GetVar("spawner_node_id") }
		end
	end	

end
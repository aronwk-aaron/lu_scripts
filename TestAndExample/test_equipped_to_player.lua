
function onFactionTriggerItemEquipped(self, msg)
	--self:AddStatTrigger { Name="Low Health", Stat="HEALTH", Operator="LESS_EQUAL", Value=1 }
	self:AddStatTrigger { Name="Half Health", Stat="HEALTH", Operator="LESS_EQUAL", Value=50, IsPercent=true }
	
	self:AddStatTrigger { Name="Low Armor", Stat="ARMOR", Operator="LESS", Value=1 }
	--self:AddStatTrigger { Name="Half Armor", Stat="ARMOR", Operator="LESS_EQUAL", Value=50, IsPercent=true }
	
	--self:AddStatTrigger { Name="Low Imagination", Stat="IMAGINATION", Operator="LESS", Value=1 }
	--self:AddStatTrigger { Name="Half Imagination", Stat="IMAGINATION", Operator="LESS", Value=0, IsPercent=true }

	--print("Breastplate of scripting armed: "..self:GetID())
end

function onFactionTriggerItemUnequipped(self, msg)
	-- this item doesn't do anything on unequip
end

function onStatEventTriggered(self, msg)

	local parent = msg.Parent
	local sender = msg.Sender
	local name = msg.Name
	local stat = msg.Stat
	local statValue = msg.StatValue
	local totalValue = msg.TotalValue

	--print("StatEventTriggered: Name=" .. name .. ", stat=" .. stat .. ", value=" .. tostring(statValue) .. "/" .. tostring(totalValue))
	
	if name == "Half Health" then
		msg.StatValue = 10
		--print("Fixed health = 10")
	end
	
	if name == "Low Armor" then
		msg.StatValue = 1
		--print("Fixed armor = 1")
	end
	
	if name == "Low Imagination" then
		msg.StatValue = 1
		--print("Fixed imagination = 1")
	end
	
	return msg
end
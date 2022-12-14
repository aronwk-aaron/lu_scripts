require('TestAndExample/test_equipped_to_player')

-- apply any benefits for this item's faction
function onFactionTriggerItemStartup(self, msg)
	--print("Applying faction benefits")
	
	local parent = msg.playerID
	parent:ModifyMaxArmor{ amount=1 }
	--print("Max armor="..parent:GetMaxArmor{}.armor)

	if parent:GetImagination{}.imagination < 1 then
		parent:SetImagination { imagination = 1 }
		--print("Set initial imagination = 1")
	end
end

-- remove any benefits for this item's faction
function onFactionTriggerItemShutdown(self, msg)
	--print("Removing faction benefits")
	
	local parent = msg.playerID
	parent:ModifyArmor{ amount=-1 } -- make 'em recollect armor when they reequip
	parent:ModifyMaxArmor{ amount=-1 }
	
	--print("Max armor="..parent:GetMaxArmor{}.armor)
end

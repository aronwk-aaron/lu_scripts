

-- Groups
local CutsceneVolume = "BossCutsceneVolume"

function onStartup(self)
    debugPrint(self,"** This a Prototype Script attached to " .. self:GetName().name .. ". **")
    debugPrint(self,"** This script needs to be completed by Someone. **")
    debugPrint(self,"** This file is located at <res/scripts/02_client/map/LD>. **")
end



-- print function that only works in an internal build
function debugPrint(self, text)	
	if self:GetVersioningInfo().bIsInternal then
		print(text)
	end
end

-------------------------------------------------------------

-- when the local player exits
----------------------------------------------------------------
function onPlayerExit(self,msg)

	-- make sure their health bar is on
	if not self:GetVar("HealthBarOn") then return end
				
	--turn off the health bar, we don't have a player near us anymore :(
	UI:SendMessage( "ToggleEnemyStatusBar", { {"visible", false} } )
	self:SetVar("HealthBarOn",false)
	
end


function onNotifyClientObject(self,msg)

	--local localPlayer = GAMEOBJ:GetControlledID()
	
	if msg.name == "TurnOnHealthBar" then
	
		TurnOnHealthBar(self,msg.paramObj)
	
		-- Frakjaw is dead, turn the health bar off
	elseif msg.name == "GarmadonIsDead" then
	
		UI:SendMessage( "ToggleEnemyStatusBar", { {"visible", false} } )
		self:SetVar("HealthBarOn",false)
		
	elseif msg.name == "LGVisible" then
		
		local garmadon = msg.paramObj
		if ( not garmadon ) or ( not garmadon:Exists() ) then return end
		
		local vis = true
		if msg.param1 == 0 then
			vis = false
		end
		
		garmadon:SetVisible{visible = vis}
			
	end
	
end



----------------------------------------------------------------
-- if frakjaw has been hit
----------------------------------------------------------------
function notifyHitOrHealResult(self,garmadon,msg)


	-- update the health bar
	UpdateHealthBar(self,garmadon)	
	
end

----------------------------------------------------------------
-- custom function - turn the health hud on
----------------------------------------------------------------
function TurnOnHealthBar(self,garmadon)

	-- get the player
	local player = GAMEOBJ:GetControlledID()
		
	if not garmadon:Exists() then return	end
	
	-- set armor vis to true
	local armorVis = true
	-- if there is no armor, set vis to false
	if garmadon:GetArmor().armor == 0 then
		armorVis = false
	end
	
	garmadon:SetNameBillboardState{bState = false, bOverrideDefaultSetting = true}
	self:SendLuaNotificationRequest{requestTarget = garmadon, messageName = "HitOrHealResult"}
		
	UI:SendMessage( "ToggleEnemyStatusBar", { {"visible", true}, {"healthVisible", true},
		{"armorVisible", armorVis},
		{"nameVisible", true},
		{"health", math.floor((garmadon:GetHealth().health / garmadon:GetMaxHealth().health) * 100) },
		{"armor", math.floor((garmadon:GetArmor().armor / garmadon:GetMaxArmor().armor) * 100) },
		{"nameTxt", garmadon:GetName().name},
		{"id", "|" .. garmadon:GetID()} } )
		
	-- we have turned on the healthbar
	self:SetVar("HealthBarOn",true)
		
end

----------------------------------------------------------------
-- custom function - update the health hud
----------------------------------------------------------------
function UpdateHealthBar(self,garmadon)

	-- get the player
	local player = GAMEOBJ:GetControlledID()

	if not garmadon:Exists() then return	end
	
	-- set armor vis to true
	local armorVis = true
	-- if there is no armor, set vis to false
	if garmadon:GetArmor().armor == 0 then
		armorVis = false
	end
	
	-- update the health bar
	UI:SendMessage( "UpdateEnemyStatusBar", { {"healthVisible", true},
		
		{"armorVisible", armorVis},
		{"nameVisible", true},
		{"health", math.floor((garmadon:GetHealth().health / garmadon:GetMaxHealth().health) * 100) },
		{"armor", math.floor((garmadon:GetArmor().armor / garmadon:GetMaxArmor().armor) * 100) },
		{"nameTxt", garmadon:GetName().name},
		{"id", "|" .. garmadon:GetID()} } )
	
	if garmadon:GetHealth().health == 0 then
		--fight over
		UI:SendMessage( "ToggleEnemyStatusBar", { {"visible", false} } )
		self:SetVar("HealthBarOn",false)
	end

end
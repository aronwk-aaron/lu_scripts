---------------------------------------------
-- script on the shield generator in CP, displays a popup when the player is close and closes it when the player leaves the area
--
-- updated by brandi... 1/11/11 - added ability to change the radius that the health bar shows up
-- updated by brnadi... 1/18/11 - changed the size of the proximity monitor and deleted the second one
---------------------------------------------

--***************************************************
-- TO CHANGE THE RADIUS OF THE HEALTH BAR
-- the radius of the health bar needs to be added to the config data in Happy Flower on the dragon
-- healthBarRad  1:####
--****************************************************

function onStartup(self)
    
    local dist = self:GetVar("healthBarRad") or 100 --self:GetTetherPoint().radius
    self:SetProximityRadius{radius = dist, name="animProx", collisionGroup = 8, shapeType = "CYLINDER", height = 50, heightOffset = -10 }
    self:SetUseStatusDisplay{bEnable = true, displayRangeProximityName = "animProx"}

end

-------------------------------------------------------------
-- handle proximity updates
--------------------------------------------------------------
function onProximityUpdate(self, msg)
	if msg.objId:IsCharacter().isChar and (msg.name == "animProx") then
		if msg.status == "ENTER" then
			if self:IsInCombat().bInCombat == false then
				self:PlayAnimation{animationID = "prox"}
			end
		end
	end
end
-----------------------------------------------
-- Script for Sentinel Walkways
--
-- Last Updated: mrb... 2/18/11
-----------------------------------------------
local defaultForce = 115
local missions = {1047, 1330, 1331, 1332}

function onStartup(self,msg) 
	-- get the forward direction, in this case it's actually the right direction that matches the render.
	local dir = self:GetObjectDirectionVectors().right
	-- check for HF override
	local force = self:GetVar("force") or defaultForce
	
	-- set the physics push volume
	self:SetPhysicsVolumeEffect{ EffectType = 'PUSH', amount = force, direction = dir, DistanceBasedEffect = false }			
end
	
function onCollisionPhantom(self, msg)	
	-- update the missions
	for k, missionID in ipairs(missions) do
		msg.senderID:UpdateMissionTask {target = self, value = missionID, value2 = 1, taskType = "complete"}
	end
end 
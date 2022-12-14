--------------------------------------------------------------
-- Server side script giving stinky fish 
-- Created mrb... 6/13/11
--------------------------------------------------------------
local fishObject = 8570
local vertOffset = -0.5

function onStartup(self)
	local pos = self:GetPosition().pos
	
	-- adjust the objects pos
	pos.y = pos.y + vertOffset
	self:SetPosition{pos = pos}
end

function onSkillEventFired(self,msg)
    -- catch the spinjitzu charge up skill
	if msg.wsHandle ~= "stinkfish" or self:GetVar("bUsed") then return end	
	
	-- only let one player use this
	self:SetVar("bUsed", true)
	
	local pos = self:GetPosition().pos
	local rot = self:GetRotation()
	local config = { {"no_timed_spawn", true} }
	
	-- spawn the fish
	RESMGR:LoadObject{ objectTemplate = fishObject, x = pos.x, y = pos.y + vertOffset, z = pos.z, 
													rw = rot.w, rx = rot.x, ry = rot.y, rz = rot.z, 
													owner = self, configData = config}
	-- save out the player who through the fish
	self:SetVar("playerObj", msg.casterID:GetParentObj().objIDParent)
end 

function onChildLoaded(self, msg)
	if msg.templateID == fishObject then
		local animTimer = msg.childID:GetAnimationTime{animationID = "idle"}.time + 1
		
		-- start a timer to remove the objects
		GAMEOBJ:GetTimer():AddTimerWithCancel( animTimer, "Smash", self )
		-- store out the child object
		self:SetVar("fishObj", msg.childID)
	end
end 

function onTimerDone(self, msg)
	if msg.name == "Smash" then
		local child = self:GetVar("fishObj")
		
		-- kill the fish
		if child and child:Exists() then
			GAMEOBJ:DeleteObject( child )
		end
		
		local player = self:GetVar("playerObj")
		
		-- if we dont have a player then use self
		if not player or not player:Exists() then
			player = self
		end
		
		-- kill target
		self:RequestDie{killerID = player}--, killType = "SILENT"}		
	end
end 
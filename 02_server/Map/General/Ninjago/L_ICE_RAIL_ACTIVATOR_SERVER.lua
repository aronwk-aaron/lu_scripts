----------------------------------------
-- server side script on start rails for ninjago rails
--
-- created by brandi... 6/14/11
---------------------------------------------

---------------------------------------------
-- to set up in HF for an Ice Rail that breaks a chunk
-- 		put the ice block in a unique group
--		on the rail activator
--			in config data
--				BreakPoint	1:(the number of the rail node just before the ice chunk should break)
--				BlockGroup 	0:(the name of the group you put on the ice block)
--			in the dynamic UI check "Notify activator on arrived"
---------------------------------------------

require('02_server/Map/General/Ninjago/L_RAIL_ACTIVATORS_SERVER')

function onPlayerRailArrivedNotification(self,msg)
	local breakPoint = self:GetVar("BreakPoint") 
	if not breakPoint then return end

	if msg.waypointNumber == breakPoint then
		local blockGroup = self:GetVar("BlockGroup")
		if not blockGroup then return end
		
		local block = self:GetObjectsInGroup{ group = blockGroup, ignoreSpawners = true }.objects
		-- make sure it returned a valid table and parse through it
		for k,v in ipairs(block) do
			-- found an endrail, verify it and return to back to the function that called this one
			if v:Exists() then
				self:SetVar("IceBlock",v)
				v:PlayAnimation{animationID = "explode", bPlayImmediate = true}
				local animTime = v:GetAnimationTime {animationID = "explode"}.time or .5
				GAMEOBJ:GetTimer():AddTimerWithCancel(animTime, "killBlock",self)
				--v:RequestDie{killtype = "VIOLENT"}
				break
			end
		end
	end
end

function onTimerDone(self,msg)
	if msg.name == "killBlock" then
		local block = self:GetVar("IceBlock")
		if not block:Exists() then return end
		block:RequestDie{killtype = "VIOLENT"}
	end
end
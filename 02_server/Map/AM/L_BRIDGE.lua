--------------------------------------------------------------
-- Server side Script on the bridge in aura mar
-- 
-- created by brandi... 10/7/10
-- updated by brandi... 11/19/10 - telling the bridges to tell the consoles when they cahnge states to the picktype of the console can update
-- updated brandi... 11/29/10 - took out the notify the console since it is no longer needed
--------------------------------------------------------------

----------------------------------------------
--  when the bridge spawns in, even before its built
----------------------------------------------
function onStartup(self,msg)
    -- when the bridge spawns, dont let it path
    --self:StopPathing()
    
end

----------------------------------------------
-- when the bridge is fully built
----------------------------------------------
function onRebuildComplete(self, msg)
	-- when the bridge is fully built, put it to the correct way point, then make sure it doesnt path
	--self:GoToWaypoint{iPathIndex = 0}
	--self:StopPathing()
	local console = self:GetObjectsInGroup{ group = "Console"..self:GetVar("bridge"), ignoreSpawners = true }.objects[1]
	console:NotifyObject{name = "BridgeBuilt"}
	GAMEOBJ:GetTimer():AddTimerWithCancel( 50, "SmashBridge", self )
end

function onTimerDone(self,msg)
	if msg.name == "SmashBridge" then
		self:RequestDie{ killType = "VIOLENT" }
	end
end

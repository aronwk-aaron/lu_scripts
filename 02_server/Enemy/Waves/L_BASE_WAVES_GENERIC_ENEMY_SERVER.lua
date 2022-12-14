----------------------------------------
-- Generic Server side Survival strombie script
--
-- created mrb... 10/20/10 - shared script for mobs
----------------------------------------

function baseWavesStartup(self, other)    
    self:SetVar("Set.SuspendLuaMovementAI", true)   -- a state suspending scripted movement AI
    self:SetVar("Set.SuspendLuaAI", true)           -- a state suspending scripted AI
    
    local points = iPoints or 0
    
    self:SetNetworkVar("points", points)
end 

function baseWavesGetActivityPoints(self, msg, other)
	local points = iPoints or 0
	
	msg.points = points
	
	return msg
end

function baseWavesDie(self, msg, other)
	local points = iPoints or 0
	
	GAMEOBJ:GetZoneControlID():NotifyObject{ name="Survival_Update", param1 = points, ObjIDSender = msg.killerID}
end 
----------------------------------------
-- Generic Server side script that disables Lua AI
--
-- created mrb... 1/7/11 - shared script for mobs
----------------------------------------

function onStartup(self)
	suspendLuaAI(self)
end

function suspendLuaAI(self)    
    self:SetVar("Set.SuspendLuaMovementAI", true)   -- a state suspending scripted movement AI
    self:SetVar("Set.SuspendLuaAI", true)           -- a state suspending scripted AI
end 
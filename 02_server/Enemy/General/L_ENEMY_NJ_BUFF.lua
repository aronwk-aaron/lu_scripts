----------------------------------------
-- Generic Server side script that casts 
-- the NJ Buff on self so player NJ skills can react to this buff.
--
-- created mrb... 1/7/11 - moved script and updated
----------------------------------------
require('02_server/Enemy/General/L_SUSPEND_LUA_AI')

function onStartup(self)
	baseStartup(self)
end 

function baseStartup(self)
    -- Applies the NJ buff so NJ players do more damage 
    self:CastSkill{skillID = 1127}
    
    -- turn off lua ai
    suspendLuaAI(self)
end 
-- Script used to start and kill a skill on an object that will be randomly spawing through a spawner network.


function onPhysicsComponentReady(self, msg)
	local sDelay = self:GetVar("delay") or 4
    GAMEOBJ:GetTimer():AddTimerWithCancel( sDelay  , "Fire", self )

end


function onTimerDone(self, msg)
    if msg.name == "Fire" then
		local mySkill = self:GetVar("skill")
        self:CastSkill{skillID = mySkill}
        GAMEOBJ:GetTimer():AddTimerWithCancel( 5  , "Fire", self )
    end
end
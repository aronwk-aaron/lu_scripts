------------------------------------------------------
-- script on the hydrants in PR that shoot the player in the air

-- updated by brandi.. 6/23/11
------------------------------------------------------

function onStartup(self)
	
	self:SetVar( "hydrantPos", self:GetPosition{}.pos )
	self:PlayFXEffect{ name = "water", effectID = 384, effectType = "water" }

	local hydrant = "hydrant0"..self:GetVar('hydrant')
	local bouncerObj = self:GetObjectsInGroup{ group = hydrant, ignoreSpawners = true}.objects
	for k,bouncer in ipairs(bouncerObj) do
		if bouncer:Exists() then
			bouncer:NotifyObject{name = "enableCollision"}
			self:SetVar( "bouncer", bouncer)
			break
		end
	end

	GAMEOBJ:GetTimer():AddTimerWithCancel( 25, "KillBroken",self )
end

function onTimerDone(self,msg)

	if (msg.name == "KillBroken") then
			
		local bouncerObj = self:GetVar( "bouncer" )
		if bouncerObj:Exists() then 
			bouncerObj:NotifyObject{name = "disableCollision"}
		end
		GAMEOBJ:DeleteObject(self)
	end

end



function onCollision (self,msg)

	self:PlayFXEffect{effectType = "down_gsharp"}

end

function onOffCollision (self,msg)

	self:PlayFXEffect{effectType = "up"}

end

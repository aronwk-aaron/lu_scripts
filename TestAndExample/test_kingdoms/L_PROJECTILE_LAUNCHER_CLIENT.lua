
function onStartup(self,msg)
end

function onCheckUseRequirements( self, msg )
	msg.bCanUse = true
	return msg
end

function onRenderComponentReady(self,msg)
	GAMEOBJ:GetTimer():AddTimerWithCancel(3, "interact_icon", self)
end

function onTimerDone(self,msg)
	if msg.name == "interact_icon" then
		self:SetOverheadIconOffset{horizOffset = 0, vertOffset = 10, depthOffset = 0}
	end
end
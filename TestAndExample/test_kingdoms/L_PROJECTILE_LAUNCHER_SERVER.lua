
function onStartup(self,msg)
	-- set our fov
	self:SetProjectileLauncherParams{ playerPosOffset	= {x = 0, y = 0, z = -12}, 
									  cameraFOV         = 78 }
end


function onCheckUseRequirements(self, msg)
	msg.bCanUse = true
	return msg
end


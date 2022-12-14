function onStartup(self)
	self:SetMovingPlatformParams{ wsPlatformPath = "MapTour", iStartIndex = 0 }
	self:SetVisible{ visible = false }
	CAMERA:ActivateCamera("CAMERA_ATTACHED")
	CAMERA:AttachCameraToObj("CAMERA_ATTACHED", self, true, true)
	CAMERA:SetRenderCamera("CAMERA_ATTACHED")
end

function onPlatformAtLastWaypoint(self, msg)
	CAMERA:SetToPrevGameCam()
end
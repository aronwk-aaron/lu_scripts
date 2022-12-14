--spinner test

-- old
--[[
function onObjectActivated(self, msg)
	local path = self:GetPathName{}.pathName
	msg.activatorID:SetRailMovement{pathName=path}
	print(path)
end

--]]

-- new
---[[
function onObjectActivated(self, msg)
	local path = self:GetRailInfo{}
	msg.activatorID:SetRailMovement{pathName=path.pathName, pathStart=path.pathStart, pathGoForward=path.pathGoForward}
end
--]]
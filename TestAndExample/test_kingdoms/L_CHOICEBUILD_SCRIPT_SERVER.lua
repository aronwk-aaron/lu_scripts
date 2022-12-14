
function onStartup(self,msg)
	local our_lot = self:GetLOT().objtemplate
	GAMEOBJ:GetZoneControlID():NotifyObject{ObjIDSender = self, name = "cb_added", param1 = our_lot}	
end


function onShutDown(self, msg)
	print("ON SHUTDOWN")
    local our_lot = self:GetLOT().objtemplate
	GAMEOBJ:GetZoneControlID():NotifyObject{ObjIDSender = self, name = "cb_removed", param1 = our_lot}
end
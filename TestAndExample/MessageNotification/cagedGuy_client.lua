require('TestAndExample/MessageNotification/cagedGuy_common')

function onStartupComplete(self)
	self:DisplayChatBubble{ wsText = "Help! I'm trapped!" }
end

function onCageDied(self,savior)
	self:DisplayChatBubble{ wsText = "Thanks for saving me, " .. savior:GetName().name .. "!" }
end

function onBridgeBuilt(self,builder)
	self:DisplayChatBubble{ wsText = "Phear " .. builder:GetName().name .. "'s leet bridge-building skillz!" }
end

function onBbqBuilt(self,builder)
	self:DisplayChatBubble{ wsText = "OMGBBQ!\nOM nom nom nom!\nThis BBQ is so tasty I...\nI could just..." }
end

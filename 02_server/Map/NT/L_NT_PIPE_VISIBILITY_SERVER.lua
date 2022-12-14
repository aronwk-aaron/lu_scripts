--------------------------------------------------------------
-- server script on the imagination pipes in the beam 

-- updated mrb... 10/26/10
--------------------------------------------------------------

-- when the quickbuild is built
function onRebuildComplete( self, msg)
	-- set the player flag to true
	local player = msg.userID
	local flag = self:GetVar('flag')
	
	-- if there isnt a flag number, something is wrong and kill the script before it crashes
	if not flag then return end
	
	player:SetFlag{iFlagID = flag, bFlag = true}
	
	--tell the client script that the pipe was built
	self:NotifyClientObject{name = "PipeBuilt",  rerouteID = player}
end

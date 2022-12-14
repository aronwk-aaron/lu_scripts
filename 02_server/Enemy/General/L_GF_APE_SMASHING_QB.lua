----------------------------------------
-- Server side AM Ape Anchor QB
--
-- created mrb... 1/7/11
----------------------------------------

function onStartup(self)
	local lootTagID = self:GetVar("lootTagOwner") or 0
	
	self:SetNetworkVar("lootTagOwner", lootTagID)
end

function onCheckUseRequirements(self, msg)
	local tagID = self:GetVar("lootTagOwner") or 0	
	local tagObj = GAMEOBJ:GetObjectByID(tagID)
	
	if tagObj:Exists() then
		if tagObj:GetID() ~= msg.objIDUser:GetID() and not msg.objIDUser:TeamIsOnWorldMember{i64PlayerID = tagObj}.bResult then		
			msg.bCanUse = false
		end
	end
    
    return msg
end 

function onRebuildNotifyState(self, msg)	
	local Ape = self:GetParentObj().objIDParent 
	
	if( Ape == nil or Ape:Exists() == false ) then
		return
	end
	
	-- a player just did the quickbuild.
	if (msg.iState == 2) then
		-- Notify the APE that the build is done and using the player as the sender so we can update missions.
		Ape:NotifyObject{ ObjIDSender = msg.player, name = "rebuildDone" }
		
		self:PlayAnimation{animationID = "smash", fPriority = 1.7}
		
		GAMEOBJ:GetTimer():AddTimerWithCancel( 1, "AnchorBreakTime", self )
    end
end

function onTimerDone(self, msg) 
	if msg.name == "AnchorBreakTime" then
		self:RequestDie{}
	end
end

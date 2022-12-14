--------------------------------------------------------------
-- Server side script for the lootable chest for the dragon fight.
--
-- updated by mrb... 8/30/10 - added network var from server so 
-- that only one person can use the chest, but all clients get the animations
--------------------------------------------------------------

function onCheckUseRequirements(self, msg)

	local preConVar = self:GetVar("CheckPrecondition")
	local check = msg.objIDUser:CheckListOfPreconditionsFromLua{PreconditionsToCheck = preConVar, requestingID = self}
	
	-- dont let the playe use this if the minigame is active or they dont meet the precondition check.
	if not check.bPass  then
		msg.bCanUse = false
	end
    
    return msg
end

function onUse(self,msg)
    local player = msg.user
	
	player:SetFlag{iFlagID = 2099, bFlag = false}
	local lootMatrix = self:GetCurrentLootMatrix().iMatrix
	self:DropItems{iLootMatrixID = lootMatrix, owner = player, sourceObj = self}
end 



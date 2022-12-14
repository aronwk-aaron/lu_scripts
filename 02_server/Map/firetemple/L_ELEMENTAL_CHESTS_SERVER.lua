--------------------------------------------------------------
-- Server side script for the 
--
-- 
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
    
	local lootMatrix = self:GetCurrentLootMatrix().iMatrix
	self:DropItems{iLootMatrixID = lootMatrix, owner = player, sourceObj = self}
	
	local dropCurrency = self:RollCurrency{iTable = 132, iLevel = 1}.iCurrency
	self:DropCurrency{iAmount  = dropCurrency, owner = player}
    
    -- this will not work for multiple preconditions
    local preConVar = self:GetVar("CheckPrecondition")
    if not preConVar then return end
    
 --   local Tprecons = split(preConVar, ";")
 --   local validPreconsT = {}
    
 --   for k,var in ipairs(Tprecons) do
	--	local newPre = split(var, "|")
	--	for k2,v in ipairs(newPre) do
	--		table.insert(validPreconsT,v)
	--	end
	--end
	
 --   if validPreconsT then
		
	--	for k,precondition in ipairs(validPreconsT) do
			local preconInfo = player:CheckPrecondition{PreconditionID = preConVar}
			--if preconInfo.iPreconditionType == 23 then
				local flagNum = preconInfo.TargetLOT
				player:SetFlag{iFlagID = flagNum, bFlag = true}
			--end
		--end
		
	--end


end 

----------------------------------------------
-- splits a string based on the pattern passed in
----------------------------------------------
function split(str, pat)
    local t = {}
    -- Creates a table of strings based on the passed in pattern   
    string.gsub(str .. pat, "(.-)" .. pat, function(result) table.insert(t, result) end)

    return t
end


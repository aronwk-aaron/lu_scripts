--------------------------------------------------------------
-- Server side script on the faction token console 
-- this script takes infected bricks and give the player faction tokens
-- can be used as a stand alone script, or added as a require script
-- 
-- created by brandi.. 4/14/11
-- updated mrb... 5/2/11 - added interact sound option
--------------------------------------------------------------
--
-- add configData on the object in HF to play audio on interact
-- sound1 -> 0:{GUID}
--
--------------------------------------------------------------

-- general local variables, these can be changed, but they will change all the token consoles in the whole game. 
-- to change only a specific console, you can either make a custom script or put config data on the asset in HF
local bricksToTake = 25
local tokensToGive = 5
local missionID = {}

-- if you want to change any of the above values without using another script, put any of the following GetVars as config data on the asset in HF
function onStartup(self,msg)
	-- put config misID as a string in HF
	if not self:GetVar("misID") then return end
	missionID = self:GetVar("misID")
	-- put config bricks as a number in HF
	if not self:GetVar("bricks") then return end
	bricksToTake = self:GetVar("bricks")
	-- put config tokens as a number in HF
	if not self:GetVar("tokens") then return end
	tokensToGive = self:GetVar("tokens")
end

-- if another script is used, values placed in it will be pulled in using this function
function setVariables(passedMissionID,passedBricksToTake,passedTokensToGive)
	bricksToTake = passedBricksToTake or bricksToTake
	tokensToGive = passedTokensToGive or tokensToGive
	missionID = passedMissionID or missionID
end

function onCheckUseRequirements(self,msg)
	baseCheckUseRequirements (self,msg)
	
	return msg
end

-- check through any preconditions on the console
function baseCheckUseRequirements (self,msg)
	local preConVar = self:GetVar("CheckPrecondition")
    
    if preConVar and preConVar ~= "" then
        local check = msg.objIDUser:CheckListOfPreconditionsFromLua{PreconditionsToCheck = preConVar, requestingID = self}
        
        if not check.bPass then 			
            msg.bCanUse = false
            
            return msg
        end
    end
end

-- if the player interacts with the console
function onUse(self,msg)
	baseUse(self,msg)
end

function baseUse(self,msg)
	local player = msg.user
	
	-- makes sure the player has the required amount of infected bricks, they shouldnt get past 
	--	the CheckUseRequirements, but just in case
	if not (player:GetInvItemCount{ iObjTemplate = 6194}.itemCount >= bricksToTake) then return end
	--remove the bricks from the players inventory
	player:RemoveItemFromInventory{iObjTemplate = 6194, iStackCount = bricksToTake }
	
	local useSound = self:GetVar("sound1") or false
	
	if useSound then
		-- play the start audio
		self:PlayNDAudioEmitter{m_NDAudioEventGUID = useSound}	
	end
	
	-- checks to see which faction the player is a part of, then gives them the correct tokens
	if player:GetFlag{iFlagID = 46}.bFlag then -- venture
		player:AddItemToInventory{iObjTemplate = 8321, itemCount = tokensToGive, bMailItemsIfInvFull = true }
	elseif player:GetFlag{iFlagID = 47}.bFlag then -- Assembly
		player:AddItemToInventory{iObjTemplate = 8318, itemCount = tokensToGive, bMailItemsIfInvFull = true }
	elseif player:GetFlag{iFlagID = 48}.bFlag then -- Paradox
		player:AddItemToInventory{iObjTemplate = 8320, itemCount = tokensToGive, bMailItemsIfInvFull = true }
	elseif player:GetFlag{iFlagID = 49}.bFlag then -- Sentinel
		player:AddItemToInventory{iObjTemplate = 8319, itemCount = tokensToGive, bMailItemsIfInvFull = true }
	end
		
	for k,mission in ipairs(missionID) do
		--if the player is on the mission to use the console, complete their mission
		player:UpdateMissionTask{taskType = "complete", value = mission, value2 = 1, target = self}
	end

	-- be sure to ternimate the interaction so the shift icon comes up again.
	player:TerminateInteraction{type = 'fromInteraction', ObjIDTerminator = self}	
end
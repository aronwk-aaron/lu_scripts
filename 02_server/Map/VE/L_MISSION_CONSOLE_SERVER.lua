--------------------------------------------------------------
-- Server script for consoles in the venture explore battle instance

-- created by brandi.. 11/10/10
-- updated brandi.. 11/12/10 - to acount for all the different missions
-------------------------------------------------------------- 

--------------------------------------------------------------
-- check to see if the player can use the consoles
--------------------------------------------------------------
function onCheckUseRequirements(self, msg)
	local player = msg.objIDUser
	if not player:Exists() then return end
	-- get the number of the console that is set in happy flower
	local number = self:GetVar("num")
	-- use the number to create the flag number
	local flag = tonumber("101"..number)
	--check to make sure the player hasn't used the console yet
	
	if player:GetFlag{iFlagID = flag}.bFlag then   
		-- set the console to unuseable
		msg.bCanUse = false
		return msg	
	end
	local repeatmissionState = player:GetMissionState{missionID = 1225}.missionState
	if repeatmissionState ~= 10	and repeatmissionState ~= 2
					and player:GetMissionState{missionID = 1220}.missionState ~= 2 then
		-- set the console to unuseable
		msg.bCanUse = false
		return msg	
	end
end

--------------------------------------------------------------
-- whent he player uses the consoles
--------------------------------------------------------------
function onUse(self,msg)

	local player = msg.user
	-- allows the loot to be distributed for the player based on the activity of the console
	self:AddActivityUser{userID = player}
	self:DistributeActivityRewards{userID = player, bAutoAddCurrency = false, bAutoAddItems = false}
	self:RemoveActivityUser{userID = player}
	-- forces the mission item into the players inventory, so if they dont pick it up they can still complete the mission
	player:AddItemToInventory{iObjTemplate = 12547, itemCount = 1}	
	
	-- get the number of the console that is set in happy flower 
	local number = self:GetVar("num")
	-- put the number together with the first 3 numbers to make the flag number
	local flag = tonumber("101"..number)
	-- set the flag for this console to true
	player:SetFlag{iFlagID = flag, bFlag = true}
	-- tell the client up update it picktype
	self:NotifyClientObject()
	
	-- terminate the player's interaction with the console 
	player:TerminateInteraction{type = 'fromInteraction', ObjIDTerminator = self}   
	 
end
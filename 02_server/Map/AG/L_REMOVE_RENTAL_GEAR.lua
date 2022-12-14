--------------------------------------------------------------
-- Removes the rental gear from the player on mission turn in
--
-- created mrb ... 5/25/11
-- updated abeechler 6/27/11 ... Add session flag resetting for set equips
--------------------------------------------------------------
-- add missionID configData to the object in HF to remove this 
-- gear what the specified mission is completed
--------------------------------------------------------------

local defaultMission = 768	                            -- mission to remove gearSets on completion
local gearSets = {14359,14321,14353,14315}	-- inventory items to remove
local equipFlag = 126                                     -- Set upon wearing trial faction armor for the first time in a session

function baseMissionDialogueOK(self, msg)
	local mission = self:GetVar("missionID") or defaultMission
	
	-- if we're not on the right mission do nothing
	if msg.missionID ~= mission then return end

	if msg.bIsComplete then 
		-- remove the inventory items
		for key,item in ipairs(gearSets) do
			msg.responder:RemoveItemFromInventory{iObjTemplate = item}
		end
		
		-- reset the equipment flag
		msg.responder:SetFlag{iFlagID = equipFlag, bFlag = false}
	end
end 

function onMissionDialogueOK(self, msg)
	baseMissionDialogueOK(self, msg)
end 

--------------------------------------------------------------
-- Server side script on npcs that can be healed with the imagination backpack

-- created by brandi.. 2/15/11
-- updated by brandi.. 4/18/11 - the missions are now set on the object so this script can be used on brick fury as well.
--------------------------------------------------------------

-- skill sent from the imagination backpack when it releases its imagination
local backpackSkill = "CastImaginationBackpack"


-- set config data for the missions in HF. If the same mission turns the fx on as turns the fx off, then you only need FXOnMis
-- in HF   FXOnMis  1:####
--         FXOffMis 1:####

----------------------------------------------
-- Catch a skill that was fired near by
----------------------------------------------
function onSkillEventFired(self,msg)
	baseSkillEventFired(self,msg)
end

function baseSkillEventFired(self,msg)
	-- make sure the skill is the skill we are looking for
	if msg.wsHandle == backpackSkill then
		-- get the player
		local player = msg.casterID
		-- mission to use the imagination backpack on the npc
		local healMisID		= self:GetVar("FXOffMis") or self:GetVar("FXOnMis")
		if not healMisID then return end
		-- check to see if the player is on the mission to heal the npc, if so, update it
		if player:GetMissionState{missionID = healMisID}.missionState == 2 then
			player:UpdateMissionTask{taskType = "complete", value = healMisID, value2 = 1, target = self}
			-- send a message to client to kill the fx (or change the render)
			self:NotifyClientObject{ name = "ClearMaelstrom" , paramObj = player , rerouteID = player }	
		end
	end
end
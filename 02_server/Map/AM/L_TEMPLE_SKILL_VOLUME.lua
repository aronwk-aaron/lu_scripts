---------------------------------------------
-- Server side script on a Sensei Wu to complete
-- mission when the player casts the charge up 
-- whirlwind attack. 
--
-- created by mrb... 1/4/11
---------------------------------------------

local missionIDs = {}

function onSkillEventFired(self,msg)
    -- catch the spinjitzu charge up skill
	if msg.wsHandle ~= "NinjagoSpinAttackEvent" then return end	
	
	missionIDs = split(self:GetVar("missions"),"_")
	-- complete missions for the player who cast the skill
	for k,missionID in ipairs(missionIDs) do
		msg.casterID:UpdateMissionTask{taskType = "complete", value = missionID, value2 = 1, target = self}
	end
end 

function split(str, pat)
    local t = {}
    -- Creates a table of strings based on the passed in pattern   
    string.gsub(str .. pat, "(.-)" .. pat, function(result) table.insert(t, result) end)

    return t
end

--------------------------------------------------------------
-- General use script for POI explorer task missions (replaces using triggers in HF)
-- on the trigger, be sure to add config data POI 0:name of the poi

-- created by brandi 10/19/10
--------------------------------------------------------------

function onCollisionPhantom(self,msg)
	-- get the collider
	local player = msg.senderID
	local possessor = player:GetPossessor().possessorID
	if possessor:Exists() then
		player = possessor
	end
		
	-- make sure they really exist
	if player:Exists() then
		-- make sure its a player
		if player:IsCharacter().isChar then
			-- get the name of the poi to update from the trigger volume in HF config data
			local POIname = self:GetVar("POI")
			-- make sure the there is a POI name so the script doesnt crap out
			if POIname then
				-- update the mission task for the player
				player:UpdateMissionTask{taskType = "exploretask", wsValue = POIname }
			end
		end
	end	
end
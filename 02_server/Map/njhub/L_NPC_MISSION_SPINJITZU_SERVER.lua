--------------------------------------------------------------
-- server side script for the 4 elemental ninjas in the dojos
-- the script has the npc perform a spinjitzu then force the player to interact with the npc for the next mission offer

-- created by Brandi... 7/14/11
--------------------------------------------------------------

-- table of the player flags based on the element
local elementT = { 	["earth"] = 2030,
					["lightning"] = 2031,
					["ice"] = 2032,
					["fire"] = 2033
				 }
	
-- table of the mission based on the element			 
local missionT = { ["earth"] = 1796,
					["lightning"] = 1952,
					["ice"] = 1959,
					["fire"] = 1962
				 }


function onMissionDialogueOK(self,msg)
	spinMissionDialogueOK(self,msg)
end

function spinMissionDialogueOK(self,msg)
	
	--get the element that is placed on the npc in hf
	local element = self:GetVar("element")
	if not element then return end
	
	-- the player has completed the mission to put on the elemental gear
	if msg.bIsComplete and msg.missionID == missionT[element] then
	
		local playerID = msg.responder:GetID()
		-- add a delay so the client can run the animation
		GAMEOBJ:GetTimer():AddTimerWithCancel( 5, "SetFlag_"..playerID,self ) 
		
	end
end


function onTimerDone(self,msg)

	local var = split(msg.name, "_") --Spliting the message name back into the timers name and the player's ID
	local player = ''
		
	if var[2] then
		player = GAMEOBJ:GetObjectByID(var[2]) --Resetting the players Object ID into a Variable
	end

	if var[1] == "SetFlag" then
		
		if not player:Exists() then return end
		
		-- set the flag that completes the players achievement to learn spinjitzu
		local element = self:GetVar("element")
		if not element then return end
		
		player:SetFlag{iFlagID = elementT[element], bFlag = true}
		
	end
end
		
				
----------------------------------------------
-- splits a string based on the pattern passed in
----------------------------------------------
function split(str, pat)
    local t = {}
    -- creates a table of strings based on the passed in pattern   
    string.gsub(str .. pat, "(.-)" .. pat, function(result) table.insert(t, result) end)

    return t
end 
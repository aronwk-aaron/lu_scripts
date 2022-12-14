--------------------------------------------------------------
-- server side script for the guard in NT
-- if the player action emotes near him, he wakes up and updates an achievement

-- created by Brandi... 4/12/11
--------------------------------------------------------------

-- list of all action and more action emotes
local validEmotes = {175,372,354,356,374,115,210,373,392,352,364,69,174,386,375,384,376,385,393,383}

--------------------------------------------------------------
-- set guard variable to be asleep
--------------------------------------------------------------
function onStartup(self,msg)
	self:SetNetworkVar("asleep",true)
end

--------------------------------------------------------------
-- someone emoted at the guard
--------------------------------------------------------------
function onEmoteReceived(self,msg)
	-- print("you emoted "..msg.emoteID)
	-- make sure the guard is still asleep
	if not self:GetNetworkVar("asleep") then return end
	-- parse through all the valid emotes to wake the guard
    for k,emote in ipairs(validEmotes) do
		-- the emote a player did matches an emote in the valid list
		if msg.emoteID == emote then
			-- set the guard to awake
			self:SetNetworkVar("asleep",false)
			-- player an animation on the guard
			self:PlayAnimation{ animationID = "greet" }
			-- update the achievement for the player
			msg.senderID:UpdateMissionTask{taskType = "complete", value = 1346, value2 = 1, target = self}
			-- set a timer to send the guard back to sleep
			GAMEOBJ:GetTimer():AddTimerWithCancel( 5, "AsleepAgain", self )
			break
		end
    end
end

--------------------------------------------------------------
-- set the guard variable to be back asleep
--------------------------------------------------------------
function onTimerDone(self,msg)
	if msg.name == "AsleepAgain" then
		self:SetNetworkVar("asleep",true)
	end
end
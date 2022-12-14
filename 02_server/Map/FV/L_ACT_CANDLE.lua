--------------------------------------------------------------
-- Server side script for candles in FV

-- updated by brandi... 4/28/11 - consolidated into a function and added a table of missions to update
--------------------------------------------------------------

local missions = {850, 1431, 1529, 1566, 1603}

-----------------------------------------------------------------------------
--candle script to turn the effects off and on again
-----------------------------------------------------------------------------
function onStartup(self)

   self:PlayFXEffect{name = "candle_light", effectID = 2108, effectType = "create"}
   self:SetVar("Smoke", 5)
   self:SetVar("AmHit", false)

end

function onOnHit(self, msg)
	local blower = msg.attacker
	BlowCandleOut(self,blower)
end


function onSkillEventFired( self, msg )
    if msg.wsHandle == "waterspray" then
		local blower = msg.casterID
		BlowCandleOut(self,blower)
	end
end

function BlowCandleOut(self,blower)
	if self:GetVar("AmHit") then return end
   
	for k,missionID in ipairs(missions) do
		blower:UpdateMissionTask{taskType = "complete", value = missionID, value2 = 1, target = self}
	end
	self:SetVar("AmHit", true)

	self:StopFXEffect{name = "candle_light"}
	self:PlayFXEffect{name = "candle_smoke", effectID = 2109, effectType = "create"}
   
	GAMEOBJ:GetTimer():AddTimerWithCancel( self:GetVar("Smoke")  , "SmokeTime", self )
	
    
end

function onTimerDone(self, msg)

   self:SetVar("AmHit", false)
   
   self:StopFXEffect{name = "candle_smoke"}
   self:PlayFXEffect{name = "candle_light", effectID = 2108, effectType = "create"}
end
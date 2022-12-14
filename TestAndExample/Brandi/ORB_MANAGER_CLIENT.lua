

function onNotifyClientObject(self,msg)
	if msg.name == "TurnTimerOn" then
        UI:SendMessage( "ToggleFootRaceScoreboard",  {{"visible", true }, {"time", 15 }} )
		self:SetVar("TimeLeft",15)
		GAMEOBJ:GetTimer():CancelTimer("TimeToOrb", self) 
		GAMEOBJ:GetTimer():AddTimerWithCancel(1, "Countdown", self )
	elseif msg.name == "OrbPickedUp" then

        UI:SendMessage( "UpdateFootRaceScoreboard",  {{"time", 15}} )
		self:SetVar("TimeLeft",15)
		GAMEOBJ:GetTimer():CancelTimer("Countdown", self) 
		GAMEOBJ:GetTimer():AddTimerWithCancel(1, "Countdown", self )

	elseif msg.name == "LastOrbPickedUp" then

		UI:SendMessage( "UpdateFootRaceScoreboard",  {{"time", 15}, {"raceComplete", true}} )

	elseif msg.name == "OrbPickUpFailed" then

        UI:SendMessage("UpdateFootRaceScoreboard",  {{"visible", false }} )  
	
	end
end

function onTimerDone(self,msg)
	if msg.name == "Countdown" then
		local timeLeft = self:GetVar("TimeLeft")
		timeLeft = timeLeft - 1
		self:SetVar("TimeLeft",timeLeft)
		UI:SendMessage( "UpdateFootRaceScoreboard",  {{"time", timeLeft}} )
		GAMEOBJ:GetTimer():AddTimerWithCancel(1, "Countdown", self )
	end
end
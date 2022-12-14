
function onStartup(self,msg)

	GAMEOBJ:GetTimer():AddTimerWithCancel( 3, "NextCandle", self )
	self:SetVar("CandleNum",0)
	local spawner = LEVEL:GetSpawnerByName("FireSpawner1")
	self:SetVar("TotalNodes", spawner:SpawnerGetNumNodes().uiNum)
end

function onTimerDone(self,msg)
	if msg.name == "NextCandle" then
		local candle = self:GetVar("CandleNum")
		local spawner = LEVEL:GetSpawnerByName("FireSpawner1")
		spawner:SpawnerDestroyObjects()
		spawner:SpawnerSpawnNewAtIndex{spawnLocIndex = candle}
		GAMEOBJ:GetTimer():AddTimerWithCancel( 3, "NextCandle", self )
		candle = candle + 1
		if candle >= self:GetVar("TotalNodes") then
			candle = 0
		end
		self:SetVar("CandleNum",candle)
	end
end
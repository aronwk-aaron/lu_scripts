--------------------------------------------------------------
-- Server side script on the imagination beam collector arms

-- created by mrb...  5/5/11
--------------------------------------------------------------

-- global variable shared between all objects with the script on it.
lastRandom = 0
-- random start/stop
local randMin = 5
local randMax = 15
-- effectType to play
local fxName = "beam_collect"

function onStartup(self)
	-- start the random seed
	math.randomseed(os.time())
	
	-- start up the fx timer
	GAMEOBJ:GetTimer():AddTimerWithCancel( getRandomNum(), "PlayFX", self )	
end

function getRandomNum()
	-- set randNum to lastRandom for starting and to get different values each time
	local randNum = lastRandom
	
	-- while randNum is the same as lastRandom keep getting new numbers
	while randNum == lastRandom do	
		randNum = math.random(randMin, randMax)
	end
	
	-- set the new lastRandom
	lastRandom = randNum
	
	return randNum
end

function onTimerDone(self,msg)
	-- timer to play the FX
	if msg.name == "PlayFX" then		
		-- play the effect
		self:PlayFXEffect{name = "Beam", effectType = fxName}
		
		-- start a timer to buff the player again
		GAMEOBJ:GetTimer():AddTimerWithCancel( getRandomNum(), "PlayFX", self )		
	end
end
			
		
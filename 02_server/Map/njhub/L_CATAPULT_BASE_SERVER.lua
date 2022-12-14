----------------------------------------
-- Server side script on Nya on the base of the catapult, which is acting as a manager for the whole catapult system
--
-- created by brandi... 6/16/11
----------------------------------------

local PlatformBuiltGUID = "{8cccf912-69e3-4041-a20b-63e4afafc993}"

function onNotifyObject(self,msg)
	-- the bouncer told us it was built
	if msg.name == "BouncerBuilt" then
		-- start a timer for the arm to player the with bouncer animation
		GAMEOBJ:GetTimer():AddTimerWithCancel(.75, "PlatAnim", self)
		-- set the bouncer so we can use it later
		self:SetVar("Bouncer", msg.ObjIDSender )
	end
end

function onTimerDone(self,msg)
	if msg.name == "PlatAnim" then
		-- get the arm asset
		local arm = self:GetObjectsInGroup{ group = self:GetVar("ArmGroup"), ignoreSpawners = true }.objects
		-- tell the arm to the play the platform animation, which is just the arm laying there but with bouncer
		for k,obj in ipairs(arm) do
			if obj:Exists() then
				obj:PlayAnimation{animationID = "idle-platform"}
				obj:PlayNDAudioEmitter{m_NDAudioEventGUID = PlatformBuiltGUID} 
				-- set the art so we can use it again
				self:SetVar("Arm", obj)
				break
			end
		end
		-- start a timer till the bouncer actually bounces
		GAMEOBJ:GetTimer():AddTimerWithCancel(3, "bounce", self)

	elseif msg.name == "launchAnim" then
	
		local arm = self:GetVar("Arm")
		if not arm:Exists() then return end
		
		-- tell the arm to player the launcher animation
		local animTime = arm:GetAnimationTime{ animationID = "launch"}.time or 1
		GAMEOBJ:GetTimer():AddTimerWithCancel(animTime, "resetArm", self)
		arm:PlayAnimation{animationID = "launch"}
				
	elseif msg.name == "bounce" then

		local bouncer = self:GetVar("Bouncer")
		if not bouncer:Exists() then return end
		
		-- bounce all players
		bouncer:NotifyObject{name = "bounceAllInProximity"}
		-- add a delay to play the animation
		GAMEOBJ:GetTimer():AddTimerWithCancel(.3, "launchAnim", self)
				
	elseif msg.name == "resetArm" then
	
		local arm = self:GetVar("Arm")
		if not arm:Exists() then return end
		-- set the arm back to natural state
		arm:PlayAnimation{animationID = "idle"}
				
		local bouncer = self:GetVar("Bouncer")
		if not bouncer:Exists() then return end
		
		-- kill the bouncer
		bouncer:NotifyClientObject{name = "TimeToDie"}
		bouncer:RequestDie{killType = "VIOLENT", killerID = self} 
				
	end
end
function onStartup(self,msg)
	self:SetProximityRadius{radius = 10, name="ChaseProx", collisionGroup = 8 }
	
	GAMEOBJ:GetTimer():AddTimerWithCancel( 3, "GetTrigger", self )
end

function onProximityUpdate(self, msg)
	if not msg.name == "ChaseProx" then return end
	if msg.status == "ENTER"  then
		
		--self:CastSkill{skillID = 589}
		local myPos = self:GetPosition().pos
		local objPos = msg.objId:GetPosition().pos		
		local newVec = {x = (objPos.x - myPos.x) * 4, y = 15, z = (objPos.z - myPos.z) * 4}
		
		-- do knockback, fx and animation
		msg.objId:Knockback{vector = newVec, Caster = self, Originator = self}
	end
end

function notifyCollisionPhantom(self,other,msg)
	self:FollowTarget{targetID = msg.objectID, keepFollowing = true, speed = 1.5}
	local trigger = self:GetObjectsInGroup{ group = "FollowTrigger", ignoreSpawners = true }.objects
	for k,v in ipairs(trigger) do
		if v:Exists() then
			trigger = v
			break
		end
	end
	self:SendLuaNotificationCancel{requestTarget=trigger, messageName="CollisionPhantom"}
	self:SendLuaNotificationRequest{requestTarget = trigger , messageName="OffCollisionPhantom"}
end

function notifyOffCollisionPhantom(self,msg)
	self:StopPathing()
	local trigger = self:GetObjectsInGroup{ group = "FollowTrigger", ignoreSpawners = true }.objects
	for k,v in ipairs(trigger) do
		if v:Exists() then
			trigger = v
			break
		end
	end
	self:SendLuaNotificationCancel{requestTarget=trigger, messageName="OffCollisionPhantom"}
	self:SendLuaNotificationRequest{requestTarget = trigger , messageName="CollisionPhantom"}
end

function onTimerDone(self,msg)
	if msg.name == "GetTrigger" then
		local trigger = self:GetObjectsInGroup{ group = "FollowTrigger", ignoreSpawners = true }.objects
		for k,v in ipairs(trigger) do
			if v:Exists() then
				trigger = v
				break
			end
		end
		
		self:SendLuaNotificationRequest{requestTarget = trigger , messageName="CollisionPhantom"}
	end
end
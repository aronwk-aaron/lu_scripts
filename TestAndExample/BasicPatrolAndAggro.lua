--L_NPC_GRUMPY-DARKLING
require('State')
require('Delay')
homepoint = {}

--------------------------------------------------------
-- PUT THIS IN A UTIL SCRIPT
--------------------------------------------------------
function storeTarget(self, target)
	idString = target:GetID()
	finalID = "|" .. idString
	self:SetVar("myTarget", finalID)
end

function getMyTarget(self)
	targetID = self:GetVar("myTarget")
	return GAMEOBJ:GetObjectByID(targetID)
end

---------------------------------------------------------
-- STATE PATROL
---------------------------------------------------------
patrolBegin = State.create()

patrolBegin.onEnter = function(self)

	print("In patrolBegin onEnter")
   	local mypos = self:GetPosition().pos
    self:GoTo { speed = 0.5,
	            target = { x = mypos.x + math.random(-50,50),
	 		               z = mypos.z + math.random(-50,50),
	 		               y = mypos.y,
			             }
               }
end

patrolBegin.onArrived = function(self)
	setState("patrolEnd", self)
end

patrolEnd = State.create()

patrolEnd.onEnter = function(self)
	print("patrolEnd.onEnter" )
   	local mypos = self:GetPosition().pos
    self:GoTo { speed = 0.5,
				target = homepoint
			   }
end

patrolEnd.onArrived = function(self)
	setState("patrolBegin", self)
end


function onProximityUpdate(self, msg)

	if msg.status == "ENTER" and self:IsEnemy{ targetID = msg.objId }.enemy == true and not msg.objId:IsDead().bDead then
			storeTarget(self, msg.objId)
			setState("aggro", self)
		end
end


--------------------------------------------------
-- AGGRO STATE
--------------------------------------------------
aggro = State.create()

aggro.onEnter = function(self)
    myTarget = getMyTarget(self)
	self:FollowTarget { targetID = myTarget,
                        radius = 2,
                        speed = 1
        			  }
end

aggro.onArrived = function(self)
	setSubState("attack", self)
end

aggro.onProximityUpdate = function(self, msg)
	-- TODO: Handle the target leaving the tether radius
end


	--------------------------------------------------
	-- ATTACK SUB-STATE
	--------------------------------------------------
	attack = State.create()
	attack.onEnter = function(self)
		print("I'll kill you!")
	end
		
function onStartup(self)
	
	local mypos = self:GetPosition().pos
	homepoint = mypos  -- TODO: Store homepoint in C, not in Lua.  All instances of this object will share the same homepoint if the variable is left in Lua
	
	self:SetProximityRadius { radius = 15 }
	
	self:UseStateMachine{} -- Use curly braces
	
	addState(patrolBegin, "patrolBegin", "patrolBegin", self)
	addState(patrolEnd, "patrolEnd", "patrolEnd", self)
	addState(aggro, "aggro", "aggro", self)
		addSubState(attack, "attack", "attack", self)
	
		
	beginStateMachine("patrolBegin", self)

    patrolBegin.onEnter(self)	
end

---------------------------------------------
-- base script for the shield generator
-- used old script and broke it up to work for either a qb sheild generator or a static one
--
-- created by brandi... 1/13/11
---------------------------------------------

--------------------------------------------------------------
-- on startup, set proximities
--------------------------------------------------------------
function baseStartup(self,msg)
	-- set proximity monitor for enemies
	self:SetProximityRadius{name = "shield", radius = 20, collisionGroup = 10}
	-- set proximity monitor for players
	self:SetProximityRadius{name = "buffer", radius =21, collisionGroup = 1} --67109888}
	--self:SetProximityRadius{name = "bullet", radius = 19, collisionGroup = 9}
end

--------------------------------------------------------------
-- qb completed, start the shield
--------------------------------------------------------------
function StartShield( self, msg )
	-- add timer to start the fx after the start up animation (they are both called idle, so i cant just get the time of the animation)
	self:ActivityTimerSet{name = "PlayFX", updateInterval = 1.5,  duration = 1.5}
 
	local mypos = self:GetPosition().pos
	local myRot = self:GetRotation()
	RESMGR:LoadObject { objectTemplate = 13111, x= mypos.x, y= mypos.y , z= mypos.z, rw= myRot.w, rx= myRot.x, ry= myRot.y, rz = myRot.z, owner = self } 
	
	-- go to function to buff the players
	buffplayers(self)
	self:ActivityTimerSet{name = "BuffPlayers", updateInterval = 3}
end

function baseChildLoaded(self, msg)
	self:SetVar("Child", msg.childID:GetID())
end


--------------------------------------------------------------
-- when something enters the proximity
--------------------------------------------------------------
function EnemyEnteredShield(self,msg)
	local intruder = msg.objId
	-- get the direction the enemies is running in, and use the back vector
	local dir = intruder:GetObjectDirectionVectors().backward --GetLinearVelocity().linVelocity
	-- adjust the velocity
	dir.y = dir.y + 15
	dir.x = dir.x * 50
	dir.z = dir.z * 50
	-- knock enemey back the way he came
	intruder:Knockback{vector = dir}
	-- clear the player off the enemies threat list so it wont just keep running into the shield
	intruder:ClearThreatList()
end

--------------------------------------------------------------
-- when the shield smashs, stop the activity timer
--------------------------------------------------------------
function baseDie(self, msg)
    -- clear the timers
    self:ActivityTimerStopAllTimers()
    GAMEOBJ:DeleteObject(GAMEOBJ:GetObjectByID(self:GetVar("Child")))
end

--------------------------------------------------------------
-- while the generator is up, buff the palyer
--------------------------------------------------------------
function buffplayers(self)
	-- get the players in the shield bubble
	local players = self:GetProximityObjects{name = "buffer"}.objects
	--print("there are "..#players.." players in the shield")
	-- parse through all the players
	for k,v in ipairs(players) do
		-- cast the buff skill on the player
		self:CastSkill{skillID = self:GetSkills().skills[1], optionalTargetID = v}
		-- print("buff "..v:GetName().name)
	end
	
end

--------------------------------------------------------------
-- use the activity timer to buff the players
--------------------------------------------------------------
function baseActivityTimerUpdate(self, msg)
    if msg.name == "BuffPlayers" then
		-- run buffplayer function again
		buffplayers(self)
	elseif msg.name == "PlayFX" then
		-- start the generator fx
		self:PlayFXEffect{ name = "generatorOn" , effectType = "generatorOn", effectID = 5351 }	
	end
end			

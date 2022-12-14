--------------------------------------------------------------
-- Server side script on the Blue X's in CP for Mission from NT

-- created by brandi.. 2/10/11
--------------------------------------------------------------

local bombTime = 3.3
local missionID = 1448
local dukeSwordSkill = 1259
local AOESkill = 1258
local FXObject = 13808

----------------------------------------------
-- check to see if the player use the X
----------------------------------------------
function onCheckUseRequirements(self,msg)
	-- get the flag number set in config data on the X thru happy flower
	local myFlag = self:GetVar("flag")
	-- get the player and if they dont really exist, return out of the function
	local player = msg.objIDUser
	if not player:Exists() then return end
	
	-- check to see if the player is on the mission to use the Xs, hasnt used this one before 
	-- and no one else has just used this X
	if not (player:GetMissionState{missionID = missionID}.missionState == 2) or 
				player:GetFlag{iFlagID = myFlag}.bFlag == true or 
				self:GetNetworkVar("XUsed") then
		msg.bCanUse = false  
	end
				
	return msg
end

----------------------------------------------
-- the player uses the X
----------------------------------------------
function onUse(self,msg)
	-- get the player
	local player = msg.user
	
	-- cast the duke sword skill just like the player just used the sword in their backpack 
	player:CastSkill{skillID = dukeSwordSkill}
end

----------------------------------------------
-- the timer is done
----------------------------------------------
function onTimerDone(self,msg)
	local var = split(msg.name, "_") --Spliting the message name back into the timers name and the player's ID
	local player = ''
		
	if var[2] then
		player = GAMEOBJ:GetObjectByID(var[2]) --Resetting the players Object ID into a Variable
	end

	if var[1] == "ImgBeam" then
		-- cast AOE Skill and give credit for the kills to the player who used the X
		if player:Exists() then
			self:CastSkill{skillID = AOESkill, optionalOriginatorID = player}
		else
			self:CastSkill{skillID = AOESkill}
		end
		
		-- get the child fx object that was created, make sure its really there, then kill it
		local child = GAMEOBJ:GetObjectByID(self:GetVar("ChildFX"))
		if not child then return end
		
		child:RequestDie{killType = "VIOLENT"}
		
		-- explode the red X
		self:RequestDie{killerID = self, killType = "VIOLENT"}
	end
end

----------------------------------------------
-- catches when a skill is fired
----------------------------------------------
function onSkillEventFired( self, msg )
	-- compare the skill casts with the Duke skill 
	if msg.wsHandle == "FireDukesStrike" then
		-- mark this X as used so no one else can use it
		self:SetNetworkVar("XUsed",true)
		
		-- get the position and rotation of the X
		local mypos = self:GetPosition().pos
		local myRot = self:GetRotation()
		-- spawn a child fx object
		RESMGR:LoadObject { objectTemplate = FXObject, x= mypos.x, y= mypos.y, z= mypos.z, rw= myRot.w, rx= myRot.x, ry= myRot.y, rz = myRot.z, owner = self } 
		
		-- get the player 
		local player = msg.casterID
		-- set flag
		player:SetFlag{ iFlagID = self:GetVar("flag"), bFlag = true }
		-- tell the client to start the blue flashing fx (this is temporary)
		self:SetNetworkVar("startEffect", true) 
		-- add a timer for how long it takes for the imagination bomb to hit
		GAMEOBJ:GetTimer():AddTimerWithCancel( bombTime, "ImgBeam_"..player:GetID(), self )
	end
end

----------------------------------------------
-- grab the id of the child object when it is loaded
----------------------------------------------
function onChildLoaded(self,msg)
	self:SetVar("ChildFX", msg.childID:GetID())
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



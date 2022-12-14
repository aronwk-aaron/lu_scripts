----------------------------------------
-- Server side script calls in a volley of arrows when the target is completed
--
-- created by brandi... 6/8/11
-- updated by brandi... 7/14/11 - added GUID
----------------------------------------

local arrowFXobject = 15850
local arrowSkill = 1482
local arrowDelay = 6
local arrowsGUID = "{532cba3c-54da-446c-986b-128af9647bdb}"


function onRebuildComplete(self,msg)
	-- get the position and rotation of the X
	local mypos = self:GetPosition().pos
	local myRot = self:GetRotation()
	-- spawn a child fx object
	RESMGR:LoadObject { objectTemplate = arrowFXobject, x= mypos.x, y= mypos.y, z= mypos.z, rw= myRot.w, rx= myRot.x, ry= myRot.y, rz = myRot.z, owner = self } 
	-- get the player 
	local player = msg.userID
	-- start a timer to allow the arrows to come over the wall
	GAMEOBJ:GetTimer():AddTimerWithCancel( arrowDelay, "ArrowsIncoming_"..player:GetID(), self )
	GAMEOBJ:GetTimer():AddTimerWithCancel( arrowDelay - 4, "PlayArrowSound", self )
end

function onChildLoaded(self,msg)
	-- grab the arrows object that spawn so we can use it later
	self:SetVar("ChildFX", msg.childID:GetID())
end

function onTimerDone(self,msg)
	-- get the child fx object that was created, make sure its really there, then kill it
	local child = GAMEOBJ:GetObjectByID(self:GetVar("ChildFX"))
	if not child then return end
	
	local var = split(msg.name, "_") --Spliting the message name back into the timers name and the player's ID
	local player = ''
		
	if var[2] then
		player = GAMEOBJ:GetObjectByID(var[2]) --Resetting the players Object ID into a Variable
	end

	if var[1] == "ArrowsIncoming" then
		
		-- cast AOE Skill and give credit for the kills to the player who built the targe
		if player:Exists() then
			child:CastSkill{skillID = arrowSkill, optionalOriginatorID = player}
		else
			child:CastSkill{skillID = arrowSkill}
		end
		-- add a delay for the arrows to stop following
		GAMEOBJ:GetTimer():AddTimerWithCancel( .7, "FireSkill", self )
	elseif var[1] == "FireSkill" then
		-- kill the arrows fx object
		child:RequestDie{killType = "VIOLENT"}
		
		-- explode the target
		self:RequestDie{killerID = self, killType = "VIOLENT"}
	elseif var[1] == "PlayArrowSound" then
		self:PlayNDAudioEmitter{m_NDAudioEventGUID = arrowsGUID}	
	end
end


function split(str, pat)
    local t = {}
    -- Creates a table of strings based on the passed in pattern   
    string.gsub(str .. pat, "(.-)" .. pat, function(result) table.insert(t, result) end)

    return t
end

--------------------------------------------------------------
-- script on the wandering vendor in Aura mar
-- as of 10/19/10 this script is generic enough to use on any pathing object that you want to stop pathing on player proximity

-- created by brandi 10/19/10
-- Modified by MEdwards 1/6/11 -- set a delay to the continue following waypoints so the animation can play.
-- updated by brandi 1/13/11 - increased a timer and added a cancel timer.
--------------------------------------------------------------

function onStartup(self)
	-- allows the npc to path (dont ask me why, just have to have it)
    self:SetVar("Set.SuspendLuaMovementAI", true)   
	-- set the proximity on the vendor. make sure this number is larger than the interact distance in HF
	-- collision group one tells the proximity radius only to notify on players
    self:SetProximityRadius{radius = 10, collisionGroup = 1}
end 

function onProximityUpdate(self,msg)
	-- someone entered the vendors bubble
    if msg.status == "ENTER" then
		-- get the intruder
        local player = msg.objId
		-- does the intruder really exist?
        if player:Exists() then 
			-- its a player, stop moving so he can talk to you
			self:StopPathing{}
			GAMEOBJ:GetTimer():CancelTimer("startWalking", self)
        end
	-- someone left the vendors bubble
    elseif msg.status == "LEAVE" then
		-- get all objects still in the vendors bubble
		local proxObjs = self:GetProximityObjects().objects	
		-- check to see if there were objects in the bubble
		if #proxObjs > 0 then   
			--if it finds anything return out of the function
			return
		end
		-- if no player was found in the vendors bubble, tell the vendor to continue on his way
        GAMEOBJ:GetTimer():AddTimerWithCancel( 1.5 , "startWalking", self )       
        --self:FollowWaypoints()
   end
end

function onTimerDone(self, msg)
    if msg.name == "startWalking" then
        self:FollowWaypoints()
    end  
end

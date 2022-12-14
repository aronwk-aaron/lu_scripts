--------------------------------------------------------------
-- Server side Script on the console that controls the bridge in aura mar

-- created by brandi... 10/7/10
-- updated by brandi... 11/19/10 - changed setvar inuse to setnetworkvar
-- updated brandi... 11/29/10 - added check use requirements for popups of why the player cant interact
-- updated by brandi... 1/18/11 - added calls to client script to play audio
--------------------------------------------------------------

----------------------------------------------
-- make sure console is set to not be in use
----------------------------------------------
function onStartup(self,msg)
	-- the console in not in use
	self:SetNetworkVar("InUse", false)
	-- set the bridge to not be down because it builds in the up position
	self:SetVar("BridgeDown",false)
end

----------------------------------------------
-- check to see if the player can use the console
----------------------------------------------
function onCheckUseRequirements(self,msg)
	-- custom function to get the bridge that goes with that console
	local bridge = GetBridge(self)
	-- if no bridge is found, return out of the script
	if not bridge then return end
	
	-- cant use the console if the bridge isnt built or the console is already being used
	if bridge:GetRebuildState{}.iState == 0 or self:GetNetworkVar("InUse") then
		msg.bCanUse = false  
	end
				
	return msg
end


----------------------------------------------
-- when the player uses the console
----------------------------------------------
function onUse(self,msg)
	-- custom function to get the bridge that goes with that console
	local bridge = GetBridge(self)
	-- if no bridge is found, return out of the script
	if not bridge then return end
	
	-- make sure the bridge is not currently in use
	if not self:GetNetworkVar("InUse") then
		-- tell the client to start the blue flash effect
		self:SetNetworkVar("startEffect", 5)
		-- add a timer to actually raise or lower the bridge
		GAMEOBJ:GetTimer():AddTimerWithCancel( 5, "ChangeBridge", self )
		-- set the console to be in use
		self:SetNetworkVar("InUse", true)
	end
	
	-- terminate the interaction of the player who interacted with the bridge
	local player = msg.user
	if player:Exists() then
	    player:TerminateInteraction{type = 'fromInteraction', ObjIDTerminator = self} 
    end
end

----------------------------------------------
-- when the bridge dies, the console is no longer being used
----------------------------------------------
function notifyDie(self,other,msg)
	self:SetNetworkVar("InUse", false)
	self:SetVar("BridgeDown",false)
	GAMEOBJ:GetTimer():CancelAllTimers( self )
	--self:SendLuaNotificationCancel{requestTarget= other, messageName="ArrivedAtDesiredWaypoint"}
	self:SendLuaNotificationCancel{requestTarget= other, messageName="Die"}
	
end

----------------------------------------------
-- when the bridge dies, the console is no longer being used
----------------------------------------------
function onNotifyObject( self, msg )
    -- if the rebuild is complete
	if ( msg.name == "BridgeBuilt" ) then
		GAMEOBJ:GetTimer():AddTimerWithCancel( 45, "SmashEffectBridge", self )
		self:SetNetworkVar("BridgeDead", true)
		-- custom function to get the bridge that goes with that console
		local bridge = GetBridge(self)
		-- if no bridge is found, return out of the script
		if not bridge then return end
		-- tell the bridge to let the script know when it dies
		self:SendLuaNotificationRequest{requestTarget = bridge, messageName = "Die"}
		
		-- tell the bridge to tell the console script when it reached its last way point
		--self:SendLuaNotificationRequest{requestTarget = bridge, messageName = "ArrivedAtDesiredWaypoint"}
	end
end

----------------------------------------------
-- when the bridge arrives at the last waypoint
----------------------------------------------
--function notifyArrivedAtDesiredWaypoint(self,other,msg)
--	-- if the way point that it arrived at is the first one or the last one, then tell the client, so it can play the correct audio
--    if msg.iPathIndex == 9 or msg.iPathIndex == 0 then
--		self:SetNetworkVar("BridgeLeaving",false)
--	end
--end

function MoveBridgeDown(self,bridge,down)
	local forwardVect = bridge:GetObjectDirectionVectors().forward
	
	local degrees = 90
	
	if not down then
		degrees = -90
	end
	
	local travelTime = 2
	
	forwardVect.x = forwardVect.x * math.rad(degrees / travelTime)
	forwardVect.y = forwardVect.y * math.rad(degrees / travelTime)
	forwardVect.z = forwardVect.z * math.rad(degrees / travelTime)
	bridge:SetAngularVelocity{angVelocity = forwardVect, bIgnoreDirtyFlags = false}
	
	GAMEOBJ:GetTimer():AddTimerWithCancel( travelTime, "rotateBridgeDown", self )
end

----------------------------------------------
-- timers on the console
----------------------------------------------
function onTimerDone(self,msg)
	-- timer for the bridge to either raise or lower
	if msg.name == "ChangeBridge" then
		-- custom function to get the bridge that goes with that console
		local bridge = GetBridge(self)
		-- if no bridge is found, return out of the script
		if not bridge then return end
		
		-- if the bridge is not down, lower it, otherwise, raise it
		if not self:GetVar("BridgeDown") then
			-- move the way point to the down position, and mark the console as in use 
			--bridge:GoToWaypoint{iPathIndex = 9, bAllowPathingDirectionChange = true} 
			self:SetVar("BridgeDown",true)
			
			MoveBridgeDown(self,bridge,true)

		else
			-- move the way point to the down position, and mark the console as in use 
			--bridge:GoToWaypoint{iPathIndex = 0, bAllowPathingDirectionChange = true}
			self:SetVar("BridgeDown",false)	
			
			MoveBridgeDown(self,bridge,false)
		end
		
		-- tell the client script the bridge is lowering to play audio and turn the blue flashing off
		self:SetNetworkVar("BridgeLeaving",true)
		-- tell the everyone the console is no longer in use
		self:SetNetworkVar("InUse", false)
	
	--the bridge is about to die, tell the client to start the smash effect
	elseif msg.name == "SmashEffectBridge" then
		self:SetNetworkVar("SmashBridge", 5)
	elseif msg.name == "rotateBridgeDown" then
		
		-- custom function to get the bridge that goes with that console
		local bridge = GetBridge(self)
		-- if no bridge is found, return out of the script
		if not bridge then return end
		
		self:SetNetworkVar("BridgeLeaving",false)
	
		bridge:SetAngularVelocity{angVelocity = {x = 0, y = 0, z = 0  }, bIgnoreDirtyFlags = false}
		
	end
end

----------------------------------------------
-- custom function to get the bridge associated with this console
----------------------------------------------
function GetBridge(self,msg)
	-- get the config data set on the asset in hf
	local console = self:GetVar("bridge")
	
	if not console then return end
	
	-- get all the items in the bridge group
	local bridge = self:GetObjectsInGroup{ group = "Bridge", ignoreSpawners = true }.objects
	
	-- error check to see if there are briges
	if bridge then
		-- parse through all bridges spawned
		for k,v in ipairs(bridge) do
			-- see if they are built and if their location matches that of the console
			if v:Exists() and v:GetVar("bridge") == console then
				-- see if they are built and if their location matches that of the console
				return v
			end
		end
	end
end
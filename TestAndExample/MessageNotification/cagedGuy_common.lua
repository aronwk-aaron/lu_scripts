require('TestAndExample/MessageNotification/notificationDemoHelpers')

function onStartup(self)
	GAMEOBJ:GetTimer():AddTimerWithCancel(8, "delayedStartup", self)
end

function onDelayedStartup(self)
	local cage = self:GetObjectsInGroup{group = "cage", ignoreSpawners = true}.objects[1]
	local bridge = self:GetObjectsInGroup{group = "bridge", ignoreSpawners = true}.objects[1]
	local bbq = self:GetObjectsInGroup{group = "bbq", ignoreSpawners = true}.objects[1]
	
	storeObjectByName(self,"cage",cage)
	storeObjectByName(self,"bridge",bridge)
	storeObjectByName(self,"bbq",bbq)

	self:SendLuaNotificationRequest{requestTarget=cage, messageName="Die"}
	self:SendLuaNotificationRequest{requestTarget=bridge, messageName="RebuildNotifyState"}
	self:SendLuaNotificationRequest{requestTarget=bbq, messageName="RebuildNotifyState"}
	
	if( onStartupComplete ) then onStartupComplete(self) end
end

function notifyDie(self,other,msg)
	local cage = getObjectByName(self,"cage")
	if( other:GetID() == cage:GetID() ) then
		self:SendLuaNotificationCancel{requestTarget=cage, messageName="Die"}
		onCageDied(self,msg.killerID)
	end
end

function notifyRebuildNotifyState(self,other,msg)
	-- note: rebuild state 2 is REBUILD_STATE_COMPLETED
	if( msg.iState == 2 ) then
		local bridge = getObjectByName(self,"bridge")
		local bbq = getObjectByName(self,"bbq")
		if( other:GetID() == bridge:GetID() ) then
			self:SendLuaNotificationCancel{requestTarget=bridge, messageName="RebuildNotifyState"}
			onBridgeBuilt(self,msg.player)
		elseif( other:GetID() == bbq:GetID() ) then
			self:SendLuaNotificationCancel{requestTarget=bbq, messageName="RebuildNotifyState"}
			onBbqBuilt(self,msg.player)
		end
	end
end

function onTimerDone(self, msg)
	if( msg.name == "delayedStartup" ) then
		onDelayedStartup(self)
	elseif( msg.name == "bbqReact" ) then
		-- server only
		onBbqReact(self)
	end
end

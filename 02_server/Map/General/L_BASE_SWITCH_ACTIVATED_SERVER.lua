----------------------------------------
-- Server side script to be used on objects that need to know when a switch is activated or deactivated
-- this handles all the necessary switch messages
--
-- created by brandi... 6/16/11
----------------------------------------

function onStartup(self)
	switchStartup(self)
end

function switchStartup(self)
	local mySwitch = self:GetVar("switchGroup")

	if not mySwitch then return end

	local objs = self:GetObjectsInGroup{group = mySwitch, ignoreSpawners = true, ignoreSelf = true}.objects

    if ( table.maxn(objs) > 0 ) then 
        for k,v in ipairs(objs) do

            if ( v:Exists() ) then
                -- Let switch know we exist in case we loaded after it
                v:NotifyObject{name = "objectAdded", ObjIDSender = self}
                self:SetVar("activationRequested", true)
                self:SendLuaNotificationRequest{requestTarget = v, messageName="ObjectActivated"}                
            end
        end
    end
end

function onNotifyObject(self,msg)
	switchNotifyObject(self,msg)
end

-- the switch tells all the objects listed in its notify group set on the switch in HF that it loaded in
function switchNotifyObject(self,msg)
	-- which the switch is loaded in, ask it to tell the script when it is activated
	if msg.name == "objectTypeLoaded" and not self:GetVar("activationRequested") then
		self:SendLuaNotificationRequest{requestTarget = msg.ObjIDSender , messageName="ObjectActivated"}
	end
end

function notifyObjectActivated(self,button,msg)
	switchNotifyObjectActivated(self,button,msg)
end

-- the switch notified us that it was activated
function switchNotifyObjectActivated(self,button,msg)
	-- make sure it was a valid notification
	if not msg.objectActivatedID:Exists() then return end
	-- cancel the request for activation
	self:SendLuaNotificationCancel{requestTarget = button  , messageName="ObjectActivated"}
	-- send a request for deactivation
	self:SendLuaNotificationRequest{requestTarget = button  , messageName="ObjectDeactivated"}
end

function notifyObjectDeactivated(self,button,msg)
	switchNotifyObjectDeactivated(self,button,msg)
end

-- the switch notified us that it was deactivated
function switchNotifyObjectDeactivated(self,button,msg)
	-- make sure it was a valid notification
	if not msg.objectActivatedID:Exists() then return end
	-- cancel the request for deactivation
	self:SendLuaNotificationCancel{requestTarget = button  , messageName="ObjectDeactivated"}
	-- send a request for activation
	self:SendLuaNotificationRequest{requestTarget = button  , messageName="ObjectActivated"}
end
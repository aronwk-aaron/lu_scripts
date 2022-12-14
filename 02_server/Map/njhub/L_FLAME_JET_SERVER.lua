----------------------------------------
-- Server side script on the flame jets in the fire attic of the monastery
--
-- created by brandi... 6/16/11
----------------------------------------

require('02_server/Map/General/L_BASE_SWITCH_ACTIVATED_SERVER')

-- set that the flame is on 
function onStartup(self,msg)

	switchStartup(self)

	if self:GetVar("NotActive") then return end

    self:SetNetworkVar("FlameOn",true)
end

function onNotifyObject(self,msg)
	switchNotifyObject(self,msg)
end

-- when a player collides
function onCollisionPhantom(self,msg)
	-- check to see if the flame is on
	if not self:GetNetworkVar("FlameOn") then return end
	-- get the player
	local player = msg.senderID 
	-- castskill on player
	self:CastSkill{skillID = 726, optionalTargetID = player}
	-- get the direction that is player is traveling
	local dir = player:GetForwardVector().niForwardVector
	-- adjust the velocity and reverse it to push them backwards
	dir.y = 25
	dir.x = -dir.x * 15
	dir.z = -dir.z * 15
		
	-- send the player backwards
	player:Knockback{vector = dir}
end

function notifyObjectActivated(self,button,msg)
	switchNotifyObjectActivated(self,button,msg)
	-- turn the flame off when a player is on the button
	self:SetNetworkVar("FlameOn",false)
end

function notifyObjectDeactivated(self,button,msg)
	switchNotifyObjectDeactivated(self,button,msg)
	-- turn the flame on when no players are on the button
	self:SetNetworkVar("FlameOn",true)
end

-- to work with spinners
function onFireEvent(self,msg)
    if msg.args == self:GetVar("name_deactivated_event") then
                    self:SetNetworkVar("FlameOn",false)
    elseif msg.args == self:GetVar("name_activated_event") then
                    self:SetNetworkVar("FlameOn",true)
    end
end

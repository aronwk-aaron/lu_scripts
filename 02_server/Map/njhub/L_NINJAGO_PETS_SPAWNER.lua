--------------------------------------------------------------
-- Server side script on the object to spawn the lion pet
-- lion has to be spawned for a server side script because the lion is a pet to be tamed
-- pet taming minigame runs on the server as well as the client

-- created by Brandi... 2/17/10
--------------------------------------------------------------

require('02_server/Map/General/L_SPAWN_PET_BASE_SERVER')

function onUse(self,msg)
	TalkToOtherStatue(self,msg)
	baseUse(self,msg)
end



--------------------------------------------------------------
-- when a pet has loaded into the world, call custom function to talk to the client
--------------------------------------------------------------
function onChildLoaded(self,msg)
	baseChildLoaded(self,msg)
	TalkToClient(self:GetVar("otherStatue"),msg,true,1)
end

--------------------------------------------------------------
-- when a pet has left the world, call custom function to talk to the client
--------------------------------------------------------------
function onChildRemoved(self,msg)
	baseChildRemoved(self,msg)
	TalkToClient(self:GetVar("otherStatue"),msg,false,-1)
end

--------------------------------------------------------------
-- when a pet has been tamed, call custom function to talk to the client
--------------------------------------------------------------
function onChildDetached(self,msg)
	baseChildDetached(self,msg)
	TalkToClient(self:GetVar("otherStatue"),msg,false,-1)
end

--------------------------------------------------------------
-- get the other statue,so we can interact and not interac with it
--------------------------------------------------------------
function TalkToOtherStatue(self,msg)

	if self:GetVar("otherStatue") then return end
	
	local group = string.sub(self:GetVar("groupID"),1,-2)
	local otherStatue = self:GetObjectsInGroup{ group = group, ignoreSpawners = true, ignoreSelf = true }.objects
	
	if not otherStatue then return end
	
	for k,v in ipairs(otherStatue) do
		if v:Exists() then
			otherStatue = v
			break
		end
	end
	
	self:SetVar("otherStatue",otherStatue)
end
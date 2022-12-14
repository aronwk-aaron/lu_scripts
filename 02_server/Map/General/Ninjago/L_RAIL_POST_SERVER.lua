----------------------------------------
-- server side script on rail posts for ninjago rails
--
-- created by brandi... 6/14/11
---------------------------------------------

---------------------------------------------
-- to set up in HF if this is a quickbuild end post for a rail and you want to tell a start rail that you were built and died
-- put the start rail to connected to this end rail in a group, it should be the only thing in the group
-- add this config data to the start rail
-- 		NotActive 7:1  (this sets a bool to true)
-- add this config data to the end rail that is a quickbuild
-- 		RailGroup 0:name of the group you put the start rail in
---------------------------------------------

function onStartup(self)
	
	-- if its a quick build, it isnt active until the post is built
	if self:HasComponentType{iComponent = 48}.bHasComponent then
	
		-- not active, the end rail post should no be interactive and should not play fx
		self:SetNetworkVar("NetworkNotActive",true)

	end
	
end
-- the start rail server script notified that it was rebuilt or it died
function onNotifyObject(self,msg)
	if msg.name == "PostRebuilt" then
		-- not not active, the end rail should become active and play fx
		self:SetNetworkVar("NetworkNotActive",false)
	elseif msg.name == "PostDied" then
		-- not active, the end rail post should no be interactive and should not play fx
		self:SetNetworkVar("NetworkNotActive",true)
	end
end

function onRebuildNotifyState(self,msg)
 	if msg.iState == 2 then
		-- find the end rail and tell it we got rebuilt
		local myEndRail = GetRail(self,msg)
		if not myEndRail then return end
		myEndRail:NotifyObject{ name = "PostRebuilt" }
		
		if self:GetVar("NotActive") then return end
		
		-- not not active, the end rail should become active and play fx
		self:SetNetworkVar("NetworkNotActive",false)
	elseif msg.iState == 4 then
		-- find the end rail, and tell it we died
		local myEndRail = GetRail(self,msg)
		if not myEndRail then return end
		myEndRail:NotifyObject{ name = "PostDied" }
	end
end

-- custom function
function GetRail(self,msg)
	-- check to see if the start rail has config data with the group name of the end rail
	if self:GetVar("RailGroup") then
		-- get all objects in the end rail group (there should only be one)
		local rail = self:GetObjectsInGroup{ group = self:GetVar("RailGroup"), ignoreSpawners = true }.objects
		-- make sure it returned a valid table and parse through it
		if table.maxn(rail) > 0 then
			for k,v in ipairs(rail) do
				-- found an endrail, verify it and return to back to the function that called this one
				if v:Exists() then
					return v
				end
			end
		end
	end
end
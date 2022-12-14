----------------------------------------
-- Server side script on the the manager for the moving platform rocks in the fire transition
--
-- created by brandi... 6/16/11
----------------------------------------
local rockGroupDefault = "FireTransRocks"
local numOfRocksDefault = 3

function onStartup(self,msg)

	GAMEOBJ:GetTimer():AddTimerWithCancel(5, "check", self)
	--print("in on startup")
	if not self:GetVar("RockGroup") then
		self:SetVar("RockGroup",rockGroupDefault)
	end
	
	if not self:GetVar("NumberOfRocks") then
		self:SetVar("NumberOfRocks",numOfRocksDefault)
	end
	
end

function CheckForRocks(self,msg)
	-- get all the moving rocks
	
	local rocks = self:GetObjectsInGroup{ group = self:GetVar("RockGroup"), ignoreSpawners = true }.objects
	local platforms = 0
	-- parse through them and make sure they are valid rocks, if so add to a tally
	for k,v in ipairs(rocks) do
		if v:Exists() then
			platforms = platforms + 1
		end
	end
	
	-- if there arent there rocks yet, start a heart beat timer for to check again
	if platforms < self:GetVar("NumberOfRocks") then
		GAMEOBJ:GetTimer():AddTimerWithCancel(1, "check", self)
		return
	end
	
	GAMEOBJ:GetTimer():AddTimerWithCancel(5, "StartPlatforms", self)
	--print("more than 3 and we have "..platforms)
	-- found all three rocks. Start them pathing

end


-- the rocks all tell the manager when they are back at their down waypoint
function onNotifyObject(self,msg)
	if msg.name == "PlatformDown" then
		-- get the table of rocks, or create a new one
		local platTable = self:GetVar("PlatTable") or {}
		-- parse through the table and make sure the rock isnt already in it
		for k,v in ipairs(platTable) do
			if v == msg.ObjIDSender:GetID() then
				return
			end
		end
		-- rock isnt in the table already, add it it
		table.insert(platTable,msg.ObjIDSender:GetID())
		-- if there arent 3 rocks set, set the table to a set var
		if table.maxn(platTable) < self:GetVar("NumberOfRocks") then 
			self:SetVar("PlatTable",platTable)
			return
		end
		-- got all three rocks, make a timer to start them pathing again
		GAMEOBJ:GetTimer():AddTimerWithCancel(1, "restartPlatforms", self)
	end
end


function onTimerDone(self,msg)
	if msg.name ==  "check" then
		-- still looking for rocks, run startup again
		CheckForRocks(self,msg)
	elseif msg.name == "StartPlatforms" then
		local rocks = self:GetObjectsInGroup{ group = self:GetVar("RockGroup"), ignoreSpawners = true }.objects

		for k,plat in ipairs(rocks) do
		if plat:Exists() then
			plat:GoToWaypoint{iPathIndex = 1}
		end
	end
	elseif msg.name == "restartPlatforms" then
		-- clear out the rocks table
		self:SetVar("PlatTable",{})
		--get all the rocks
		local rocks = self:GetObjectsInGroup{ group = self:GetVar("RockGroup"), ignoreSpawners = true }.objects
		-- send the rocks to up again
		for k,plat in ipairs(rocks) do
			if plat:Exists() then
				plat:GoToWaypoint{iPathIndex = 1}
			end
		end
	end
end
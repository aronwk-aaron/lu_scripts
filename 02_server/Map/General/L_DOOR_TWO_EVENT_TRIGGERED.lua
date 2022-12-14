---------------------------------------------
-- Script for doors that take 2 events to open
--
-- created by mrb... 11/30/10
---------------------------------------------

function onStartup(self)
	-- stop the mover
	self:StopPathing()
end

function onFireEvent(self,msg)
	-- if the door is open then return out of the function
	if self:GetVar("door_open") then return end
	
	--print(msg.args)		
	
	-- get the event number and set the open var based on the event
	if string.starts(msg.args, "open") then
		local eventNum = string.sub(msg.args, -1)
		
		self:SetVar("open".. eventNum, true)		
		
		-- check to see if both are triggered
		checkDoors(self)
	elseif string.starts(msg.args, "close") then
		local eventNum = string.sub(msg.args, -1)
		
		self:SetVar("open".. eventNum, false)	
	end
end 

function checkDoors(self)
	-- if both var's are true then open the door and set the door_open var
	if self:GetVar("open1") and self:GetVar("open2") then
		self:SetVar("door_open", true)
		self:StartPathing()
	end
end

function string.starts(String,Start)
    -- finds if a string starts with a giving string.
   return string.sub(String,1,string.len(Start))==Start
end 
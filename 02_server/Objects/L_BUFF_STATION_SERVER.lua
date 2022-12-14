----------------------------------------
-- Server side Buff station script
--
-- updated mrb... 11/4/10 - cleaned up script
----------------------------------------
local DieTime = 25
local DropLifeTime = 3
local DropArmorTime = 6
local DropImagTime = 4

--------------------------------------------------------------------------------
-- onRebuildNotifyState
-- 
-- Notes: Whenever the rebuild state changes Update
--------------------------------------------------------------------------------
function onRebuildNotifyState(self, msg)    
	if (msg.iState == 2) then	-- RebuildStateCompleted state = 2
		-- Set to Darkling hated smashable faction Using PLAYER faction for now.
	    self:SetFaction{ faction = 1 }
		-----------------------------------------
        self:ActivityTimerSet{name = "DieTime", duration = DieTime}
        self:ActivityTimerSet{name = "DropLifeTime", updateInterval = DropLifeTime}
        self:ActivityTimerSet{name = "DropArmorTime", updateInterval = DropArmorTime}
        self:ActivityTimerSet{name = "DropImagTime", updateInterval = DropImagTime}
	end	
end

function onRebuildStart(self, msg)
   self:SetVar("iplayer", msg.userID:GetID())
end

-------------------------
-- Check if the timer for self death is done.
-------------------------
function onActivityTimerUpdate(self, msg)
	local playerID = self:GetVar("iplayer")
	
	if not playerID then return end 
	
	local player = GAMEOBJ:GetObjectByID(playerID)
	local objLOT = 177 -- LIFE powerup
	
	if msg.name == "DropArmorTime" then
		objLOT = 6431 -- ARMOR powerup
    elseif msg.name == "DropImagTime" then
		objLOT = 935 -- IMAG powerup
	end
	
		
	self:DropItems{itemTemplate = objLOT, owner = player, iAmount = 1, sourceObj = self, bUseTeam = true}
end

function onActivityTimerDone(self, msg)
    if msg.name == "DieTime" then
		self:ActivityTimerStopAllTimers()
		self:Die()         
    end
end 
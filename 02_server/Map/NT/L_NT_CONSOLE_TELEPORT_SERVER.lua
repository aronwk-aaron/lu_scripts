--------------------------------------------------------------

-- L_NT_CONSOLE_TELEPORT_SERVER.lua

-- Server Script for the a Teleport Console interact
-- Destination = Crux Prime
-- Updated mrb... 4/4/11		-- Generalized teleporter script

--------------------------------------------------------------
require('02_server/Map/General/L_BASE_CONSOLE_TELEPORT_SERVER')

local teleportAnim = "lup-teleport"				-- Teleportation animation intro sequence name

-----------------------------------------------
-- ** uncomment these if you want to play extra fx durning the transfer **
--local teleportEffectID = 6478										-- behaviorEfffectID for the teleportEffectTypes table below
--local teleportEffectTypes = {"teleportRings", "teleportBeam"} 	-- FX to play before transfering the player, you can have as many fx play as you want by adding them to the table. They must all be in the same behaviorEffectID though.
-----------------------------------------------

local teleportString = "UI_TRAVEL_TO_CRUX_PRIME" -- Localized string token for teleport confirmation

----------------------------------------------
-- Adjust the interact display icon on set-up
----------------------------------------------
function onStartup(self,msg)
	-- Set Console Variables
	self:SetVar("teleportAnim", teleportAnim)
	self:SetVar("teleportEffectTypes", teleportEffectTypes)
	self:SetVar("teleportEffectID", teleportEffectID)
	self:SetVar("teleportString", teleportString)
end

----------------------------------------------
-- Check to see if the player can use the console
----------------------------------------------
function onCheckUseRequirements(self, msg)
	baseCheckUseRequirements(self, msg)
	
	return msg
end

----------------------------------------------
-- When the player interacts with the console
----------------------------------------------
function onUse(self,msg)
	baseUse(self, msg)
end

----------------------------------------------
-- When the player interacts with the UI confirmation widget
----------------------------------------------
function onMessageBoxRespond(self, msg)
	baseMessageBoxRespond(self, msg)
end

----------------------------------------------
-- Manages teleportation state transitions
----------------------------------------------
function onTimerDone(self, msg)
	baseTimerDone(self, msg)
end 
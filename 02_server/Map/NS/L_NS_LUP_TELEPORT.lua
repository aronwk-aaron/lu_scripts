--------------------------------------------------------------
-- Transfers player to Lup world or transferZoneID
--
-- updated mrb... 4/18/11 - updated to use base script and new functionality
--------------------------------------------------------------
require('02_server/Map/General/L_BASE_CONSOLE_TELEPORT_SERVER')
require('02_server/Map/General/L_CHOOSE_YOUR_DESTINATION_NS_TO_NT')

local teleportAnim = "lup-teleport"				-- Teleportation animation intro sequence name
local spawnPoint = "NS_LW"						-- what respawn point to put the player in the new map
local choiceZoneID = 1600

-----------------------------------------------
-- ** uncomment these if you want to play extra fx durning the transfer **
--local teleportEffectID = 6478										-- behaviorEfffectID for the teleportEffectTypes table below
--local teleportEffectTypes = {"teleportRings", "teleportBeam"} 	-- FX to play before transfering the player, you can have as many fx play as you want by adding them to the table. They must all be in the same behaviorEffectID though.
-----------------------------------------------

local teleportString = "UI_TRAVEL_TO_LUP_STATION" -- Localized string token for teleport confirmation

-- choicebox Options, these hae to be in this format
local choiceOptions = { {0,{
							{"image", "textures/ui/zone_thumnails/Nimbus_Station.dds"}, 
							{"caption", "%[UI_CHOICE_NS]"}, -- "%[LOC_STRING]" is the format for sending localization tokens to the choice box
							{"identifier", "zoneID_1200"}, 
							{"tooltipText", "%[UI_CHOICE_NS_HOVER]"} 
						}},
						{1,{
							{"image", "textures/ui/zone_thumnails/Nexus_Tower.dds"}, 
							{"caption", "%[UI_CHOICE_NT]"}, 
							{"identifier", "zoneID_1900"}, 
							{"tooltipText", "%[UI_CHOICE_NT_HOVER]"} 
						} } }

----------------------------------------------
-- Adjust the interact display icon on set-up
----------------------------------------------
function onStartup(self,msg)
    self:SetVar("currentZone", LEVEL:GetCurrentZoneID())
    self:SetVar("choiceZone", choiceZoneID)
	-- Set Console Variables
	self:SetVar("teleportAnim", teleportAnim)
	self:SetVar("teleportEffectTypes", teleportEffectTypes)
	self:SetVar("teleportEffectID", teleportEffectID)
	self:SetVar("teleportString", teleportString)
	self:SetVar("spawnPoint", spawnPoint)
end

----------------------------------------------
-- Check to see if the player can use the console
----------------------------------------------
function onCheckUseRequirements(self, msg)	
	return baseCheckUseRequirements(self, msg)
end

----------------------------------------------
-- When the player interacts with the console
----------------------------------------------
function onUse(self, msg)
    local player = msg.user    
    
    if not player:Exists() then return end
    	
	-- if we are in LUP station so we can open the choice box
    if CheckChoice(self, player) then
		local multiArgs = { {"callbackClient", self}, 
							{"strIdentifier", "choiceDoor"}, 
							{"title", "%[UI_CHOICE_DESTINATION]"}, 
							{"options", choiceOptions} }				
								 
		player:UIMessageServerToSingleClient{ strMessageName = "QueueChoiceBox", args = multiArgs}
    else	
		-- do baseUse
		baseUse(self, msg)
	end
end

----------------------------------------------
-- When the player interacts with the UI confirmation widget
----------------------------------------------
function onMessageBoxRespond(self, msg)       
    baseMessageBoxRespond(self, msg)
end 

function onChoiceBoxRespond(self, msg)
	baseChoiceBoxRespond(self, msg)
end 

----------------------------------------------
-- Manages teleportation state transitions
----------------------------------------------
function onTimerDone(self, msg)
	baseTimerDone(self, msg)
end 
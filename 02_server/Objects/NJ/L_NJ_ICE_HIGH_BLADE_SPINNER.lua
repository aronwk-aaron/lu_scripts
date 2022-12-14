----------------------------------------
-- template script on the ninjago spinner
-- Generic Server Spinner Traps
--
-- created by mrb... 6/15/11 
---------------------------------------------
require('02_server/Objects/NJ/L_NJ_SPINNER_SERVER')

---------------------------------------------
-- config data variables for HF; defaults listed. ** if nothing is set the spinner defaults to a toggle elevator spinner **
-- type -> 0:elevator 					-- other types; blade, arrow 
-- spin_distance -> 1:3.5				-- setting this will change the distance the player has to be from the object to cast the skill
-- damage_radius -> 1:7					-- this changes the radius of the damage proximity 
-- damage_height -> 1:-4				-- this changes the height of the damage proximity, it's negative cause the pivot point of these objects are at the top of the object
-- skill_pulse_time -> 1:1				-- this is how long to wait to pulse a skill
-- reset_time -> 1:0 					-- this is how long to wait before putting the spinner back to it's initial state, 0 means the spinner toggles on skill cast with no reset time
-- once_only -> 7:1 					-- if this is set it will move once and lock in place and will never be able to be triggered again
-- static -> 7:0						-- if this is set to 1 then the spinner will be locked in it's starting position unless triggered from an event
-- element_type -> 0:imagination		-- other types; fire, earth, ice, lighting, collision, imagination
-- spawner_network -> 0:networkName		-- spawner network to activate/deactivate with the spinner.

--- cinematics
-- on_cinematic -> 0:spinner1on			-- animation to play when the spinner is put into the active state
-- off_cinematic -> 0:spinner1off		-- animation to play when the spinner is put into the inactive state

--- fire events
-- name_activated_event --> 0:event1	-- event name to fire when the spinner is put into the active state
-- group_activated_event --> 0:group1	-- group name to fire the on_event_name to, this has to be set to fire the on event
-- name_deactivated_event --> 0:event2	-- event name to fire when the spinner is put into the inactive state
-- group_deactivated_event --> 0:group1	-- group name to fire the off_event_name to, this has to be set to fire the off event

--- types of events: this is set on the object configData in HF for the receiving the event. 
----
-- FORMAT: this is for the name_activated_event sent to the group_activated_event from above
-- event1 --> 0:activate
----
-- activate			-- use this variable name to put the spinner into the active state
-- deactivate		-- use this variable name to put the spinner into the inactive state
-- toggle_active	-- use this variable name to put the spinner into it's other active state
-- interact			-- use this variable name to put the spinner into the interactive state
-- noninteract		-- use this variable name to put the spinner into the noninactive state
-- toggle_interact	-- use this variable name to put the spinner into it's other interactive state
---------------------------------------------

-----------------------------------------------
---- default variables incase there is no HF configdata; defaults listed
--local defaultSpinDistance = 3.5		-- config data variable = spin_distance -> 1:3.5 
--local defaultDamageRadius = 10		-- config data variable = damage_radius -> 1:10 
--local defaultDamageHeight = -4		-- config data variable = damage_height -> 1:-4 
--local defaultPulseTime = 1			-- config data variable = skill_pulse_time -> 1:1 
--local defaultResetTime = 0			-- config data variable = reset_time -> 1:1 
---- animations on use
--local startAnim = "spinjitzu-staff-windup"
--local runAnim = "spinjitzu-staff-loop"
--local endAnim = "spinjitzu-staff-end"
-----------------------------------------------

local defaultType = "blade"					-- other types; blade, elevator, arrow
local defaultElement_type = "ice"	-- other types; fire, earth, ice, lighting, collision, imagination
local defaultDamageHeight = -10				-- config data variable = damage_height -> 1:-4 
-- audio GUIDs
local audioDefaultMovementBeginGUID = "{5c30c263-00ae-42a2-80a3-2ae33c8f13fe}"
local audioDefaultMovementEndGUID   = "{40e86d71-084c-4149-884e-ab9b45b694dc}"
local audioDefaultMovementGUID      = "{ab21b048-5d1a-40b3-9203-88b376f92087}"
local audioDefaultSpinningGUID      = "{b1bbe65e-330d-4ef6-a534-63e98dd199ec}"

function onStartup(self, msg)
	if not self:GetVar("type") then
		self:SetVar("type", defaultType)
	end
	if not self:GetVar("element_type") then
		self:SetVar("element_type", defaultElement_type)
	end
	if not self:GetVar("damage_height") then
		self:SetVar("damage_height", defaultDamageHeight)
	end
	if not self:GetVar("audioMovementBeginGUID") then
		self:SetVar("audioMovementBeginGUID", audioDefaultMovementBeginGUID)
	end
	if not self:GetVar("audioMovementEndGUID") then
		self:SetVar("audioMovementEndGUID", audioDefaultMovementEndGUID)
	end
	if not self:GetVar("audioMovementGUID") then
		self:SetVar("audioMovementGUID", audioDefaultMovementGUID)
	end
	if not self:GetVar("audioSpinningGUID") then
		self:SetVar("audioSpinningGUID", audioDefaultSpinningGUID)
	end
	
	spinStartup(self, msg)
end 
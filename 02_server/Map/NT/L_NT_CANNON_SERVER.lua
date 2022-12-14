-------------------------------------------------------------------------------------------
--Prototype: Venture Cannon Launcher script
--Server side
--Updated: Raymond Visner 10/19/2010
-------------------------------------------------------------------------------------------

require('o_mis') --added required lua script for Split function

function onStartup(self)
    print("** This a Prototype Script attached to " .. self:GetName().name .. ". **")
    print("** This script needs to be completed by <Ray>. **")
    print("** This file is located at <res/scripts/02_server/map/NT>. **")
end

function onCollisionPhantom(self, msg)
	local player = msg.senderID --find players object ID
	
	if not player:Exists() then   --Checking to see if the player still exists
		return 
	end
	
	local cam = self:GetVar('Cam') -- in Config data set teleporter to Name 0:tele#
	local Wait = 1.85  --Variable for TeleWait1 timer
		
	if player:IsCharacter().isChar then -- make sure its a player and not an NPC, with this line NPCs cannot use the teleporter
		
		player:PlayCinematic{pathName = cam} --Play Cinematic named tele#cam, tele# comes from the config data on the trigger that was set to the variable "tube"

		GAMEOBJ:GetTimer():AddTimerWithCancel(Wait, "TeleWait1_"..player:GetID(), self ) -- setting the timers using the Wait and stun Variables
		GAMEOBJ:GetTimer():AddTimerWithCancel(1.95, "FireEffect_"..player:GetID(), self ) -- setting the timers using the Wait and stun Variables
		GAMEOBJ:GetTimer():AddTimerWithCancel(2.5, "closeCannon_"..player:GetID(), self ) -- setting the timers using the Wait and stun Variables
	end
end
	


function onTimerDone(self, msg)
	
	local var = split(msg.name, "_") --Spliting the message name back into the timers name and the player's ID
	local arch = self:GetVar('Name') --Regeting the Name from the triggers config data
	local player = ''
		
	if var[2] then
		player = GAMEOBJ:GetObjectByID(var[2]) --Resetting the players Object ID into a Variable
	end
	
	if not player:Exists() then   --Checking to see if the player still exists
		return 
	end
		
	if var[1] == "TeleWait1" then  --Checking the split timers name
		local destination = self:GetObjectsInGroup{group = arch.."port", ignoreSpawners = true}.objects[1] -- your destination point should be in a group named tele#port		
		
		if destination then          -- make sure you actually have a port location to avoid errors

			if destination:Exists() then
				local cannon = self:GetObjectsInGroup{group = "cannon", ignoreSpawners = true}.objects[1]
				cannon:NotifyClientObject{name = "OpenCannon", rerouteID = player}
				local tele = destination:GetPosition().pos			-- get the location of your marker
				local telerot = destination:GetRotation()
	
				player:Teleport {pos = {x = tele.x, y = tele.y, z = tele.z}, x = telerot.x, y = telerot.y, z = telerot.z, w = telerot.w, bIgnoreY = false, bSetRotation = true} -- teleport the player to the location of the marker	
				return
			end
		end
		GAMEOBJ:GetTimer():AddTimerWithCancel(1, "Cancel_"..var[2], self )
	elseif var[1] == "closeCannon" then
		local cannon = self:GetObjectsInGroup{group = "cannon", ignoreSpawners = true}.objects[1]
		cannon:NotifyClientObject{name = "CloseCannon", rerouteID = player}
	
	elseif var[1] == "FireEffect" then
		local CannonEffect = self:GetObjectsInGroup{group = "cannonEffect", ignoreSpawners = true}.objects[1]
		CannonEffect:PlayFXEffect{name = "console_sparks", effectType = "create", effectID = 6036}
	end	
end
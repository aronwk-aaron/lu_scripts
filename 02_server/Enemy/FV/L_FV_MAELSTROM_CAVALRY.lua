----------------------------------------
-- Base Server side script for Forbidden Valley Horsemen enemies
--
-- Created by abeechler... 2/3/11 - moved script and updated
----------------------------------------
require('02_server/Enemy/General/L_SUSPEND_LUA_AI')

function onStartup(self)  
   for groupName in string.gmatch(self:GetVar("groupID"), "%w+;") do
      
      --------------------------------------------------------------
      --get the name of the group that the object is in and trim off the ';'s
      --------------------------------------------------------------
      
      groupName = string.sub(groupName, 1, -2)
      local mygroup = self:GetObjectsInGroup{group = groupName, ignoreSpawners = true}.objects
      
      --------------------------------------------------------------
      --for the object in my group with ID 8551, tell it I spawned
      --------------------------------------------------------------
      
      for i, object in ipairs(mygroup) do
         if object and object:GetLOT().objtemplate == 8551 then
   
            object:FireEvent{args = "ISpawned", senderID = self}
            --print("telling the turret I spawned")
         end
      end
   end
end

-- On horseman death
function onDie(self,msg)
	
	-- If Brick Fury killed the horseman
	if msg.killerID:GetLOT().objtemplate == 8665 then
		
		-- Get the mission update volume by group name, tell it Brick fury killed the horseman
		local volume = self:GetObjectsInGroup{group = "HorsemenTrigger", ignoreSpawners = true}.objects[1]
		-- I'm assuming there is only one volume
		if volume then
			volume:FireEvent{senderID = self; args = "HorsemanDeath"}
		end
	end
end

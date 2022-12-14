-------------------------------------------------------------------
--script to have the switches all play nice with each other when multiple people are stepping on them (they activate the same platforms)
-------------------------------------------------------------------

function onStartup(self)
   self:PlayFXEffect{name = "sirenlight_B", effectID = 242, effectType = "orange"}
   --self:SetVar("IAMengaged", false)
   self:SetVar("Switch1IsEngaged", false)
   self:SetVar("Switch3IsEngaged", false)
end

function onNotifyObject(self, msg)
   if msg.name == "Switch1Pressed" then
      self:SetVar("Switch1IsEngaged", true)
   elseif msg.name == "Switch1Depressed" then
      self:SetVar("Switch1IsEngaged", false)
   elseif msg.name == "Switch3Pressed" then
      self:SetVar("Switch3IsEngaged", true)
   elseif msg.name == "Switch3Depressed" then
      self:SetVar("Switch3IsEngaged", false)
   end
end

function onFireEvent(self, msg)
   if msg.args == "down" then
      --self:SetVar("IAMengaged", true)
      local object = self:GetObjectsInGroup{group = "SpiderPitSwitch1", ignoreSpawners = true}.objects[1]
      if object then
         object:NotifyObject{name = "Switch2Pressed", ObjIDSender = self}
      end
      local object = self:GetObjectsInGroup{group = "SpiderPitSwitch3", ignoreSpawners = true}.objects[1]
      if object then
         object:NotifyObject{name = "Switch2Pressed", ObjIDSender = self}
      end
      local object = self:GetObjectsInGroup{group = "PitPlatform1", ignoreSpawners = true}.objects[1]
      if object then
         object:GoToWaypoint{iPathIndex = 1, bAllowPathingDirectionChange = true}
      end
      local object = self:GetObjectsInGroup{group = "PitPlatform2", ignoreSpawners = true}.objects[1]
      if object then
         object:GoToWaypoint{iPathIndex = 1, bAllowPathingDirectionChange = true}
      end
   elseif msg.args == "up" then
      --self:SetVar("IAMengaged", false)
      local object = self:GetObjectsInGroup{group = "SpiderPitSwitch1", ignoreSpawners = true}.objects[1]
      if object then
         object:NotifyObject{name = "Switch2Depressed", ObjIDSender = self}
      end
      local object = self:GetObjectsInGroup{group = "SpiderPitSwitch3", ignoreSpawners = true}.objects[1]
      if object then
         object:NotifyObject{name = "Switch2Depressed", ObjIDSender = self}
      end
      if self:GetVar("Switch1IsEngaged") == false then
         local object = self:GetObjectsInGroup{group = "PitPlatform1", ignoreSpawners = true}.objects[1]
         if object then
            object:GoToWaypoint{iPathIndex = 0, bAllowPathingDirectionChange = true}
         end
      end
      if self:GetVar("Switch3IsEngaged") == false then
         local object = self:GetObjectsInGroup{group = "PitPlatform2", ignoreSpawners = true}.objects[1]
         if object then
            object:GoToWaypoint{iPathIndex = 0, bAllowPathingDirectionChange = true}
         end
      end
   end
end
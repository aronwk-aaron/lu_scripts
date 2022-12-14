require('o_mis')

function onStartup(self)

end

function onUse(self)

    local PadObject = self:GetObjectsInGroup{ group = "GP_Pad"}.objects[1]
    PadObject:NotifyObject{ObjIDSender=self, name = "Trashed"}

    local BounceObject = self:GetObjectsInGroup{ group = "GP_Bounce"}.objects[1]
    BounceObject:NotifyObject{ObjIDSender=self, name = "Trashed"}

    local ClimberObject = self:GetObjectsInGroup{ group = "GP_Climb"}.objects[1]
    ClimberObject:NotifyObject{ObjIDSender=self, name = "Trashed"}

    local MiscObject = self:GetObjectsInGroup{ group = "GP_Misc"}.objects[1]
    MiscObject:NotifyObject{ObjIDSender=self, name = "Trashed"} 

    local TrapObject = self:GetObjectsInGroup{ group = "GP_Trap"}.objects[1]
    TrapObject:NotifyObject{ObjIDSender=self, name = "Trashed"}

    local BlockerObject = self:GetObjectsInGroup{ group = "GP_Blocker"}.objects[1]
    BlockerObject:NotifyObject{ObjIDSender=self, name = "Trashed"} 

    local AllObject = self:GetObjectsInGroup{ group = "GP_ALL"}.objects[1]
    AllObject:NotifyObject{ObjIDSender=self, name = "Trashed"} 
end

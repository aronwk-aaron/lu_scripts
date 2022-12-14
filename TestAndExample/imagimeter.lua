local char = GAMEOBJ:GetObjectByID(GAMEOBJ:GetLocalCharID())
char:SetRotation{w = 1, x = 0, y = 0, z = 0}
char:StartCelebrationEffect{celebrationID = 24} 
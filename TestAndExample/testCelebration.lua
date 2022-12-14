local pos = GAMEOBJ:GetObjectByID(GAMEOBJ:GetLocalCharID()):GetPosition{}.pos
local effectDuration = 5.5

CAMERA:AttachCameraEffectNVMsg("lookAt","lookatCelebrateFX1", effectDuration, 
			{	--{"objectID", GAMEOBJ:GetLocalCharID()},
				{"leadIn", 0.1},
				{"leadOut", 0.5},
				{"xPos", pos.x},
				{"yPos", pos.y + 3.0},
				{"zPos", pos.z},
				{"FOV", 54.4}})
CAMERA:AttachCameraEffectNVMsg("celebrate","celebrateFX1", effectDuration, 
			{	{"objectID", GAMEOBJ:GetLocalCharID()},
				{"startOffsetX", -5},
				{"startOffsetY", 0},
				{"startOffsetZ", 12},
				{"endOffsetX", 5},
				{"endOffsetY", 0},
				{"endOffsetZ", 12},
				{"leadIn", .75},
				{"leadOut", .5},
				{"FOV", 54.4}})

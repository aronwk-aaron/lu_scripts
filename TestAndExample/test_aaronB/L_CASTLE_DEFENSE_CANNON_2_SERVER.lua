local normalLoadout = 1
local superLoadout = 2

function onStartup(self,msg)
	-- set our fov
	self:SetProjectileLauncherParams{ playerPosOffset	= {x = 0, y = 0, z = -12}, 
									  cameraFOV         = 78 }

end

function onCheckUseRequirements(self, msg)

	local preConVar = self:GetVar("CheckPrecondition")
	local check = msg.objIDUser:CheckListOfPreconditionsFromLua{PreconditionsToCheck = preConVar, requestingID = self}

	-- Dont let the player use this if the minigame is active or they dont meet the precondition check.
	if not check.bPass  then
		msg.bCanUse = false
	end
    
    return msg
end

function onUse(self, msg)
    -- Receive the user ID
    local playerID = msg.user
    self:SetVar("playerID", playerID)
end

function onGetActiveSkillLoadLevel(self, msg)
    -- Receive the user ID
    local playerID = self:GetVar("playerID")
    
    -- Obtain the current super shot table
	local superShotTable = GAMEOBJ:GetZoneControlID():GetVar("superShotTable") or {}
	local pidSuperShotCount = superShotTable[playerID:GetID()] or 0
	if(pidSuperShotCount == 5) then
	    msg.iLoadLevel = superLoadout
	    
	else
	    msg.iLoadLevel = normalLoadout

	end
	
	return msg
	
end

function onFireEventServerSide(self, msg)
     if msg.args == "superShotCheck" then
        -- Obtain the current super shot table
	    local superShotTable = GAMEOBJ:GetZoneControlID():GetVar("superShotTable") or {}
	    local senderID = msg.senderID
	    local sendObj = senderID:GetID()
	    local pidSuperShotCount = superShotTable[sendObj] or 0
	    
	    if(pidSuperShotCount == 5) then
	        -- Reset the super shot counter
	        GAMEOBJ:GetZoneControlID():FireEvent{senderID=senderID, args="resetSuperShotTbl"}
	    end
     end
end

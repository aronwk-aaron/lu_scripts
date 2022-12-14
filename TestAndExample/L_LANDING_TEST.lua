local target = ''

function onCollisionPhantom(self, msg)
    target = msg.objectID  
    
    isColliding = self:GetVar("isColliding") 
    if isColliding or target:IsDead().bDead then
        return
    end        
    if isColliding == nil then
        self:SetVar("isColliding", true)
    end 
    
    local scoreObj = self:GetObjectsInGroup{ group = "RespawnPoints" }.objects
	
	--print("******** Landed ***********")
	
	scoreVal = self:GetVar("ScoreVal")
    if scoreVal == nil then
        self:SetVar("ScoreVal", 0)
    end
    
    --Freezes the player, plays an celebration animagion, starts respawn timer
    target:PlayAnimation{animationID = "rebuild-celebrate"}
    local animTime = target:GetAnimationTime{animationID = "rebuild-celebrate"}
    GAMEOBJ:GetTimer():AddTimerWithCancel( animTime.time, "RespawnTimer", self )
    
    -- Set the scores and send them to displayScore()
    scoreTotal = scoreObj[1]:GetVar("pScoreTotal")
	if scoreTotal == nil then        
        scoreTotal = scoreVal
    else    
        scoreTotal = scoreTotal + scoreVal
    end    
    scoreObj[1]:SetVar("pScoreTotal", scoreTotal)    
    displayScore('You Scored: ' .. scoreVal .. '\nYour Total: ' .. scoreTotal)
    checkMission(target, scoreTotal)
    
    return msg
end

function displayScore(text)
    target:DisplayTooltip { bShow = true, strText = text, iTime = 3000 }
end

function onTimerDone(self, msg)    
    if msg.name == "CollideTimer" then
        self:SetVar("isColliding", false)
        return
    end
    
    if not target:IsDead().bDead then
        --local respawnPoints = self:GetObjectsInGroup{ group = "RespawnPoints" }.objects                   
        --local respawnPos = respawnPoints[1]:GetPosition().pos     

        if msg.name == "RespawnTimer" then        
            --target:Teleport{ pos = respawnPos}        
            target:Die()
            GAMEOBJ:GetTimer():AddTimerWithCancel( 3 , "CollideTimer", self )
        end
    end
    
end

function checkMission(player, score) 
    local mstate = player:GetMissionState{missionID = 300}.missionState
    
    if score == 10  then
         player:UpdateMissionTask{ value = 300, value2 = score, taskType = "complete" }
    else        
        player:UpdateMissionTask{ value = 300, value2 = score, taskType = "incomplete" }
    end
end
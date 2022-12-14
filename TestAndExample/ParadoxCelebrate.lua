    local player = GAMEOBJ:GetObjectByID(GAMEOBJ:GetLocalCharID()) 
    local factionAnimation = ""
    local factionBackground = 3596
    local factionSubText = ""
    local factionMainText = ""
    local factionIcon = 2953
    local celebrationlookAtVerticalOffset = 0
    local celebrationCeleLeadIn = 0.25
    local celebrationCeleLeadOut = 0.25
    local celebrationstartOffsetX = 1
    local celebrationstartOffsetY = 1
    local celebrationstartOffsetZ = 1
    local celebrationendOffsetX = 1
    local celebrationendOffsetY = 1
    local celebrationendOffsetZ = 1
    local celebrationlookAtLeadIn = 0.25
    local celebrationlookAtLeadOut = 0.25    

    -- Paradox <-> ************************************************

    factionAnimation = "faction-join-paradox"
    factionBackground = 12233
    factionSubText = "CELEBRATIONS_JOINED_PARADOX_SUB"
    factionMainText = "CELEBRATIONS_JOINED_PARADOX_MAIN"
    factionIcon = 2983
    celebrationlookAtLeadIn = 0.25
    celebrationlookAtLeadOut = 0.25
    celebrationlookAtVerticalOffset = 3.115
    celebrationCeleLeadIn = 0.25
    celebrationCeleLeadOut = 0.25
    celebrationstartOffsetX = 0.059
    celebrationstartOffsetY = 5.158
    celebrationstartOffsetZ = 18.255
    celebrationendOffsetX = 0.059
    celebrationendOffsetY = 1.338
    celebrationendOffsetZ = 10.214
   
    player:StartCelebrationEffect{rerouteID = player,
                            backgroundObject = factionBackground,
                            animation = factionAnimation,
							duration = player:GetAnimationTime{ animationID = factionAnimation }.time,
							subText = factionSubText,
							mainText = factionMainText,
							iconID = factionIcon,
                            lookAtLeadIn = celebrationlookAtLeadIn,
                            lookAtLeadOut = celebrationlookAtLeadOut,
                            lookAtVerticalOffset = celebrationlookAtVerticalOffset,
                            celeLeadIn = celebrationCeleLeadIn,
                            celeLeadOut = celebrationCeleLeadOut,
                            startOffsetX = celebrationstartOffsetX,
                            startOffsetY = celebrationstartOffsetY,
                            startOffsetZ = celebrationstartOffsetZ,
                            endOffsetX = celebrationendOffsetX,
                            endOffsetY = celebrationendOffsetY,
                            endOffsetZ = celebrationendOffsetZ}
                            

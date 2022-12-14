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

    -- Venture <-> ************************************************

    factionAnimation = "faction-join-venture"
    factionBackground = 12235
    factionSubText = "CELEBRATIONS_JOINED_VENTURE_SUB"
    factionMainText = "CELEBRATIONS_JOINED_VENTURE_MAIN"
    factionIcon = 2953
    celebrationlookAtLeadIn = 0.25
    celebrationlookAtLeadOut = 0.25
    celebrationlookAtVerticalOffset = 3.019
    celebrationCeleLeadIn = 0.25
    celebrationCeleLeadOut = 0.25
    celebrationstartOffsetX = 0
    celebrationstartOffsetY = 2.839
    celebrationstartOffsetZ = 16
    celebrationendOffsetX = -4
    celebrationendOffsetY = 4.58
    celebrationendOffsetZ = 15

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
                            
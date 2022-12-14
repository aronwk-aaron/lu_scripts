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
    
    -- Sentinel <-> ************************************************

    factionAnimation = "faction-join-sentinel"
    factionBackground = 12236
    factionSubText = "CELEBRATIONS_JOINED_SENTINEL_SUB"
    factionMainText = "CELEBRATIONS_JOINED_SENTINEL_MAIN"
    factionIcon = 2984
    celebrationlookAtLeadIn = 0.25
    celebrationlookAtLeadOut = 0.25
    celebrationlookAtVerticalOffset = 2.63
    celebrationCeleLeadIn = 0.25
    celebrationCeleLeadOut = 0.25
    celebrationstartOffsetX = 0
    celebrationstartOffsetY = 3.115
    celebrationstartOffsetZ = 14.412
    celebrationendOffsetX = 0
    celebrationendOffsetY = 1.036
    celebrationendOffsetZ = 7.5

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
                            
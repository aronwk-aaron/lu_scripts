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
   
     --Assembly <-> ***********************************************

    factionAnimation = "faction-join-assembly"
    factionBackground = 12234
    factionSubText = "CELEBRATIONS_JOINED_ASSEMBLY_SUB"
    factionMainText = "CELEBRATIONS_JOINED_ASSEMBLY_MAIN"
    factionIcon = 2959
    celebrationlookAtLeadIn = 0.25
    celebrationlookAtLeadOut = 0.25
    celebrationlookAtVerticalOffset = 3.3
    celebrationCeleLeadIn = 0.25
    celebrationCeleLeadOut = 0.25
    celebrationstartOffsetX = 0.129
    celebrationstartOffsetY = 2.107
    celebrationstartOffsetZ = 16.602
    celebrationendOffsetX = -11.644
    celebrationendOffsetY = 1.814
    celebrationendOffsetZ = 15.631

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
                            
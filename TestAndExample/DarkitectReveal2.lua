local char = GAMEOBJ:GetObjectByID(GAMEOBJ:GetLocalCharID()) 

char:StartCelebrationEffect{rerouteID = player,
                            backgroundObject = 12126,
                            animation = "darkitect-reveal",
							duration = char:GetAnimationTime{ animationID = "darkitect-reveal" }.time,
							--duration = 10,
                            lookAtLeadIn = 0.15,
                            lookAtLeadOut = 0.15,
                            lookAtVerticalOffset = 10,
                            celeLeadIn = 0.15,
                            celeLeadOut = 0.15,
                            startOffsetX = 7.707,
                            startOffsetY = 1.89,
                            startOffsetZ = -38.658,
                            endOffsetX = -1.888,
                            endOffsetY = -2,
                            endOffsetZ = -49.463}

--[[
/runscript TestAndExample/DarkitectReveal2
--]]
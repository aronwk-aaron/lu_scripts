local char = GAMEOBJ:GetObjectByID(GAMEOBJ:GetLocalCharID()) 
char:SetRotation{w = 1, x = 0, y = 0, z = 0}
char:StartCelebrationEffect{animation = "celebrate-newitem", 
                                   backgroundObject = 11164,
                                   duration = 5.667, 
                                   subText = "You earned a", 
                                   mainText = "New Item!", 
                                   iconID = 3596,
                                   celeLeadIn = 0,
                                   celeLeadOut = .2,
                                   cameraPathLOT = 12458,
                                   pathNodeName = "camera1"}
                                   
LEVEL:ModifyEnvironmentSettings{ambient = {r = .45, g = .3, b = .3},
                                directional = {r = 1, g = .94, b = .75},
                                specular = {r = 1, g = 1, b = 1},
                                lightPosition = {x = 7, y = -8, z = 2 },
                                blendTime = .1,                                
                                fogColor = {r = 1, g = 1, b = 1},                                                                  
                                minDrawDistances = {fogNear = 1000, fogFar = 1000, postFogSolid = 1000, postFogFade = 1000, staticObjectDistance = 1000, dynamicObjectDistance = 1000},
                                maxDrawDistances = {fogNear = 1000, fogFar = 1000, postFogSolid = 1000, postFogFade = 1000, staticObjectDistance = 1000, dynamicObjectDistance = 1000}
                                }   

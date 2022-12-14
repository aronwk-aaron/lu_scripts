--This is just an example script. To run this you must type /runscript testandexample/darkitectreveal

local char = GAMEOBJ:GetObjectByID(GAMEOBJ:GetLocalCharID()) 

char:StartCelebrationEffect{rerouteID = player,
                            backgroundObject = 12019,
                            animation = "darkitect-reveal",
							--duration = char:GetAnimationTime{ animationID = "darkitect-reveal" }.time,
							duration = 24,                           
                            celeLeadIn = .3,
                            celeLeadOut = .5,
                            cameraPathLOT = 12510,
                            pathNodeName = "camera1"}                       
    
    
 LEVEL:ModifyEnvironmentSettings{ambient = {r = .2, g = .2, b = .2},
                                directional = {r = 1, g = 1, b = 1},
                                specular = {r = .4, g = 0, b = 1},
                                lightPosition = { -17, 8, -2.5 },
                                blendTime = .3,
                                fogColor = {r = 0, g = 0, b = 0},                                                                  
                                minDrawDistances = {fogNear = 1000, fogFar = 1000, postFogSolid = 1000, postFogFade = 1000, staticObjectDistance = 1000, dynamicObjectDistance = 1000},
                                maxDrawDistances = {fogNear = 1000, fogFar = 1000, postFogSolid = 1000, postFogFade = 1000, staticObjectDistance = 1000, dynamicObjectDistance = 1000}
                                }                              
    

    

--This is just an example script. To run this you must type /runscript testandexample/timetravel

local char = GAMEOBJ:GetObjectByID(GAMEOBJ:GetLocalCharID()) 

char:StartCelebrationEffect{rerouteID = player,
                            backgroundObject = 12626,
                            animation = "time-travel",
							--duration = char:GetAnimationTime{ animationID = "darkitect-reveal" }.time,
							duration = 14,                           
                            celeLeadIn = .3,
                            celeLeadOut = .5,
                            cameraPathLOT = 12628,
                            pathNodeName = "camera1"}                      
    
    
 LEVEL:ModifyEnvironmentSettings{ambient = {r = .7, g = .7, b = .7},
                                directional = {r = 1, g = 1, b = 1},
                                specular = {r = 1, g = 1, b = 1},
                                lightPosition = { -20, 1, 25 },
                                blendTime = .3,
                                fogColor = {r = 1, g = 1, b = 1},                                                                  
                                minDrawDistances = {fogNear = 75, fogFar = 150, postFogSolid = 1000, postFogFade = 1000, staticObjectDistance = 1000, dynamicObjectDistance = 1000},
                                maxDrawDistances = {fogNear = 75, fogFar = 150, postFogSolid = 1000, postFogFade = 1000, staticObjectDistance = 1000, dynamicObjectDistance = 1000}
                                }                              
    
    


    
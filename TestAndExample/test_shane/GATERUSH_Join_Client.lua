--------------------------------------------------------------
-- Description:
--
-- Client script for NS Race Instancer.
-- Lets client know the object can be interacted with
-- updated mrb... 3/23/10
--------------------------------------------------------------
require('client/ai/MINIGAME/BASE_INSTANCER')

local tVars = {
    releaseVersion = 1, -- which version release # the content should be made available for Beta 1
    misID = 624, -- run the foot race to unlock
    missionState = 2,
    itemType = 8092, -- allow vehicles to start the racing
    failItem = "What the heck is this?  Drop a car, MORAN!  :)",
    UI_Type = "NS_Race_01",
    failText = "Take a ride in the Failboat!",
    bUseBothInteractions = true,} -- if this is set to true then the player will be able to drag or click      
     
function onStartup(self)
    baseSetVars(self, tVars)
end

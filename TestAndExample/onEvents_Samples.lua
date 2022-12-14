
-- Object gets hit
onOnHit = function(self,msg)  
 
     local = objThatHitMe =  msg.attacker
     
end

-- When a object spawn another object useing the   RESMGR:LoadObject { objectTemplate =  2497 , x=  , y=  , z=  , owner = self } -- Student 1
-- the onChildLoaded with be triggered

onChildLoaded = function(self,msg)
       
         local = myChildObj =  msg.childID
                
end 

-- onTimmerDone is triggerd from   GAMEOBJ:GetTimer():AddTimerWithCancel( 15.33 , "bow2", self )  
    
onTimerDone = function(self, msg)

    if msg.name == "Timer_String_Name" then 
    

    end
  
end 
-- When a rebuild state is changed event will trigger
onRebuildNotifyState = function(self, msg)
	
	if (msg.iState) == 4 then -- Cancle
	    
	end
    
end 
-- When an object enters or exits a Radius onProximityUpdate is triggered
onProximityUpdate = function (self, msg)
      if msg.objId:GetFaction().faction == 1 and msg.status == "ENTER" and msg.name == "aggroRadius" then
       
      end 
      
end
-- when the player/object leaves the TetherRadius 
onLeftTetherRadius = function(self, msg)
  

end

-- Custom Event between two objects. object1:NotifyObject{ name = "Notify_String_Name" }

onNotifyObject = function(self, msg) -- object1
	if msg.name == "Notify_String_Name" then
		
	end
end

-- Triggered when player chick on a messged box button
function onMessageBoxRespond(self, msg)

	if (msg.iButton == 1) then

	end
end

-- Triggered when player click on 3d /clickable object

function onUse(self, msg)

	local Obj_that_pressed_Ok = msg.user
    
end

--[[

   **** Client Side only Events ****
   **** Client Side only Events ****
   
--]]


onClientUse = function(self, msg)

   local targetID = msg.user 			
 
end 



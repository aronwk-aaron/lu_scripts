require('o_mis')


function onStartup(self)
   self:SetVar("Trg.1", 0 )

  
end


function onArrived(self, msg)

            local mypos = self:GetPosition().pos
            local myRot = self:GetRotation()
            RESMGR:LoadObject { objectTemplate = 4639 , x= mypos.x, y= mypos.y , z= mypos.z, owner = self, rw= myRot.w, rx= myRot.x, ry= myRot.y, rz = myRot.z } 
 
end

onChildLoaded = function(self,msg)
        
           local t = self:GetVar("Trg")
            -- Save Target ID's/
           for i = 1, table.maxn( t ) do 
                if self:GetVar("Trg."..i) ==  nil or self:GetVar("Trg."..i) == 0  then
                    storeChild(self,  msg.childID , i) 
                     self:SetVar("Trg."..i+1, 0 )
                end
            end     
       
end 

onDie = function(self,msg)
   
    for i = 1, table.maxn( self:GetVar("Trg")) do 
            
       local child = getChild(self, i)   
       if child:Exists() then
         child:Die{killType = "SILENT"} 
       end
             
    end 

end  

function getChild(self, num)
    targetID = self:GetVar("Trg."..num )
    return GAMEOBJ:GetObjectByID(targetID)
end

function storeChild(self, target, num)
    idString = target:GetID()
    finalID = "|" .. idString
    self:SetVar("Trg."..num , finalID)
end


onPlatformAtLastWaypoint = function (self, msg)
            
	self:SetPlatformIdleState()
       

end
onNotifyObject = function(self, msg)


	if msg.name == "Arrow" then
		self:Die{killType = "SILENT"} 
	
	end


end 
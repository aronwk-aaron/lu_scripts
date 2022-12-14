require('o_mis')


function onStartup(self)

   	   self:SetProximityRadius { radius = 20 ,name = "misArrows" }
  
end


onDie = function(self,msg)


    	local foundObj = self:GetProximityObjects{ name = "misArrows" }.objects

        for i = 1, table.maxn (foundObj) do  
                if foundObj[i]:GetLOT().objtemplate == 4639 then
                    --storeObjectByName(missionObj[i], "missionArrow", self)
                    foundObj[i]:NotifyObject{ name = "removeArrow" }
                   break
                    
                end
        end
end 	






        

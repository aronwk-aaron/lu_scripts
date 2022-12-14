require('o_mis')


function onStartup(self)

   	 
  
end
	

onNotifyObject = function(self, msg)


	if msg.name == "removeArrow" then
	    local myParent = self:GetParentObj().objIDParent 
	    
	  
	    myParent:NotifyObject{ name="Arrow" }
	end


end 




        

-- OnEnter in HF Trigger system
function onCollisionPhantom(self, msg)
    -- Gets the target id that has collided
    if msg.objectID then 
        local target = msg.objectID
		 
		if target:IsDead().bDead == false then	
			print('Killing')		
			target:Die{ killType = "SILENT" }
		end

	return msg

    end        
	
end
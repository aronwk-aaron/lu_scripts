
function onMessageBoxRespond(self,msg)
			
	--print("identifier == "..msg.identifier	)
			
	if msg.iButton == 1  and msg.identifier == "PlaySG" then
	
		  msg.sender:TransferToZone{ zoneID = 1302, ucInstanceType = 1 } --instance type single	
	
	end


end

function onFireEventServerSide(self, msg)
    --print('onFireEventServerSide ' .. msg.args .. ' ' .. msg.senderID:GetName().name .. ' ' .. msg.param1)
    if msg.args == "TransferToInstance" then
        msg.senderID:TransferToZone{ zoneID = msg.param1, ucInstanceType = 1 } --instance type single		
    end
end 
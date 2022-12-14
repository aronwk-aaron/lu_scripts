--------------------------------------------------------------
-- Adds or removes a boost action to the vehicle.
-- created seraas... 2/3/10
--------------------------------------------------------------

function onStartup(self)
	self:SetVar("bIsDead", false)
    self:SetOffscreenAnimation{bAnimateOffscreen = true}
    
    -- new "drop-in" animation takes a while, don't let players hit it while it is still falling
	GAMEOBJ:GetTimer():AddTimerWithCancel(2.6, "playingAnimation", self)
	self:SetCollisionGroup{colGroup = 25}
    
end

function onCollisionPhantom(self, msg)
	
	--print("onCollisionPhantom")

    if ( self:GetVar("bIsDead") == true ) then
		--print("already dead")
        return
    end
	
	local vehicle = msg.objectID
	
	--print("Vehicle HIT VOLUME")
	
	if ( vehicle:GetID() == GAMEOBJ:GetControlledID():GetID() ) then
	
		-- make sure we do this first, before this object is smashed
		GAMEOBJ:GetZoneControlID():GateRushVehicleHitGate{ vehicleID = vehicle, objHit = self }
    
		-- have the vehicle smash this thing
		vehicle:VehicleNotifyHitSmashable{ objHit = self }
		
   		self:SetVar("bIsDead", true) 
   		--print("success")
	end
    
end


function onTimerDone(self,msg)

    if (msg.name == "playingAnimation") then
		--print("timer done!")
		self:SetCollisionGroup{colGroup = 17}
	end
	
end
    
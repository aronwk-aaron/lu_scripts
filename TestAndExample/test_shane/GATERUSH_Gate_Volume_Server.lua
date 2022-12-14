--------------------------------------------------------------
-- Adds or removes a boost action to the vehicle.
-- created seraas... 2/3/10
--------------------------------------------------------------

function onStartup(self)
	--print("STARTUP!")
--	self:SetVar("bIsDead", false)
	GAMEOBJ:GetZoneControlID():NotifyObject{ ObjIDSender = self, name = "AddGate" }
end

function onDie(self, msg)
	--print("ON DIE!")
	GAMEOBJ:GetZoneControlID():NotifyObject{ ObjIDSender = self, name = "RemoveGate" }
end

function onCollisionPhantom(self, msg)
	
	--print("onCollisionPhantom")

--    if ( self:GetVar("bIsDead") == true ) then
--		print("already dead")
--        return
--    end
	
	local vehicle = msg.objectID
	
	--print("Vehicle HIT VOLUME")
	
	-- make sure we do this first, before this object is smashed
    --GAMEOBJ:GetZoneControlID():GateRushVehicleHitGate{ vehicleID = vehicle, objHit = self }
    
    -- have the vehicle smash this thing
    --vehicle:VehicleNotifyHitSmashable{ objHit = self }
 
--   	self:SetVar("bIsDead", true) 
   	--print("success")
end



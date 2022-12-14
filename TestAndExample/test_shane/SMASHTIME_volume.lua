--------------------------------------------------------------
-- Adds or removes a boost action to the vehicle.
-- created seraas... 2/3/10
--------------------------------------------------------------

local TimeToAdd = 5

function onCollisionPhantom(self, msg)
	--print("onCollisionPhantom")
	local vehicle = msg.objectID
	
	if vehicle:GetID() == GAMEOBJ:GetControlledID():GetID() then
		print("Vehicle HIT VOLUME")
		showFloatingText(self, self:GetPosition(), 5, 6)
		
		-- make sure we do this last, as it is going to kill us
	    msg.objectID:VehicleNotifyHitSmashable{ objHit = self }
	end
end


function showFloatingText(self, pos, text, yOffset)    
    if not pos or not text then return end
    
    -- get the local player
    local player = GAMEOBJ:GetObjectByID(GAMEOBJ:GetLocalCharID())
    
    -- if player exists then display the floating text
    if player:Exists() then
        local tTextSize = {x = 0.11, y = 0.16}
        local tTextStart = pos
        
        -- offset by 6
        if not yOffset then
            yOffset = 6
        end
        
        tTextStart.y = tTextStart.y + yOffset
		
		-- yellow text
        player:RenderFloatingText{  ni3WorldCoord = tTextStart, ni2ElementSize = tTextSize, 
                                    fFloatAmount = 0.1,  uiTextureHeight = 200, uiTextureWidth = 200,
                                    i64Sender = self, fStartFade = 1.0, 
                                    fTotalFade = 1.25, wsText = text, 
                                    uiFloatSpeed = 4.5, iFontSize = 4, 
                                    niTextColor = {r=255 ,g=255 ,b=255 ,a=0} }
    end     
end 
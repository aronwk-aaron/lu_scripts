function onObjectActivated(self, msg)
    print ("You entered")
      
    LEVEL:SetLights(
        true, 0x7F7F7F,					--ambient color
        true, 0x6B6B6B,					--directional color
        true, 0xFFFE87,					--specular color
        true, 0xFFFFFF,					--upper Hemi  color
        true, { 0.60, -0.75, 0.10 },	--directional direction
        true, 0x5BAAFF,					--fog color

        true,                           --modifying draw distances (all of them)
        60.0, 60.0,					    --fog near min/max
        500.0, 500.0,					--fog far min/max
        10000.0, 10000.0,					--post fog solid min/max
        100.0, 100.0,					--post fog fade min/max
        8000.0, 8000.0,	    			--static object cutoff min/max
        8000.0, 8000.0,	     			--dynamic object cutoff min/max

        true, "mesh\env\challenge_sky_light_2awesome.nif"
        )			
        
    local tObjs = self:GetObjectsInGroup{ group = "Swap" }.objects
    
    --print(#tObjs)
    for k,v in ipairs(tObjs) do
        local objLot = v:GetLOT().objtemplate
        --print(objLot)
        if objLot == 4712 then
            --print('die')
            v:Die()        
        else            
            if objLot == 6450 then
                local oPos = {pos = v:GetPosition().pos}
                local oScale = v:GetObjectScale().scale       
                oPos.rot = v:GetRotation()   
                --print("setting scale: " .. oScale)
                local config = { {"newScale", oScale} }
                RESMGR:LoadObject{ objectTemplate = 2445, x= oPos.pos.x, y= oPos.pos.y , z= oPos.pos.z, rw = oPos.rot.w, rx = oPos.rot.x, ry = oPos.rot.y, rz = oPos.rot.z, owner = self, configData = config}
            end
   
            --print('delete')
            GAMEOBJ:DeleteObject(v)
        end
    end
end

function onChildLoaded(self, msg)
    if msg.templateID == 2445 then
        --print('scale child by: ' .. self:GetVar('newScale'))
        msg.childID:SetObjectScale{scale = 0.5}
    end
end

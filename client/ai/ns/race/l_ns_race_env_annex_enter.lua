--------------------------------------------------------------
-- Script to change the fog/light settings in NS Racetrack as the player ENTERS Annex area
--
-- updated NateS... 4/9/10
--------------------------------------------------------------

function onCollisionPhantom(self, msg)
   if msg.objectID:GetID() == GAMEOBJ:GetControlledID():GetID() then
      
     LEVEL:SetLights(
		true, 0x0208d3,					--ambient color
		false, 0xFFFFFF,					--directional color
		false, 0xFFFFFF,					--specular color
		false, 0xFFFFFF,					--upper Hemi  color
		false, { 0.17, -0.81, 0.56 },	--directional direction
		true, 0x705a6f,					--fog color

		true,                           --modifying draw distances (all of them)
        	100.0, 100.0,					--fog near min/max
		1700.0, 1700.0,					--fog far min/max
		2060.0, 2060.0,					--post fog solid min/max
		00.0, 00.0,					--post fog fade min/max
		3500.0, 3500.0,	    			--static object cutoff min/max
		3000.0, 3000.0,	     			--dynamic object cutoff min/max

		false, "mesh\env\env_gen_sky_lightblue.nif",

		1.0					-- blend time
	 )
	end			
end
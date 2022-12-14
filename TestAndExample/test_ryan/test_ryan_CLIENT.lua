 --------------------------------------------------------------
-- Includes
--------------------------------------------------------------
require('o_mis')
function onStartup(self)
    
    --[[
    MobWaves = {}
    Con["Darkling_01"] = 4712
    Con["Blue_Spawners"] = 1
    Con["rSpawn"] = 0 
    self:SetVar("Con",Con)
	UI:SendMessage( "pushGameState", {{"state", "Siege" }} )
	UI:SendMessage("ShowUI", { {"show", true } })
	

	PHYSICS:SetCanCollide(10, 10, true)
	]]--

	

end

function onNotifyClientZoneObject(self,msg) 
                --these pushes are questionable, is this a workaround from the old system?
	--UI:SendMessage( "pushGameState", {{"state", "Siege" }} )
--[[
	if msg.name == "ShowText" then
		UI:SendMessage("SiegeBigTxt", {{"bigtxtVisible", "hide" }} )
		UI:SendMessage("SiegeText", {{"Text", " " }} )
		UI:SendMessage("SiegeText", {{"UI", "show" }} )
	elseif msg.name == "SetGameState" then	
		UI:SendMessage( "pushGameState", {{"state", "Siege" }} )
	elseif msg.name == "nubOfPlayers" then	
		UI:SendMessage("SiegeJoin", {{"nubOfPlayers", msg.paramStr} })
	elseif msg.name == "HideUI" then
		UI:SendMessage("SiegeUI", { {"UI", "hide"} })
	elseif msg.name == "HideText" then
		UI:SendMessage("SiegeText", {{"UI", "hide" }} )
	elseif msg.name == "OverHeadText" then
		UI:SendMessage("SiegeText", {{"Text", msg.paramStr }} )
	elseif msg.name == "ShowPlayButton" then
		UI:SendMessage("SiegeJoin", {{"sgPlayShow", true }} )
]]--
		

		
		
	end
 
end



function onTimerDone(self,msg)



	
end



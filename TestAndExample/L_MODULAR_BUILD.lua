local iTemplateID = 4717 -- the LOT of the module within the iAssemblyTemplate you are searching for.

function onModularBuildEnter(self, msg)
    print("*******************************")
    print("**** ModularBuildEnter Called ****")
    print("**** self name = " .. self:GetName().name .. " ****")
    print("**** playerID name = " .. msg.playerID:GetName().name .. " ****")
    print("**** modularBuildID = " .. msg.modularBuildID .. " ****")
    print("*******************************")
end

function onModularBuildExit(self, msg)
    print("*******************************")
    print("**** ModularBuildExit Called ****")
    print("**** self name = " .. self:GetName().name .. " ****&&&&****")
    print("**** self id = " .. self:GetID() .. " ****")
    print("**** playerID name = " .. msg.playerID:GetName().name .. " ****")
    print("**** modularBuildID = " .. msg.modularBuildID .. " ****")
    print("**** bCompleted = " .. tostring(msg.bCompleted) .. " ****")
    print("**** i64AssemblySubkey = " .. msg.i64modelSubkey:GetID() .. " ****")
    print("*******************************")
    
    -- message params legend:
    -- iObjTemplate			= This is the LOT of the module that you want to search for inside of the completed module assembly (ex. steam cockpit)
    -- iAssemblyTemplate	= This is the LOT of the completed module assembly associated with the object this script is on (ex. rocket)
    -- i64modelSubkey		= This is the unique key of a freshly created rocket (necessary to handle the case when a rocket has been built but may not exist in the inventory yet)
    -- callbackTarget		= This is the object this script is attached to (necessary as we send the message to the player's inventory (server side) and need to get a callback here
    
    if(msg.bCompleted == true) then
		local check = msg.playerID:CheckPlayerAssemblyForUniqueModuleByLOT{iObjTemplate = iTemplateID, iAssemblyTemplate = msg.modularBuildID, i64modelSubkey = msg.i64modelSubkey:GetID(), callbackTarget = self}
	end
	
    print("*******************************")
end 

function onModuleAssemblyDBDataToLua(self, msg)

    print("*ooo**ooo* bModuleFound = " .. tostring(msg.bModuleFound) .. " *ooo**ooo*")
    print("*ooo**ooo* bAssemblyFound = " .. tostring(msg.bAssemblyFound) .. " *ooo**ooo*")
    print("*ooo**ooo* bDataReady = " .. tostring(msg.bDataReady) .. " *ooo**ooo*")    

end
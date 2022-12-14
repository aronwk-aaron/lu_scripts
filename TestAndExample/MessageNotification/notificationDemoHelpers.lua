function storeObjectByName(self, varName, object)
	local finalID = nil
	if( object ) then
		idString = object:GetID()
		finalID = "|" .. idString
	end
    self:SetVar(varName, finalID)
end

function getObjectByName(self, varName)
    targetID = self:GetVar(varName)
    if (targetID) then
		return GAMEOBJ:GetObjectByID(targetID)
	else
		return nil
	end
end

function dumpVar(name,var,indent)
	if( indent == nil ) then
		indent = ""
	end
	if( type(var) == "table" ) then
		print( indent .. name .. " is a table with " .. #var .. " entries:" )
		local i,v = next(var)
		while i do
			dumpVar(i,v,indent .. "  ")
			i, v = next(var, i)
		end
	else
		local startOfLine = indent .. name .. " is "
		if( type(var) == "userdata" ) then
			if( type(var.GetID) == "function" ) then
				print( startOfLine .. "an object proxy with ID = " .. var:GetID() )
			else
				print( startOfLine .. "unknown userdata" )
			end
		elseif( var == nil ) then
			print( startOfLine .. "nil" )
		else
			print( startOfLine .. "a(n) " .. type(var) .. " with value = " .. var )
		end
	end
end

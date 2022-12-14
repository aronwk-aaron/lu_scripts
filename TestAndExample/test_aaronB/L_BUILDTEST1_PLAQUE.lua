--------------------------------------------------------------

-- L_BUILDTEST1_PLAQUE.lua

-- Process property edit functionality

-- Created abeechler... 10/10/11 

-------------------------------------------------------------

function onServerGetPropertyEditValid(self, msg)
    msg.isValid = true
    return msg
end

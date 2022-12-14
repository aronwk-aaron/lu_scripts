--------------------------------------------------------------
-- caged spider server
-- Created mrb... 6/7/11
--------------------------------------------------------------

local spiderGroup = "cagedSpider"
local preconID = "188;189"
local flagID = 74
local invenItem = 14553

function onCheckUseRequirements(self, msg)
	local check = msg.objIDUser:CheckListOfPreconditionsFromLua{PreconditionsToCheck = preconID}

	if not check.bPass then --check mission		
		msg.bCanUse = false
	end
	
	return msg
end

function onUse(self, msg)		
	local spiderObj = self:GetObjectsInGroup{group = spiderGroup, ignoreSelf = true, ignoreSpawners = true}.objects
	
	for key, obj in ipairs(spiderObj) do
		if obj:Exists() then
			-- tell the spider to show up
			obj:FireEventClientSide{args = "toggle", senderID = msg.user, rerouteID = msg.user}
			-- set the mission player flag
			msg.user:SetFlag{iFlagID = flagID, bFlag = true}
			-- Player has completed the mission, remove necessary items
			msg.user:RemoveItemFromInventory{iObjTemplate = invenItem, itemCount = 1}
			
			return
		end
	end
end 
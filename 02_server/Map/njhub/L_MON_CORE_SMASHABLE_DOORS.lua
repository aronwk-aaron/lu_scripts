--------------------------------------------------------------
-- Server side Script on the door over the nooks in the monastery

-- 
-- created by brandi... 6/10/11
--------------------------------------------------------------

-- on die, tell the trigger volume
function onDie(self, msg)
	local myNum = self:GetVar("spawner_name")
	myNum =string.sub(myNum,-1)
	local trigger = self:GetObjectsInGroup{ group = "CoreNookTrig0"..myNum, ignoreSpawners = true }.objects
	if not trigger then return end
	for k,v in ipairs(trigger) do
		if v:Exists() then
			v:FireEvent{args = "DoorSmashed"}
			break
		end
	end
end
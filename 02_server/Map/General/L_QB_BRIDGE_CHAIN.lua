--------------------------------------------------------------
--  Server script on QBs to make a QB chain
-- this script only works if the spawner networks are set up correctly, in numerical order 

-- created mrb... 11/30/10 -- modifed the Blue brick script to make this work
--------------------------------------------------------------

--------------------------------------------------------------
-- when the object dies
--------------------------------------------------------------
function onDie(self,msg)
	-- get the name of the spawner network
	local mySpawner = tostring(self:GetVar("spawner_name"))
	-- get the first part of the spawner network, without the number
	local qbGroup = string.sub(mySpawner,1,-2)
	
	-- deactivate and reset current spawner network
	local sameSpawner = LEVEL:GetSpawnerByName(mySpawner)
	
	if sameSpawner then
		sameSpawner:SpawnerReset()
		sameSpawner:SpawnerDeactivate()
	end
	

	-- create a string for the first spawner network
	local firstQB = qbGroup.."1"
	-- activate the first spawner network
	local firstSpawner = LEVEL:GetSpawnerByName(firstQB)
	
	if firstSpawner then
		firstSpawner:SpawnerActivate()
	end
end


--------------------------------------------------------------
-- when the object dies
--------------------------------------------------------------
function onRebuildComplete(self, msg)
	-- get the name of the spawner network
	local mySpawner = tostring(self:GetVar("spawner_name"))
	-- get the last value in the string and convert it to a number
	local qbNum = tonumber(string.sub(mySpawner,-1))
	-- get the first part of the spawner network, without the number
	local qbGroup = string.sub(mySpawner,1,-2)
	-- add 1 to the value of the spawner network
	local nextqbNum = qbNum + 1
	
	-- deactivate and reset current spawner network
	local sameSpawner = LEVEL:GetSpawnerByName(mySpawner)
	
	if sameSpawner then
		sameSpawner:SpawnerReset()
		sameSpawner:SpawnerDeactivate()
	end
	
	-- create the string for the next spawner network
	local nextQB = qbGroup..nextqbNum
	local nextQBSpawner = LEVEL:GetSpawnerByName(nextQB)
	
	if nextQBSpawner then
		nextQBSpawner:SpawnerActivate()
	end
end 
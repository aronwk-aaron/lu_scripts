--------------------------------------------------------------

-- L_CASTLE_DEFENSE_WALL_CLIENT.lua

-- Server side test script for Castle Defense wall prototyping.
-- created abeechler ... 8/5/11

--------------------------------------------------------------

-- 13925 Castle Corner Inner 2 9499 3 4210
-- 13926 Castle Gate 2 9503 3 4214
-- 13927 Castle Tower 2 9507 3 4218
-- 13928 Castle Wall Bridge 2 9508 3 4219
-- 13929 Castle Wall Straight 2 9514 3 4225
-- 13930 Castle Wall T 2 9517 3 4228
-- 13931 Castle Wall Tower With Top
-- 13932 Castle Wall Widening 2 9520 3 4231

-- 14202 Castle Wall Tower With Top QB
-- 14206 Castle Corner Inner QB
-- 14207 Castle Gate QB
-- 14208 Castle Tower QB
-- 14209 Castle Wall Bridge QB
-- 14210 Castle Wall Straight QB
-- 14211 Castle Wall T QB
-- 14213 Castle Wall Widening QB




function onRenderComponentReady(self,msg)
	local mylot = self:GetLOT().objtemplate 
	local yOffset = 0
	
	if(mylot == 13931 or mylot == 14202) then
		yOffset = 40
	elseif(mylot == 13925 or mylot == 14206) then
		yOffset = 15
	elseif(mylot == 13926 or mylot == 14207) then
		yOffset = 15
	elseif(mylot == 13927 or mylot == 14208) then
		yOffset = 15
	elseif(mylot == 13928 or mylot == 14209) then
		yOffset = 15
	elseif(mylot == 13929 or mylot == 14210) then
		yOffset = 15
	elseif(mylot == 13930 or mylot == 14211) then
		yOffset = 15
	elseif(mylot == 13932 or 14213) then
		yOffset = 15
	end

	self:SetBillboardOffset{ vertOffset = yOffset }
end


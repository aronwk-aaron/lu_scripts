-- Edited by Erik B., 7/18, adding FX for damage states on server so everyone can see the same states
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

local maxhealth = 1
local defaulthealth = 5

function onStartup(self,msg)
    -- Get max health once, since the objects max health won't change 
    if (self:GetMaxHealth().health) then
        maxhealth = self:GetMaxHealth().health
    else
        maxhealth = defaulthealth
    end        
end

function onHitOrHealResult(self,msg)

-- If we're dead, stop updating
    if (msg.diedAsResult) then return end
    
-- Here's where we're defining visual damage states.
-- Since a standard cannonball currently takes 5 hits to destroy a wall, I'm adding 5 visual states

    local health = self:GetHealth().health
    local healthpercent = health / maxhealth
    local FXname = "hit1"

    if healthpercent >= 0.8 then
        FXname = "hit1"
    elseif healthpercent >= 0.6 and healthpercent < 0.8 then
        FXname = "hit2"
    elseif healthpercent >= 0.4 and healthpercent < 0.6 then
        FXname = "hit3"
    elseif healthpercent >= 0.2 and healthpercent < 0.4 then
        FXname = "hit4"
    elseif healthpercent > 0 and healthpercent < 0.2 then
        FXname = "hit5"
    end

    self:StopFXEffect{name = "fx"}
    self:PlayFXEffect{name = "fx", effectID = 9223, effectType = FXname}
   
end

function onDie(self, msg)

	local mylot = self:GetLOT().objtemplate 
	local newlot = 0
	
	if(mylot == 13931 or mylot == 14202) then
		newlot = 14202
		
	elseif(mylot == 13925 or mylot == 14206) then
		newlot = 14206
	
	elseif(mylot == 13926 or mylot == 14207) then
		newlot = 14207
	
	elseif(mylot == 13927 or mylot == 14208) then
		newlot = 14208
	
	elseif(mylot == 13928 or mylot == 14209) then
		newlot = 14209
	
	elseif(mylot == 13929 or mylot == 14210) then
		newlot = 14210
	
	elseif(mylot == 13930 or mylot == 14211) then
		newlot = 14211
	
	elseif(mylot == 13932 or 14213) then
		newlot = 14213
	end

	 -- get all the position and rotation info for the turret 
    local mypos = self:GetPosition().pos
    local posString = self:CreatePositionString{ x = mypos.x, y = mypos.y, z = mypos.z }.string
    local myRot = self:GetRotation()
    --local parent = msg.killerID;
    local config = { {"rebuild_activators", posString }, {"respawn", 100000 }, {"rebuild_reset_time", -1}, {"no_timed_spawn", true}, {"currentTime", 0} , {"CheckPrecondition" , "21"} }
    local terrainY = PHYSICS:GetTerrainHeightPosition(mypos.x, mypos.y, mypos.z);
	-- set y pos to the terrain hieght
    mypos.y = terrainY
   
    -- load the turret object
    RESMGR:LoadObject { objectTemplate = newlot, x= mypos.x, y= mypos.y , z= mypos.z, rw= myRot.w, rx= myRot.x, ry= myRot.y, rz = myRot.z, configData = config }
end


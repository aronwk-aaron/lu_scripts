----------------------------------------
-- Base Server side script for Mech type enemies
--
-- created mrb... 1/7/11 - moved script and updated
----------------------------------------
require('02_server/Enemy/General/L_SUSPEND_LUA_AI')

local defaultQBTurretLOT = 6254 -- DEFAULT TURRET LOT

function onStartup(self) 
	baseStartup(self)
end

function baseStartup(self)
	-- set the faction to 4 so the player can attack this
    self:SetFaction{faction = 4}    
    
    -- turn off lua ai
	suspendLuaAI(self)
end

function onDie(self,msg)
	baseDie(self,msg)
end

function baseDie(self, msg, newMsg)	
	-- disable the ai state
	self:EnableCombatAIComponent {bEnable = false}   
    
    -- get all the position and rotation info for the turret 
    local mypos = self:GetPosition().pos
    local posString = self:CreatePositionString{ x = mypos.x, y = mypos.y, z = mypos.z }.string
    local myRot = self:GetRotation()
    local config = { {"rebuild_activators", posString }, {"respawn", 100000 }, {"rebuild_reset_time", -1}, {"no_timed_spawn", true}, {"currentTime", 0} , {"CheckPrecondition" , "21"} }
    local terrainY = PHYSICS:GetTerrainHeightPosition(mypos.x, mypos.y, mypos.z);
	-- set y pos to the terrain hieght
    mypos.y = terrainY
    
	local qbTurretLOT = self:GetVar("qbTurretLOT") or defaultQBTurretLOT
	
    -- load the turret object
    RESMGR:LoadObject { objectTemplate = qbTurretLOT, x= mypos.x, y= mypos.y , z= mypos.z, rw= myRot.w, rx= myRot.x, ry= myRot.y, rz = myRot.z, configData = config }
end 
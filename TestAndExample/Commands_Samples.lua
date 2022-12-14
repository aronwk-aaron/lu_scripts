--[[

   LU Sample Hooks [basic commands]

--]]


-- Set or get a Varibale from an Object
   self:SetVar("varibale_name", 22 ) -- saves variable to the object. 
   self:GetVar("variable_name")      -- returns the saved varialbe = 22

-- Check to see if an object is a enemy
   self:IsEnemy{ targetID = objId }.enemy
   --Returns bool ( true / false ) 
   
-- Get the template ID from a Object
   local TemplateID = object:GetLOT().objtemplate 
   -- TemplateID will the turn a [Int] # exampel 2245 is the object tempalte id of the red ninja
   
-- Check to see if object is Dead
    objId:IsDead().bDead
    -- Returns bool ( true / false )
    
-- Get the x,y,z Position of an object 
   local pos = self:GetPosition().pos
   pos.x = xxx
   pos.y = xxx
   pos.z = xxx
   -- returns a talbe of the x,y,z
   
-- Get the Rotation of an object 
   	local myRot = self:GetRotation()
    myrot.y = -0.4833
    myRot.w =  0.8754
   -- returns a talbe of the [y],x,[w],z ( note y and w are the only vars you really care about ) 
   
-- Get the Faction of an Object
   object:GetFaction().factionList
   -- Returns the list of factions an object has ( The player faction is usually 1 ) 
   
-- Get/Set NPC stats 

   local hp = self:GetMaxHealth{}.health        -- Get the Max heal of an Object
   object:SetHealth{ health = hp }              -- Set the health of an Object

   local Im = self:GetImagination{}.health      -- Get the Max imagination of an Object
   object:SetImagination{ imagination = Im }    -- Set the imagination of an Object
   
   object:SetImmunity{ immunity = true }          -- Turn immunity On
   object:SetImmunity{ immunity = false }         -- Turn immunity Off
   
-- 


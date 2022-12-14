--------------------------------------------------------------
-- (SERVER SIDE) Trigger for Course Finish
-- Finishes the course for the player
--
-- updated mrb... 6/9/11 - refactored
--------------------------------------------------------------

--------------------------------------------------------------
-- On Collision
--------------------------------------------------------------
function onCollisionPhantom(self, msg)
    -- if a player is colliding with us
    if not msg.objectID:IsCharacter().isChar then return end
    
    -- get all objects in course manager group
    local objects = self:GetObjectsInGroup{group = "race_manager", ignoreSpawners = true}.objects

    -- loop through objects and return the first object that matches the 
    -- course manager lot
    for key, manager in ipairs(objects) do
        -- notify manager of collision
        if manager:Exists() then
            manager:FireEvent{ args = "course_cancel", senderID = msg.objectID }
            
			break
        end		
    end
end 
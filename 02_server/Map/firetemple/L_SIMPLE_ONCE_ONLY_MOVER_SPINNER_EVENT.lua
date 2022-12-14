----------------------------------------
-- Server side script on moving platforms that are controlled by a spinner
--
-- created by brandi... 8/24/11
----------------------------------------

-- FOR SIMPLE MOVERS ONLY (or a path with only 2 points)

------------------------------------------------
-- This script assumes the spinner is starting in its active location. the first move of the moving platform (from waypoint 0 to waypoint 1)
-- will happen when the spinner is deactivated.

-- To set up in HF, use the name name and group you are using on the spinner
-- put the moving platform in the group_deactivated_event
-- add the following config data just the same as you did on the spinner
-- name_activated_event --> 0:event1	-- event name to fire when the spinner is put into the active state

----------------------------------------------

function onFireEvent(self,msg)
	if msg.args == self:GetVar("name_deactivated_event") then
		self:GoToWaypoint{iPathIndex = 1}
	end
end


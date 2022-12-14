require('o_mis')


function onStartup(self) 
Set = {}
	-- Basic Game Settings --
	self:SetActivityParams{activityID = 43, activityActive = true , modifyMaxUsers = true, maxUsers = 8, }


	RESMGR:LoadObject {
	   objectTemplate = 4712,
	   x = -140,
	   y = 200,
	   z = 579,
	   owner = self
	  }

	
	--(((((((((((( 1.	Enter Level: wait for init )))))))))))))
	Set['GameState'] = "Starting"						-- Do Not Change -- 
    Set['Rounds_To_Play']           = 3             	-- INT ( Set the number of rounds to play ) 
    Set['RespawnTime']              = 8					-- INT ( Player Respawn Time after being smashed )
    Set['Game_Type']                = "TOWER_DEFENSE"  	-- INT ( Game Type )
	
	MobWaves = {}
    MobWaves[1] = 4712 -- LOT of darkling 1
      
    -- End Game Timers 
	--Set['WonLostMatchTimer'] = 5    -- Show Txt Won Lost timer
	--Set['ScoreBoardTimer'] = 5    -- Show Score Board Timer
	--Set['LeaderBoardTimer'] = 5

    

	-- Siege Points
	
	
	-- All Vars are * 1 
	Set['CapturObj'] = 10
	Set['PickUpObj'] = 5		

	Set['Enemies'] = 		0
	Set['Lives'] =          10		
	Set['Tokens'] = 		0
	

	--((((((((((((  2.	Notify Team Objectives:  ))))))))))))) -- 
	Set['Notify_Txt'] = "Defend the Rocket Fuel!"
	  
  
    Set['Info_Text_1'] = " smashed "
 

	--- Game Object Lots ---
	Set['Number_of_Spawn_Groups'] = 1 --INT
    ---Set['DefendTarget'] = 4847
    
------ Do not change ----------------------------------------------------------
    self:SetVar("Set",Set)
    self:SetNetworkVar("Set",Set)
 
    
    
end

function notifyArrived(self,msg)
	-- this will only get called by npcs on paths, so self is not zone in this case
	
	--if(msg.actions) then   
       -- if (msg.actions[1] == "killme") then
						self:Die{}
       -- end
  --end
        

end


function onNotifyObject(self, msg)
   	--mainNotifyObject(self, msg)
end

function onObjectLoaded(self, msg)
    --if (msg) then
    --    mainObjectLoaded(self, msg)
    --end
end

function onChildLoaded(self, msg)
	--mainChildLoaded(self, msg)
        
	--msg.lotID
	self:SendLuaNotificationRequest{requestTarget=msg.childID, messageName="OnArrived"}
	
	msg.childID:FollowWaypoints{bPaused = false, bUseNewPath = true, newPathName = "Badguys", newStartingPoint = 1}


end
--------------------------------------------------------------------------------
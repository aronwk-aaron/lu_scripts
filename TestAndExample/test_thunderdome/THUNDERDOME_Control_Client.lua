require('o_mis')

function onStartup(self)
    -- configure the racing control
    local racingParams =
		{
			--{ "IntroCinematic", "Precountdown" },
			--{ "ExitCinematic", "Finish" },
			--{ "CountdownCinematic", "Countdown" },
			{ "DirectionArrowLOT", 14005 },
			{ "DirectionArrowLOT2", 14006 },
			{ "ArrowColorDistance", 800 },
			--{ "DirectionArrowLOT", 4639 },
			--{ "DirectionArrowLOT", 8510 },
			--{ "CountdownCinematic", "Countdown" },
			{ "NDAudioMusicCueName1", "GF_Race-Track"},
			{ "NDAudioMusicCueName2", "GF_Race-Track2"},
			{ "NDAudioMusicCueName3", "GF_Race-Track3"},
			{ "NDAudioMusicCueName4", "GF_Race-Track4"},			
		}
		
	--print("ConfigureRacingControl...")
	
	self:ConfigureRacingControlClient{ parameters = racingParams }
	--print("...Done")
	
	self:SetVar("bSceenEffectOn", false) 
	
end


function onLocalPlayerTargeted(self, msg)
	
	-- add objectID to a list

	
	if (self:GetVar("bSceenEffectOn") == false) then
		LEVEL:AttachCameraParticles("prototype/red_full_screen/red_full_screen", { x = 0, y = 0, z = 3.0 })
		GAMEOBJ:GetTimer():AddTimerWithCancel(5.0, "removeeffect", self)
		self:SetVar("bSceenEffectOn", true)
		--print("Turning effect on")
	end
	
	local controlledObject = GAMEOBJ:GetControlledID()
	self:SendLuaNotificationRequest{requestTarget = controlledObject, messageName = "Die"}
	
	local player = GAMEOBJ:GetObjectByID(GAMEOBJ:GetLocalCharID())
    
	-- if player exists then display the floating text
	if player:Exists() then
		local tTextSize = {x = 0.5, y = 0.1}
	
		local text = "Missile Incoming!"
		
		-- missile incoming text
		player:Request2DTextElement{ni2ElementPosit = {x = 0.5, y = 0.5}, ni2ElementSize = tTextSize, 
								    fFloatAmount = 0.5,  uiTextureHeight = 200, uiTextureWidth = 1300,
									i64Sender = self, fStartFade = 1.0, 
									fTotalFade = 1.0, wsText = text, 
									uiFloatSpeed = 0, iFontSize = 5, 
									niTextColor = {r=1.0, g=0.0, b=0.0, a=0} }
	 end   
	  
end


function onTimerDone(self,msg)

    if (msg.name == "removeeffect") then
		LEVEL:DetachCameraParticles("prototype/red_full_screen/red_full_screen")		
		self:SetVar("bSceenEffectOn", false)
	end
	
end
    

function notifyDie(self, player, msg)

	LEVEL:DetachCameraParticles("prototype/red_full_screen/red_full_screen")
	self:SetVar("bSceenEffectOn", false)
	GAMEOBJ:GetTimer():CancelTimer("removeeffect", self)
	
end


function onSkillCountChanged(self, msg)

	local bDisplay = false
	
	local icon_name = "mesh\\test\\racing_pickup-landmine_icon.dds"
	
	if(msg.iSkillID == 428) then
		icon_name = "mesh\\test\\racing_pickup-missile_icon.dds"
	end
	
	if(msg.iCount > 0) then
		bDisplay = true
	end
	
	local num_string = msg.iCount .. "x"
	
	UI:SendMessage( "ToggleWeaponCount", { {"visible", bDisplay},  {"numLeft", num_string}, {"icon", icon_name} } )

end


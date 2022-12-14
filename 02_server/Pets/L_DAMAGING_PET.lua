--------------------------------------------------------------
-- Script on the pets that damage players and arent tamable 
-- unless the player casts a skill to make them tamable
-- 
-- taken from scripts created by MEdwards
-- created by brandi... 1/26/11
-----------------------------------------------------------
 
 local petData = 
 {	-- FORMAT: 	NameOfPet = {	LOT = lot # of that pet,
	--							FX = FX ids to play on the pet that shows they're dangerous
	--							skill = that skill that is cast on the pet to make them tamable
		RedDragon 	= {LOT = 5639, FX = {3170,4058}, 	skill = "waterspray"}, 
		GreenDragon = {LOT = 5641, FX = {3170,4058}, 	skill = "waterspray"}, 
		Skunk		= {LOT = 3261, FX = {1490}, 		skill = "waterspray"} 
}
 
 
function onStartup(self,msg)
	-- find out which pet it is
	local objLot = self:GetLOT().objtemplate
	local PetInfo = {}
	
	-- set the pet from the table for easier use later 
	for type, data in pairs(petData) do
		if data.LOT == objLot then
			-- this will set the pet name from the table above
			self:SetVar("CurrentPet", type)
			-- when it find the correct pet, break out of the loop
			break
		end
	end
	-- short timer to set everything on the pet, so allow the pet to fully load
	GAMEOBJ:GetTimer():AddTimerWithCancel( 0.5, "SetUp", self )
end

-- When the player casts a skill on the pet
function onSkillEventFired( self, msg )
	-- compare the skill casts with the skill this pet is looking for
	if msg.wsHandle == petData[self:GetVar("CurrentPet")].skill then
		-- Check if the pet has been tamed and, if so, don't do this
		if self:IsPetWild().bIsPetWild == false then return	end
		
		-- Check if the pet is already tamable
		if not self:BelongsToFaction{factionID = 99}.bIsInFaction then
			-- custom script to take off the damaging effects
			ClearEffects(self,msg)
			-- start a timer that will turn the pet untamable and aggro  
			GAMEOBJ:GetTimer():AddTimerWithCancel( 30, "GoEvil", self )
			-- Send a network valriable to the client script to change picktype.
			self:SetPetsTamableState{bTamable = true}
			self:SetNetworkVar("bIAmTamable", true)
		 end
	end

end

function onTimerDone(self, msg)
    -- timer to make the pet hate the player again
    if msg.name == "GoEvil" then
		MakeUntameable(self)
	-- inital set up on the pet
    elseif msg.name == "SetUp" then
		-- if the pet is wild, make them hate the player
		if self:IsPetWild().bIsPetWild == true then
			MakeUntameable(self)
		else 
			 -- change faction to normal pet faction
			self:SetFaction{faction = 99}
			-- clear threat list
			self:ClearThreatList{}
		end
	end
end

--Checking the state of the pet taming minigame. If start, cancel timers. If quit, start short "go evil" timer
function onNotifyPetTamingMinigame(self, msg)  
     if msg.notifyType == "BEGIN" then
        GAMEOBJ:GetTimer():CancelAllTimers(self)
		ClearEffects(self,msg)		
     elseif msg.notifyType == "FAILED" or msg.notifyType == "QUIT" then
		-- make the pet unpickable again
		self:SetPetsTamableState{bTamable = false}
		self:SetNetworkVar("bIAmTamable", false)
        GAMEOBJ:GetTimer():AddTimerWithCancel( 1, "GoEvil", self )
	elseif  msg.notifyType == "SUCCESS" then
		ClearEffects(self,msg)
     end
end

-- used to remove taming faction and send a variable to the client script to make unpickable
function MakeUntameable(self)
	-- check the skunks taming state. 5 means the pet is currently being tamed. This checks if that is false
	if self:GetPetHasState{iStateType = 5}.bHasState == true then return end
	--make the pet non tamable
	self:SetNetworkVar("bIAmTamable", false)
	-- change faction to faction that hates the player, but the player doesnt hate
	self:SetFaction{faction = 114}
	-- refill health
	self:SetHealth{health = 5}
	-- play the damaging effect
	for key,num in ipairs(petData[self:GetVar("CurrentPet")].FX) do
		self:PlayFXEffect{name = "FXname"..key, effectID = num, effectType = "create"}
	end
	self:SetPetsTamableState{bTamable = false}
end

-- custom function to make the pet not evil
function ClearEffects(self,msg)
	-- change faction
	self:SetFaction{faction = 99}
	-- clear threat list
	self:ClearThreatList{}

	for key,num in ipairs(petData[self:GetVar("CurrentPet")].FX) do
		-- turn off damaging fx
		self:StopFXEffect{name = "FXname"..key}
	end

end
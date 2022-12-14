-- Script that updates all missions leading upto joining a faction for 1.9 release bug fixes.
-- 
-- created mrb... 7/15/11 1727

-- test object 16505

local missionUpdateList = 
{
	-- hidden achievment for player update and bypassing requirements
	{ID = 2061, bAdd = false, bComplete = true, items = {{lot = -1, num = -1}}}, 
	-- Wake Up Call
	{ID = 1727, bAdd = true, bComplete = true, items = {{lot = -1, num = -1}}},
	-- Your Creative Spark
	{ID = 173, bAdd = true, bComplete = true, items = {{lot = -1, num = -1}}},
	-- Unlock Your Imagination
	{ID = 664, bAdd = false, bComplete = true, items = {{lot = -1, num = -1}}},
	-- Bounce to Sky Lane
	{ID = 660, bAdd = true, bComplete = true, items = {{lot = -1, num = -1}}},
	-- Venture into Knowledge
	{ID = 1896, bAdd = true, bComplete = true, items = {{lot = -1, num = -1}}},
	-- Not Enough Lifepods?
	{ID = 308, bAdd = true, bComplete = true, items = {{lot = 6086, num = 1}}},
	-- Escape the Venture Explorer
	{ID = 1732, bAdd = true, bComplete = true, items = {{lot = -1, num = -1}}},
	-- Get Help!
	{ID = 311, bAdd = true, bComplete = true, items = {{lot = 4880, num = 1}, {lot = 4881, num = 1}, {lot = 4883, num = 1}}},
	-- To Arms!
	{ID = 755, bAdd = true, bComplete = true, items = {{lot = -1, num = -1}}},
	-- Smash or Be Smashed
	{ID = 312, bAdd = true, bComplete = true, items = {{lot = -1, num = -1}}},
	-- Report In!
	{ID = 314, bAdd = true, bComplete = true, items = {{lot = -1, num = -1}}},
	-- Respect My Authority
	{ID = 315, bAdd = true, bComplete = true, items = {{lot = -1, num = -1}}},
	-- Sentinel Shine
	{ID = 733, bAdd = true, bComplete = true, items = {{lot = 1726, num = 1}}},
	-- Fortify the Front
	{ID = 316, bAdd = true, bComplete = true, items = {{lot = -1, num = -1}}},
	-- The Sentinel Shield
	{ID = 939, bAdd = true, bComplete = true, items = {{lot = -1, num = -1}}},
	-- Your Action Bar
	{ID = 940, bAdd = true, bComplete = true, items = {{lot = 3039, num = 5},{lot = 6207, num = 1}}},
	-- Impress the Sentinel Faction
	{ID = 479, bAdd = true, bComplete = true, items = {{lot = -1, num = -1}}},
	-- Seal of Approval
	{ID = 1847, bAdd = true, bComplete = true, items = {{lot = -1, num = -1}}},
	-- Following the Trail
	{ID = 1848, bAdd = true, bComplete = true, items = {{lot = -1, num = -1}}},
	-- Secrets of the Maelstrom
	{ID = 477, bAdd = true, bComplete = true, items = {{lot = 2198, num = 3}}},
	-- Slot Five
	{ID = 1151, bAdd = true, bComplete = true, items = {{lot = -1, num = -1}}},
	-- Following the Trail
	{ID = 1849, bAdd = true, bComplete = true, items = {{lot = -1, num = -1}}},
	-- Lightning Strikes Twice
	{ID = 1850, bAdd = true, bComplete = true, items = {{lot = -1, num = -1}}},
	-- Paradox Approval
	{ID = 1851, bAdd = true, bComplete = true, items = {{lot = -1, num = -1}}},
	-- Agent Foxtrot
	{ID = 1852, bAdd = true, bComplete = true, items = {{lot = -1, num = -1}}},
	-- Borrowed Gear
	{ID = 1935, bAdd = true, bComplete = true, items = {{lot = -1, num = -1}}},
	-- Spider Fighter
	{ID = 313, bAdd = true, bComplete = true, items = {{lot = 1966, num = 3}}},
	-- Recon Report
	{ID = 1853, bAdd = true, bComplete = true, items = {{lot = -1, num = -1}}},
	-- Hall Pass
	{ID = 1936, bAdd = true, bComplete = true, items = {{lot = -1, num = -1}}},
	-- Talk to Rusty
	{ID = 317, bAdd = true, bComplete = true, items = {{lot = -1, num = -1}}},
	-- Laser Rampage
	{ID = 1854, bAdd = true, bComplete = true, items = {{lot = -1, num = -1}}},
	-- Monumental Repairs
	{ID = 1855, bAdd = true, bComplete = true, items = {{lot = -1, num = -1}}},
	-- Scarecrow
	{ID = 1856, bAdd = true, bComplete = true, items = {{lot = 9721, num = 1},{lot = 10396, num = 1}}},
	-- A Monumental View
	{ID = 318, bAdd = true, bComplete = true, items = {{lot = 9722, num = 1},{lot = 10397, num = 1}}},
	-- Infested!
	{ID = 633, bAdd = true, bComplete = true, items = {{lot = 9723, num = 1},{lot = 10398, num = 1}}},
	-- Back-up Bulwark!
	{ID = 377, bAdd = true, bComplete = true, items = {{lot = -1, num = -1}}},
	-- One Size Fits All
	{ID = 1950, bAdd = true, bComplete = true, items = {{lot = -1, num = -1}}},
	-- Arachnophobia
	{ID = 768, bAdd = true, bComplete = true, items = {{lot = 9724, num = 1},{lot = 10399, num = 1}}},
	-- Check In with Sky Lane
	{ID = 320, bAdd = true, bComplete = true, items = {{lot = 6199, num = 1},{lot = 6198, num = 1},{lot = 6197, num = 1}}},
	-- Faction Time
	{ID = 483, bAdd = true, bComplete = true, items = {{lot = -1, num = -1}}},
	-- Find Mardolf the Orange
	{ID = 476, bAdd = true, bComplete = true, items = {{lot = 9516, num = 1},{lot = 9517, num = 1},{lot = 9518, num = 1}}},
	-- Rocket Builder
	{ID = 809, bAdd = true, bComplete = true, items = {{lot = -1, num = -1}}},
	-- Back to Nexus Jay
	{ID = 475, bAdd = true, bComplete = true, items = {{lot = 3039, num = 2}}},
	-- Find Johnny Thunder
	{ID = 478, bAdd = true, bComplete = true, items = {{lot = -1, num = -1}}},
	-- A Thunderous Collection
	{ID = 482, bAdd = true, bComplete = true, items = {{lot = -1, num = -1}}},
	-- Choose a Faction
	{ID = 474, bAdd = true, bComplete = false, items = {{lot = -1, num = -1}}},
}

local flagUpdateList = { 2, 6, 7, 9, 12, 13, 26, 27, 30,  37, 38, 41, 42, 44, 54, 66, 71, 74, 83, 100 }

function onStartup(self) 
	--print("*****************************")
    --print("** Checking Character Vers **")
    
    local player = self:GetParentObj().objIDParent
    
    if not player:Exists() then return end
    
    local info = player:GetCharacterVersionInfo()
	--print("*** oldVersion = " .. info.oldVersion .. " ***")
	--print("*** newVersion = " .. info.newVersion .. " ***")    
	--print("****                     ****")
	
    -- update player for 1.9
    if (info.oldVersion == 0 and info.newVersion == 1) then    
		--print("** Update missions for 1.9 **") 
		if GetZoneVisited(self, player, 1100) then
			-- set player flags
			for k, flag in ipairs(flagUpdateList) do
				player:SetFlag{iFlagID = flag, bFlag = true}
			end
			
			-- update missions
			for k,set in ipairs(missionUpdateList) do
				local state = player:GetMissionState{missionID = set.ID}.missionState 
				
				if state < 2 and set.bAdd then
					player:AddMission{missionID = set.ID}
					--print("** AddMission = ".. set.ID .. " state = " .. state .. " **")
				end
					
				if state < 8 and set.bComplete then
					player:CompleteMission{missionID = set.ID, bShouldGiveRewards = false}
					--print("** CompleteMission = ".. set.ID .. " state = " .. state .. " **")
					
					for k, itemSet in ipairs(set.items) do
						if itemSet.lot ~= -1 then
							-- MailRewardItem to the player
							player:MailRewardItem{templateID = itemSet.lot, itemCount = itemSet.num, subjectText = "MYTHRAN_REWARD_EMAIL_TITLE", bodyText = "MYTHRAN_REWARD_EMAIL_BODY", showRewardIcon=false}
						end
					end
					
					-- if the player needs to complete the imagination mission we need to set imagination, should never happen
					if set.ID == 173 then
						player:SetImagination{ imagination = 6 }				
					end
				end
			end	
		else
			-- player is still on the space ship so update new first mission
			player:AddMission{missionID = 1727}
				
			-- existing player has accepted 173 so complete first mission
			if player:GetMissionState{missionID = 173}.missionState > 1 then
				player:CompleteMission{missionID = 1727, bShouldGiveRewards = false}
			end
			
			-- existing player is on not enough life pods mission so add/complete mission hud
			if player:GetMissionState{missionID = 308}.missionState > 1 then
				player:AddMission{missionID = 1896}
				player:CompleteMission{missionID = 1896, bShouldGiveRewards = false}			
			end
			
			-- clear stunned state and end cinematic incase the player is in the opening cinematic volume
			player:SetStunned{ StateChangeType = "POP", bCantMove = true, bCantTurn = true, bCantAttack = true, bCantEquip = true }
			player:EndCinematic()
		end
	end
	
	--print("*****************************")
	
	GAMEOBJ:DeleteObject(self)
end 

function GetZoneVisited(self, player, mapID)    		
	local visitedZones = player:GetLocationsVisited().locations or {}
	
	-- check if the player has been to NT and show the choicebox
	for k, zoneID in ipairs(visitedZones) do
		if zoneID == mapID then				
			return true
		end
	end		
	
	return false							
end 
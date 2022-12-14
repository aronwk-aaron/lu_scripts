--------------------------------------------------------------
-- AG Survival Instance Server Zone Script: Including this 
-- file lets you set the custom variables for the Survival game.
--
-- created mrb... 10/26/10 
-- updated pml... 12/7/10 wave iteration
-- updated mrb... 7/18/11 - updated for solo missions
--------------------------------------------------------------

--------------------------------------------------------------
-- Includes
--------------------------------------------------------------
require('02_server/Minigame/Waves/L_BASE_WAVES_SERVER')

--//////////////////////////////////////////////////////////////////////////////////

-- User Config local variables
gConstants = 
{
    acceptedDelay = 60,         -- how long to wait after one person has presed start to start the match
    startDelay = 2,             -- how long to wait after all the players have accepted before starting the game.
    waveTime = 6,               -- how often to spawn a new wave of mobs, UI will display 1 second less than this number
    eventGroup = "suprise",     -- global event group name, this can be overriden per wave using optEventGroup in the wavePreload table
    waveCompleteDelay = 2,		-- how long to leave the wave Complete UI on the screen
    introCelebration = "intro",
    
    -- **** uncomment and set these two variables to override TransferToLastNonInstance ****
    --returnZone = 1200,          -- map number the player will return to on exit
    --returnLoc = {x = 131.83, y = 376, z = -180.31, rx = 0, ry = -0.268720, rz = 0, rw = 0.963218} --location that the player will be teleported to in the returnZone on exit
    -- *************************************************************************************
}
--============================================================
-- table of variables of the object LOT's to spawn in
spawnLOTs = 
{   
    stromling = 12586, mech = 12587, spiderling = 12588,
    pirate = 12589, admiral = 12590, ape_boss = 12591,
    stromling_boss = 12600, hammerling = 12602, sentry = 12604,
    spiderling_ve = 12605, spiderling_boss = 12609, ronin = 12610,
    cavalry = 12611, dragon_boss = 12612, stromling_minifig = 12586,
    mushroom = 12614, maelstrom_chest = 4894, outhouse = 12616,
    dragon_statue = 12617, treasure_chest = 12423, hammerling_melee = 12653,
    maelstrom_geyser = 10314, ronin_statue = 12611, horseman_boss01 = 11999,
    horseman_boss02 = 12467, horseman_boss03 = 12468, horseman_boss04 = 12469,
    admiral_cp = 13523, 
}
                    
-- table of variables of the spawner names in the map
spawnerNames = 
{   
    interior_A = "Base_MobA", interior_B = "Base_MobB",	interior_C = "Base_MobC",
    gf_A = "MobA_01", gf_B = "MobB_01", gf_C = "MobC_01",
    concert_A = "MobA_02", concert_B = "MobB_02", concert_C = "MobC_02",
    ag_A = "MobA_03", ag_B = "MobB_03", ag_C = "MobC_03",       
    Reward_01 = "Reward_01", interior_Reward = "Base_Reward", Obstacle = "Obstacle_01",
    Boss = "Boss", Ape_Boss = "Ape_Boss", Geyser = "Geyser_01", Treasure_01 = "Treasure_01",
    Cavalry_Boss = "Cavalry_Boss", Horseman_01 = "Horseman_01", Horseman_02 = "Horseman_02",
    Horseman_03 = "Horseman_03", Horseman_04 = "Horseman_04",
}

cinematics = 
{	
	boss1 = "Stromling_Boss", boss2 = "Gorilla_Boss", 
	boss3 = "Spiderling_Boss", 	boss4 = "Horsemen_Boss", 
	treasure1 = "Treasure_Camera",
}

tTimedMissions =  
{	
	{time  = 190, wave = 7, misID = 1242},
	{time  = 240, wave = 7, misID = 1226},
	{time  = 450, wave = 15, misID = 1243},
	{time  = 600, wave = 15, misID = 1227},
	{time  = 720, wave = 22, misID = 1244},
	{time  = 840, wave = 22, misID = 1228},
	{time  = 1080, wave = 29, misID = 1245},
	{time  = 1200, wave = 29, misID = 1229},
}

-- wavePreloads is a nested table of the wave load outs there should be one table for each wave
-- FORMAT: 
--{-- Wave # -------------------------- **
--    {LOT = spawnerName.Var, num = #toSpawn, name = spawnerNames.Var}, -- keep repeating in the same format for each different spawnerNetwork
--    winDelay = #timeBeforeGameRestarts,   -- adding this will end the game after x seconds
--    winNotify = true,                     -- adding this as true will make the game wait for a NotifyObject call to start the winDelay 
--    optTime = 10,                         -- adding this will make the wave have a timed count down instead of waiting for the mobs to die, mainly used for reward waves
--    optEvent = "eventToFire",             -- adding this will fire an event at the begining of a wave
--    optEventGroup = "eventGroupName",		-- adding this will override the default gConstants.eventGroup for this wave
--	  optCelebration = "final",				-- adding this will play the specified celebration for the celebrations table below
--	  optCinematic = cinematics.boss1,		-- adding this will play a cinematic at the beginning of the wave
--	  updateMissions = {missionID_1, missionID_2, etc...}		-- adding this will update the table of missions/achievements at the end of the wave
--	  soloUpdateMissions = {missionID_1, missionID_2, etc...}	-- adding this will update the table of missions/achievements at the end of the wave for solo missions
--}, 
wavePreloads =  
{       
    {-- ** Wave 1 -------------------------- **
        {LOT = spawnLOTs.stromling_minifig, num = 8, name = spawnerNames.interior_A,},
        {LOT = spawnLOTs.stromling_minifig, num = 2, name = spawnerNames.ag_A,},
        {LOT = spawnLOTs.stromling_minifig, num = 2, name = spawnerNames.concert_A,},
        {LOT = spawnLOTs.stromling_minifig, num = 2, name = spawnerNames.gf_A,},
    },
    {-- ** Wave 2 -------------------------- **
        {LOT = spawnLOTs.stromling, num = 8, name = spawnerNames.interior_A,},
        {LOT = spawnLOTs.stromling, num = 2, name = spawnerNames.ag_A,},
        {LOT = spawnLOTs.stromling, num = 2, name = spawnerNames.concert_A,},
        {LOT = spawnLOTs.stromling, num = 2, name = spawnerNames.gf_A,},
    },                        
    {-- ** Wave 3 -------------------------- **
        {LOT = spawnLOTs.stromling, num = 4, name = spawnerNames.interior_A,},
        {LOT = spawnLOTs.mech, num = 2, name = spawnerNames.interior_B,},
        {LOT = spawnLOTs.stromling, num = 3, name = spawnerNames.ag_A,},
        {LOT = spawnLOTs.stromling, num = 3, name = spawnerNames.concert_A,},
        {LOT = spawnLOTs.stromling, num = 3, name = spawnerNames.gf_A,},
    },
    {-- ** Wave 4 -------------------------- **
        {LOT = spawnLOTs.stromling, num = 3, name = spawnerNames.interior_A,},
        {LOT = spawnLOTs.mech, num = 1, name = spawnerNames.interior_B,},
        {LOT = spawnLOTs.stromling, num = 2, name = spawnerNames.ag_A,},
        {LOT = spawnLOTs.mech, num = 1, name = spawnerNames.ag_B,},
        {LOT = spawnLOTs.stromling, num = 2, name = spawnerNames.concert_A,},
        {LOT = spawnLOTs.mech, num = 1, name = spawnerNames.concert_B,},
        {LOT = spawnLOTs.stromling, num = 2, name = spawnerNames.gf_A,},
        {LOT = spawnLOTs.mech, num = 1, name = spawnerNames.gf_B,},
    },
    {-- ** Wave 5 -------------------------- **
        {LOT = spawnLOTs.stromling, num = 2, name = spawnerNames.interior_A,},
        {LOT = spawnLOTs.spiderling, num = 1, name = spawnerNames.interior_C,},   
        {LOT = spawnLOTs.hammerling_melee, num = 2, name = spawnerNames.ag_A,},
        {LOT = spawnLOTs.mech, num = 1, name = spawnerNames.ag_B,},
        {LOT = spawnLOTs.stromling, num = 1, name = spawnerNames.concert_A,},
        {LOT = spawnLOTs.mech, num = 1, name = spawnerNames.concert_B,},
        {LOT = spawnLOTs.stromling, num = 1, name = spawnerNames.gf_A,},
        {LOT = spawnLOTs.mech, num = 1, name = spawnerNames.gf_B,},
    },
    {-- ** Wave 6 -------------------------- **
        {LOT = spawnLOTs.hammerling_melee, num = 1, name = spawnerNames.interior_A,},
        {LOT = spawnLOTs.mech, num = 2, name = spawnerNames.interior_B,},
        {LOT = spawnLOTs.spiderling, num = 1, name = spawnerNames.interior_C,},
        {LOT = spawnLOTs.hammerling_melee, num = 2, name = spawnerNames.ag_A,},
        {LOT = spawnLOTs.mech, num = 1, name = spawnerNames.ag_B,},
        {LOT = spawnLOTs.spiderling, num = 1, name = spawnerNames.ag_C,},
        {LOT = spawnLOTs.stromling, num = 2, name = spawnerNames.concert_A,},
        {LOT = spawnLOTs.mech, num = 1, name = spawnerNames.concert_B,},
        --{LOT = spawnLOTs.spiderling, num = 1, name = spawnerNames.concert_C,},
        {LOT = spawnLOTs.stromling, num = 2, name = spawnerNames.gf_A,},
        {LOT = spawnLOTs.mech, num = 1, name = spawnerNames.gf_B,},
        --{LOT = spawnLOTs.spiderling, num = 1, name = spawnerNames.gf_C,},
    },
    {-- ** Wave 7 -------------------------- **
        {LOT = spawnLOTs.stromling_boss, num = 1, name = spawnerNames.Boss},
        optCinematic = cinematics.boss1,
        soloUpdateMissions = {1885},
    },
    {-- ** Wave 8 -------------------------- **
        {LOT = spawnLOTs.mushroom, num = 6, name = spawnerNames.Reward_01,},
        {LOT = spawnLOTs.mushroom, num = 3, name = spawnerNames.interior_Reward,},
        --{LOT = spawnLOTs.maelstrom_chest, num = 6, name = spawnerNames.Obstacle,},
        --{LOT = spawnLOTs.maelstrom_chest, num = 3, name = spawnerNames.Geyser,},
        optTime = 25,
    },
    {-- ** Wave 9 -------------------------- **
        {LOT = spawnLOTs.pirate, num = 4, name = spawnerNames.interior_A,},
        {LOT = spawnLOTs.pirate, num = 2, name = spawnerNames.concert_A,},
        {LOT = spawnLOTs.pirate, num = 2, name = spawnerNames.gf_A,},
        {LOT = spawnLOTs.admiral, num = 1, name = spawnerNames.gf_B,},
    },         
    {-- ** Wave 10 -------------------------- **
        {LOT = spawnLOTs.pirate, num = 4, name = spawnerNames.interior_A,},
        {LOT = spawnLOTs.mech, num = 2, name = spawnerNames.interior_B,},
        {LOT = spawnLOTs.pirate, num = 2, name = spawnerNames.ag_A,},
        {LOT = spawnLOTs.mech, num = 1, name = spawnerNames.ag_B,},
        {LOT = spawnLOTs.pirate, num = 2, name = spawnerNames.concert_A,},
        {LOT = spawnLOTs.mech, num = 1, name = spawnerNames.concert_B,},
        {LOT = spawnLOTs.pirate, num = 2, name = spawnerNames.gf_A,},
        {LOT = spawnLOTs.admiral, num = 2, name = spawnerNames.gf_B,},
    },               
    {-- ** Wave 11 -------------------------- **
        {LOT = spawnLOTs.pirate, num = 4, name = spawnerNames.interior_A,},
        {LOT = spawnLOTs.spiderling, num = 2, name = spawnerNames.interior_C,},
        {LOT = spawnLOTs.pirate, num = 2, name = spawnerNames.ag_A,},
        {LOT = spawnLOTs.spiderling, num = 1, name = spawnerNames.ag_C,},
        {LOT = spawnLOTs.pirate, num = 2, name = spawnerNames.concert_A,},
        {LOT = spawnLOTs.spiderling, num = 1, name = spawnerNames.concert_C,},
        {LOT = spawnLOTs.pirate, num = 2, name = spawnerNames.gf_A,},
        {LOT = spawnLOTs.spiderling, num = 1, name = spawnerNames.gf_C,},
    },
    {-- ** Wave 12 -------------------------- **
        {LOT = spawnLOTs.pirate, num = 4, name = spawnerNames.interior_A,},
        {LOT = spawnLOTs.hammerling, num = 2, name = spawnerNames.interior_B,},
        {LOT = spawnLOTs.spiderling, num = 2, name = spawnerNames.interior_C,},
        {LOT = spawnLOTs.mech, num = 2, name = spawnerNames.ag_B,},
        {LOT = spawnLOTs.spiderling, num = 1, name = spawnerNames.ag_C,},
        {LOT = spawnLOTs.pirate, num = 2, name = spawnerNames.concert_A,},
        {LOT = spawnLOTs.admiral, num = 1, name = spawnerNames.concert_C,},
        {LOT = spawnLOTs.pirate, num = 2, name = spawnerNames.gf_A,},
        {LOT = spawnLOTs.admiral, num = 1, name = spawnerNames.gf_C,},
    },
    {-- ** Wave 13 -------------------------- **
        {LOT = spawnLOTs.pirate, num = 3, name = spawnerNames.interior_A,},
        {LOT = spawnLOTs.admiral, num = 2, name = spawnerNames.interior_B,},
        {LOT = spawnLOTs.pirate, num = 2, name = spawnerNames.ag_A,},
        {LOT = spawnLOTs.admiral, num = 1, name = spawnerNames.ag_B,},
        {LOT = spawnLOTs.pirate, num = 2, name = spawnerNames.concert_A,},
        {LOT = spawnLOTs.admiral, num = 1, name = spawnerNames.concert_B,},
        {LOT = spawnLOTs.pirate, num = 2, name = spawnerNames.gf_A,},
        {LOT = spawnLOTs.admiral, num = 1, name = spawnerNames.gf_B,},
    },
    {-- ** Wave 14 -------------------------- **
        {LOT = spawnLOTs.pirate, num = 2, name = spawnerNames.interior_A,},
        {LOT = spawnLOTs.admiral, num = 2, name = spawnerNames.interior_B,},
        {LOT = spawnLOTs.mech, num = 2, name = spawnerNames.interior_C,},
        {LOT = spawnLOTs.pirate, num = 2, name = spawnerNames.ag_A,},
        {LOT = spawnLOTs.admiral, num = 1, name = spawnerNames.ag_B,},
        {LOT = spawnLOTs.mech, num = 1, name = spawnerNames.ag_C,},
        {LOT = spawnLOTs.pirate, num = 2, name = spawnerNames.concert_A,},
        {LOT = spawnLOTs.admiral, num = 1, name = spawnerNames.concert_B,},
        {LOT = spawnLOTs.mech, num = 1, name = spawnerNames.concert_C,},
        {LOT = spawnLOTs.pirate, num = 2, name = spawnerNames.gf_A,},
        {LOT = spawnLOTs.admiral, num = 1, name = spawnerNames.gf_B,},
        {LOT = spawnLOTs.mech, num = 1, name = spawnerNames.gf_C,},
    },
    {-- ** Wave 15 -------------------------- **
        {LOT = spawnLOTs.ape_boss, num = 1, name = spawnerNames.Ape_Boss},
        optCinematic = cinematics.boss2,
        soloUpdateMissions = {1886},
    },
    {-- ** Wave 16 -------------------------- **
        {LOT = spawnLOTs.outhouse, num = 3, name = spawnerNames.interior_Reward,},
        {LOT = spawnLOTs.mushroom, num = 6, name = spawnerNames.Reward_01,},
        --{LOT = spawnLOTs.maelstrom_chest, num = 6, name = spawnerNames.Obstacle,},
        --{LOT = spawnLOTs.maelstrom_chest, num = 3, name = spawnerNames.Geyser,},
        optTime = 25,
    },
    {-- ** Wave 17 -------------------------- **
        {LOT = spawnLOTs.hammerling_melee, num = 2, name = spawnerNames.interior_A,},
        {LOT = spawnLOTs.hammerling_melee, num = 2, name = spawnerNames.interior_B,},
        {LOT = spawnLOTs.hammerling_melee, num = 1, name = spawnerNames.ag_A,},
        {LOT = spawnLOTs.hammerling_melee, num = 2, name = spawnerNames.ag_B,},
        {LOT = spawnLOTs.hammerling_melee, num = 1, name = spawnerNames.concert_A,},
        {LOT = spawnLOTs.hammerling_melee, num = 2, name = spawnerNames.concert_B,},
        {LOT = spawnLOTs.hammerling_melee, num = 1, name = spawnerNames.gf_A,},
        {LOT = spawnLOTs.hammerling_melee, num = 2, name = spawnerNames.gf_B,},
    },
    {-- ** Wave 18 -------------------------- **
        {LOT = spawnLOTs.hammerling_melee, num = 4, name = spawnerNames.interior_A,},
        {LOT = spawnLOTs.hammerling, num = 2, name = spawnerNames.interior_B,},
        {LOT = spawnLOTs.hammerling_melee, num = 2, name = spawnerNames.concert_A,},
        {LOT = spawnLOTs.hammerling, num = 1, name = spawnerNames.concert_B,},
        {LOT = spawnLOTs.hammerling_melee, num = 2, name = spawnerNames.ag_A,},
        {LOT = spawnLOTs.hammerling, num = 1, name = spawnerNames.ag_B,},
        {LOT = spawnLOTs.hammerling_melee, num = 2, name = spawnerNames.gf_A,},
        {LOT = spawnLOTs.hammerling, num = 1, name = spawnerNames.gf_B,},
    },
    {-- ** Wave 19 -------------------------- **
        {LOT = spawnLOTs.hammerling, num = 4, name = spawnerNames.interior_A,},
        {LOT = spawnLOTs.sentry, num = 2, name = spawnerNames.interior_B,},
        {LOT = spawnLOTs.hammerling, num = 2, name = spawnerNames.ag_A,},
        {LOT = spawnLOTs.sentry, num = 1, name = spawnerNames.ag_B,},
        {LOT = spawnLOTs.hammerling, num = 2, name = spawnerNames.concert_A,},
        {LOT = spawnLOTs.sentry, num = 1, name = spawnerNames.concert_B,},
        {LOT = spawnLOTs.hammerling, num = 2, name = spawnerNames.gf_A,},
        {LOT = spawnLOTs.sentry, num = 1, name = spawnerNames.gf_B,},
    },
    {-- ** Wave 20 -------------------------- **
        {LOT = spawnLOTs.ronin, num = 3, name = spawnerNames.interior_A,},
        {LOT = spawnLOTs.sentry, num = 2, name = spawnerNames.interior_B,},
        {LOT = spawnLOTs.spiderling_ve, num = 1, name = spawnerNames.interior_C,},
        {LOT = spawnLOTs.hammerling, num = 1, name = spawnerNames.ag_A,},
        {LOT = spawnLOTs.sentry, num = 1, name = spawnerNames.ag_B,},
        {LOT = spawnLOTs.spiderling_ve, num = 1, name = spawnerNames.ag_C,},
        {LOT = spawnLOTs.hammerling, num = 1, name = spawnerNames.concert_A,},
        {LOT = spawnLOTs.sentry, num = 1, name = spawnerNames.concert_B,},
        {LOT = spawnLOTs.spiderling_ve, num = 1, name = spawnerNames.concert_C,},
        {LOT = spawnLOTs.hammerling, num = 1, name = spawnerNames.gf_A,},
        {LOT = spawnLOTs.sentry, num = 1, name = spawnerNames.gf_B,},
        {LOT = spawnLOTs.spiderling_ve, num = 1, name = spawnerNames.gf_C,},
    },
    {-- ** Wave 21 -------------------------- **
        {LOT = spawnLOTs.admiral, num = 2, name = spawnerNames.interior_A,},
        {LOT = spawnLOTs.ronin, num = 2, name = spawnerNames.interior_B,},
        {LOT = spawnLOTs.spiderling_ve, num = 2, name = spawnerNames.interior_C,},
        {LOT = spawnLOTs.admiral, num = 1, name = spawnerNames.ag_A,},
        {LOT = spawnLOTs.ronin, num = 1, name = spawnerNames.ag_B,},
        {LOT = spawnLOTs.spiderling_ve, num = 1, name = spawnerNames.ag_C,},
        {LOT = spawnLOTs.admiral, num = 1, name = spawnerNames.concert_A,},
        {LOT = spawnLOTs.ronin, num = 1, name = spawnerNames.concert_B,},
        {LOT = spawnLOTs.spiderling_ve, num = 1, name = spawnerNames.concert_C,},
        {LOT = spawnLOTs.admiral, num = 1, name = spawnerNames.gf_A,},
        {LOT = spawnLOTs.ronin, num = 1, name = spawnerNames.gf_B,},
        {LOT = spawnLOTs.spiderling_ve, num = 1, name = spawnerNames.gf_C,},
    },
    {-- ** Wave 22 -------------------------- **
        {LOT = spawnLOTs.spiderling_boss, num = 1, name = spawnerNames.Cavalry_Boss},
        optCinematic = cinematics.boss3,
        soloUpdateMissions = {1887},
    },
    {-- ** Wave 23 -------------------------- **
        {LOT = spawnLOTs.outhouse, num = 6, name = spawnerNames.Reward_01,},
        {LOT = spawnLOTs.outhouse, num = 3, name = spawnerNames.interior_Reward,},
        {LOT = spawnLOTs.maelstrom_chest, num = 4, name = spawnerNames.Obstacle,},
        --{LOT = spawnLOTs.maelstrom_chest, num = 3, name = spawnerNames.Geyser,},       
        optTime = 25,
    },
    {-- ** Wave 24 -------------------------- **
        {LOT = spawnLOTs.pirate, num = 2, name = spawnerNames.gf_A,},
        {LOT = spawnLOTs.pirate, num = 2, name = spawnerNames.concert_A,},
        {LOT = spawnLOTs.pirate, num = 3, name = spawnerNames.ag_A,},
        {LOT = spawnLOTs.ronin, num = 3, name = spawnerNames.interior_A,},
        {LOT = spawnLOTs.ronin, num = 2, name = spawnerNames.interior_B,},
    },
    {-- ** Wave 25 -------------------------- **
        {LOT = spawnLOTs.cavalry, num = 2, name = spawnerNames.interior_A,},
        {LOT = spawnLOTs.cavalry, num = 1, name = spawnerNames.interior_B,},
        {LOT = spawnLOTs.admiral_cp, num = 1, name = spawnerNames.ag_B,},
        {LOT = spawnLOTs.admiral_cp, num = 1, name = spawnerNames.gf_B,},
        {LOT = spawnLOTs.admiral_cp, num = 1, name = spawnerNames.concert_B,},
        {LOT = spawnLOTs.spiderling, num = 2, name = spawnerNames.gf_A,},
        {LOT = spawnLOTs.spiderling, num = 2, name = spawnerNames.concert_A,},
        {LOT = spawnLOTs.spiderling, num = 1, name = spawnerNames.ag_A,},
    },
    {-- ** Wave 26 -------------------------- **
        {LOT = spawnLOTs.ronin, num = 3, name = spawnerNames.interior_A,},
        {LOT = spawnLOTs.ronin, num = 3, name = spawnerNames.interior_B,},
        {LOT = spawnLOTs.spiderling_ve, num = 1, name = spawnerNames.ag_B,},
        {LOT = spawnLOTs.spiderling_ve, num = 1, name = spawnerNames.gf_B,},
        {LOT = spawnLOTs.spiderling_ve, num = 1, name = spawnerNames.concert_B,},
        {LOT = spawnLOTs.admiral_cp, num = 2, name = spawnerNames.gf_C,},
        {LOT = spawnLOTs.admiral_cp, num = 2, name = spawnerNames.ag_C,},
        {LOT = spawnLOTs.admiral_cp, num = 1, name = spawnerNames.concert_C,},
    },
    {-- ** Wave 27 -------------------------- **
        {LOT = spawnLOTs.ronin, num = 5, name = spawnerNames.interior_A,},
        {LOT = spawnLOTs.ronin, num = 4, name = spawnerNames.interior_B,},
        {LOT = spawnLOTs.cavalry, num = 1, name = spawnerNames.ag_C,},
        {LOT = spawnLOTs.cavalry, num = 1, name = spawnerNames.gf_C,},
        {LOT = spawnLOTs.cavalry, num = 1, name = spawnerNames.concert_C,},
        {LOT = spawnLOTs.admiral_cp, num = 1, name = spawnerNames.ag_B,},
        {LOT = spawnLOTs.admiral_cp, num = 1, name = spawnerNames.gf_B,},
        {LOT = spawnLOTs.admiral_cp, num = 1, name = spawnerNames.concert_B,},
    },
    {-- ** Wave 28 -------------------------- **
        --{LOT = spawnLOTs.dragon_statue, num = 3, name = spawnerNames.interior_Reward,},
        {LOT = spawnLOTs.dragon_statue, num = 12, name = spawnerNames.Reward_01,},
        optTime = 30,
    },
    {-- ** Wave 29 -------------------------- **
        {LOT = spawnLOTs.horseman_boss01, num = 1, name = spawnerNames.Horseman_01,},
        {LOT = spawnLOTs.horseman_boss02, num = 1, name = spawnerNames.Horseman_02}, 
        {LOT = spawnLOTs.horseman_boss03, num = 1, name = spawnerNames.Horseman_03},  
        {LOT = spawnLOTs.horseman_boss04, num = 1, name = spawnerNames.Horseman_04},
        optCinematic = cinematics.boss4,
        soloUpdateMissions = {1888},
        updateMissions = {1236,1237,1249},
    },
    {-- ** Wave Treasure ------------------- **
        {LOT = spawnLOTs.treasure_chest, num = 1, name = spawnerNames.Treasure_01},
        winNotify = true,
        winDelay = 60,
        optCinematic = cinematics.treasure1,
    },
}  


--//////////////////////////////////////////////////////////////////////////////////

--============================================================
-- Game messages sent to the L_BASE_WAVES_SERVER.lua file, these
-- must be in this script. Only change to add custom functionality, 
-- but leav e the base*message*(self, msg, newMsg) in the function.
--============================================================

----------------------------------------------------------------
-- Received when the script is loaded
----------------------------------------------------------------
function onStartup(self)
    -- send the configured variables to the base script
    baseStartup(self, newMsg)
end

----------------------------------------------------------------
-- Gets called when a celebration ends
----------------------------------------------------------------
function onCelebrationCompleted(self, msg)
	baseCelebrationCompleted(self, msg, newMsg)
end

----------------------------------------------------------------
-- Player has loaded into the map
----------------------------------------------------------------
function onPlayerLoaded(self, msg)
    basePlayerLoaded(self, msg, newMsg)
end

----------------------------------------------------------------
-- Player has exited the map
----------------------------------------------------------------
function onPlayerExit(self, msg)
    basePlayerExit(self, msg, newMsg)
end

----------------------------------------------------------------
-- Received a fire event messaged from the client
----------------------------------------------------------------
function onFireEventServerSide(self, msg)   
    baseFireEventServerSide(self, msg, newMsg)
end

----------------------------------------------------------------
-- Received a fire event messaged from someplace on the server
----------------------------------------------------------------
function onFireEvent(self,msg)   
    baseFireEvent(self, msg, newMsg)
end

----------------------------------------------------------------
-- A player had died
----------------------------------------------------------------
function onPlayerDied(self, msg)
    basePlayerDied(self, msg, newMsg)
end

----------------------------------------------------------------
-- A player has respawned
----------------------------------------------------------------
function onPlayerResurrected(self, msg)
    basePlayerResurrected(self, msg, newMsg)
end

----------------------------------------------------------------
-- Received a notify object message 
----------------------------------------------------------------
function onNotifyObject(self, msg)
	if msg.name ~= "Survival_Update" then return end
	    
	if UpdateSpawnedEnemies(self, msg.ObjIDSender, msg.param1) then        	
		-- get the time/wave of the player to check for mission updates
		local curTime = GetActivityValue(self, msg.ObjIDSender, 1) or 0
		local curWave = GetActivityValue(self, msg.ObjIDSender, 2) or 0
		
		for k,missionData in ipairs(tTimedMissions) do
			if curWave == missionData.wave and curTime <= missionData.time then
				UpdateMissionForAllPlayers(self, missionData.misID)
			end
		end
	end		
end

----------------------------------------------------------------
-- This is called when players hit the UI to exit or stop the game.
----------------------------------------------------------------
function onMessageBoxRespond(self,msg)
    baseMessageBoxRespond(self, msg, newMsg)
end

----------------------------------------------------------------
-- When activity is stopped this is needed to update the leaderboard.
----------------------------------------------------------------
function onDoCalculateActivityRating(self, msg)     
    return baseDoCalculateActivityRating(self,msg)
end 
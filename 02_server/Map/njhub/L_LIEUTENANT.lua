----------------------------------------
-- Server side script on the lieutenants in ninjago
-- when the lieutentant dies, he activates a spawner network that spawns a qb
--
-- created by brandi... 7/28/11
----------------------------------------

require('02_server/Enemy/General/L_ENEMY_NJ_BUFF_STUN_IMMUNITY')


local SpawnerNetworks = {
							[16047] = "EarthShrine_ERail",
							[16050] = "IceShrine_QBBouncer",
							[16049] = "LightningShrine_LRail"
						}
						
function onDie(self,msg)
	
	local myLOT = self:GetLOT().objtemplate
	
	local spawner = LEVEL:GetSpawnerByName(SpawnerNetworks[myLOT])
	
	if not spawner:Exists() then return end
	
	spawner:SpawnerReset()
	spawner:SpawnerActivate()
	
end
chestfunctions = require("scenarios/chestfunctions")
local FA_ScenarioUtil=require("scenarios/fa_helperfunctions")
chest_openfunctions = require("scenarios/chest_openfunctions")

local function OnCreate(inst, scenariorunner)


	local items = 
	{
		{
			item = {"redgem", "bluegem", "purplegem","yellowgem", "orangegem", "greengem"},
			count = math.random(1,3),
			chance = 1--0.15,
		},
		{
			item = {"goldnugget"},
			count = math.random(1,8),
			chance = 1--0.15,
		},
		{
			item={"fa_scroll_25"},
			count=1,
			chance=0.5
		}
	}
	local count=4
	local loots={}
	for i=1,count do
		loots=FA_ScenarioUtil.FA_GenerateLoot(FALLENLOOTTABLEMERGED,FALLENLOOTTABLE.TABLE_WEIGHT,1,loots)
	end
	for k,prefab in pairs(loots) do
		inst.components.container:GiveItem(SpawnPrefab(prefab))
	end
	chestfunctions.AddChestItems(inst, items)
end

local function OnDestroy(inst)
--    chestfunctions.OnDestroy(inst)
end
return
{
    OnCreate = OnCreate,
    OnDestroy = OnDestroy
}

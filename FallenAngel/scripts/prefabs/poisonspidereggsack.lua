require "prefabutil"
local assets =
{
    Asset("ANIM", "anim/poisonspider_egg_sac.zip"),
    Asset("SOUND", "sound/spider.fsb"),
    Asset("ATLAS", "images/inventoryimages/poisonspider_egg_sac.xml"),
    Asset("IMAGE", "images/inventoryimages/poisonspider_egg_sac.tex"),
}

local function ondeploy(inst, pt) 
    inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/spider_egg_sack")
    local tree = SpawnPrefab("poisonspiderden") 
    if tree then 
        tree.Transform:SetPosition(pt.x, pt.y, pt.z) 
        inst.components.stackable:Get():Remove()
    end 
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("poisonspider_egg_sac")
    inst.AnimState:SetBuild("poisonspider_egg_sac")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL
    
	MakeSmallBurnable(inst, TUNING.LARGE_BURNTIME)
    MakeSmallPropagator(inst)
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename="poisonspider_egg_sac"
    inst.components.inventoryitem.atlasname="images/inventoryimages/poisonspider_egg_sac.xml"
    
    inst.components.inventoryitem:SetOnPickupFn(function() inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/spider_egg_sack") end)
    
    inst:AddComponent("deployable")
    inst.components.deployable.test = function() return true end
    inst.components.deployable.ondeploy = ondeploy
    

    return inst
end

return Prefab( "common/inventory/poisonspidereggsack", fn, assets),
	   MakePlacer( "common/poisonspidereggsack_placer", "spider_cocoon", "spider_cocoon", "cocoon_small" ) 


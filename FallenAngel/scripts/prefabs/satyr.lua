local assets=
{
    Asset("ANIM", "anim/wilton.zip"),
}

local PET_HEALTH=300


local function GetInventory(inst)
    local item=SpawnPrefab("panflute")
    inst.components.inventory:Equip(item)
end
    
local function fn(Sim)
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    local anim=inst.entity:AddAnimState()

    local sound = inst.entity:AddSoundEmitter()
    local shadow = inst.entity:AddDynamicShadow()
    shadow:SetSize( 2.5, 1.5 )
    inst.Transform:SetTwoFaced()
    inst.Transform:SetScale(0.75, 0.75, 0.75)
   
    inst.entity:AddPhysics()
    
    inst:AddTag("monster")
    inst:AddTag("hostile")

    MakeCharacterPhysics(inst, 20, .5)

    anim:SetBank("wilson")
    anim:SetBuild("wilton")

    anim:Hide("ARM_carry")
    anim:Hide("hat")
    anim:Hide("hat_hair")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({  "meat"})
    inst:AddComponent("inventory")
--    inst:AddComponent("sanity")
    inst.components.inventory.dropondeath = true
--    inst.components.inventory.starting_inventory = inventoryrng

    GetInventory(inst)

    anim:PlayAnimation("idle")

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor.walkspeed = TUNING.WILSON_RUN_SPEED
    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED*3

    inst:AddComponent("follower")
    
    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED

    inst:AddComponent("inspectable")
        
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "torso"
    inst.components.combat:SetDefaultDamage(TUNING.HOUND_DAMAGE)
    inst.components.combat:SetAttackPeriod(2)
--    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat.areahitdamagepercent=0.0

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(PET_HEALTH)
    inst.components.health:SetInvincible(false)

     MakeMediumFreezableCharacter(inst, "torso")
     MakeMediumBurnableCharacter(inst, "torso")

--    inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_howl_LP", "howl")
    inst:SetStateGraph("SGpig")

    local brain = require "brains/skeletonspawnbrain"
    inst:SetBrain(brain)

    return inst
end

return Prefab( "common/satyr", fn, assets)
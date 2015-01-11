local assets=
{
    Asset("ANIM", "anim/fa_iceaxe.zip"),
    Asset("ANIM", "anim/swap_fa_iceaxe.zip"),
}


local ICEAXE_DAMAGE_T1=55
local ICEAXE_DAMAGE_T2=75
local ICEAXE_DAMAGE_T3=90
local ICEAXE_PROC_T1=0.05
local ICEAXE_PROC_T2=0.15
local ICEAXE_PROC_T3=0.30
local ICEAXE_ICE_PROC=50
local ICEAXE_USES_T1=150
local ICEAXE_USES_T2=250
local ICEAXE_USES_T3=375
local ICEAXE_COLDNESS=1
local FROZEN_DEBUFF_LENGTH=10

local function onfinished(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/gem_shatter")
    inst:Remove()
end

local function onattack(inst, attacker, target)
    if(target and math.random()<=inst.procRate)then
        print("proc eff")
        if  target.components.burnable and  target.components.burnable:IsBurning() then
            target.components.burnable:Extinguish()
        end
        if target.components.freezable then
            target.components.combat:GetAttacked(attacker, ICEAXE_ICE_PROC, nil,nil,FA_DAMAGETYPE.COLD)
            target.components.freezable:AddColdness(ICEAXE_COLDNESS)
            target.components.freezable:SpawnShatterFX()
            FA_BuffUtil.FrozenSlowDebuff(target,FROZEN_DEBUFF_LENGTH)
        end
    end
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_fa_iceaxe", "swap_fa_iceaxe")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
end


local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
  
    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "fa_iceaxe.tex" )

    inst.AnimState:SetBank("fa_iceaxe")
    inst.AnimState:SetBuild("fa_iceaxe")
    inst.AnimState:PlayAnimation("idle")

    inst.Transform:SetScale(2, 2, 1)
    
    inst:AddTag("sharp")
    
    inst:AddComponent("weapon")
    inst.components.weapon:SetOnAttack(onattack)
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetOnFinished( onfinished )

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename="fa_iceaxe"
    inst.components.inventoryitem.atlasname="images/inventoryimages/fa_inventoryimages.xml"
--    inst:AddComponent("dapperness")
--    inst.components.dapperness.dapperness = TUNING.CRAZINESS_MED,
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    
    return inst
end


local function t1()
    local inst =fn()
    inst:AddTag("tier1")
    inst.procRate=ICEAXE_PROC_T1
    inst.components.weapon:SetDamage(ICEAXE_DAMAGE_T1)
    inst.components.finiteuses:SetMaxUses(ICEAXE_USES_T1)
    inst.components.finiteuses:SetUses(ICEAXE_USES_T1)
    return inst
end

local function t2()
    local inst =fn()
    inst:AddTag("tier2")
    inst.procRate=ICEAXE_PROC_T2
    inst.components.weapon:SetDamage(ICEAXE_DAMAGE_T2)
    inst.components.finiteuses:SetMaxUses(ICEAXE_USES_T2)
    inst.components.finiteuses:SetUses(ICEAXE_USES_T2)
    return inst
end

local function t3()
    local inst =fn()
    inst:AddTag("tier3")
    inst.procRate=ICEAXE_PROC_T3
    inst.components.weapon:SetDamage(ICEAXE_DAMAGE_T3)
    inst.components.finiteuses:SetMaxUses(ICEAXE_USES_T3)
    inst.components.finiteuses:SetUses(ICEAXE_USES_T3)
    return inst
end

return Prefab( "common/inventory/fa_iceaxe", t1, assets),
    Prefab( "common/inventory/fa_iceaxe2", t2, assets),
    Prefab( "common/inventory/fa_iceaxe3", t3, assets) 

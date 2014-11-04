
local assets = {

        Asset( "ANIM", "anim/player_basic.zip" ),
        Asset( "ANIM", "anim/player_idles_shiver.zip" ),
        Asset( "ANIM", "anim/player_actions.zip" ),
        Asset( "ANIM", "anim/player_actions_axe.zip" ),
        Asset( "ANIM", "anim/player_actions_pickaxe.zip" ),
        Asset( "ANIM", "anim/player_actions_shovel.zip" ),
        Asset( "ANIM", "anim/player_actions_blowdart.zip" ),
        Asset( "ANIM", "anim/player_actions_eat.zip" ),
        Asset( "ANIM", "anim/player_actions_item.zip" ),
        Asset( "ANIM", "anim/player_actions_uniqueitem.zip" ),
        Asset( "ANIM", "anim/player_actions_bugnet.zip" ),
        Asset( "ANIM", "anim/player_actions_fishing.zip" ),
        Asset( "ANIM", "anim/player_actions_boomerang.zip" ),
        Asset( "ANIM", "anim/player_bush_hat.zip" ),
        Asset( "ANIM", "anim/player_attacks.zip" ),
        Asset( "ANIM", "anim/player_idles.zip" ),
        Asset( "ANIM", "anim/player_rebirth.zip" ),
        Asset( "ANIM", "anim/player_jump.zip" ),
        Asset( "ANIM", "anim/player_amulet_resurrect.zip" ),
        Asset( "ANIM", "anim/player_teleport.zip" ),
        Asset( "ANIM", "anim/wilson_fx.zip" ),
        Asset( "ANIM", "anim/player_one_man_band.zip" ),
        Asset( "ANIM", "anim/shadow_hands.zip" ),
        Asset( "SOUND", "sound/sfx.fsb" ),
        Asset( "SOUND", "sound/wilson.fsb" ),
        Asset( "ANIM", "anim/beard.zip" ),
        Asset( "ANIM", "anim/wortox.zip" ),
}
local prefabs = {}

local TARGET_DISTANCE=30

local function RetargetFn(inst)

    local defenseTarget = inst
    local invader=nil
    local home = inst.components.homeseeker and inst.components.homeseeker.home
    if home and inst:GetDistanceSqToInst(home) < TUNING.MERM_DEFEND_DIST*TUNING.MERM_DEFEND_DIST then
       invader = FindEntity(home, TARGET_DISTANCE, function(guy)
        return guy:HasTag("character") 
    end)
    end
    if not invader then
        invader = FindEntity(inst, TARGET_DISTANCE, function(guy)
        return guy:HasTag("character") 
        end)
    end
    return invader

end
local function KeepTargetFn(inst, target)
    local home = inst.components.homeseeker and inst.components.homeseeker.home
    if home then
        return home:GetDistanceSqToInst(target) < TUNING.MERM_DEFEND_DIST*TUNING.MERM_DEFEND_DIST
               and home:GetDistanceSqToInst(inst) < TUNING.MERM_DEFEND_DIST*TUNING.MERM_DEFEND_DIST
    end
    return inst.components.combat:CanTarget(target)     
end


local function OnBlocked(owner,data) 
    local attacker = data and data.attacker
    if attacker and owner.components.combat:CanTarget(attacker) then
        owner.components.combat:SetTarget(attacker)
    end
    if(attacker and  data.attacker.components.burnable and not data.attacker.components.fueled )then
        if(math.random()<=0.2)then
            print("reflecting to",data.attacker)
            data.attacker.components.combat:GetAttacked(owner, 20, nil,nil,FA_DAMAGETYPE.FIRE)
            data.attacker.components.burnable:Ignite()
        end
    end
end

local function demonattack(attacker,data)
    local target=data.target
    target.components.combat:GetAttacked(attacker, 20, nil,nil,FA_DAMAGETYPE.FIRE)
    if(target.components.health:IsInvincible() == false and math.random()<=0.2)then
        if(target.components.burnable and not target.components.fueled)then
            target.components.burnable:Ignite()
        end
    end
end


local function fn(Sim)
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    local anim=inst.entity:AddAnimState()

    local sound = inst.entity:AddSoundEmitter()
    local shadow = inst.entity:AddDynamicShadow()
    shadow:SetSize( 2.5, 1.5 )
--    inst.Transform:SetTwoFaced()
    inst.Transform:SetFourFaced()

--    inst.OnLoad = onloadfn
--    inst.OnSave = onsavefn

    inst.entity:AddPhysics()
 
--
    local light = inst.entity:AddLight()
    light:SetFalloff(0.9)
    light:SetIntensity(0.9)
    light:SetRadius(1)
    light:SetColour(155/255, 225/255, 250/255)
    light:Enable(true)


    anim:SetBank("wilson")
    anim:SetBuild("wortox")
    anim:PlayAnimation("idle")
    
    anim:Hide("ARM_carry")
    anim:Hide("hat")
    anim:Hide("hat_hair")
    inst:AddTag("scarytoprey")
    inst:AddTag("monster")
    inst:AddTag("hostile")

    MakeCharacterPhysics(inst, 20, .5)
 
inst:AddComponent("eater")

        inst.components.eater:SetCarnivore(true)
    inst.components.eater:SetCanEatHorrible()
        inst.components.eater.monsterimmune = true
        inst.components.eater.strongstomach = true

    

    inst:AddComponent("inventory")
--    inst:AddComponent("sanity")
    

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
--    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED

    inst:AddComponent("follower")
    
    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED

    inst:AddComponent("inspectable")
    inst:AddComponent("knownlocations")
        
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "torso"
    inst.components.combat:SetDefaultDamage(40)
    inst.components.combat:SetAttackPeriod(1)

    inst:AddComponent("health")
    inst.components.health.fa_dodgechance=0.2
    inst.components.health:SetMaxHealth(900)
        inst.components.health.fa_resistances[FA_DAMAGETYPE.FIRE]=1
        inst.components.health.fa_resistances[FA_DAMAGETYPE.COLD]=-1

    inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_howl_LP", "howl")
        inst:ListenForEvent("onattackother",demonattack) 

        inst:ListenForEvent("attacked",OnBlocked,inst)
        inst:ListenForEvent("blocked",OnBlocked, inst)
    
    return inst
end

local function mob()
    local inst=fn()
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst:SetStateGraph("SGskeletonspawn")    
    local brain = require "brains/orcbrain"
    inst:SetBrain(brain)
    return inst
end

local function npc()
    local inst=fn()

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({ "fa_ring_demon"})
    return inst
end

return Prefab( "common/fa_cursedwortox", mob, assets),
Prefab( "common/fa_cursedpigking", mob, assets),
Prefab( "common/fa_wortox_npc", npc, assets)
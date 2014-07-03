local ssassets=
{
  Asset("ANIM", "anim/armor_marble.zip"),
}
local maassets=
{
  Asset("ANIM", "anim/armor_sanity.zip"),
}
local tinyassets =
{
  Asset("ANIM", "anim/tent.zip"),
}

local STONESKINARMOR_ABSO=1
local STONESKINARMOR_DURABILITY=1000
local STONESKIN_DURATION=8*60
local MAGEARMOR_ABSO=0.6
local MAGEARMOR_DURABILITY=2^30
local MAGEARMOR_DURATION=4*60
local TINYHUT_DURATION=8*60
local SHELTER_DURATION=4*8*60

--TODO what's the best way to deal with timers? fuel would do the trick, but it would mess display. And how do I tell the timer anyway?


local function OnBlocked(owner,data) 
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_armour") 
end

local onloadfn = function(inst, data)
    if(data and data.countdown and data.countdown>0)then
        if inst.shutdowntask then
            inst.shutdowntask:Cancel()
        end
    inst.shutdowntask=inst:DoTaskInTime(data.countdown, function()
      inst:Remove()
    end)
    inst.shutdowntime=GetTime()+data.countdown
    end
end

local onsavefn = function(inst, data)
    data.countdown=inst.shutdowntime-GetTime()
end

local stoneskinonloadfn = onloadfn
local stoneskinonsavefn = onsavefn

local function stoneskinonequip(inst, owner) 

    owner.AnimState:OverrideSymbol("swap_body", "armor_marble", "swap_body")
    inst:ListenForEvent("attacked", OnBlocked,owner)
    inst:ListenForEvent("blocked",OnBlocked, owner)
end

local function stoneskinonunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst:RemoveEventCallback("blocked", OnBlocked, owner)
    inst:RemoveEventCallback("attacked", OnBlocked, owner)
end

local function stoneskinfn(Sim)
	local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("armor_marble")
    inst.AnimState:SetBuild("armor_marble")
    inst.AnimState:PlayAnimation("anim")

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "evilsword.tex" )
    
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
     inst.components.inventoryitem.atlasname = "images/inventoryimages/shield.xml"
    inst.components.inventoryitem.imagename="shield"

    inst:AddComponent("equippable")
      inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    
    inst:AddComponent("armor")
    --i have to intercept all damage types... and since it has to be ran over the rest of the armor, it cant be using the health temp logic
    inst.components.armor:InitCondition(STONESKINARMOR_DURABILITY, STONESKINARMOR_ABSO)
    
    inst.OnLoad = stoneskinonloadfn
    inst.OnSave = stoneskinonsavefn

    inst.components.equippable:SetOnEquip( stoneskinonequip )
    inst.components.equippable:SetOnUnequip( stoneskinonunequip )

    inst.shutdowntime=GetTime()+STONESKIN_DURATION
    inst.shutdowntask=inst:DoTaskInTime(STONESKIN_DURATION, function()
      inst:Remove()
    end)

    return inst
end

local function magearmoronequip(inst, owner) 
   local fx=SpawnPrefab("fa_forcefieldfx_teal")
   fx.persists=false
   local follower = fx.entity:AddFollower()
   follower:FollowSymbol( owner.GUID, owner.components.combat.hiteffectsymbol, 0, 0, -0.0001 )
   inst.fa_forcefieldfx=fx
   owner.AnimState:ClearOverrideSymbol("swap_body")
end

local function magearmoronunequip(inst, owner) 
   inst.fa_forcefieldfx:Remove()
   inst.fa_forcefieldfx=nil
    owner.AnimState:ClearOverrideSymbol("swap_body")
end

--'armor' does not save anything but remaining durability
local magearmoronloadfn = function(inst, data)
    if(data.armorabso)then
      inst.components.armor.absorb_percent=data.armorabso
    end
    if(data and data.countdown and data.countdown>0)then
        if inst.shutdowntask then
            inst.shutdowntask:Cancel()
        end
    inst.shutdowntask=inst:DoTaskInTime(data.countdown, function()
      inst:Remove()
    end)
    inst.shutdowntime=GetTime()+data.countdown
    end

end

local magearmoronsavefn = function(inst, data)
    data.countdown=inst.shutdowntime-GetTime()
    data.armorabso=inst.components.armor.absorb_percent
end

local function magearmorfn(Sim)
  local inst = CreateEntity()
    
  inst.entity:AddTransform()
  inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("armor_sanity")
    inst.AnimState:SetBuild("armor_sanity")
    inst.AnimState:PlayAnimation("anim")

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "evilsword.tex" )
    
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
     inst.components.inventoryitem.atlasname = "images/inventoryimages/shield.xml"
    inst.components.inventoryitem.imagename="shield"
    inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/nightarmour"

    inst:AddComponent("equippable")
      inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    
    inst:AddComponent("armor")
    inst.components.armor:InitCondition(MAGEARMOR_DURABILITY, MAGEARMOR_ABSO)
    
    
    inst.components.equippable:SetOnEquip( magearmoronequip )
    inst.components.equippable:SetOnUnequip( magearmoronunequip )

    inst.OnLoad = magearmoronloadfn
    inst.OnSave = magearmoronsavefn

    inst.shutdowntime=GetTime()+MAGEARMOR_DURATION
    inst.shutdowntask=inst:DoTaskInTime(MAGEARMOR_DURATION, function()
      inst:Remove()
    end)
    
    return inst
end


local function tentonfinished(inst)
  inst.AnimState:PlayAnimation("destroy")
  inst:ListenForEvent("animover", function(inst, data) inst:Remove() end)
  inst.SoundEmitter:PlaySound("dontstarve/common/tent_dis_pre")
  inst.persists = false
  inst:DoTaskInTime(16*FRAMES, function() inst.SoundEmitter:PlaySound("dontstarve/common/tent_dis_twirl") end)
end

local function tentonbuilt(inst)
  inst.AnimState:PlayAnimation("place")
  inst.AnimState:PushAnimation("idle", true)
end


local function onsleep(inst, sleeper)
  
  local hounded = GetWorld().components.hounded
  local danger = FindEntity(inst, 10, function(target) return target:HasTag("monster") or target.components.combat and target.components.combat.target == inst end)  
  if hounded and (hounded.warning or hounded.timetoattack <= 0) then
    danger = true
  end
  
  if danger then
    if sleeper.components.talker then
      sleeper.components.talker:Say(GetString(sleeper.prefab, "ANNOUNCE_NODANGERSLEEP"))
    end
    return
  end

  sleeper.components.health:SetInvincible(true)
  sleeper.components.playercontroller:Enable(false)

  GetPlayer().HUD:Hide()
  TheFrontEnd:Fade(false,1)

  inst:DoTaskInTime(1.2, function() 
    
    GetPlayer().HUD:Show()
    TheFrontEnd:Fade(true,1) 
    
    
    if sleeper.components.sanity then
      sleeper.components.sanity:SetPercent(1)
    end
    if sleeper.components.health then
      sleeper.components.health:DoDelta(TUNING.HEALING_HUGE, false, "tent", true)
    end
    
    if(FA_DLCACCESS)then
      if sleeper.components.temperature and sleeper.components.temperature.current < TUNING.TARGET_SLEEP_TEMP then
        sleeper.components.temperature:SetTemperature(TUNING.TARGET_SLEEP_TEMP)
      end 
    else    
      if sleeper.components.temperature then
        sleeper.components.temperature:SetTemperature(sleeper.components.temperature.maxtemp)
      end
    end  
    
    inst.components.finiteuses:Use()
    GetClock():MakeNextDay()

    if(sleeper.components.moisture)then
      --if its truly majic it shouldn't be 'too op' to dry you up huh? yeah im just sick of dlc code
      sleeper.components.moisture.moisture=0
    end
    
    sleeper.components.health:SetInvincible(false)
    sleeper.components.playercontroller:Enable(true)
    sleeper.sg:GoToState("wakeup")  
  end)  
  
end

local function hutfn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst:AddTag("tent")    
    
    MakeObstaclePhysics(inst, 1)    

    inst:AddTag("structure")
    anim:SetBank("tent")
    anim:SetBuild("tent")
    anim:PlayAnimation("idle", true)
    
    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "tent.png" )
  
    --[[inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = 2
    inst.components.fuel.startsize = "medium"
    --]]
    
    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")

  
      
    inst.OnLoad = onloadfn
    inst.OnSave = onsavefn

        
    inst:AddComponent("sleepingbag")
    inst.components.sleepingbag.onsleep = onsleep
    MakeSnowCovered(inst, .01)
    inst:ListenForEvent( "onbuilt", onbuilt)
    return inst

end

local function tinyhutfn(Sim)
    local inst=hutfn
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(2)
    inst.components.finiteuses:SetUses(2)
    inst.components.finiteuses:SetOnFinished( tentonfinished )

    inst.shutdowntime=GetTime()+TINYHUT_DURATION
    inst.shutdowntask=inst:DoTaskInTime(TINYHUT_DURATION, function()
     tentonfinished(inst)
    end)
    return inst
end

local function shelterfn(Sim)
    local inst=hutfn
    
    inst.shutdowntime=GetTime()+SHELTER_DURATION
    inst.shutdowntask=inst:DoTaskInTime(SHELTER_DURATION, function()
     tentonfinished(inst)
    end)
    return inst
end


return Prefab( "common/inventory/fa_magearmor", magearmorfn, ssassets),
Prefab( "common/inventory/fa_stoneskin", stoneskinfn, maassets),
Prefab( "common/inventory/fa_spell_tinyhut", tinyhutfn, tinyassets),
 MakePlacer( "common/fa_spell_tinyhut_placer", "tent", "tent", "idle" ),
Prefab( "common/inventory/fa_spell_secureshelter", shelterfn, tinyassets),
 MakePlacer( "common/fa_spell_secureshelter_placer", "tent", "tent", "idle" ) 


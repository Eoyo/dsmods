
local MakePlayerCharacter = require "prefabs/player_common"


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

		-- Don't forget to include your character's custom assets!
        Asset( "ANIM", "anim/necromancer.zip" ),
}
local prefabs = {
    "necropet",
}

STRINGS.TABS.SPELLS = "Spells"



local DAMAGE_MULT=0.5


local onloadfn = function(inst, data)
    inst.fa_playername=data.fa_playername
end

local onsavefn = function(inst, data)
    data.fa_playername=inst.fa_playername
end

local fn = function(inst)
	
  	-- choose which sounds this character will play
	inst.soundsname = "wolfgang"

	-- a minimap icon must be specified
	inst.MiniMapEntity:SetIcon( "wilson.png" )

	-- todo: Add an example special power here.
    inst.components.combat.damagemultiplier=DAMAGE_MULT
	inst.components.health:SetMaxHealth(125)
	inst.components.sanity:SetMax(300)
	inst.components.hunger:SetMax(150)
    inst.components.sanity.night_drain_mult = 0

    inst:AddTag("evil")
    
    inst:AddComponent("xplevel")
    inst:AddComponent("reader")

    inst.OnLoad = onloadfn
    inst.OnSave = onsavefn
    
RECIPETABS["SPELLS"] = {str = "SPELLS", sort=999, icon = "tab_book.tex"}--, icon_atlas = "images/inventoryimages/herotab.xml"}
end

return MakePlayerCharacter("necromancer", prefabs, assets, fn)

local locale = {}
locale.identifier = 'en_EN'
locale.strings = {
    -- ==============================
    -- General
    -- ==============================
    ['general_exit'] = 'Exit',
    ['general_cancel'] = 'Cancel',

    ['nationality_german'] = 'German',
    ['nationality_finnish'] = 'Finnish',
    ['nationality_russian'] = 'Russian',
    ['nationality_british'] = 'British',

    -- ==============================
    -- TILES
    -- ==============================
    ['tile_empty'] = 'Empty',
    ['tile_asphalt'] = 'Asphalt',
    ['tile_deep_water'] = 'Deep Water',
    ['tile_grass'] = 'Grass',
    ['tile_soil'] = 'Soil',
    ['tile_water'] = 'Water',
    ['tile_gravel'] = 'Gravel',
    ['tile_woodenfloor'] = 'Wooden Floor',
    ['tile_carpet'] = 'Carpet',
    ['tile_floortiles'] = 'Tiles',

    -- ==============================
    -- WORLDOBJECTS
    -- ==============================
    ['worldobject_chair'] = 'Chair',
    ['worldobject_crate'] = 'Crate',
    ['worldobject_door'] = 'Door',
    ['worldobject_fence'] = 'Fence',
    ['worldobject_fencegate'] = 'Fence Gate',
    ['worldobject_lowwall'] = 'Low Wall',
    ['worldobject_table'] = 'Table',
    ['worldobject_wall'] = 'Wall',
    ['worldobject_window'] = 'Window',
    ['worldobject_tree'] = 'Tree',
    ['worldobject_toilet'] = 'Toilet',
    ['worldobject_shower'] = 'Shower',

    -- ==============================
    -- BODYPARTS
    -- ==============================
    ['bodypart_head'] = "Head",
    ['bodypart_legs'] = "Legs",
    ['bodypart_torso'] = "Torso",
    ['bodypart_hands'] = "Hands",
    ['bodypart_feet'] = "Feet",

    -- ==============================
    -- EQUIPMENT SLOTS
    -- ==============================
    ['equip_head'] = "Head",
    ['equip_mouth'] = "Mouth",
    ['equip_backpack'] = "Backpack",
    ['equip_torso'] = "Torso",
    ['equip_hands'] = "Hands",
    ['equip_legs'] = "Legs",
    ['equip_feet'] = "Feet",

    -- ==============================
    -- CHARACTERS
    -- ==============================
    ['body_human'] = "Human",
    ['body_dog'] = "Dog",

    -- Classes
    ['class_stalker'] = "Stalker",
    ['class_bandit'] = "Bandit",
    ['class_dog'] = "Dog",

    -- Status Effects
    ['blind'] = 'blind',
    ['dead'] = 'dead',

    -- ==============================
    -- INVENTORY
    -- ==============================
    ['inventory_character'] = "Inventory",
    ['inventory_base'] = "Base Inventory",
    ['inventory_equipment'] = "Equipment",
    ['inventory_tile_inventory'] = "Tile Inventory",
    ['inventory_container_inventory'] = "Container Inventory",

    -- ==============================
    -- ITEMS
    -- ==============================
    ['default_item_description'] = "Bacon ipsum dolor amet kielbasa meatloaf fatback pork loin jerky rump leberkas alcatra boudin frankfurter ball tip chuck doner corned beef bacon. Swine rump shankle sausage shank. Bacon pork belly doner brisket. Cow doner ground round jerky porchetta rump, chicken biltong ribeye pancetta capicola chuck fatback ham. Corned beef chuck hamburger kielbasa, meatball pig capicola filet mignon boudin strip steak tri-tip alcatra spare ribs picanha.",
    ['weapon_aks74'] = "AKS-74",
    ['weapon_aks74_desc'] = "The AKS-74 was originally designed for airborne infantry and sports a folding shoulder stock.\nA trusty companion for your everyday adventures.",
    ['weapon_m67_grenade'] = "M67 Grenade",
    ['weapon_m67_grenade_desc'] = "1. Pull pin\n2. Throw\n3. ???\n4. Profit",
    ['weapon_tonfa'] = "Tonfa",
    ['weapon_tonfa_desc'] = "The Tonfa is a melee weapon widely used by German police forces. That's probably the reason why it is so common in some parts of the zone.",
    ['weapon_knife'] = "Knife",
    ['weapon_knife_desc'] = "A regular knife.",
    ['weapon_rpg7'] = "RPG-7",
    ['weapon_rpg7_desc'] = "The RPG-7 is a portable rocket-propelled grenade launcher. In case you need to bring down a tank.",
    ['weapon_benelli_m4'] = "Benelli M4 Super 90",
    ['weapon_benelli_m4_desc'] = "The Benelli M4 Super 90 is an Italian semi-automatic shotgun and a perfect fit for the zone.",
    ['weapon_shuriken'] = "Shuriken",
    ['weapon_shuriken_desc'] = "Nothing makes you feel more like a Ninja than these Shuriken.",
    ['weapon_bite'] = "Sharp Teeth",
    ['weapon_bite_desc'] = "Things that bite don't bark ... or something like that.",
    ['thick_fur'] = "Thick fur",
    ['thick_fur_desc'] = "Doesn't offer much protection against attacks, but would make a great winter coat.",
    ['bag_small_backpack'] = "Small Backpack",
    ['bag_small_backpack_desc'] = "A small backpack which offers a decent amount of space for carrying around stuff.",
    ['footwear_combat_boots'] = "Combat Boots",
    ['footwear_combat_boots_desc'] = "These boots are made for walking.",
    ['headgear_pasgt_helmet'] = "PASGT Helmet",
    ['headgear_pasgt_helmet_desc'] = "The PASGT Helmet is part of the Personnel Armor System for Ground Troops and widely used in the U.S. Army since the 80s. It offers decent protection against shrapnel and ballistic threats, but leaves the face uncovered.\n\nIt was brought to the zone by army personnel and smugglers and can be bought on the black market for relatively low prices.",
    ['jacket_pasgt_vest'] = "PASGT Ballistic Vest",
    ['jacket_pasgt_vest_desc'] = "The PASGT Vest is part of the Personnel Armor System for Ground Troops and widely used in the U.S. Army since the 80s. It only offers protection against small arms.",
    ['trousers_jeans'] = "Jeans",
    ['trousers_jeans_desc'] = "Jeans are widely used in the zone, but offer little to no protection. But at least they look cool, right?",
    ['misc_nail'] = "Nail",
    ['misc_nail_desc'] = "An ordinary nail. It doesn't look useful.",
    ['misc_splintered_wood'] = "Splintered wood",
    ['misc_splintered_wood_desc'] = "A bunch of splintered wood. It doesn't look useful.",
    ['misc_glass_shard'] = "Shard of glass",
    ['misc_glass_shard_desc'] = "A shard of broken glass. It doesn't look useful.",
    ['misc_ceramic_shard'] = "Shard of ceramic",
    ['misc_ceramic_shard_desc'] = "A broken ceramic shard. It doesn't look useful.",

    -- ==============================
    -- MESSAGES
    -- ==============================
    ['msg_body_hit'] = "The attack hits the creature's %s and deals %d points of damage",
    ['msg_character_no_ap_left'] = "Not enough AP left",
    ['msg_status_effect'] = "Creature is %s",

    -- ==============================
    -- USER INTERFACE
    -- ==============================

    -- User interface
    ['ui_class'] = "Class: ",
    ['ui_ap'] = "AP: ",
    ['ui_hp'] = "HP: ",
    ['ui_weapon'] = "Weapon: ",
    ['ui_ammo'] = "Ammo: ",
    ['ui_cover'] = "Cover",
    ['ui_target_cover'] = "Target",
    ['ui_win'] = "All enemies are dead. You won!\n\nPress any key to continue...",
    ['ui_lose'] = "Your team is dead. You lose!\n\nPress any key to continue...",
    ['ui_tile_info_passable'] = "passable",
    ['ui_tile_info_impassable'] = "impassable",
    ['ui_tile_info_moreitems'] = "... %d additional items",
    ['ui_worldobject_info_climbable'] = "climbable",
    ['ui_worldobject_info_openable'] = "openable",
    ['ui_worldobject_info_lootable'] = "lootable",
    ['ui_worldobject_info_destructible'] = ", destructible",
    ['ui_worldobject_info_indestructible'] = ", indestructible",
    ['ui_faction_allied'] = 'Allied',
    ['ui_faction_neutral'] = 'Neutral',
    ['ui_faction_enemy'] = 'Enemy',

    -- Base screen
    ['base_next_mission'] = "Next Mission",
    ['character_shooting_accuracy'] = "Shooting Skill: ",
    ['character_throwing_accuracy'] = "Throwing Skill: ",
    ['character_missions'] = "Missions: ",
    ['ui_nationality'] = "Nationality: ",
    ['base_recruitment_button'] = "Recruitment",
    ['recruitment_hire_button'] = "Hire",
    ['ui_base_inventory'] = "Inventory",
    ['base_shop_button'] = "Shop",
    ['base_shop_checkout'] = "Checkout",
    ['base_shop_checkout_label'] = "Balance: %s",

    -- Health screen
    ['ui_healthscreen_type'] = "Type: ",
    ['ui_healthscreen_name'] = "Name: ",
    ['ui_healthscreen_status'] = "Status: ",

    -- Main Menu buttons
    ['ui_main_menu_new_game'] = "New",
    ['ui_main_menu_load_game'] = "Load",
    ['ui_main_menu_options'] = "Options",
    ['ui_main_menu_mapeditor'] = "Map Editor",
    ['ui_main_menu_changelog'] = "Changes",

    -- Options
    ['ui_on'] = "On",
    ['ui_off'] = "Off",
    ['ui_yes'] = "Yes",
    ['ui_no'] = "No",
    ['ui_ok'] = "Ok",
    ['ui_apply'] = "Apply",
    ['ui_unsaved_changes'] = "There are unsaved changes. Are you sure you want to quit?",
    ['ui_applied_settings'] = "Your settings have been updated.",
    ['ui_settings_ingame_editor'] = "Activate Map Editor:",
    ['ui_settings_mouse_panning'] = "Mouse Panning:",
    ['ui_settings_invert_messagelog'] = "Invert message log:",
    ['ui_keybindings'] = "Edit Keybindings",
    ['ui_open_modding_dir'] = "Open Save Directory",

    -- Keybindings
    ['action_stand'] = "Stand",
    ['action_crouch'] = "Crouch",
    ['action_prone'] = "Prone",
    ['action_reload_weapon'] = "Reload Weapon",
    ['next_weapon_mode'] = "Next weapon mode",
    ['prev_weapon_mode'] = "Previous weapon mode",
    ['movement_mode'] = "Move",
    ['attack_mode'] = "Attack",
    ['interaction_mode'] = "Interact",
    ['next_character'] = "Next character",
    ['prev_character'] = "Previous character",
    ['end_turn'] = "End turn",
    ['open_inventory_screen'] = "Open inventory screen",
    ['open_health_screen'] = "Open health screen",
    ['center_camera'] = "Center camera",
    ['pan_camera_left'] = "Move camera left",
    ['pan_camera_right'] = "Move camera right",
    ['pan_camera_up'] = "Move camera up",
    ['pan_camera_down'] = "Move camera down",
    ['ui_enter_key'] = "Press a key you want to asign to this action.\n\nPress escape to cancel.",

    ['open_shop_screen'] = "Open shop screen",

    ['drag_item_stack'] = "Drag whole stack (hold&click)",
    ['split_item_stack']  = "Split item stack (hold&click)",

    ['increase_tool_size'] = "Increase tool size",
    ['decrease_tool_size'] = "Decrease tool size",
    ['mode_draw'] = "Select drawing tool",
    ['mode_erase'] = "Select eraser tool",
    ['mode_fill'] = "Select filling tool",
    ['hide_worldobjects'] = "Hide object layer",

    -- Map Editor
    ['ui_mapeditor_save'] = "Save Layout",
    ['ui_mapeditor_load'] = "Load Layout",
    ['ui_mapeditor_test'] = "Test Map",
    ['ui_mapeditor_switch'] = "Prefab Editor",
    ['ui_mapeditor_enter_name'] = "Save layout as:",

    -- Prefab Editor
    ['ui_prefabeditor_save'] = "Save Prefab",
    ['ui_prefabeditor_load'] = "Load Prefab",
    ['ui_prefabeditor_test'] = "Test Map",
    ['ui_prefabeditor_switch'] = "Layout Editor",
    ['ui_prefabeditor_enter_name'] = "Save prefab as:",
    ['tool_draw'] = "Draw",
    ['tool_fill'] = "Fill",
    ['tool_erase'] = "Erase",

    -- Texture packs
    ['ui_texturepack'] = "Texture Pack:",

    -- Language selector
    ['ui_lang'] = "Language:",

    -- Avoid translating these so people can easily switch back
    -- if they select the wrong language.
    ['en_EN'] = "English",

    -- Other options
    ['ui_fullscreen'] = "Fullscreen:",

    -- Navigation
    ['ui_back'] = "Back",

    -- Ingame menu
    ['ui_ingame_paused'] = "Paused",
    ['ui_ingame_save_game'] = "Save game",
    ['ui_ingame_input_save_name'] = "Save as:",
    ['ui_ingame_open_help'] = "Show help",
    ['ui_ingame_abort'] = "Abort Mission",
    ['ui_ingame_exit'] = "Main menu",
    ['ui_ingame_resume'] = "Resume",

    -- Savegame menu
    ['ui_savename'] = 'Name',
    ['ui_type'] = 'Type',
    ['ui_version'] = 'Version',
    ['ui_date'] = 'Date',
    ['ui_delete'] = 'Delete',
    ['combat'] = 'COMBAT',
    ['base'] = 'BASE',
    ['error'] = 'ERROR',

    -- Help Screen
    ['ui_help_header'] = 'Help',
}

locale.strings['ui_title_main_menu'] = [[
              OOOO    OO   OO     OOOOOOO  OOO  OOO  OOOOOOO
            OOOOOOOO  OOO  OOO    OOOOOOO  OOO  OOO  OOOOOOOO
            OO!  OOO  OO!O OOO      OO!    OO!  OOO  OO!
            !O!  O!O  !O!!O!O!      !O!    !O!  O!O  !O!
            O!O  !O!  O!O !!O!      O!!    O!O!O!O!  O!!!:!
            !O!  !!!  !O!  !!!      !!!    !!!O!!!!  !!!!!:
            !!:  !!!  !!:  !!!      !!:    !!:  !!!  !!:
            :!:  !:!  :!:  !:!      :!:    :!:  !:!  :!:
            :!:::!!:   ::   ::       ::     ::   !:  ::!::!!
              :!::      :    :        :      :    :  :!:::::!

OOOOOOO     OOOO     OOOOOO   OOOOOO     OOOOO    OOO  OOOOOOO   OOOOOOO
OOOOOOOO  OOOOOOOO  OOOOOOOO  OOOOOOOO  OOOOOOO   OOO  OOOOOOOO  OOOOOOOO
OO!  OOO  OO!  OOO  OO!  OOO  OO!  OOO  !OO       OO!  OO!  OOO  OO!
!O!  O!O  !O!  O!O  !O!  O!O  !O!  O!O  !O!       !O!  !O!  O!O  !O!
O!O!!O!   O!O  !O!  O!O!O!O!  O!O  !O!  !!OO!!    !!O  O!O  !O!  O!!!:!
!!O!O!    !O!  !!!  !!!O!!!!  !O!  !!!   !!O!!!   !!!  !O!  !!!  !!!!!:
!!: :!!   !!:  !!!  !!:  !!!  !!:  !!!       !:!  !!:  !!:  !!!  !!:
:!:  !:!  :!:  !:!  :!:  !:!  :!:  !:!      !:!   :!:  :!:  !:!  :!:
 ::   !:  ::!:!!::   ::   ::  !:::::::  ::!::::    ::  !:!!::::  ::!::!!
  !    :    ::!:      !    :  :::::::    :::::      :  :::::::   :!:::::!
]]

-- Titles
locale.strings['ui_title_options'] = [[
  OOOO    OOOOOOO   OOOOOOO  OOO    OOOO    OO   OO    OOOOO
OOOOOOOO  OOOOOOOO  OOOOOOO  OOO  OOOOOOOO  OOO  OOO  OOOOOOO
OO!  OOO  OO!  OOO    OO!    OO!  OO!  OOO  OO!O OOO  !OO
!O!  O!O  !O!  O!O    !O!    !O!  !O!  O!O  !O!!O!O!  !O!
O!O  !O!  O!OO!O!     O!!    !!O  O!O  !O!  O!O !!O!  !!OO!!
!O!  !!!  !!O!!!      !!!    !!!  !O!  !!!  !O!  !!!   !!O!!!
!!:  !!!  !!:         !!:    !!:  !!:  !!!  !!:  !!!       !:!
:!:  !:!  :!:         :!:    :!:  :!:  !:!  :!:  !:!      !:!
:!:::!!:   ::          ::     ::  :!:::!!:   ::   ::  ::!::::
  :!::      :           :      :    :!::      :    :   :::::
]]

locale.strings['ui_title_savegames'] = [[
 OOOOO     OOOOOO   OOO  OOO  OOOOOOO    OOOOO
OOOOOOO   OOOOOOOO  OOO  OOO  OOOOOOOO  OOOOOOO
!OO       OO!  OOO  OO!  OOO  OO!       !OO
!O!       !O!  O!O  !O!  O!O  !O!       !O!
!!OO!!    O!O!O!O!  O!O  !O!  O!!!:!    !!OO!!
 !!O!!!   !!!O!!!!  !O!  !!!  !!!!!:     !!O!!!
     !:!  !!:  !!!  :!:  !!:  !!:            !:!
    !:!   :!:  !:!   ::!!::   :!:           !:!
::!::::    ::   ::    !:::    ::!::!!   ::!::::
 :::::      !    :     !:     :!:::::!   :::::
]]

locale.strings['ui_title_controls'] = [[
 OOOOO      OOOO    OO   OO   OOOOOOO  OOOOOOO     OOOO    OOO        OOOOO
OOOOOOOO  OOOOOOOO  OOO  OOO  OOOOOOO  OOOOOOOO  OOOOOOOO  OOO       OOOOOOO
OO!       OO!  OOO  OO!O OOO    OO!    OO!  OOO  OO!  OOO  OO!       !OO
!O!       !O!  O!O  !O!!O!O!    !O!    !O!  O!O  !O!  O!O  !O!       !O!
O!O       O!O  !O!  O!O !!O!    O!!    O!O!!O!   O!O  !O!  O!O       !!OO!!
!O!       !O!  !!!  !O!  !!!    !!!    !!O!O!    !O!  !!!  !O!        !!O!!!
!!:       !!:  !!!  !!:  !!!    !!:    !!: :!!   !!:  !!!  !!:            !:!
:!:       :!:  !:!  :!:  !:!    :!:    :!:  !:!  :!:  !:!  :!:           !:!
:!:::!!   :!:::!!:   ::   ::     ::     ::   !:  :!:::!!:  :!:::!!   ::!::::
 ::!::!:    :!::      :    :      :      !    :    :!::    !::!::!:   :::::
]]

return locale

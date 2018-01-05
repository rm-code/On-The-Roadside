local locale = {};
locale.identifier = 'en_EN';

locale.strings = {
    -- User interface
    ['ui_class'] = "Class: ",
    ['ui_ap'] = "AP: ",
    ['ui_weapon'] = "Weapon: ",
    ['ui_ammo'] = "Ammo: ",
    ['ui_win'] = "All enemies are dead. You won!\n\nPress any key to continue...",
    ['ui_lose'] = "Your team is dead. You lose!\n\nPress any key to continue...",
    ['ui_tile_info_passable'] = "passable",
    ['ui_tile_info_impassable'] = "impassable",
    ['ui_tile_info_moreitems'] = "... %d additional items.",
    ['ui_worldobject_info_climbable'] = "climbable",
    ['ui_worldobject_info_openable'] = "openable",
    ['ui_worldobject_info_lootable'] = "lootable",
    ['ui_worldobject_info_destructible'] = ", destructible",
    ['ui_worldobject_info_indestructible'] = ", indestructible",

    -- Health screen
    ['ui_healthscreen_type'] = "Type: ",
    ['ui_healthscreen_name'] = "Name: ",
    ['ui_healthscreen_limb'] = "Limb",
    ['ui_healthscreen_bleeding'] = "Bleeding",
    ['ui_healthscreen_status'] = "Status",

    -- Main Menu buttons
    ['ui_main_menu_new_game'] = "New",
    ['ui_main_menu_load_game'] = "Load",
    ['ui_main_menu_options'] = "Options",
    ['ui_main_menu_mapeditor'] = "Map Editor",
    ['ui_main_menu_changelog'] = "Changes",
    ['ui_main_menu_exit'] = "Exit",

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
    ['ui_settings_ingame_editor_active'] = "Once activated, the map editor can be accessed from the main menu. This currently is an early development version.",
    ['ui_settings_mouse_panning'] = "Mouse Panning:",
    ['ui_keybindings'] = "Edit Keybindings",

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
    ['pan_camera_left'] = "Move camera left",
    ['pan_camera_right'] = "Move camera right",
    ['pan_camera_up'] = "Move camera up",
    ['pan_camera_down'] = "Move camera down",
    ['ui_enter_key'] = "Press a key you want to asign to this action.\n\nPress escape to cancel.",

    -- Map Editor
    ['ui_mapeditor_save'] = "Save Layout",
    ['ui_mapeditor_load'] = "Load Layout",
    ['ui_mapeditor_test'] = "Test Map",
    ['ui_mapeditor_switch'] = "Prefab Editor",
    ['ui_mapeditor_exit'] = "Exit",
    ['ui_mapeditor_enter_name'] = "Save layout as:",

    -- Prefab Editor
    ['ui_prefabeditor_save'] = "Save Prefab",
    ['ui_prefabeditor_load'] = "Load Prefab",
    ['ui_prefabeditor_test'] = "Test Map",
    ['ui_prefabeditor_switch'] = "Layout Editor",
    ['ui_prefabeditor_exit'] = "Exit",
    ['ui_prefabeditor_enter_name'] = "Save prefab as:",

    -- Texture packs
    ['ui_texturepack'] = "Texture Pack:",

    -- Language selector
    ['ui_lang'] = "Language:",
    ['ui_lang_eng'] = "English",

    -- Other options
    ['ui_fullscreen'] = "Fullscreen:",

    -- Navigation
    ['ui_back'] = "Back",

    -- Ingame menu
    ['ui_ingame_paused'] = "Paused",
    ['ui_ingame_save_game'] = "Save game",
    ['ui_ingame_input_save_name'] = "Save as:",
    ['ui_ingame_open_help'] = "Show help",
    ['ui_ingame_exit'] = "Main menu",
    ['ui_ingame_resume'] = "Resume",

    -- Help Screen
    ['ui_help_header'] = 'Help'
}

return locale;

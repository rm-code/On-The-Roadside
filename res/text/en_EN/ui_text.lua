local locale = {};
locale.identifier = 'en_EN';

locale.strings = {
    -- User interface
    ['ui_class'] = "Class: ",
    ['ui_ap'] = "AP: ",
    ['ui_hp'] = "HP: ",
    ['ui_weapon'] = "Weapon: ",
    ['ui_ammo'] = "Ammo: ",
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
    ['ui_settings_mouse_panning'] = "Mouse Panning:",
    ['ui_settings_invert_messagelog'] = "Invert message log:",
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

    -- Avoid translating these so people can easily switch back
    -- if they select the wrong language.
    ['en_EN'] = "English",
    ['de_DE'] = "Deutsch",

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
    ['ui_help_header'] = 'Help',

    -- Titles
    ['ui_title_main_menu'] = {
        "             OOOO    OO   OO       OOOOOOO  OOO  OOO  OOOOOOO            ",
        "           OOOOOOOO  OOO  OOO      OOOOOOO  OOO  OOO  OOOOOOOO           ",
        "           OO!  OOO  OO!O OOO        OO!    OO!  OOO  OO!                ",
        "           !O!  O!O  !O!!O!O!        !O!    !O!  O!O  !O!                ",
        "           O!O  !O!  O!O !!O!        O!!    O!O!O!O!  O!!!:!             ",
        "           !O!  !!!  !O!  !!!        !!!    !!!O!!!!  !!!!!:             ",
        "           !!:  !!!  !!:  !!!        !!:    !!:  !!!  !!:                ",
        "           :!:  !:!  :!:  !:!        :!:    :!:  !:!  :!:                ",
        "           :!:::!!:   ::   ::         ::     ::   !:  ::!::!!            ",
        "             :!::      :    :          :      :    :  :!:::::!           ",
        "                                                                         ",
        "OOOOOOO     OOOO     OOOOOO   OOOOOO     OOOOO    OOO  OOOOOOO   OOOOOOO ",
        "OOOOOOOO  OOOOOOOO  OOOOOOOO  OOOOOOOO  OOOOOOO   OOO  OOOOOOOO  OOOOOOOO",
        "OO!  OOO  OO!  OOO  OO!  OOO  OO!  OOO  !OO       OO!  OO!  OOO  OO!     ",
        "!O!  O!O  !O!  O!O  !O!  O!O  !O!  O!O  !O!       !O!  !O!  O!O  !O!     ",
        "O!O!!O!   O!O  !O!  O!O!O!O!  O!O  !O!  !!OO!!    !!O  O!O  !O!  O!!!:!  ",
        "!!O!O!    !O!  !!!  !!!O!!!!  !O!  !!!   !!O!!!   !!!  !O!  !!!  !!!!!:  ",
        "!!: :!!   !!:  !!!  !!:  !!!  !!:  !!!       !:!  !!:  !!:  !!!  !!:     ",
        ":!:  !:!  :!:  !:!  :!:  !:!  :!:  !:!      !:!   :!:  :!:  !:!  :!:     ",
        " ::   !:  ::!:!!::   ::   ::  !:.:.:::  ::!::::    ::  !:!!::.:  ::!:.:: ",
        "  !    :    ::!:      !    :  ::::..:    :::..      :  ::..:.:   ::..::.:",
    },
    ['ui_title_options'] = {
        "  OOOO    OOOOOOO   OOOOOOO  OOO    OOOO    OO   OO    OOOOO  ",
        "OOOOOOOO  OOOOOOOO  OOOOOOO  OOO  OOOOOOOO  OOO  OOO  OOOOOOO ",
        "OO!  OOO  OO!  OOO    OO!    OO!  OO!  OOO  OO!O OOO  !OO     ",
        "!O!  O!O  !O!  O!O    !O!    !O!  !O!  O!O  !O!!O!O!  !O!     ",
        "O!O  !O!  O!OO!O!     O!!    !!O  O!O  !O!  O!O !!O!  !!OO!!  ",
        "!O!  !!!  !!O!!!      !!!    !!!  !O!  !!!  !O!  !!!   !!O!!! ",
        "!!:  !!!  !!:         !!:    !!:  !!:  !!!  !!:  !!!       !:!",
        ":!:  !:!  :!:         :!:    :!:  :!:  !:!  :!:  !:!      !:! ",
        ":!:::!!:   ::          ::     ::  :!:::!!:   ::   ::  ::!:::: ",
        "  :!::      :           :      :    :!::      :    :   :::..  "
    },
    ['ui_title_savegames'] = {
        " OOOOO     OOOOOO   OOO  OOO  OOOOOOO    OOOOO  ",
        "OOOOOOO   OOOOOOOO  OOO  OOO  OOOOOOOO  OOOOOOO ",
        "!OO       OO!  OOO  OO!  OOO  OO!       !OO     ",
        "!O!       !O!  O!O  !O!  O!O  !O!       !O!     ",
        "!!OO!!    O!O!O!O!  O!O  !O!  O!!!:!    !!OO!!  ",
        " !!O!!!   !!!O!!!!  !O!  !!!  !!!!!:     !!O!!! ",
        "     !:!  !!:  !!!  :!:  !!:  !!:            !:!",
        "    !:!   :!:  !:!   ::!!::   :!:           !:! ",
        "::!::::    ::   ::    !:::    ::!::!!   ::!:::: ",
        " :::..      !    :     !:     :!:::::!   :::..  "
    },
    ['ui_title_controls'] = {
        " OOOOO      OOOO    OO   OO   OOOOOOO  OOOOOOO     OOOO    OOO        OOOOO  ",
        "OOOOOOOO  OOOOOOOO  OOO  OOO  OOOOOOO  OOOOOOOO  OOOOOOOO  OOO       OOOOOOO ",
        "OO!       OO!  OOO  OO!O OOO    OO!    OO!  OOO  OO!  OOO  OO!       !OO     ",
        "!O!       !O!  O!O  !O!!O!O!    !O!    !O!  O!O  !O!  O!O  !O!       !O!     ",
        "O!O       O!O  !O!  O!O !!O!    O!!    O!O!!O!   O!O  !O!  O!O       !!OO!!  ",
        "!O!       !O!  !!!  !O!  !!!    !!!    !!O!O!    !O!  !!!  !O!        !!O!!! ",
        "!!:       !!:  !!!  !!:  !!!    !!:    !!: :!!   !!:  !!!  !!:            !:!",
        ":!:       :!:  !:!  :!:  !:!    :!:    :!:  !:!  :!:  !:!  :!:           !:! ",
        ":!:::!!   :!:::!!:   ::   ::     ::     ::   !:  :!:::!!:  :!:::!!   ::!:::: ",
        " ::!::!:    :!::      :    :      :      !    :    :!::    !::!::!:   :::..  "
    }
}

return locale;

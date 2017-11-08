-- Define your own color presets here.
local COLORS = {}

-- DawnBringer's 32 Col Palette V1.0
-- @see http://pixeljoint.com/forum/forum_posts.asp?TID=16247
COLORS.DB00 = {   0,   0,   0 }
COLORS.DB01 = {  34,  32,  52 }
COLORS.DB02 = {  69,  40,  60 }
COLORS.DB03 = { 102,  57,  49 }
COLORS.DB04 = { 143,  86,  59 }
COLORS.DB05 = { 223, 113,  38 }
COLORS.DB06 = { 217, 160, 102 }
COLORS.DB07 = { 238, 195, 154 }
COLORS.DB08 = { 251, 242,  54 }
COLORS.DB09 = { 153, 229,  80 }
COLORS.DB10 = { 106, 190,  48 }
COLORS.DB11 = {  55, 148, 110 }
COLORS.DB12 = {  75, 105,  47 }
COLORS.DB13 = {  82,  75,  36 }
COLORS.DB14 = {  50,  60,  57 }
COLORS.DB15 = {  63,  63, 116 }
COLORS.DB16 = {  48,  96, 130 }
COLORS.DB17 = {  91, 110, 225 }
COLORS.DB18 = {  99, 155, 255 }
COLORS.DB19 = {  95, 205, 228 }
COLORS.DB20 = { 203, 219, 252 }
COLORS.DB21 = { 255, 255, 255 }
COLORS.DB22 = { 155, 173, 183 }
COLORS.DB23 = { 132, 126, 135 }
COLORS.DB24 = { 105, 106, 106 }
COLORS.DB25 = {  89,  86,  82 }
COLORS.DB26 = { 118,  66, 138 }
COLORS.DB27 = { 172,  50,  50 }
COLORS.DB28 = { 217,  87,  99 }
COLORS.DB29 = { 215, 123, 186 }
COLORS.DB30 = { 143, 151,  74 }
COLORS.DB31 = { 138, 111,  48 }

return {
    -- ==============================
    -- TILES
    -- ==============================
    ['tile_unexplored']  = COLORS.DB00,
    ['tile_unseen']      = COLORS.DB01,

    ['tile_asphalt']     = COLORS.DB25,
    ['tile_deep_water']  = COLORS.DB15,
    ['tile_grass']       = COLORS.DB12,
    ['tile_gravel']      = COLORS.DB24,
    ['tile_soil']        = COLORS.DB03,
    ['tile_water']       = COLORS.DB16,
    ['tile_woodenfloor'] = COLORS.DB03,

    -- ==============================
    -- WORLD OBJECTS
    -- ==============================
    ['worldobject_chair']   = COLORS.DB04,
    ['worldobject_crate']   = COLORS.DB04,
    ['worldobject_fence']   = COLORS.DB04,
    ['worldobject_lowwall'] = COLORS.DB23,
    ['worldobject_table']   = COLORS.DB04,
    ['worldobject_tree']    = COLORS.DB12,
    ['worldobject_wall']    = COLORS.DB23,
    ['worldobject_window']  = COLORS.DB19,

    -- ==============================
    -- CHARACTERS
    -- ==============================
    ['allied_active']    = COLORS.DB17,
    ['allied_inactive']  = COLORS.DB15,
    ['neutral_active']   = COLORS.DB09,
    ['neutral_inactive'] = COLORS.DB10,
    ['enemy_active']     = COLORS.DB05,
    ['enemy_inactive']   = COLORS.DB27,

    -- ==============================
    -- ITEMS
    -- ==============================
    ['items'] = COLORS.DB16,

    -- ==============================
    -- WORLD OBJECTS (OPENABLE)
    -- ==============================
    ['worldobject_door']      = COLORS.DB03,
    ['worldobject_fencegate'] = COLORS.DB04,

    -- ==============================
    -- UI
    -- ==============================

    -- Used for drawing the titles in the main menu and options screens.
    ['ui_title_1'] = COLORS.DB18,
    ['ui_title_2'] = COLORS.DB17,
    ['ui_title_3'] = COLORS.DB17,

    -- Buttons.
    ['ui_button']     = COLORS.DB16,
    ['ui_button_hot'] = COLORS.DB18,
    ['ui_button_focus'] = COLORS.DB18,
    ['ui_button_inactive'] = COLORS.DB25,
    ['ui_button_inactive_hot'] = COLORS.DB24,
    ['ui_button_inactive_focus'] = COLORS.DB24,

    ['ui_scrollbar_element'] = COLORS.DB01,
    ['ui_scrollbar_cursor']  = COLORS.DB25,

    ['ui_select_field']     = COLORS.DB16,
    ['ui_select_field_hot'] = COLORS.DB18,

    ['ui_outlines'] = COLORS.DB15,
    ['ui_text_dim'] = COLORS.DB01,
    ['ui_text']     = COLORS.DB20,

    ['ui_help_section'] = COLORS.DB24,

    ['ui_equipment_highlight'] = COLORS.DB12,
    ['ui_equipment_mouseover'] = COLORS.DB15,
    ['ui_equipment_item']      = COLORS.DB20,
    ['ui_equipment_empty']     = COLORS.DB23,

    ['ui_inventory_headers'] = COLORS.DB20,
    ['ui_inventory_full'] = COLORS.DB27,

    ['ui_inventory_stats_name'] = COLORS.DB12,
    ['ui_inventory_stats_type'] = COLORS.DB24,
    ['ui_inventory_stats_value'] = COLORS.DB20,
    ['ui_inventory_description'] = COLORS.DB20,

    ['ui_inventory_drag_bg'] = COLORS.DB01,
    ['ui_inventory_drag_text'] = COLORS.DB20,

    ['ui_ap_cost'] = COLORS.DB27,
    ['ui_ap_cost_result'] = COLORS.DB10,

    ['ui_shot_valid']               = COLORS.DB09,
    ['ui_shot_potentially_blocked'] = COLORS.DB05,
    ['ui_shot_blocked']             = COLORS.DB27,

    ['ui_mouse_pointer_movement'] = COLORS.DB18,
    ['ui_mouse_pointer_attack']   = COLORS.DB27,
    ['ui_mouse_pointer_interact'] = COLORS.DB10,

    ['ui_path_ap_full'] = COLORS.DB09,
    ['ui_path_ap_high'] = COLORS.DB08,
    ['ui_path_ap_med']  = COLORS.DB05,
    ['ui_path_ap_low']  = COLORS.DB27,

    ['ui_health_destroyed_limb']     = COLORS.DB24,
    ['ui_health_badly_damaged_limb'] = COLORS.DB27,
    ['ui_health_damaged_limb']       = COLORS.DB05,
    ['ui_health_ok_limb']            = COLORS.DB08,
    ['ui_health_fine_limb']          = COLORS.DB10,
    ['ui_health_bleeding_bad']       = COLORS.DB27,
    ['ui_health_bleeding']           = COLORS.DB05,
    ['ui_health_bleeding_ok']        = COLORS.DB08,
    ['ui_health_bleeding_fine']      = COLORS.DB10,

    -- Changelog Menu
    ['ui_changelog_version'] = COLORS.DB05,
    ['ui_changelog_additions'] = COLORS.DB16,
    ['ui_changelog_removals'] = COLORS.DB16,
    ['ui_changelog_fixes'] = COLORS.DB16,
    ['ui_changelog_other'] = COLORS.DB16,
    ['ui_changelog_text'] = COLORS.DB25,

    -- ==============================
    -- SYSTEM
    -- ==============================
    ['sys_background'] = { 0, 0, 0, 255 },
    ['sys_reset']      = { 255, 255, 255, 255 } -- Should not be changed!
}

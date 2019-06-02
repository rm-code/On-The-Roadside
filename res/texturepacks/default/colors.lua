-- Define your own color presets here.
local COLORS = {}

-- DawnBringer's 32 Col Palette V1.0
-- @see http://pixeljoint.com/forum/forum_posts.asp?TID=16247
COLORS.DB00  = { 0.000000, 0.000000, 0.000000 }
COLORS.DB01  = { 0.133333, 0.125490, 0.203922 }
COLORS.DB02  = { 0.270588, 0.156863, 0.235294 }
COLORS.DB03  = { 0.400000, 0.223529, 0.192157 }
COLORS.DB04  = { 0.560784, 0.337255, 0.231373 }
COLORS.DB05  = { 0.874510, 0.443137, 0.149020 }
COLORS.DB06  = { 0.850980, 0.627451, 0.400000 }
COLORS.DB07  = { 0.933333, 0.764706, 0.603922 }

COLORS.DB08  = { 0.984314, 0.949020, 0.211765 }
COLORS.DB09  = { 0.600000, 0.898039, 0.313725 }
COLORS.DB10  = { 0.415686, 0.745098, 0.188235 }
COLORS.DB11  = { 0.215686, 0.580392, 0.431373 }
COLORS.DB12  = { 0.294118, 0.411765, 0.184314 }
COLORS.DB13  = { 0.321569, 0.294118, 0.141176 }
COLORS.DB14  = { 0.196078, 0.235294, 0.223529 }
COLORS.DB15  = { 0.247059, 0.247059, 0.454902 }

COLORS.DB16  = { 0.188235, 0.376471, 0.509804 }
COLORS.DB17  = { 0.356863, 0.431373, 0.882353 }
COLORS.DB18  = { 0.388235, 0.607843, 1.000000 }
COLORS.DB19  = { 0.372549, 0.803922, 0.894118 }
COLORS.DB20  = { 0.796078, 0.858824, 0.988235 }
COLORS.DB21  = { 1.000000, 1.000000, 1.000000 }
COLORS.DB22  = { 0.607843, 0.678431, 0.717647 }
COLORS.DB23  = { 0.517647, 0.494118, 0.529412 }

COLORS.DB24  = { 0.411765, 0.415686, 0.415686 }
COLORS.DB25  = { 0.349020, 0.337255, 0.321569 }
COLORS.DB26  = { 0.462745, 0.258824, 0.541176 }
COLORS.DB27  = { 0.674510, 0.196078, 0.196078 }
COLORS.DB28  = { 0.850980, 0.341176, 0.388235 }
COLORS.DB29  = { 0.843137, 0.482353, 0.729412 }
COLORS.DB30  = { 0.560784, 0.592157, 0.290196 }
COLORS.DB31  = { 0.541176, 0.435294, 0.188235 }

COLORS.RESET      = { 1.0, 1.0, 1.0, 1.0 }
COLORS.BACKGROUND = { 0.0, 0.0, 0.0, 1.0 }
COLORS.DEBUG_GRID = { 0.2, 0.2, 0.2, 0.3 }

return {
    -- ==============================
    -- TILES
    -- ==============================
    ['tile_empty']       = COLORS.DB00,
    ['tile_unseen']      = COLORS.DB01,

    ['tile_asphalt']     = COLORS.DB25,
    ['tile_deep_water']  = COLORS.DB15,
    ['tile_grass']       = COLORS.DB12,
    ['tile_gravel']      = COLORS.DB24,
    ['tile_soil']        = COLORS.DB03,
    ['tile_water']       = COLORS.DB16,
    ['tile_woodenfloor'] = COLORS.DB03,
    ['tile_carpet']      = COLORS.DB27,
    ['tile_floortiles']  = COLORS.DB22,

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
    ['worldobject_toilet']  = COLORS.DB20,
    ['worldobject_shower']  = COLORS.DB16,

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

    -- Armor
    ['footwear_combat_boots'] = COLORS.DB05,
    ['headgear_pasgt_helmet'] = COLORS.DB05,
    ['jacket_pasgt_vest'] = COLORS.DB05,
    ['trousers_jeans'] = COLORS.DB05,
    ['thick_fur'] = COLORS.DB05,

    -- Containers
    ['bag_small_backpack'] = COLORS.DB17,

    -- Miscellaneous
    ['misc_nail'] = COLORS.DB16,
    ['misc_splintered_wood'] = COLORS.DB16,
    ['misc_glass_shard'] = COLORS.DB16,
    ['misc_ceramic_shard'] = COLORS.DB16,

    -- Melee
    ['weapon_knife'] = COLORS.DB08,
    ['weapon_tonfa'] = COLORS.DB08,
    ['weapon_bite'] = COLORS.DB08,

    -- Ranged
    ['weapon_aks74'] = COLORS.DB08,
    ['weapon_benelli_m4'] = COLORS.DB08,
    ['weapon_rpg7'] = COLORS.DB08,

    -- Thrown
    ['weapon_m67_grenade'] = COLORS.DB08,
    ['weapon_shuriken'] = COLORS.DB08,

    -- Projectiles
    ['12_gauge'] = COLORS.DB06,

    -- ==============================
    -- WORLD OBJECTS (OPENABLE)
    -- ==============================
    ['worldobject_door']      = COLORS.DB03,
    ['worldobject_fencegate'] = COLORS.DB04,

    -- ==============================
    -- UI
    -- ==============================

    -- Used for drawing the titles in the main menu and options screens.
    ['ui_title_0'] = COLORS.DB00,
    ['ui_title_1'] = COLORS.DB18,
    ['ui_title_2'] = COLORS.DB17,
    ['ui_title_3'] = COLORS.DB17,

    -- Savegames
    ['ui_valid'] = COLORS.DB09,
    ['ui_invalid'] = COLORS.DB27,

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
    ['ui_text_dark'] = COLORS.DB25,
    ['ui_text_passive'] = COLORS.DB15,
    ['ui_text_success'] = COLORS.DB09,
    ['ui_text_warning'] = COLORS.DB05,
    ['ui_text_error'] = COLORS.DB27,

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

    -- Changelog Menu
    ['ui_changelog_version'] = COLORS.DB05,
    ['ui_changelog_additions'] = COLORS.DB16,
    ['ui_changelog_removals'] = COLORS.DB16,
    ['ui_changelog_fixes'] = COLORS.DB16,
    ['ui_changelog_other'] = COLORS.DB16,
    ['ui_changelog_text'] = COLORS.DB25,

    ['ui_character_name'] = COLORS.DB17,

    -- Message log
    ['ui_msg_info'] = COLORS.DB25,
    ['ui_msg_important'] = COLORS.DB08,
    ['ui_msg_warning']  = COLORS.DB05,
    ['ui_msg_danger']  = COLORS.DB27,

    -- Shop
    ['shopitem_buy_hot'] = COLORS.DB09,
    ['shopitem_buy_focus'] = COLORS.DB10,
    ['shopitem_buy'] = COLORS.DB11,

    ['shopitem_sell_hot'] = COLORS.DB28,
    ['shopitem_sell_focus'] = COLORS.DB05,
    ['shopitem_sell'] = COLORS.DB27,

    ['shop_balance_positive'] = COLORS.DB11,
    ['shop_balance_negative'] = COLORS.DB27,

    -- UITooltip
    ['ui_tooltip_text'] = COLORS.DB00,
    ['ui_tooltip_bg'] = COLORS.DB17,

    -- Cover indicators
    ['full_cover'] = COLORS.DB10,
    ['half_cover'] = COLORS.DB11,
    ['no_cover'] = COLORS.DB01,

    -- ==============================
    -- MAP EDITOR
    -- ==============================
    ['ui_prefab_editor_brush'] = COLORS.DB25,

    ['parcel_spawns_friendly'] = COLORS.DB09,
    ['parcel_spawns_neutral'] = COLORS.DB08,
    ['parcel_spawns_enemy'] = COLORS.DB27,

    ['parcel_foliage'] = COLORS.DB11,
    ['parcel_road'] = COLORS.DB22,
    ['parcel_xs'] = COLORS.DB15,
    ['parcel_s'] = COLORS.DB08,
    ['parcel_m'] = COLORS.DB05,
    ['parcel_l'] = COLORS.DB26,
    ['parcel_xl'] = COLORS.DB02,
    ['ingame_editor_grid_lines'] = COLORS.DB14,

    -- ============================================================
    -- SYSTEM - These values shouldn't be changed!
    -- ============================================================

    ['sys_background'] = COLORS.BACKGROUND,
    ['sys_debug_grid'] = COLORS.DEBUG_GRID,
    ['sys_reset'] = COLORS.RESET
}

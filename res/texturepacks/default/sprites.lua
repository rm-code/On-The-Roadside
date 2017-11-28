return {
    -- ==============================
    -- TILES
    -- ==============================
    ['tile_empty']       =   1,
    ['tile_asphalt']     =  47,
    ['tile_deep_water']  = 248,
    ['tile_grass']       =  40,
    ['tile_gravel']      = 250,
    ['tile_soil']        =  45,
    ['tile_water']       = 248,
    ['tile_woodenfloor'] = 173,
    ['tile_carpet']      = 179,
    ['tile_floortiles']  = 251,

    -- ==============================
    -- WORLD OBJECTS
    -- ==============================
    ['worldobject_chair']   = 111,
    ['worldobject_crate']   = 247,
    ['worldobject_lowwall'] =  62,
    ['worldobject_table']   = 211,
    ['worldobject_tree']    =   7,
    ['worldobject_window']  = 177,
    ['worldobject_toilet']  = 226,
    ['worldobject_shower']  = 127,

    -- Connected world objects.
    ['worldobject_wall'] = 207,
    ['worldobject_wall_vertical'] = 187,
    ['worldobject_wall_horizontal'] = 206,
    ['worldobject_wall_ne'] = 201,
    ['worldobject_wall_nw'] = 189,
    ['worldobject_wall_se'] = 202,
    ['worldobject_wall_sw'] = 188,
    ['worldobject_wall_nes'] = 205,
    ['worldobject_wall_new'] = 203,
    ['worldobject_wall_nws'] = 186,
    ['worldobject_wall_sew'] = 204,
    ['worldobject_wall_news'] = 207,

    ['worldobject_fence'] = 198,
    ['worldobject_fence_vertical'] = 180,
    ['worldobject_fence_horizontal'] = 197,
    ['worldobject_fence_ne'] = 193,
    ['worldobject_fence_nw'] = 218,
    ['worldobject_fence_se'] = 219,
    ['worldobject_fence_sw'] = 192,
    ['worldobject_fence_nes'] = 196,
    ['worldobject_fence_new'] = 194,
    ['worldobject_fence_nws'] = 181,
    ['worldobject_fence_sew'] = 195,
    ['worldobject_fence_news'] = 198,

    -- ==============================
    -- Items
    -- ==============================
    ['items'] = 34,

    ['weapon_m67_grenade'] =  8,
    ['weapon_shuriken']    = 16,

    ['12_gauge'] = 8,

    -- ==============================
    -- WORLD OBJECTS (OPENABLE)
    -- ==============================
    ['worldobject_door']      = { closed =  44, open = 96 },
    ['worldobject_fencegate'] = { closed = 241, open = 96 },

    -- ==============================
    -- UI
    -- ==============================

    -- Outlines
    ['ui_outlines_nsew'] = 198, -- Connected to all sides.
    ['ui_outlines_ns']   = 180, -- Vertically connected.
    ['ui_outlines_ew']   = 197, -- Horizontally connected.
    ['ui_outlines_sw']   = 192, -- Top right corner.
    ['ui_outlines_se']   = 219, -- Top left corner.
    ['ui_outlines_ne']   = 193, -- Bottom left corner.
    ['ui_outlines_nw']   = 218, -- Bottom right corner.
    ['ui_outlines_sew']  = 195, -- T-Intersection down.
    ['ui_outlines_new']  = 194, -- T-intersection up.
    ['ui_outlines_nse']  = 196, -- T-intersection right.
    ['ui_outlines_nsw']  = 181, -- T-intersection left.

    -- Mouse Pointer
    ['ui_mouse_pointer_movement'] = 176,
    ['ui_mouse_pointer_attack']   =  11,
    ['ui_mouse_pointer_interact'] =  30,

    -- Scrollareas
    ['ui_scroll_area_up']   = 31,
    ['ui_scroll_area_down'] = 32,
    ['ui_scrollbar_cursor']  = 180,
    ['ui_scrollbar_element'] = 180,

    -- ==============================
    -- Prefab Editor
    -- ==============================

    ['prefab_editor_cursor_draw'] = 101,
    ['prefab_editor_cursor_fill'] = 160,
    ['prefab_editor_cursor_erase'] = 89,

    -- ==============================
    -- Creatures
    -- ==============================
    ['human'] = { stand =   2, crouch =  32, prone =  23 },
    ['dog']   = { stand = 101, crouch = 101, prone = 101 },
}

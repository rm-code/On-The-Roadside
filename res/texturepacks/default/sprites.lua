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
    ['worldobject_wall'] = {
        default = 207,
        vertical = 187,
        horizontal = 206,
        ne = 201,
        nw = 189,
        se = 202,
        sw = 188,
        nes = 205,
        new = 203,
        nws = 186,
        sew = 204,
        news = 207,
    },

    ['worldobject_fence'] = {
        default = 198,
        vertical = 180,
        horizontal = 197,
        ne = 193,
        nw = 218,
        se = 219,
        sw = 192,
        nes = 196,
        new = 194,
        nws = 181,
        sew = 195,
        news = 198,
    },

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

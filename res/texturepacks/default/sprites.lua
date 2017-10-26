return {
    -- ==============================
    -- TILES
    -- ==============================
    ['tile_empty']       =   1,
    ['tile_asphalt']     =  47,
    ['tile_deep_water']  = 248,
    ['tile_grass']       =  45,
    ['tile_gravel']      = 250,
    ['tile_soil']        =  45,
    ['tile_water']       = 248,
    ['tile_woodenfloor'] = 173,

    -- ==============================
    -- WORLD OBJECTS
    -- ==============================
    ['worldobject_chair']   = 111,
    ['worldobject_crate']   = 247,
    ['worldobject_fence']   =  62,
    ['worldobject_lowwall'] =  62,
    ['worldobject_table']   = 211,
    ['worldobject_tree']    =   7,
    ['worldobject_wall']    =  36,
    ['worldobject_window']  = 177,

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
    -- Creatures
    -- ==============================
    ['human'] = { stand =   2, crouch =  32, prone =  23 },
    ['dog']   = { stand = 101, crouch = 101, prone = 101 },
}

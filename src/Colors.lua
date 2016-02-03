local COLORS = {};

COLORS.INVISIBLE = {   0,   0,   0,   0 };
COLORS.WHITE     = { 255, 255, 255, 255 };
COLORS.GREY      = { 150, 150, 150, 255 };
COLORS.DARK_GREY = {  50,  50,  50, 255 };
COLORS.RED       = { 255,   0,   0, 255 };
COLORS.GREEN     = {   0, 255,   0, 255 };
COLORS.ORANGE    = { 255, 180,  80, 255 };
COLORS.PURPLE    = { 148,   0, 211, 255 };

-- Make table read-only.
return setmetatable( COLORS, {
    __index = function( _, key )
        error( "Can't access constant value at key: " .. key );
    end,
    __newindex = function()
        error( "Can't change a constant value." );
    end
} );
